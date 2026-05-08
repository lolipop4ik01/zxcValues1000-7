import json
import re
from playwright.sync_api import sync_playwright

# ========== ЧЁРНЫЙ СПИСОК ==========
IGNORE_KEYWORDS = [
    "pet", "puppy", "pony", "bunny", "bear", "dog", "cat", "fox", "pig",
    "join our discord", "make sure", "extra features", "placeholder",
    "owner -", "owners -", "gold ", "silver ", "bronze ",
    "wrapping paper", "sparkle", "potion", "mummy", "zombie", "grave",
]

def should_ignore_item(name):
    name_lower = name.lower()
    for kw in IGNORE_KEYWORDS:
        if kw in name_lower:
            return True
    if name.startswith("×") or len(name) < 3:
        return True
    return False

# ========== РУЧНЫЕ СООТВЕТСТВИЯ ==========
MANUAL_MAPPING = {
    # Battleaxe
    "BattleAxe II": "Battleaxe II",
    "BattleAxe": "Battleaxe",
    "Battle Axe II": "Battleaxe II",
    "Battle Axe": "Battleaxe",
    # Chroma (C. ↔ Chroma)
    "Chroma Traveler's Gun": "C. Traveler's Gun",
    "Chroma Vampire's Gun": "C. Vampire's Gun",
    "Chroma Constellation": "C. Constellation",
    "Chroma Snowcannon": "C. Snowcannon",
    "Chroma Heart Wand": "C. Heart Wand",
    "Chroma Snow Dagger": "C. Snow Dagger",
    "Chroma Darkbringer": "C. Darkbringer",
    "Chroma Lightbringer": "C. Lightbringer",
    "Chroma Candleflame": "C. Candleflame",
    "Chroma Elderwood Blade": "C. Elderwood Blade",
    "Chroma Swirly Gun": "C. Swirly Gun",
    "Chroma Deathshard": "C. Deathshard",
    "Chroma Cookiecane": "C. Cookiecane",
    "Chroma Gingerblade": "C. Gingerblade",
    # Обратные
    "C. Traveler's Gun": "Chroma Traveler's Gun",
    "C. Vampire's Gun": "Chroma Vampire's Gun",
    "C. Constellation": "Chroma Constellation",
    "C. Snowcannon": "Chroma Snowcannon",
    "C. Heart Wand": "Chroma Heart Wand",
    "C. Snow Dagger": "Chroma Snow Dagger",
    "C. Darkbringer": "Chroma Darkbringer",
    "C. Lightbringer": "Chroma Lightbringer",
    "C. Candleflame": "Chroma Candleflame",
    "C. Elderwood Blade": "Chroma Elderwood Blade",
    "C. Swirly Gun": "Chroma Swirly Gun",
    "C. Deathshard": "Chroma Deathshard",
    "C. Cookiecane": "Chroma Cookiecane",
    "C. Gingerblade": "Chroma Gingerblade",
}

# ========== SUPREME VALUES ==========
SUPREME_URLS = {
    "godlies": "https://supremevalues.com/mm2/godlies",
    "chromas": "https://supremevalues.com/mm2/chromas",
    "vintages": "https://supremevalues.com/mm2/vintages",
    "ancients": "https://supremevalues.com/mm2/ancients",
}

def parse_supreme_item(text):
    result = {"value": 0, "trend": "", "stability": "", "range": "", "demand": "", "rarity": ""}
    
    value_match = re.search(r"Value\s*-\s*([\d,]+)", text)
    if value_match:
        result["value"] = int(value_match.group(1).replace(",", ""))
    
    trend_match = re.search(r"(Rising|Falling|Stable)", text)
    if trend_match:
        result["trend"] = trend_match.group(1)
    
    stability_match = re.search(r"(Doing Well|Receding|Fluctuating|Overpaid For|Underpaid For)", text)
    if stability_match:
        result["stability"] = stability_match.group(1)
    elif "Stability - Stable" in text:
        result["stability"] = "Stable"
    
    range_match = re.search(r"\[([\d,\s\-]+)\]", text)
    if range_match:
        result["range"] = range_match.group(1).strip()
    
    demand_match = re.search(r"Demand\s*-\s*(\d+)", text)
    if demand_match:
        result["demand"] = int(demand_match.group(1))
    
    rarity_match = re.search(r"Rarity\s*-\s*(\d+)", text)
    if rarity_match:
        result["rarity"] = int(rarity_match.group(1))
    
    return result

def extract_supreme_items(page, category):
    page.wait_for_timeout(8000)
    items = {}
    blocks = page.query_selector_all("div")
    
    for block in blocks:
        try:
            text = block.inner_text().strip()
            if len(text) < 20 or len(text) > 1000:
                continue
            lines = [x.strip() for x in text.split("\n") if x.strip()]
            if len(lines) < 2:
                continue
            name = lines[0]
            
            skip_words = ["value", "demand", "trend", "join our", "make sure", "×", "extra features"]
            if any(skip in name.lower() for skip in skip_words):
                continue
            
            if should_ignore_item(name):
                continue
            
            info = parse_supreme_item(text)
            if info["value"] > 0:
                items[name] = info
        except:
            continue
    return items

# ========== DREAM PETS ==========
def get_dreampets_prices(page):
    print("  Закрываю рекламу...")
    try:
        close_btn = page.query_selector("xpath=/html/body/div[3]/div/div/div/button")
        if close_btn:
            close_btn.click()
            page.wait_for_timeout(1000)
            print("    ✅ Реклама закрыта")
    except:
        print("    Реклама не найдена")
    
    container = page.query_selector("xpath=/html/body/div/div/main/section/div/div/div/div[1]/div/div/div[2]")
    
    if not container:
        print("  ⚠️ Контейнер не найден")
        return {}
    
    print("  Прокручиваю контейнер...")
    for i in range(25):
        container.evaluate("element => element.scrollTop = element.scrollHeight")
        page.wait_for_timeout(1500)
        if i % 5 == 0:
            print(f"    Прокрутка {i+1}/25")
    
    page.wait_for_timeout(3000)
    
    js_code = """
    (function() {
        const items = {};
        const h3s = document.querySelectorAll('h3');
        
        for (let i = 0; i < h3s.length; i++) {
            const h3 = h3s[i];
            const parent = h3.closest('a');
            let priceElem = null;
            
            if (parent) {
                priceElem = parent.querySelector('[class*="price"]');
            }
            if (!priceElem && h3.parentElement) {
                priceElem = h3.parentElement.querySelector('[class*="price"]');
            }
            
            let price = 0;
            if (priceElem) {
                const priceText = priceElem.innerText.trim();
                const match = priceText.match(/(\\d+(?:\\.\\d+)?)/);
                if (match) {
                    price = parseFloat(match[1]);
                }
            }
            
            const name = h3.innerText.trim();
            if (price > 0 && name.length > 0) {
                items[name] = price;
            }
        }
        
        return items;
    })();
    """
    
    try:
        items = page.evaluate(js_code)
        return items
    except Exception as e:
        print(f"  Ошибка JS: {e}")
        return {}

# ========== ОСНОВНАЯ ФУНКЦИЯ ==========
def main():
    all_data = {}
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        print("[1/2] Сбор данных с SupremeValues...")
        for category, url in SUPREME_URLS.items():
            print(f"  → {category}...")
            page.goto(url)
            data = extract_supreme_items(page, category)
            all_data[category] = data
            print(f"    Найдено: {len(data)} предметов")
        
        print("\n[2/2] Сбор цен с DreamPets...")
        page.goto("https://dreampets.gg/mm2/", timeout=30000)
        page.wait_for_timeout(3000)
        
        dreampets_prices = get_dreampets_prices(page)
        print(f"\n  ✅ Найдено цен на DreamPets: {len(dreampets_prices)}")
        
        browser.close()
    
    print("\n[3/3] Объединение данных...")
    
    # Создаём словарь с ВСЕМИ возможными вариантами названий
    dreampets_lookup = {}
    for dream_name, price in dreampets_prices.items():
        # Оригинал
        dreampets_lookup[dream_name] = price
        
        # Ручные соответствия
        if dream_name in MANUAL_MAPPING:
            dreampets_lookup[MANUAL_MAPPING[dream_name]] = price
        
        # Автоматическое преобразование "Chroma X" → "C. X"
        if dream_name.startswith("Chroma "):
            dreampets_lookup["C. " + dream_name[7:]] = price
        
        # Автоматическое преобразование "C. X" → "Chroma X"
        if dream_name.startswith("C. "):
            chroma_name = "Chroma " + dream_name[3:]
            dreampets_lookup[chroma_name] = price
            
            # Дополнительно: убираем точку "C X" (если есть)
            dreampets_lookup["C " + dream_name[3:]] = price
    
    # Применяем цены к предметам из SupremeValues
    for category, items in all_data.items():
        for name, info in items.items():
            if name in dreampets_lookup:
                info["dreampets_price"] = dreampets_lookup[name]
            else:
                # Пробуем найти по альтернативному названию
                if name.startswith("C. "):
                    alt = "Chroma " + name[3:]
                    if alt in dreampets_lookup:
                        info["dreampets_price"] = dreampets_lookup[alt]
                    else:
                        info["dreampets_price"] = 0
                elif name.startswith("Chroma "):
                    alt = "C. " + name[7:]
                    if alt in dreampets_lookup:
                        info["dreampets_price"] = dreampets_lookup[alt]
                    else:
                        info["dreampets_price"] = 0
                else:
                    info["dreampets_price"] = 0
    
    with open("prices.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)
    
    total_items = sum(len(v) for v in all_data.values())
    items_with_dp = sum(1 for c in all_data.values() for i in c.values() if i.get("dreampets_price", 0) > 0)
    
    print(f"\n✅ Готово!")
    print(f"   Всего предметов: {total_items}")
    print(f"   Цены DreamPets найдены для: {items_with_dp}")

if __name__ == "__main__":
    main()
