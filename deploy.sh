#!/bin/bash
# CDR Worker - Deploy Script Automatizado
# Este script automatiza o deploy do CDR Worker

set -e

echo "🚀 CDR Worker - Deploy Automatizado"
echo "====================================="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Instale Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Instale Docker Compose primeiro."
    exit 1
fi

echo "✅ Docker e Docker Compose encontrados"

# Solicitar PAT Token
echo "🔑 Para acessar a imagem privada, você precisa de um PAT Token."
echo "Entre em contato com a equipe para obter o token."
read -p "Digite seu PAT Token: " PAT_TOKEN

if [ -z "$PAT_TOKEN" ]; then
    echo "❌ PAT Token é obrigatório"
    exit 1
fi

# Fazer login no GitHub Container Registry
echo "🔐 Fazendo login no GitHub Container Registry..."
echo "$PAT_TOKEN" | docker login ghcr.io -u hzis --password-stdin

# Configurar arquivo .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo "⚠️  IMPORTANTE: Edite o arquivo .env com suas configurações antes de continuar"
    echo "   Exemplo: nano .env"
    read -p "Pressione Enter quando terminar de configurar o .env..."
fi

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down 2>/dev/null || true

# Fazer pull da imagem mais recente
echo "📥 Baixando imagem mais recente..."
docker-compose pull

# Iniciar os containers
echo "🚀 Iniciando CDR Worker..."
docker-compose up -d

# Verificar status
echo "📊 Verificando status dos containers..."
docker-compose ps

echo "✅ Deploy concluído com sucesso!"
echo "📋 Comandos úteis:"
echo "   - Ver logs: docker-compose logs -f"
echo "   - Parar: docker-compose down"
echo "   - Reiniciar: docker-compose restart"

echo "🎉 CDR Worker está rodando!"
