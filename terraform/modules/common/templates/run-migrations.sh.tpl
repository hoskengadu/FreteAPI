#!/bin/bash

# ==========================================
# Database Migration Script
# ==========================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "$${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1$${NC}"
}

warn() {
    echo -e "$${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1$${NC}"
}

error() {
    echo -e "$${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1$${NC}"
}

# Check required environment variables
if [[ -z "$DB_HOST" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
    error "Missing required environment variables:"
    error "DB_HOST, DB_NAME, DB_USER, DB_PASSWORD must be set"
    exit 1
fi

# Default values
DB_PORT=$${DB_PORT:-5432}
MAX_RETRIES=30
RETRY_INTERVAL=10

log "Starting database migration process..."
log "Target database: $DB_HOST:$DB_PORT/$DB_NAME"

# Wait for database to be ready
log "Waiting for database to be ready..."
for i in $(seq 1 $MAX_RETRIES); do
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" 2>/dev/null; then
        log "Database is ready!"
        break
    fi
    
    if [ $i -eq $MAX_RETRIES ]; then
        error "Database not ready after $MAX_RETRIES attempts"
        exit 1
    fi
    
    warn "Database not ready, retrying in $RETRY_INTERVAL seconds... (attempt $i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
done

# Connection string
CONNECTION_STRING="Host=$DB_HOST;Port=$DB_PORT;Database=$DB_NAME;Username=$DB_USER;Password=$DB_PASSWORD"

# Run migrations using the API container
log "Running database migrations..."

# Check if we need to run migrations
MIGRATION_CONTAINER="${project_name}-migration-$$(date +%s)"

# Create migration container
docker run --name "$MIGRATION_CONTAINER" \
    --network host \
    -e ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    -e ASPNETCORE_ENVIRONMENT=Production \
    --rm \
    ${project_name}:${api_version} \
    dotnet ef database update --no-build --verbose

if [ $? -eq 0 ]; then
    log "✅ Database migrations completed successfully!"
    
    # Mark migrations as completed
    MIGRATION_MARKER="/tmp/migrations_completed_$$(echo $DB_HOST | tr '.' '_')"
    echo "$(date)" > "$MIGRATION_MARKER"
    log "Migration marker created: $MIGRATION_MARKER"
else
    error "❌ Database migrations failed!"
    exit 1
fi

# Optional: Run data seeding
if [ "$RUN_SEED" = "true" ]; then
    log "Running data seeding..."
    
    docker run --name "${project_name}-seed-$$(date +%s)" \
        --network host \
        -e ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
        -e ASPNETCORE_ENVIRONMENT=Production \
        --rm \
        ${project_name}:${api_version} \
        dotnet run --project FreteAPI.Api -- --seed-data
    
    if [ $? -eq 0 ]; then
        log "✅ Data seeding completed successfully!"
    else
        warn "⚠️  Data seeding failed, but continuing..."
    fi
fi

log "🚀 Migration process completed!"