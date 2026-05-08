import json
import re
import time
from playwright.sync_api import sync_playwright

# ========== ЧЁРНЫЙ СПИСОК КЛЮЧЕВЫХ СЛОВ ==========
IGNORE_KEYWORDS = [
    # Петы
    "pet", "puppy", "pony", "bunny", "bear", "dog", "cat", "fox", "pig", "chicken", "dragon",
    "phoenix", "bird", "skelly", "sammy", "icey", "electro", "fire", "chroma fire",
    # Мусорные/нетрейдерные
    "join our discord", "make sure", "extra features", "placeholder", "coming soon",
    "owner -", "owners -", "gold ", "silver ", "bronze ", "blue ", "red ", "purple ",
    "top 100", "leaderboard", "account terminated", "click here", "view item on the wiki",
    # Не оружие
    "wrapping paper", "sparkle", "potion", "mummy", "zombie", "grave", "snakebite",
    "cavern", "toxic", "frozen", "aurora", "vampire (", "vampire set", "pumpkin set",
    "latte", "bats", "spectral", "traveler (", "gingerbread", "silent night",
    "zombified", "candy swirl", "lights", "icedriller", "elite", "santa's", "scratch",
    "marble", "haunted", "eyeball", "overseer eye", "icecracker", "icedriller",
]

def should_ignore_item(name):
    """Проверяем, нужно ли игнорировать предмет"""
    name_lower = name.lower()
    
    # Игнорируем по ключевым словам
    for kw in IGNORE_KEYWORDS:
        if kw in name_lower:
            return True
    
    # Игнорируем если начинается с "×" или слишком короткое
    if name.startswith("×") or len(name) < 3:
        return True
    
    # Игнорируем если это явно не оружие (нет цены или мусор)
    if any(x in name_lower for x in ["set", "collection", "bundle"]):
        # Но оставляем отдельные сеты (они нужны для информации)
        if "set" in name_lower and len(name) < 20:
            return True
    
    return False

# ========== ОСНОВНЫЕ НАСТРОЙКИ ==========
SUPREME_URLS = {
    "godlies": "https://supremevalues.com/mm2/godlies",
    "chromas": "https://supremevalues.com/mm2/chromas",
    "vintages": "https://supremevalues.com/mm2/vintages",
    "ancients": "https://supremevalues.com/mm2/ancients",
    # Исключаем uniques и sets — там много мусора
    # "uniques": "https://supremevalues.com/mm2/uniques",
    # "sets": "https://supremevalues.com/mm2/sets",
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
            
            # Пропускаем мусорные заголовки
            skip_words = ["value", "demand", "trend", "join our", "make sure", "×", "extra features"]
            if any(skip in name.lower() for skip in skip_words):
                continue
            
            # Фильтруем ненужные предметы
            if should_ignore_item(name):
                continue
            
            info = parse_supreme_item(text)
            if info["value"] > 0:
                items[name] = info
        except:
            continue
    return items

# ========== ПАРСИНГ DREAM PETS ==========
def get_dreampets_price(page, item_name):
    """Заходит на страницу предмета на DreamPets и возвращает цену в рублях"""
    # Формируем URL
    url_name = item_name.lower().replace(" ", "-")
    url_name = re.sub(r"[\(\)]", "", url_name)
    url_name = re.sub(r"[^\w\-]", "", url_name)  # убираем всё, кроме букв, цифр и тире
    url = f"https://dreampets.gg/mm2/items/{url_name}"
    
    try:
        page.goto(url, timeout=15000)
        page.wait_for_timeout(2000)
        
        html = page.content()
        match = re.search(r"(\d+)\s*[₽]", html)
        if match:
            return int(match.group(1))
        
        price_elem = page.query_selector(".item-price, .price, [class*='price']")
        if price_elem:
            text = price_elem.inner_text()
            num = re.search(r"(\d+)", text)
            if num:
                return int(num.group(1))
    except:
        pass
    return 0

# ========== ОСНОВНОЙ ПАРСЕР ==========
def main():
    all_data = {}
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        # Собираем SupremeValues
        for category, url in SUPREME_URLS.items():
            print(f"[1/2] Сбор SupremeValues: {category}...")
            page.goto(url)
            data = extract_supreme_items(page, category)
            all_data[category] = data
            print(f"     Найдено после фильтрации: {len(data)} предметов")
        
        # Собираем названия всех отфильтрованных предметов
        all_items = []
        for category, items in all_data.items():
            for name in items.keys():
                all_items.append(name)
        
        print(f"\n[2/2] Сбор цен с DreamPets для {len(all_items)} предметов...")
        
        dreampets_prices = {}
        total = len(all_items)
        
        for i, name in enumerate(all_items):
            print(f"  {i+1}/{total}: {name}")
            price = get_dreampets_price(page, name)
            if price > 0:
                dreampets_prices[name] = price
            time.sleep(0.5)
        
        # Добавляем DreamPets цены
        for category, items in all_data.items():
            for name, info in items.items():
                info["dreampets_price"] = dreampets_prices.get(name, 0)
        
        browser.close()
    
    # Сохраняем результат
    with open("prices.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)
    
    filtered_count = sum(len(v) for v in all_data.values())
    print(f"\n✅ Готово! Оставлено предметов: {filtered_count}")
    print(f"💰 Цены с DreamPets найдены для {len(dreampets_prices)} предметов")
    print(f"🗑️ Игнорируется: {len(IGNORE_KEYWORDS)} категорий мусора")

if __name__ == "__main__":
    main()
