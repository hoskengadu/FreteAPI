#!/bin/bash

# Script para desenvolvimento - configura e executa o ambiente de desenvolvimento

echo "🚀 FreteAPI - Setup de Desenvolvimento"
echo "====================================="

# Verificar se o .NET está instalado
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK não encontrado. Instale o .NET 8 SDK primeiro."
    exit 1
fi

echo "✅ .NET SDK encontrado: $(dotnet --version)"

# Restaurar dependências
echo "📦 Restaurando dependências..."
dotnet restore

# Verificar se Docker está instalado e rodando
if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo "🐳 Docker encontrado. Iniciando PostgreSQL..."
    
    # Parar containers existentes
    docker-compose down
    
    # Iniciar apenas o PostgreSQL para desenvolvimento
    docker-compose up -d postgres
    
    # Aguardar PostgreSQL ficar pronto
    echo "⏳ Aguardando PostgreSQL ficar pronto..."
    sleep 10
    
    # Verificar se PostgreSQL está respondendo
    until docker exec freieapi-postgres pg_isready -U postgres; do
        echo "⏳ PostgreSQL ainda não está pronto..."
        sleep 2
    done
    
    echo "✅ PostgreSQL está pronto!"
else
    echo "⚠️  Docker não encontrado ou não está rodando."
    echo "   Configure a string de conexão manualmente no appsettings.json"
fi

# Executar migrações
echo "🗄️  Aplicando migrações do banco de dados..."
dotnet ef database update --project src/Infrastructure --startup-project src/Api

# Executar testes
echo "🧪 Executando testes..."
dotnet test --logger "console;verbosity=minimal"

# Verificar se tudo passou
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Setup concluído com sucesso!"
    echo ""
    echo "Para executar a API:"
    echo "  dotnet run --project src/Api"
    echo ""
    echo "A API estará disponível em:"
    echo "  - HTTP: http://localhost:5000"
    echo "  - HTTPS: https://localhost:5001"
    echo "  - Swagger: http://localhost:5000/swagger"
    echo ""
    echo "Para parar o PostgreSQL:"
    echo "  docker-compose down"
else
    echo "❌ Alguns testes falharam. Verifique os erros acima."
    exit 1
fi