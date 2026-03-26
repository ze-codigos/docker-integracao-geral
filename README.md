# Docker Integração Geral (Passhub + Bot)

Este diretório contém a configuração para rodar todo o ecossistema localmente usando Docker Compose.

## Serviços Incluídos

- **Infraestrutura**: PostgreSQL, ClickHouse, MongoDB
- **Passhub**: EmissorAuth, Rodobus, EmissorCheckout, HeroSeguros, EmissorFront, EmissorGerencia, Nexus, TicketDelivery, SearchFlightsGo
- **Bot**: Agente, Oficial-WPP-API, Gerador-Imagem, Memoshar, MemoLite, CodigoConvite, Alertas-V2

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
