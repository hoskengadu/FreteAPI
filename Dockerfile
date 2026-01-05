# Use the official .NET runtime as a parent image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project files
COPY ["src/Api/FreteAPI.Api.csproj", "src/Api/"]
COPY ["src/Application/FreteAPI.Application.csproj", "src/Application/"]
COPY ["src/Domain/FreteAPI.Domain.csproj", "src/Domain/"]
COPY ["src/Infrastructure/FreteAPI.Infrastructure.csproj", "src/Infrastructure/"]

# Restore dependencies
RUN dotnet restore "./src/Api/FreteAPI.Api.csproj"

# Copy the rest of the application code
COPY . .
WORKDIR "/src/src/Api"

# Build the application
RUN dotnet build "./FreteAPI.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./FreteAPI.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create logs directory
RUN mkdir -p /app/logs

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "FreteAPI.Api.dll"]