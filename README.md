# 🚀 CDR Worker - Deploy Repository

Este repositório contém os arquivos necessários para fazer deploy do CDR Worker.

## 📦 Informações da Build

- **Data**: 2025-10-06 04:46:04 UTC
- **Commit**: [79ef06ae7aca6d0e4c1efb728bd5f91c16717c7a](https://github.com/hzis/cdrviewer_worker/commit/79ef06ae7aca6d0e4c1efb728bd5f91c16717c7a)
- **Imagem**: ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest

## 🔑 Pré-requisito: PAT Token

Para fazer deploy, você precisa de um PAT (Personal Access Token) do GitHub.
Entre em contato com a equipe de desenvolvimento para obter o token.

## 🚀 Deploy Automatizado (Recomendado)

### Opção 1: Deploy com um comando
```bash
export CLIENT_PAT=seu_token_aqui
curl -fsSL https://raw.githubusercontent.com/hzis/cdrviewer/main/deploy-client.sh | bash
```

### Opção 2: Deploy manual
1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Export token: `export CLIENT_PAT=seu_token_aqui`
3. Execute: `cd cdrviewer && ./deploy-client.sh`

## 🔧 Deploy Manual (Alternativo)

1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Login: `echo "SEU_PAT_TOKEN" | docker login ghcr.io -u hzis --password-stdin`
3. Configure: `cp .env.example .env && nano .env`
4. Execute: `docker-compose up -d`

## 📞 Suporte

Para suporte técnico, entre em contato com a equipe de desenvolvimento.

---
*Última atualização: 2025-10-06 04:46:04 UTC*
