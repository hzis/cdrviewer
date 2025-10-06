# 🚀 CDR Worker - Deploy Repository

Este repositório contém os arquivos necessários para fazer deploy do CDR Worker.

## 📦 Informações da Build

- **Data**: 2025-10-06 02:34:52 UTC
- **Commit**: [249cab1385543a64e569a9b9130502520b3d6051](https://github.com/hzis/cdrviewer_worker/commit/249cab1385543a64e569a9b9130502520b3d6051)
- **Imagem**: ghcr.io/hzis/cdrviewer_worker/cdr-worker:latest

## 🚀 Deploy Automatizado (Recomendado)

### Opção 1: Deploy com um comando
```bash
curl -fsSL https://raw.githubusercontent.com/hzis/cdrviewer/main/deploy-client.sh | bash
```

### Opção 2: Deploy manual
1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Execute: `cd cdrviewer && ./deploy-client.sh`

## 🔧 Deploy Manual (Alternativo)

1. Clone: `git clone https://github.com/hzis/cdrviewer.git`
2. Login: `echo "SEU_PAT_TOKEN" | docker login ghcr.io -u hzis --password-stdin`
3. Configure: `cp .env.example .env && nano .env`
4. Execute: `docker-compose up -d`

## 📞 Suporte

Para suporte técnico, entre em contato com a equipe de desenvolvimento.

---
*Última atualização: 2025-10-06 02:34:52 UTC*
