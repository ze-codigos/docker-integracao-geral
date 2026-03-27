# Docker Integração Geral (Passhub + Bot + CRM)

Este diretório contém a configuração para rodar todo o ecossistema localmente usando Docker Compose.

## Serviços Incluídos

- **Infraestrutura**: PostgreSQL, ClickHouse, MongoDB
- **Passhub**: EmissorAuth, Rodobus, EmissorCheckout, HeroSeguros, EmissorFront, EmissorGerencia, Nexus, TicketDelivery, SearchFlightsGo
- **Bot**: Agente, Oficial-WPP-API, Gerador-Imagem, Memoshar, Alertas-V2
- **CRM**: crm_auth (8013), crm_gerenciamento_voos (8090), crm_templates_messages_api (8091), crm_front (3001)

## Como Usar

1. **Configure o ambiente**:
   O arquivo `.env` já vem com valores padrão para desenvolvimento local. Verifique se precisa ajustar alguma chave de API (como `GEMINI`).

2. **Inicie os containers**:
   - Para desenvolvimento (padrão):
     ```bash
     docker compose up -d --build
     ```
   - Para homologação:
     ```bash
     docker compose -f docker-compose.yml -f docker-compose.homolog.yaml up -d --build
     ```
   - Para produção:
     ```bash
     docker compose -f docker-compose.yml -f docker-compose.prod.yaml up -d --build
     ```

3. **Verifique a saúde dos serviços**:
   ```bash
   docker ps
   ```

4. **Acesse as interfaces**:
   - EmissorFront: [http://localhost:5173](http://localhost:5173)
   - EmissorCheckoutFront: [http://localhost:5172](http://localhost:5172)
   - EmissorGerencia: [http://localhost:8085](http://localhost:8085)
   - CRM Frontend: [http://localhost:3001](http://localhost:3001)
   - CRM API (gerenciamento_voos): [http://localhost:8090/docs](http://localhost:8090/docs)
   - CRM Auth: [http://localhost:8013](http://localhost:8013)
   - CRM Templates Messages: [http://localhost:8091/docs](http://localhost:8091/docs)

## Profile: WhatsApp Real Local (`local-wpp`)

Para validar o bot com mensagens WhatsApp reais, use o profile `local-wpp`. Ele sobe um serviço adicional:

- **`cloudflared`** — quick tunnel que expõe `bot_wpp_api` local para a internet

O roteamento de webhooks é feito pelo **`wpp-dev-forwarder`** que roda no servidor de produção (`34.68.95.239:8090`). Cada dev registra seu número pessoal → seu tunnel. Múltiplos devs podem usar simultaneamente.

**Fluxo:**
```
Meta → roteador_wpp prod → 34.68.95.239:8090 (wpp-dev-forwarder)
  → lookup: quem enviou essa mensagem?
  → tunnel do dev → localhost:8080 (bot_wpp_api local)
```

### Configurar `.env.local`

```bash
cp .env.local.empty .env.local
# Preencher:
#   DEV_SECRET=<token do time — peça para o responsável>
#   MEU_NUMERO=5511912345678  (seu número pessoal)
#   DEV_NAME=seunome
```

### Uso

```bash
# Subir stack + registrar no forwarder automaticamente
./start-dev-wpp.sh

# Para atualizar (tunnel mudou após restart):
./start-dev-wpp.sh

# Monitorar
docker compose logs -f bot_wpp_api bot_agente
```

### Registro manual (sem o script)

```bash
curl -X POST http://34.68.95.239:8090/register \
  -H "Authorization: Bearer $DEV_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"phone": "5511912345678", "tunnel": "https://xxx.trycloudflare.com", "dev": "seunome"}'
```

### Verificar devs ativos

```bash
curl http://34.68.95.239:8090/health
```

## Estratégia de Variáveis de Ambiente

Três camadas, aplicadas em ordem (a última vence):

| Arquivo | Propósito |
|---------|-----------|
| `.env` | Segredos reais compartilhados (tokens Meta, chaves AWS/GCS, etc.) — **não versionado** |
| `.env.dev` | Sobreposições locais: URLs internas Docker, credenciais dev (senhadobd), overrides de comportamento |
| `environment:` no docker-compose | Sobreposições por serviço que conflitam com outros (ex.: `WHATSAPP_API_URL`) |

### Conflito `WHATSAPP_API_URL`

Dois serviços usam a mesma variável com semânticas diferentes:

- `bot_wpp_api` — espera a URL da API Graph da Meta (`https://graph.facebook.com/v22.0/...`)
- `bot_alertas_v2` — espera a URL do container local do wpp-api (`http://geral-bot-wpp-api.dev:8080`)

**Solução**: `.env` define o valor global como a URL da Meta. O `docker-compose.yml` sobrescreve via `environment:` apenas para `bot_alertas_v2`.

### Firebase Credentials (bot_wpp_api)

Em produção, as credenciais são passadas via `FIREBASE_SERVICE_ACCOUNT_JSON` (JSON inline como string). Localmente, usamos um arquivo montado via volume:

```yaml
environment:
  GOOGLE_APPLICATION_CREDENTIALS: /app/firebase-credentials.json
volumes:
  - ./firebase-credentials-wpp.json:/app/firebase-credentials.json:ro
```

O código em `bot/oficial-wpp-api/src/infra/services/firebase.service.ts` foi alterado para tentar `GOOGLE_APPLICATION_CREDENTIALS` como fallback do JSON inline.

### GCS Credentials (crm_templates_messages_api)

Em vez de montar um arquivo, este serviço lê credenciais GCS via variáveis individuais `GCS_CREDENTIALS_JSON_*` (TYPE, PROJECT_ID, PRIVATE_KEY, etc.) — o mesmo padrão usado em produção. Os valores ficam no `.env`.

### StarkBank PIX (crm_gerenciamento_voos)

PIX desabilitado localmente via:
```
STARKBANK_ENVIRONMENT=sandbox
PIX_SEND_ENABLED=false
```

### Credenciais necessárias (não versionadas)

| Arquivo | Origem | Usado por |
|---------|--------|-----------|
| `firebase-credentials-wpp.json` | Firebase Console → projeto `passabot-crm` | bot_wpp_api |
| `gcs-credentials.json` | `crm/TemplatesMessagesApi/inlaid-booth-*-s3-*.json` | crm_gerenciamento_voos (volume) |
| `secrets/starkbank/privateKey.pem` | Placeholder — PIX desabilitado | crm_gerenciamento_voos (volume) |

## Limitações Conhecidas

- **`crm_front` auth/socket hardcoded**: O frontend CRM chama `https://auth.passabot.com` e `https://wpp.passabot.com` diretamente no código (hardcoded em `src/`). Localmente, auth e socket apontam para produção — não para os containers locais. `REACT_APP_API_URL` e `REACT_APP_SOCKET_URL` são passados via build args mas ignorados por partes do código que usam as URLs hardcoded.
- **Tabelas CRM**: `crm/auth` e `crm/gerenciamento_voos` usam `Base.metadata.create_all()` na inicialização — tabelas são criadas automaticamente no primeiro boot.
- **Email/SMTP**: `crm_auth` não tem SMTP configurado localmente — verificação de email não funciona. Crie usuários diretamente no banco se necessário.

## Observações

- **WhatsApp API (padrão)**: O serviço `bot-wpp-api` roda localmente mas não receberá webhooks da Meta sem o profile `local-wpp`.
- **Banco de Dados**: Todos os serviços compartilham a mesma instância de PostgreSQL e o mesmo banco `passhub`, mas as tabelas do bot e do passhub possuem nomenclaturas distintas para evitar conflitos.
- **ClickHouse**: O serviço `search-flights` aguarda a saúde do ClickHouse antes de iniciar.
- **Isolamento de produção**: O profile `local-wpp` usa um número de telefone de teste dedicado. A Meta entrega webhooks por número — os fluxos de dev e produção nunca se cruzam.

## Troubleshooting

Se algum serviço falhar ao conectar no banco na primeira vez, tente reiniciá-lo:
```bash
docker compose restart <service_name>
```
