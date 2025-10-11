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

# Detectar arquitetura do servidor
detect_architecture() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l)
            echo "arm/v7"
            ;;
        *)
            log_warning "Arquitetura não suportada: $arch"
            log_info "Tentando usar imagem genérica (pode não funcionar)"
            echo "amd64"  # fallback
            ;;
    esac
}

ARCHITECTURE=$(detect_architecture)
log_info "🏗️ Arquitetura detectada: $ARCHITECTURE"

# Mostrar informações detalhadas da arquitetura
case $ARCHITECTURE in
    "amd64")
        log_info "💻 Servidor x86_64 (Intel/AMD) - Imagem nativa"
        ;;
    "arm64")
        log_info "📱 Servidor ARM64 (Apple Silicon/ARM) - Imagem nativa"
        ;;
    "arm/v7")
        log_info "📱 Servidor ARM v7 - Imagem nativa"
        ;;
    *)
        log_warning "⚠️ Arquitetura não reconhecida - usando fallback"
        ;;
esac

log_info "Configurando deploy do cliente..."
echo ""
# Verificar se o token foi fornecido via variável de ambiente ou stdin
if [ -z "$CLIENT_PAT" ]; then
    log_info "🔑 Para acessar a imagem privada, você precisa de um PAT Token."
    log_info "Entre em contato com a equipe de desenvolvimento para obter o token."
    echo ""
    
    # Tentar ler do stdin primeiro (para pipes)
    if [ ! -t 0 ]; then
        read CLIENT_PAT
    else
        read -p "Digite seu PAT Token: " CLIENT_PAT
    fi
fi

if [ -z "$CLIENT_PAT" ]; then
    log_error "PAT Token é obrigatório!"
    log_info "Use: CLIENT_PAT=seu_token curl -fsSL ... | bash"
    log_info "Ou: echo 'seu_token' | curl -fsSL ... | bash"
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

# Executar o deploy
log_info "Iniciando deploy do CDR Worker..."
echo ""

# Usar a tag disponível ou padrão
DEFAULT_TAG="ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest"

log_info "Usando imagem: $DEFAULT_TAG"

# Criar diretórios necessários
log_info "Criando estrutura de diretórios..."
mkdir -p config logs data

# Criar docker-compose.yml se não existir
if [ ! -f "docker-compose.yml" ]; then
    log_info "Criando docker-compose.yml para arquitetura $ARCHITECTURE..."
    cat > docker-compose.yml << EOF
version: '3.8'
services:
  cdr-worker:
    image: ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest
    platform: linux/$ARCHITECTURE
    container_name: cdr-worker-01
    restart: always
    env_file:
      - .env
    volumes:
      - ./config:/app/config
      - ./logs:/app/logs
      - ./data:/app/data
    networks:
      - cdr-network

networks:
  cdr-network:
    driver: bridge
EOF
    log_success "docker-compose.yml criado para $ARCHITECTURE"
else
    # Atualizar docker-compose.yml existente com a plataforma correta
    log_info "Atualizando docker-compose.yml para arquitetura $ARCHITECTURE..."
    if grep -q "platform:" docker-compose.yml; then
        # Substituir plataforma existente
        sed -i "s/platform:.*/platform: linux\/$ARCHITECTURE/" docker-compose.yml
    else
        # Adicionar plataforma após a linha da imagem
        sed -i "/image:.*cdr-worker:latest/a\\    platform: linux/$ARCHITECTURE" docker-compose.yml
    fi
    log_success "docker-compose.yml atualizado para $ARCHITECTURE"
fi

# Criar .env se não existir
if [ ! -f ".env" ]; then
    log_info "Criando arquivo .env..."
    cat > .env << 'EOF'
# CDR Worker Configuration
DB_HOST=192.168.68.2
DB_PORT=5432
DB_NAME=cdrviewer
DB_USER=cdrviewer
DB_PASSWORD=cdrviewer123

# Worker Configuration
WORKER_NAME=worker01
WORKER_ID=worker01
LOG_LEVEL=info
LOG_FILE=/app/logs/cdr-worker.log

# POP SSH Configuration (Optional - overrides config.yaml)
# Uncomment and configure with real POP details:
# POP_BHE_IP=real_ip_here
# POP_BHE_USER=real_user_here
# POP_BHE_PASS=real_password_here
# POP_BHE_DIR=/real/cdr/directory
# POP_BHE_FORMAT=.tar.gz
# 
# POP_BSA_IP=real_ip_here
# POP_BSA_USER=real_user_here
# POP_BSA_PASS=real_password_here
# POP_BSA_DIR=/real/cdr/directory
# POP_BSA_FORMAT=.tar.gz
# 
# POP_CTA_IP=real_ip_here
# POP_CTA_USER=real_user_here
# POP_CTA_PASS=real_password_here
# POP_CTA_DIR=/real/cdr/directory
# POP_CTA_FORMAT=.tar.gz
# 
# POP_RJO_IP=real_ip_here
# POP_RJO_USER=real_user_here
# POP_RJO_PASS=real_password_here
# POP_RJO_DIR=/real/cdr/directory
# POP_RJO_FORMAT=.tar.gz
# 
# POP_OCO_IP=real_ip_here
# POP_OCO_USER=real_user_here
# POP_OCO_PASS=real_password_here
# POP_OCO_DIR=/real/cdr/directory
# POP_OCO_FORMAT=.tar.gz
# 
# POP_SPO_IP=real_ip_here
# POP_SPO_USER=real_user_here
# POP_SPO_PASS=real_password_here
# POP_SPO_DIR=/real/cdr/directory
# POP_SPO_FORMAT=.tar.gz
EOF
    log_success "Arquivo .env criado"
fi

# Parar containers existentes
log_info "Parando containers existentes..."
docker-compose down 2>/dev/null || true

# Fazer pull da imagem
log_info "Baixando imagem Docker..."
docker pull "$DEFAULT_TAG"

# Iniciar containers
log_info "Iniciando containers..."
docker-compose up -d

echo ""
log_success "Deploy do cliente concluído!"
echo ""

# Mostrar status
log_info "Verificando status dos containers..."
docker-compose ps

echo ""
log_info "Para ver logs: docker-compose logs -f"
log_info "Para parar: docker-compose down"
log_info "Para reiniciar: docker-compose restart"
echo ""

# Informações de troubleshooting para arquitetura
log_info "🔧 Troubleshooting de Arquitetura:"
echo ""
if [ "$ARCHITECTURE" = "arm64" ]; then
    log_info "📱 Servidor ARM64 detectado:"
    log_info "  ✅ Imagem multi-arquitetura configurada automaticamente"
    log_info "  ✅ Não deve haver 'exec format error'"
    log_info "  ✅ Performance nativa otimizada"
elif [ "$ARCHITECTURE" = "amd64" ]; then
    log_info "💻 Servidor x86_64 detectado:"
    log_info "  ✅ Imagem AMD64 nativa configurada"
    log_info "  ✅ Compatibilidade total garantida"
else
    log_warning "⚠️ Arquitetura não padrão detectada:"
    log_warning "  🔍 Se houver problemas, verifique se a imagem suporta $ARCHITECTURE"
    log_warning "  📞 Entre em contato com o suporte se necessário"
fi

echo ""
log_success "🎉 Sistema CDR Worker implantado com sucesso!"
log_info "🏗️ Arquitetura: $ARCHITECTURE | 🐳 Container: cdr-worker-01"
