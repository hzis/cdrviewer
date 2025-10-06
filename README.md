# 🚀 CDR Worker - Deploy Repository

Este repositório contém os arquivos necessários para fazer deploy do CDR Worker.

## 📦 Informações da Build

- **Data**: 2025-10-06 02:58:37 UTC
- **Commit**: [b12117388b3f1c54d3f17ca858aaea90cd7c64af](https://github.com/hzis/cdrviewer_worker/commit/b12117388b3f1c54d3f17ca858aaea90cd7c64af)
- **Imagem**: ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest

## 🔑 Pré-requisito: PAT Token

Para fazer deploy, você precisa de um PAT (Personal Access Token) do GitHub.
Entre em contato com a equipe de desenvolvimento para obter o token.

## 🚀 Deploy Automatizado (Recomendado)

### Opção 1: Deploy com um comando
```bash
curl -fsSL https://raw.githubusercontent.com/hzis/cdrviewer/main/deploy-client.sh | bash
```
*O script solicitará o PAT Token durante a execução*

### Opção 2: Deploy manual
1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Execute: `cd cdrviewer && ./deploy-client.sh`
*O script solicitará o PAT Token durante a execução*

## 🔧 Deploy Manual (Alternativo)

1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Login: `echo "SEU_PAT_TOKEN" | docker login ghcr.io -u hzis --password-stdin`
3. Configure: `cp .env.example .env && nano .env`
4. Execute: `docker-compose up -d`

## 📞 Suporte

Para suporte técnico, entre em contato com a equipe de desenvolvimento.

---
*Última atualização: 2025-10-06 02:58:37 UTC*
