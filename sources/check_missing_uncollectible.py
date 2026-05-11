import sys
sys.stdout.reconfigure(encoding='utf-8')

import json
import base64
import os
import urllib.request

# CONFIG - wczytaj z .env
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

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept": "application/json"
}

def fetch_json(url, headers=None):
    req = urllib.request.Request(url, headers=headers or BROWSER_HEADERS)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode('utf-8'))

def fetch_collection():
    print("Fetching collection from HSReplay...")
    url = f"https://hsreplay.net/api/v1/collection/?region=2&account_lo={ACCOUNT_LO}&type=CONSTRUCTED"
    headers = {**BROWSER_HEADERS, "Cookie": f"sessionid={SESSION_ID}"}
    return fetch_json(url, headers)

def fetch_cards():
    print("Fetching cards from HearthstoneJSON...")
    return fetch_json("https://api.hearthstonejson.com/v1/latest/enUS/cards.json")

def fetch_config():
    print("Fetching config from GitHub...")
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

def main():
    config = fetch_config()
    collection = fetch_collection()
    cards_data = fetch_cards()
    
    cards_by_id = {str(c.get("dbfId")): c for c in cards_data if c.get("dbfId")}
    
    uncollectible_sigs = set(config.get('uncollectibleSignatures', []))
    uncollectible_golds = set(config.get('uncollectibleGoldens', []))
    
    print("\n" + "="*80)
    print("CHECKING FOR MISSING UNCOLLECTIBLE CARDS")
    print("="*80)
    print("\nThese cards have howToEarnGolden=None (pass through filter)")
    print("but are NOT in config uncollectible lists.")
    print("They may need to be added to config.json if not craftable.\n")
    
    missing = []
    
    for dbf_id, values in collection.get("collection", {}).items():
        if len(values) < 2:
            continue
            
        card = cards_by_id.get(dbf_id)
        if not card:
            continue
            
        rarity = card.get('rarity')
        name = card.get('name', '')
        
        # Skip FREE cards (filtered in main script)
        if rarity == 'FREE':
            continue
            
        golden_count = values[1]
        signature_count = values[3] if len(values) > 3 else 0
        
        if golden_count == 0 and signature_count == 0:
            continue
            
        # Check if howToEarnGolden is None (passes through filter)
        how_to_earn_golden = card.get('howToEarnGolden')
        
        if how_to_earn_golden is None:
            # This card passes through the filter in hs_update.py
            # Check if it's in uncollectible lists
            is_sig_uncollectible = name in uncollectible_sigs
            is_gold_uncollectible = name in uncollectible_golds
            
            if signature_count > 0 and not is_sig_uncollectible:
                missing.append({
                    'name': name,
                    'rarity': rarity,
                    'set': card.get('set', 'Unknown'),
                    'golden': golden_count,
                    'signature': signature_count,
                    'add_to': 'uncollectibleSignatures'
                })
            elif golden_count > 0 and not is_gold_uncollectible:
                missing.append({
                    'name': name,
                    'rarity': rarity,
                    'set': card.get('set', 'Unknown'),
                    'golden': golden_count,
                    'signature': signature_count,
                    'add_to': 'uncollectibleGoldens'
                })
    
    if missing:
        print(f"Found {len(missing)} potential missing cards:\n")
        for card in missing:
            print(f"  {card['name']} ({card['rarity']}) - {card['set']}")
            print(f"    Golden: {card['golden']}, Signature: {card['signature']}")
            print(f"    Add to: {card['add_to']}")
            print()
        print("="*80)
        print("NOTE: Verify these cards are NOT craftable before adding to config!")
        print("="*80)
    else:
        print("No missing cards found - all good!")
        print("="*80)

if __name__ == "__main__":
    main()
