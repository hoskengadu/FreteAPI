@echo off
REM Script para desenvolvimento no Windows

echo 🚀 FreteAPI - Setup de Desenvolvimento
echo =====================================

REM Verificar se o .NET está instalado
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET SDK não encontrado. Instale o .NET 8 SDK primeiro.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
echo ✅ .NET SDK encontrado: %DOTNET_VERSION%

REM Restaurar dependências
echo 📦 Restaurando dependências...
dotnet restore

REM Verificar se Docker está instalado e rodando
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo 🐳 Docker encontrado. Iniciando PostgreSQL...
    
    REM Parar containers existentes
    docker-compose down
    
    REM Iniciar apenas o PostgreSQL para desenvolvimento
    docker-compose up -d postgres
    
    REM Aguardar PostgreSQL ficar pronto
    echo ⏳ Aguardando PostgreSQL ficar pronto...
    timeout /t 10 /nobreak >nul
    
    echo ✅ PostgreSQL deve estar pronto!
) else (
    echo ⚠️  Docker não encontrado ou não está rodando.
    echo    Configure a string de conexão manualmente no appsettings.json
)

REM Executar migrações
echo 🗄️  Aplicando migrações do banco de dados...
dotnet ef database update --project src/Infrastructure --startup-project src/Api

REM Executar testes
echo 🧪 Executando testes...
dotnet test --logger "console;verbosity=minimal"

if %errorlevel% equ 0 (
    echo.
    echo 🎉 Setup concluído com sucesso!
    echo.
    echo Para executar a API:
    echo   dotnet run --project src/Api
    echo.
    echo A API estará disponível em:
    echo   - HTTP: http://localhost:5000
    echo   - HTTPS: https://localhost:5001
    echo   - Swagger: http://localhost:5000/swagger
    echo.
    echo Para parar o PostgreSQL:
    echo   docker-compose down
) else (
    echo ❌ Alguns testes falharam. Verifique os erros acima.
)

pause