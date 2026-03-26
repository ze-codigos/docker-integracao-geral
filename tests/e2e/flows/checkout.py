import re
from playwright.async_api import Page, expect


async def pagar_cartao(page: Page, cartao: dict) -> None:
    """Seleciona pagamento com cartão de crédito e preenche os dados."""
    await page.get_by_role("button", name=re.compile(r"Cartão de Crédito")).click()
    await page.get_by_placeholder("1234 5678 9012 3456").fill(cartao["numero"])
    await page.get_by_placeholder("MM/AA").fill(
        f"{cartao['validade_mes']}/{cartao['validade_ano'][-2:]}"
    )
    await page.get_by_placeholder("123").fill(cartao["cvv"])
    await page.get_by_placeholder("Nome no cartão").fill(cartao["nome"])
    await page.get_by_role("button", name="Pagar com Cartão").click()


async def validar_sucesso(page: Page) -> None:
    """Valida que a mensagem de confirmação de pagamento aparece na tela."""
    await expect(
        page.get_by_role("heading", name="Pagamento Confirmado!")
    ).to_be_visible(timeout=30_000)
