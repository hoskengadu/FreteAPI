# ==========================================
# Docker Compose for Local Development
# ==========================================

version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: ${project_name}-postgres
    environment:
      POSTGRES_DB: ${project_name}_dev
      POSTGRES_USER: freteapi
      POSTGRES_PASSWORD: ${db_password}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - freteapi-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U freteapi -d ${project_name}_dev"]
      interval: 30s
      timeout: 10s
      retries: 3

  # FreteAPI Application
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${project_name}-api
    image: ${project_name}:${api_version}
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:${container_port}
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=${project_name}_dev;Username=freteapi;Password=${db_password}
      - Logging__LogLevel__Default=Information
      - AllowedHosts=*
    ports:
      - "${container_port}:${container_port}"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - freteapi-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:${container_port}/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Redis for Caching (optional)
  redis:
    image: redis:7-alpine
    container_name: ${project_name}-redis
    ports:
      - "6379:6379"
    networks:
      - freteapi-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx Load Balancer
  nginx:
    image: nginx:alpine
    container_name: ${project_name}-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - freteapi-network
    restart: unless-stopped

networks:
  freteapi-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  postgres_data:
    driver: local