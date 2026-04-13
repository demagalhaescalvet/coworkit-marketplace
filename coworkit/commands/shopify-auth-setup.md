---
description: Connect your Shopify store via the Coworkit app
allowed-tools: Bash, Read, Write
---

Guide the user through connecting their Shopify store to Cowork using the Coworkit app.

## Step 1: Check Existing Connection

```bash
python3 - <<'PY'
import json, os
path = os.path.expanduser('~/.coworkit/config.json')
if not os.path.exists(path):
    print("NOT_CONNECTED"); raise SystemExit
try:
    d = json.load(open(path))
except Exception as e:
    print(f"CONFIG INVALID: {e}"); raise SystemExit
store = d.get('store', '?')
if d.get('connection_key'):
    print("CONNECTED (connection key)")
    print(f"  Store: {store}")
    print(f"  Key:   {d['connection_key'][:12]}...")
    print(f"  Proxy: {d.get('proxy_url', '?')}")
elif d.get('token'):
    t = d['token']
    print("CONNECTED (direct token — legacy custom app)")
    print(f"  Store: {store}")
    print(f"  Token: {t[:10]}...{t[-4:]}")
else:
    print("CONFIG PRESENT BUT MISSING CREDENTIALS")
PY
```

If already connected, tell the user their store is connected and show the store domain. Ask if they want to reconnect or switch stores.

If not connected, proceed to Step 2.

## Step 2: Guide Installation

Tell the user:

1. Open the **Coworkit** app in your Shopify admin (Apps → Coworkit, or install it from `https://apps.shopify.com/coworkit`).
2. The setup guide inside the app has three steps. Skip to **Step 2: Create your connection code**.
3. Click **"Create connection code"**. A one-time code is generated — this is a `ck_...` connection key that proves your Cowork client is allowed to access your store through Coworkit.
4. Click **"Copy code"**. The copied value is a full shell one-liner that writes `~/.coworkit/config.json` with your store domain, connection key, and the proxy URL.
5. Paste the command in your terminal and press Enter.

Be explicit with the user: **the key is shown only once**. If they lose it, they can click "Create connection code" again to mint a new one, and revoke the old one from the **Connection keys** panel on the same page.

## Step 3: Verify Connection

```bash
python3 - <<'PY'
import json, os
path = os.path.expanduser('~/.coworkit/config.json')
if not os.path.exists(path):
    print("❌ Config file not found. Please paste the setup command from the app.")
    raise SystemExit
d = json.load(open(path))
if d.get('connection_key'):
    print(f"✅ Connected to {d['store']} via proxy")
elif d.get('token'):
    print(f"✅ Connected to {d['store']} (direct token — legacy custom app)")
else:
    print("❌ config.json is present but has no credentials")
PY
```

## Step 4: Test Live Connection

```bash
python3 - <<'PY'
import json, os, sys, urllib.request
cfg = json.load(open(os.path.expanduser('~/.coworkit/config.json')))
q = {"query": "{ shop { name myshopifyDomain } }"}

if cfg.get('connection_key') and cfg.get('proxy_url'):
    req = urllib.request.Request(
        cfg['proxy_url'],
        data=json.dumps(q).encode(),
        headers={
            'Content-Type': 'application/json',
            'Authorization': f"Bearer {cfg['connection_key']}",
        },
        method='POST',
    )
elif cfg.get('token') and cfg.get('store'):
    req = urllib.request.Request(
        f"https://{cfg['store']}/admin/api/2025-04/graphql.json",
        data=json.dumps(q).encode(),
        headers={
            'Content-Type': 'application/json',
            'X-Shopify-Access-Token': cfg['token'],
        },
        method='POST',
    )
else:
    print('❌ No usable credentials in config.json'); sys.exit(1)

try:
    with urllib.request.urlopen(req, timeout=10) as r:
        body = json.loads(r.read())
        name = body.get('data', {}).get('shop', {}).get('name')
        if name:
            print(f'✅ Live API working — connected to "{name}"')
        else:
            print(f'⚠️  Unexpected response: {body}')
except Exception as e:
    print(f'❌ Request failed: {e}')
PY
```

If it succeeds, congratulate the user. They can now use commands like "show my products", "check recent orders", etc.

If it returns 401:
- Connection-key flow: the key may have been revoked or the merchant uninstalled/reinstalled the app. Ask them to generate a new connection code from the Coworkit app.
- Direct-token flow: the token may be expired. Legacy custom-app tokens don't expire on their own, but the user may have regenerated them. Ask them to re-issue it in Shopify admin → Settings → Apps and sales channels → Develop apps.
