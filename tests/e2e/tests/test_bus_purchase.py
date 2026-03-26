from playwright.async_api import Page

from flows import auth, bus, checkout
from data.passengers import PASSAGEIROS
from data.cards import CARTAO_VISA_APROVADO


async def test_compra_rodoviario_cartao_progresso(page: Page):
    # 1. Autenticação
    await auth.login(page)

    # 2. Busca rodoviária Garanhuns → Recife, filtro Progresso
    await bus.buscar(page, origem="Garanhuns", destino="Recife", data="28/03/2026")
    await bus.filtrar_empresa(page, "Progresso")
    await bus.validar_card_resultado(page)

    # 3. Selecionar viagem e preencher passageiros
    await bus.selecionar_primeiro_resultado(page)
    await bus.preencher_passageiros(page, PASSAGEIROS[:2])

    # 4. Selecionar assentos e confirmar reserva
    await bus.selecionar_assentos(page, PASSAGEIROS[:2])
    await bus.ir_para_checkout(page)

    # 5. Pagamento com cartão e validação de sucesso
    await checkout.pagar_cartao(page, CARTAO_VISA_APROVADO)
    await checkout.validar_sucesso(page)
