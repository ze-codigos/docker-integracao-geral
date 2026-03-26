import re
from datetime import datetime
from playwright.async_api import Page, expect

MESES = {
    "Janeiro": 1, "Fevereiro": 2, "Março": 3, "Abril": 4,
    "Maio": 5, "Junho": 6, "Julho": 7, "Agosto": 8,
    "Setembro": 9, "Outubro": 10, "Novembro": 11, "Dezembro": 12,
}


async def _set_location(page: Page, field_name: str, text: str) -> None:
    """Clica no campo, digita a cidade e seleciona o primeiro resultado com terminais."""
    await page.get_by_role("textbox", name=field_name).click()
    await page.keyboard.press("Control+a")
    await page.keyboard.type(text)
    await page.locator("button").filter(
        has_text=re.compile(r"terminais")
    ).first().click()


async def _set_date(page: Page, data: str) -> None:
    """Seleciona a data no calendário. data: DD/MM/YYYY"""
    target = datetime.strptime(data, "%d/%m/%Y")
    await page.get_by_role("button").filter(
        has_text=re.compile(r"^\d{2}/\d{2}/\d{4}$")
    ).click()
    for _ in range(24):
        month_text = await page.locator(
            "text=/^(Janeiro|Fevereiro|Março|Abril|Maio|Junho|Julho|Agosto|Setembro|Outubro|Novembro|Dezembro) \\d{4}$/"
        ).text_content()
        parts = month_text.strip().split()
        cur_month = MESES[parts[0]]
        cur_year = int(parts[1])
        if cur_year == target.year and cur_month == target.month:
            break
        if (cur_year, cur_month) < (target.year, target.month):
            await page.get_by_role("button", name=">").click()
        else:
            await page.get_by_role("button", name="<").click()
    await page.get_by_role("button", name=str(target.day), exact=True).click()


async def buscar(page: Page, origem: str, destino: str, data: str) -> None:
    """Preenche o formulário de busca rodoviária (somente ida) e aguarda resultados."""
    await page.get_by_role("button", name="Rodoviário").click()
    await page.get_by_role("button", name="Somente Ida").click()
    await _set_location(page, "De onde você vai sair?", origem)
    await _set_location(page, "Para onde você vai?", destino)
    await _set_date(page, data)
    await page.get_by_role("button", name="BUSCAR").click()
    await page.wait_for_selector("text=opções")


async def filtrar_empresa(page: Page, empresa: str) -> None:
    """Abre o painel de filtros, seleciona a empresa e fecha o painel."""
    await page.get_by_role("button", name=re.compile(r"Filtros")).click()
    await page.get_by_role("button", name=empresa, exact=True).click()
    # Fecha o painel clicando no botão X no cabeçalho
    await page.get_by_role("heading", name="Filtros").locator("xpath=../../button").click()


async def validar_card_resultado(page: Page) -> None:
    """Valida que o primeiro card tem empresa, horário, disponibilidade, preço e botão Selecionar."""
    first_card = page.locator("div").filter(
        has=page.get_by_role("button", name="Selecionar")
    ).first()
    await expect(first_card.locator("img[alt]")).to_be_visible()
    await expect(first_card.locator("text=/\\d{1,2}:\\d{2}/").first()).to_be_visible()
    await expect(first_card.locator("text=/disponíveis/")).to_be_visible()
    await expect(first_card.locator("text=/R\\$/")).to_be_visible()
    await expect(first_card.get_by_role("button", name="Selecionar")).to_be_visible()


async def selecionar_primeiro_resultado(page: Page) -> None:
    """Clica em Selecionar no primeiro card e aguarda o formulário de passageiros."""
    await page.get_by_role("button", name="Selecionar").first().click()
    await page.wait_for_selector("text=Dados dos Passageiros")


async def preencher_passageiros(page: Page, passageiros: list[dict]) -> None:
    """Preenche o formulário para cada passageiro e confirma para avançar."""
    for i, p in enumerate(passageiros):
        nome_parts = p["nome"].split(maxsplit=1)
        primeiro = nome_parts[0]
        sobrenome = nome_parts[1] if len(nome_parts) > 1 else ""

        await page.get_by_role("textbox", name="Primeiro nome").nth(i).fill(primeiro)
        await page.get_by_role("textbox", name="Sobrenome").nth(i).fill(sobrenome)
        await page.get_by_role("textbox", name="dd/mm/aaaa").nth(i).fill(p["data_nascimento"])

        if p["sexo"] == "Fem":
            await page.get_by_role("button", name="Masculino").nth(i).click()
            await page.get_by_role("button", name="Feminino").click()

        # Muda tipo de documento para CPF
        await page.get_by_role("button", name="RG").nth(i).click()
        await page.get_by_role("button", name="CPF").last().click()

        await page.get_by_role("textbox", name="Nº do documento").nth(i).fill(p["cpf"])
        await page.get_by_role("textbox", name="email@exemplo.com").nth(i).fill(p["email"])
        await page.get_by_role("textbox", name="(11) 99999-").nth(i).fill(p["telefone"])

    await page.get_by_role("button", name="Confirmar dados e prosseguir").click()
    await page.wait_for_selector("text=Seleção de Assentos")


async def selecionar_assentos(page: Page, passageiros: list[dict]) -> None:
    """Seleciona o primeiro assento disponível para cada passageiro e confirma a reserva."""
    await page.get_by_role("button", name="Sim, quero escolher assentos").click()
    await page.wait_for_selector("h2:text('Selecionar assentos')")

    for i, passageiro in enumerate(passageiros):
        if i > 0:
            primeiro_nome = passageiro["nome"].split()[0]
            await page.get_by_role("button", name=re.compile(rf"^{primeiro_nome}")).click()

        # Encontra o primeiro assento com cursor:pointer (disponível)
        seat_number = await page.evaluate("""
            () => {
                for (const btn of document.querySelectorAll('button')) {
                    if (/^\\d+$/.test(btn.textContent.trim()) &&
                        window.getComputedStyle(btn).cursor === 'pointer') {
                        return btn.textContent.trim();
                    }
                }
                return null;
            }
        """)
        assert seat_number, f"Nenhum assento disponível para passageiro {i + 1}"
        await page.get_by_role("button", name=seat_number, exact=True).click()

    n = len(passageiros)
    await page.get_by_role("button", name=re.compile(rf"Confirmar reserva \({n} assento")).click()
    await page.wait_for_selector("text=Reserva criada com sucesso!")


async def ir_para_checkout(page: Page) -> None:
    """Extrai o link de checkout da página de confirmação e navega até ele."""
    checkout_url = await page.locator("text=/http:\\/\\/localhost:5172/").text_content()
    await page.goto(checkout_url.strip())
    await page.wait_for_selector("text=Pagar")
