# FreteAPI - Guia de Execução Rápida

## 🚀 Execução com Docker (Mais Fácil)

1. **Clone e entre na pasta:**
```bash
git clone [url-do-repo]
cd FreteAPI
```

2. **Execute tudo com Docker Compose:**
```bash
docker-compose up -d
```

3. **Acesse:**
- **API Swagger:** http://localhost:8080
- **pgAdmin:** http://localhost:8081 (admin@freteapi.com / admin123)

## 💻 Execução para Desenvolvimento

### Windows:
```cmd
scripts\dev\setup.bat
dotnet run --project src/Api
```

### Linux/Mac:
```bash
chmod +x scripts/dev/setup.sh
./scripts/dev/setup.sh
dotnet run --project src/Api
```

## 📋 Testando a API

### 1. Importar Collection no Postman
Importe o arquivo: `docs/FreteAPI.postman_collection.json`

### 2. Ou use curl:

**Criar Cliente:**
```bash
curl -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@email.com", 
    "telefone": "11999999999",
    "latitude": -23.5505,
    "longitude": -46.6333
  }'
```

**Buscar Profissionais Próximos:**
```bash
curl "http://localhost:8080/api/v1/profissionais/proximos?latitude=-23.5505&longitude=-46.6333&dataHora=2024-12-31T10:00:00&duracaoMinutos=120"
```

## 🗄️ Dados de Exemplo

A API já vem com dados iniciais:

### Clientes:
- João Silva (joao@email.com) - São Paulo
- Maria Santos (maria@email.com) - São Paulo

### Profissionais:
- Carlos Freteiro (carlos@email.com) - 15km raio
- Ana Transportes (ana@email.com) - 20km raio
- Disponíveis: Segunda a Sexta, 8h às 18h

## 🧪 Executar Testes

```bash
# Testes unitários
dotnet test tests/FreteAPI.UnitTests

# Testes de integração  
dotnet test tests/FreteAPI.IntegrationTests

# Todos os testes
dotnet test
```

## 🐛 Resolução de Problemas

### Erro de conexão com banco:
```bash
docker-compose down
docker-compose up -d postgres
# Aguarde 30 segundos
dotnet ef database update --project src/Infrastructure --startup-project src/Api
```

### Limpar containers:
```bash
docker-compose down -v
docker-compose up -d
```

### Verificar logs:
```bash
docker logs freteapi-app
docker logs freieapi-postgres
```

## 📊 Monitoramento

- **Health Check:** http://localhost:8080/health
- **Logs:** Pasta `logs/` ou `docker logs freteapi-app`
- **Metrics:** Endpoints disponíveis via Swagger

## 🔧 Configurações

### appsettings.json (Desenvolvimento)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=FreteAPI;Username=postgres;Password=postgres;Port=5432"
  }
}
```

### Variáveis de Ambiente (Docker)
```bash
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__DefaultConnection=Host=freieapi-postgres;Database=FreteAPI;Username=postgres;Password=postgres
```

## 📱 Próximos Passos

1. ✅ **Funcional:** Criar clientes e buscar profissionais
2. ✅ **Funcional:** Criar agendamentos
3. 🔄 **TODO:** Listar agendamentos por cliente/profissional  
4. 🔄 **TODO:** Cancelar agendamentos
5. 🔄 **TODO:** Sistema de autenticação JWT
6. 🔄 **TODO:** Notificações

---

🎉 **API pronta para uso! Swagger disponível em:** http://localhost:8080