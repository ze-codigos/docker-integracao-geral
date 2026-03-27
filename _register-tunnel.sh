#!/bin/bash
# Helper: captura URL do quick tunnel e registra no wpp-dev-forwarder.
# Chamado por todos os scripts de startup que sobem o bot_wpp_api.
#
# Pré-requisitos:
#   - .env.local configurado (cp .env.local.empty .env.local)
#   - wpp-dev-forwarder rodando em 34.68.95.239:8090
set -e

source "$(dirname "$0")/.env.local" 2>/dev/null || true

DEV_SECRET="${DEV_SECRET:?Defina DEV_SECRET em .env.local}"
MEU_NUMERO="${MEU_NUMERO:?Defina MEU_NUMERO em .env.local (ex: 5511912345678)}"
DEV_NAME="${DEV_NAME:-dev}"
FORWARDER_URL="http://34.68.95.239:8090"

echo "[tunnel] Aguardando quick tunnel do cloudflared..."
TUNNEL_URL=""
TRIES=0
while [ -z "$TUNNEL_URL" ] && [ $TRIES -lt 30 ]; do
  sleep 2
  TRIES=$((TRIES + 1))
  TUNNEL_URL=$(docker compose logs cloudflared 2>&1 | \
    grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' | tail -1)
done

if [ -z "$TUNNEL_URL" ]; then
  echo "ERRO: Tunnel não encontrado após 60s. Verifique: docker compose logs cloudflared"
  exit 1
fi
echo "[tunnel] URL: $TUNNEL_URL"

echo "[tunnel] Registrando no forwarder ($FORWARDER_URL)..."
curl -sf -X POST "$FORWARDER_URL/register" \
  -H "Authorization: Bearer $DEV_SECRET" \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$MEU_NUMERO\", \"tunnel\": \"$TUNNEL_URL\", \"dev\": \"$DEV_NAME\"}"

echo ""
echo "[tunnel] Pronto! Mensagens de $MEU_NUMERO → bot local ($TUNNEL_URL)"
