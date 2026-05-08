import json
from playwright.sync_api import sync_playwright

URLS = {
    "godlies": "https://supremevalues.com/mm2/godlies",
    "chromas": "https://supremevalues.com/mm2/chromas",
    "vintages": "https://supremevalues.com/mm2/vintages",
    "ancients": "https://supremevalues.com/mm2/ancients",
    "uniques": "https://supremevalues.com/mm2/uniques",
    "sets": "https://supremevalues.com/mm2/sets",
}

def extract_items(page):
    page.wait_for_timeout(8000)
    html = page.content()

    items = {}

    blocks = page.query_selector_all("div")

    for b in blocks:
        try:
            text = b.inner_text().strip()

            if len(text) < 5 or len(text) > 300:
                continue

            lines = [x.strip() for x in text.split("\n") if x.strip()]

            if len(lines) < 2:
                continue

            name = lines[0]

            if any(skip in name.lower() for skip in ["value", "demand", "trend"]):
                continue

            items[name] = {
                "raw": text
            }

        except:
            continue

    return items


all_data = {}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    for category, url in URLS.items():
        page.goto(url)
        data = extract_items(page)
        all_data[category] = data

    browser.close()


with open("prices.json", "w", encoding="utf-8") as f:
    json.dump(all_data, f, indent=2, ensure_ascii=False)

print("updated", sum(len(v) for v in all_data.values()))