---
description: Connect to a Shopify store for live API access
argument-hint: [store-domain]
allowed-tools: Bash
---

Connect to a Shopify store for live query execution.

**Recommended path:** most users should run `/shopify-auth-setup` instead. That flow uses the Coworkit public app (`https://apps.shopify.com/coworkit`) and the server-side proxy, which means tokens are refreshed automatically and can be revoked from the app UI.

This command is for advanced users who want to set up a **Custom App (direct-token) connection** manually, or to verify/inspect an existing connection of either type.

## Check for Existing Connection

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
    print(f"CONNECTED via Coworkit proxy — store: {store}, key prefix: {d['connection_key'][:12]}…")
    print(f"Proxy URL: {d.get('proxy_url', '?')}")
elif d.get('token'):
    t = d['token']
    print(f"CONNECTED via direct Admin API token (legacy custom app) — store: {store}")
    print(f"Token: {t[:10]}...{t[-4:]}")
else:
    print("CONFIG PRESENT BUT MISSING CREDENTIALS")
PY
```

If connected, ask the user whether to switch stores, reconnect, or verify the current connection.

## New Connection — Custom App Flow (direct token)

> Only use this flow if you can't or won't install the Coworkit public app on your store. If you install the Coworkit app, use `/shopify-auth-setup` instead — it is safer (tokens refresh, keys are revocable, the app is in the Shopify App Store).

If the user provided a store domain in `$ARGUMENTS`, use it. Otherwise, ask for it.

Guide them to create a custom app:

1. In Shopify admin: **Settings → Apps and sales channels → Develop apps**
2. Click **Create an app** → name it "Cowork Access"
3. Click **Configure Admin API scopes** → select the scopes they need:
   - Products: `read_products`, `write_products`
   - Orders: `read_orders`, `write_orders`
   - Customers: `read_customers`, `write_customers`
   - Inventory: `read_inventory`, `write_inventory`
4. Click **Save**, then **Install app**
5. Reveal and copy the **Admin API access token** (shown only once)

Note: since mid-2025, Shopify requires Admin API access tokens to be **expiring** tokens. A custom app token issued today will have a TTL and will need to be re-issued periodically. The Coworkit app flow handles this automatically; the custom-app flow does not.

Save the config (direct-token format):

```bash
mkdir -p ~/.coworkit
cat > ~/.coworkit/config.json << 'JSONEOF'
{
  "store": "<store-domain>.myshopify.com",
  "token": "<the-token>"
}
JSONEOF
chmod 600 ~/.coworkit/config.json
```

## Verify Connection (works for either flow)

```bash
python3 - <<'PY'
import json, os, sys, urllib.request
cfg = json.load(open(os.path.expanduser('~/.coworkit/config.json')))
q = {"query": "{ shop { name myshopifyDomain currencyCode } }"}

if cfg.get('connection_key') and cfg.get('proxy_url'):
    req = urllib.request.Request(
        cfg['proxy_url'],
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'Authorization': f"Bearer {cfg['connection_key']}"},
        method='POST',
    )
elif cfg.get('token') and cfg.get('store'):
    req = urllib.request.Request(
        f"https://{cfg['store']}/admin/api/2025-04/graphql.json",
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'X-Shopify-Access-Token': cfg['token']},
        method='POST',
    )
else:
    print('❌ config.json has no usable credentials'); sys.exit(1)

try:
    with urllib.request.urlopen(req, timeout=10) as r:
        print(json.dumps(json.loads(r.read()), indent=2))
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode(errors='replace')}")
PY
```

Show the store name and confirm the connection is active.

If it fails:
- **401 (proxy flow)** → connection key revoked or the Coworkit app was uninstalled/reinstalled. Run `/shopify-auth-setup` to generate a new code.
- **401 (direct flow)** → token expired or was regenerated. Re-issue it in Shopify admin → Settings → Apps and sales channels → Develop apps, and save the new token.
- **403** → missing Admin API scope. Fix by reinstalling the Coworkit app (to accept new scopes) or adjusting the Custom App config.
- **Connection error** → check the `store` value (must be `<name>.myshopify.com`).
