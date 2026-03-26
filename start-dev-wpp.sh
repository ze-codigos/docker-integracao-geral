#!/bin/bash
# Sobe o stack local com WhatsApp real, captura a URL do quick tunnel
# e registra seu número pessoal no wpp-dev-forwarder de produção.
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

echo "[1/3] Subindo stack local-wpp..."
docker compose --profile local-wpp up -d

echo "[2/3] Aguardando quick tunnel do cloudflared..."
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
echo "      Tunnel: $TUNNEL_URL"

echo "[3/3] Registrando no forwarder ($FORWARDER_URL)..."
curl -sf -X POST "$FORWARDER_URL/register" \
  -H "Authorization: Bearer $DEV_SECRET" \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$MEU_NUMERO\", \"tunnel\": \"$TUNNEL_URL\", \"dev\": \"$DEV_NAME\"}"

echo ""
echo "Pronto! Mensagens de $MEU_NUMERO para 5511945234206 → seu bot local"
echo "Para monitorar: docker compose logs -f bot_wpp_api bot_agente"
