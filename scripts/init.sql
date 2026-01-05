-- Script de inicialização do PostgreSQL
-- Este script é executado automaticamente quando o container PostgreSQL é criado

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar usuário de aplicação (opcional, por segurança)
-- CREATE USER freteapi WITH PASSWORD 'freteapi123';
-- GRANT ALL PRIVILEGES ON DATABASE "FreteAPI" TO freteapi;

-- O Entity Framework criará as tabelas via migrations
-- Este script serve apenas para configurações iniciais do banco