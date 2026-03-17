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

## Observações

- **WhatsApp API**: O serviço `bot-wpp-api` roda localmente mas não receberá webhooks da Meta a menos que você use uma ferramenta como o `ngrok` para expor a porta 8080 e configure o webhook na plataforma da Meta.
- **Banco de Dados**: Todos os serviços compartilham a mesma instância de PostgreSQL e o mesmo banco `passhub`, mas as tabelas do bot e do passhub possuem nomenclaturas distintas para evitar conflitos.
- **ClickHouse**: O serviço `search-flights` aguarda a saúde do ClickHouse antes de iniciar.

## Troubleshooting

Se algum serviço falhar ao conectar no banco na primeira vez, tente reiniciá-lo:
```bash
docker compose restart <service_name>
```
