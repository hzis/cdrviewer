#!/bin/bash

# Script de Deploy Específico para o Cliente
# Usa o PAT fornecido para fazer deploy sem acesso ao código fonte

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "🚀 CDR Worker - Deploy do Cliente"
echo "================================="
echo -e "${NC}"

# Configurações do cliente
GITHUB_USERNAME="hzis"
GITHUB_REGISTRY="ghcr.io"
IMAGE_NAME="hzis/cdrviewer_worker/cdr-worker"

log_info "Configurando deploy do cliente..."
echo ""
log_info "🔑 Para acessar a imagem privada, você precisa de um PAT Token."
log_info "Entre em contato com a equipe de desenvolvimento para obter o token."
echo ""
read -p "Digite seu PAT Token: " CLIENT_PAT

if [ -z "$CLIENT_PAT" ]; then
    log_error "PAT Token é obrigatório!"
    exit 1
fi

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker não está instalado!"
    log_info "Instale o Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

log_success "Docker encontrado"

# Configurar variáveis de ambiente
export GITHUB_TOKEN="$CLIENT_PAT"
export GITHUB_USERNAME="$GITHUB_USERNAME"
export GITHUB_REGISTRY="$GITHUB_REGISTRY"

log_info "Token configurado: ${CLIENT_PAT:0:20}..."

# Fazer login no GitHub Container Registry
log_info "Fazendo login no GitHub Container Registry..."
if echo "$CLIENT_PAT" | docker login "$GITHUB_REGISTRY" -u "$GITHUB_USERNAME" --password-stdin > /dev/null 2>&1; then
    log_success "Login no registry realizado com sucesso"
else
    log_error "Falha no login no registry!"
    log_info "Verifique se o token está correto"
    exit 1
fi

# Testar acesso às imagens
log_info "Testando acesso às imagens Docker..."
TAGS=("latest" "go-1.25" "main")

for tag in "${TAGS[@]}"; do
    log_info "Testando tag: $tag"
    if docker pull "$GITHUB_REGISTRY/$IMAGE_NAME:$tag" > /dev/null 2>&1; then
        log_success "Tag $tag acessível"
        break
    else
        log_warning "Tag $tag não disponível, tentando próxima..."
    fi
done

# Verificar se o deploy.sh existe
if [ ! -f "./deploy.sh" ]; then
    log_error "Script deploy.sh não encontrado!"
    log_info "Certifique-se de estar no diretório correto"
    exit 1
fi

# Tornar o deploy.sh executável
chmod +x ./deploy.sh

# Executar o deploy
log_info "Iniciando deploy do CDR Worker..."
echo ""

# Usar a tag disponível ou padrão
DEFAULT_TAG="ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest"

log_info "Executando: ./deploy.sh deploy $DEFAULT_TAG"
./deploy.sh deploy "$DEFAULT_TAG"

echo ""
log_success "Deploy do cliente concluído!"
echo ""

# Mostrar status
log_info "Verificando status dos containers..."
./deploy.sh status

echo ""
log_info "Para ver logs: ./deploy.sh logs"
log_info "Para parar: ./deploy.sh stop"
log_info "Para reiniciar: ./deploy.sh restart"
echo ""

log_success "🎉 Sistema CDR Worker implantado com sucesso!"
