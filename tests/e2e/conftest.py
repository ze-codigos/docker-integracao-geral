import pytest
from playwright.async_api import async_playwright, Browser, Page

BASE_URL = "http://localhost:5173"


@pytest.fixture(scope="session")
async def browser():
    async with async_playwright() as p:
        b = await p.chromium.launch(headless=False, slow_mo=100)
        yield b
        await b.close()


@pytest.fixture
async def page(browser: Browser) -> Page:
    p = await browser.new_page()
    yield p
    await p.close()
