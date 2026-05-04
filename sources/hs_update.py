import sys
sys.stdout.reconfigure(encoding='utf-8')

import json
import base64
import os
import urllib.request
from collections import defaultdict

# ===================== KONFIGURACJA =====================
def load_env(path):
    env = {}
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env[key.strip()] = value.strip()
    return env

_env_path = os.path.join(os.path.dirname(__file__), '.env')
_env = load_env(_env_path)

ACCOUNT_LO   = _env['ACCOUNT_LO']
SESSION_ID   = _env['SESSION_ID']
GITHUB_TOKEN = _env['GITHUB_TOKEN']
GIST_ID      = _env['GIST_ID']
# ========================================================

RARITY_COSTS = {
    "COMMON":    (0,  2),
    "RARE":      (1,  5),
    "EPIC":      (5,  20),
    "LEGENDARY": (20, 80),
}

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept": "application/json"
}

def fetch_json(url, headers=None):
    req = urllib.request.Request(url, headers=headers or BROWSER_HEADERS)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode('utf-8'))

def fetch_collection():
    print("Pobieranie kolekcji z HSReplay...")
    url = f"https://hsreplay.net/api/v1/collection/?region=2&account_lo={ACCOUNT_LO}&type=CONSTRUCTED"
    headers = {**BROWSER_HEADERS, "Cookie": f"sessionid={SESSION_ID}"}
    return fetch_json(url, headers)

def fetch_cards():
    print("Pobieranie kart z HearthstoneJSON...")
    return fetch_json("https://api.hearthstonejson.com/v1/latest/enUS/cards.json")

def fetch_config():
    print("Pobieranie configu z GitHub...")
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    req = urllib.request.Request(
        "https://api.github.com/repos/tirey93/flutter_hs_stats/contents/sources/config.json",
        headers=headers
    )
    with urllib.request.urlopen(req) as r:
        data = json.loads(r.read().decode('utf-8'))
        return json.loads(base64.b64decode(data['content']).decode('utf-8'))

def generate_markdown(config, collection, cards_data):
    uncollectible_regulars   = set(config.get("uncollectibleRegulars", []))
    uncollectible_goldens    = set(config.get("uncollectibleGoldens", []))
    uncollectible_signatures = set(config.get("uncollectibleSignatures", []))

    cards_by_id = {str(c.get("dbfId")): c for c in cards_data if c.get("dbfId")}

    expansions_data = defaultdict(lambda: defaultdict(lambda: {"regular": 0, "golden": 0, "signature": 0}))

    for dbf_id, values in collection.get("collection", {}).items():
        card = cards_by_id.get(dbf_id)
        if not card:
            continue
        rarity   = card.get("rarity")
        card_set = card.get("set")
        name     = card.get("name", "")
        if not rarity or rarity == "FREE":
            continue

        normal_collectible = card.get("howToEarn") is None
        golden_collectible = card.get("howToEarnGolden") is None

        if len(values) >= 4:
            regular_count   = values[0] if normal_collectible and name not in uncollectible_regulars   else 0
            golden_count    = values[1] if golden_collectible and name not in uncollectible_goldens    else 0
            signature_count = values[3] if golden_collectible and name not in uncollectible_signatures else 0

            if regular_count > 0 or golden_count > 0 or signature_count > 0:
                target_set = card_set if card_set in config["expansions"] else "WILD"
                expansions_data[target_set][rarity]["regular"]   += regular_count
                expansions_data[target_set][rarity]["golden"]    += golden_count
                expansions_data[target_set][rarity]["signature"] += signature_count

    years = defaultdict(list)
    for set_code, exp_config in config["expansions"].items():
        years[exp_config["yearName"]].append({
            "code": set_code, "config": exp_config, "data": expansions_data[set_code]
        })
    for year in years:
        years[year].sort(key=lambda x: x["config"].get("releaseMonth") or 0)

    md = ["# Hearthstone Collection Stats\n"]
    md.append(f"**Dust:** {collection.get('dust', 'N/A')} | **Rares:** {collection.get('dust', 0) // 20}")
    md.append(f"**Last Modified:** {collection.get('lastModified', 'N/A')}\n")

    total_value = 0

    for year_name in sorted(years.keys(), key=lambda y: -max(x["config"].get("releaseYear") or 0 for x in years[y])):
        expansions = years[year_name]
        md.append(f"\n## {year_name}\n")
        md.append("| Expansion | Leg | Ep | Ra | Cm | G.L | G.E | G.R | G.C | Value |")
        md.append("|-----------|-----|----|----|----|-----|-----|-----|-----|-------|")

        year_total = 0
        for exp in expansions:
            exp_data = exp["data"]
            exp_name = exp["config"].get("shortName", exp["code"])

            leg_r  = exp_data.get("LEGENDARY", {}).get("regular", 0)
            leg_g  = exp_data.get("LEGENDARY", {}).get("golden", 0)  + exp_data.get("LEGENDARY", {}).get("signature", 0)
            epic_r = exp_data.get("EPIC",      {}).get("regular", 0)
            epic_g = exp_data.get("EPIC",      {}).get("golden", 0)  + exp_data.get("EPIC",      {}).get("signature", 0)
            rare_r = exp_data.get("RARE",      {}).get("regular", 0)
            rare_g = exp_data.get("RARE",      {}).get("golden", 0)  + exp_data.get("RARE",      {}).get("signature", 0)
            comm_r = exp_data.get("COMMON",    {}).get("regular", 0)
            comm_g = exp_data.get("COMMON",    {}).get("golden", 0)  + exp_data.get("COMMON",    {}).get("signature", 0)

            exp_total = leg_r*20 + leg_g*80 + epic_r*5 + epic_g*20 + rare_r*1 + rare_g*5 + comm_g*2
            year_total += exp_total

            md.append(f"| {exp_name} | {leg_r} | {epic_r} | {rare_r} | {comm_r} | {leg_g} | {epic_g} | {rare_g} | {comm_g} | **{exp_total}** |")

        if len(expansions) > 1:
            md.append(f"| **YEAR TOTAL** | | | | | | | | | **{year_total}** |")
        total_value += year_total

    md.append(f"\n---\n**GRAND TOTAL: {total_value} rares**")
    return "\n".join(md)

def update_gist(content):
    url = f"https://api.github.com/gists/{GIST_ID}"
    data = {"files": {"hs_stats.md": {"content": content}}}
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json"
    }
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers, method='PATCH')
    with urllib.request.urlopen(req) as r:
        result = json.loads(r.read().decode('utf-8'))
        print(f"Gist zaktualizowany: {result['html_url']}")

if __name__ == "__main__":
    try:
        config     = fetch_config()
        collection = fetch_collection()
        cards      = fetch_cards()
        print("Generowanie raportu...")
        md = generate_markdown(config, collection, cards)
        print("Aktualizacja gista...")
        update_gist(md)
        print("Gotowe!")
    except Exception as e:
        print(f"Błąd: {e}")
