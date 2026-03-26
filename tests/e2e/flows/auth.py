from playwright.async_api import Page

BASE_URL = "http://localhost:5173"
CREDS = {
    "email": "esdras.carvalho@passabot.com",
    "password": "8l0H0Png7TBolcIUJK7P",
}


async def login(page: Page) -> None:
    """Navega para /login e autentica. Aguarda redirect para /search."""
    await page.goto(f"{BASE_URL}/login")
    await page.get_by_role("textbox", name="Email").fill(CREDS["email"])
    await page.get_by_placeholder("••••••••").fill(CREDS["password"])
    await page.get_by_role("button", name="Entrar").click()
    await page.wait_for_url("**/search")
