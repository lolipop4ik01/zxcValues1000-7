import json
import re
from playwright.sync_api import sync_playwright

URLS = {
    "godlies": "https://supremevalues.com/mm2/godlies",
    "chromas": "https://supremevalues.com/mm2/chromas",
    "vintages": "https://supremevalues.com/mm2/vintages",
    "ancients": "https://supremevalues.com/mm2/ancients",
    "uniques": "https://supremevalues.com/mm2/uniques",
    "sets": "https://supremevalues.com/mm2/sets",
}

def parse_item_text(text):
    """Извлекает из сырого текста цену, тренд, стабильность, рендж, спрос, редкость"""
    result = {
        "value": 0,
        "trend": "",
        "stability": "",
        "range": "",
        "demand": "",
        "rarity": ""
    }
    
    # Цена: "Value - 328" или "Value - 1,240"
    value_match = re.search(r"Value\s*-\s*([\d,]+)", text)
    if value_match:
        value_str = value_match.group(1).replace(",", "")
        result["value"] = int(value_str)
    
    # Тренд: "Rising", "Falling", "Stable"
    trend_match = re.search(r"(Rising|Falling|Stable)", text)
    if trend_match:
        result["trend"] = trend_match.group(1)
    
    # Стабильность: "Doing Well", "Receding", "Stable", "Fluctuating", "Overpaid For", "Underpaid For"
    stability_match = re.search(r"(Doing Well|Receding|Fluctuating|Overpaid For|Underpaid For)", text)
    if stability_match:
        result["stability"] = stability_match.group(1)
    elif "Stability - Stable" in text:
        result["stability"] = "Stable"
    
    # Рендж: [1,240 - 1,260]
    range_match = re.search(r"\[([\d,\s\-]+)\]", text)
    if range_match:
        result["range"] = range_match.group(1).strip()
    
    # Спрос: "Demand - 6"
    demand_match = re.search(r"Demand\s*-\s*(\d+)", text)
    if demand_match:
        result["demand"] = int(demand_match.group(1))
    
    # Редкость: "Rarity - 4"
    rarity_match = re.search(r"Rarity\s*-\s*(\d+)", text)
    if rarity_match:
        result["rarity"] = int(rarity_match.group(1))
    
    return result

def extract_items(page):
    page.wait_for_timeout(8000)
    
    items = {}
    
    # Ищем все блоки с предметами (обычно div с достаточным количеством текста)
    blocks = page.query_selector_all("div")
    
    for block in blocks:
        try:
            text = block.inner_text().strip()
            
            # Фильтруем мусорные блоки
            if len(text) < 20 or len(text) > 1000:
                continue
            
            # Первая строка — обычно название предмета
            lines = [x.strip() for x in text.split("\n") if x.strip()]
            if len(lines) < 2:
                continue
            
            name = lines[0]
            
            # Пропускаем служебные заголовки
            skip_words = ["value", "demand", "trend", "join our", "make sure", "×", "extra features"]
            if any(skip in name.lower() for skip in skip_words):
                continue
            
            # Парсим информацию
            info = parse_item_text(text)
            
            # Сохраняем только если есть хоть какая-то цена
            if info["value"] > 0:
                items[name] = info
                
        except Exception as e:
            continue
    
    return items

all_data = {}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    
    for category, url in URLS.items():
        print(f"Scraping {category}...")
        page.goto(url)
        data = extract_items(page)
        all_data[category] = data
        print(f"  Found {len(data)} items")
    
    browser.close()

with open("prices.json", "w", encoding="utf-8") as f:
    json.dump(all_data, f, indent=2, ensure_ascii=False)

print(f"✅ Done! Total items: {sum(len(v) for v in all_data.values())}")
