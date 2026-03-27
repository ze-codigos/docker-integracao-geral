#!/bin/bash
# Sobe o stack local com credenciais dev e registra o túnel WhatsApp.
#
# Pré-requisitos:
#   - .env.local configurado (cp .env.local.empty .env.local)
#   - wpp-dev-forwarder rodando em 34.68.95.239:8090
set -e

echo "[1/2] Subindo stack dev..."
docker compose up -d

echo "[2/2] Registrando túnel..."
"$(dirname "$0")/_register-tunnel.sh"

echo "Para monitorar: docker compose logs -f bot_wpp_api bot_agente"
