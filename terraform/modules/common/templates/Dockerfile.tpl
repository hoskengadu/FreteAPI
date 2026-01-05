# ==========================================
# Multi-stage Dockerfile for FreteAPI
# ==========================================

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY src/Domain/*.csproj ./Domain/
COPY src/Application/*.csproj ./Application/
COPY src/Infrastructure/*.csproj ./Infrastructure/
COPY src/API/*.csproj ./API/
RUN dotnet restore "./API/${project_name}.Api.csproj"

# Copy source code and build
COPY src/ .
WORKDIR /src/API
RUN dotnet build "${project_name}.Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "${project_name}.Api.csproj" -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN addgroup --system --gid 1001 apigroup && \
    adduser --system --uid 1001 --ingroup apigroup apiuser

# Copy published app
COPY --from=publish /app/publish .

# Set ownership and permissions
RUN chown -R apiuser:apigroup /app
USER apiuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

# Start the application
ENTRYPOINT ["dotnet", "${project_name}.Api.dll"]