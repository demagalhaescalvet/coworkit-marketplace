---
description: Troubleshoot Coworkit connection and configuration issues
argument-hint: [optional: verbose for detailed logs]
allowed-tools: Bash
---

Diagnose and troubleshoot Coworkit connection issues with your Shopify store.

This command handles both supported credential formats:

- **Proxy (Coworkit app) flow** — `{store, connection_key, proxy_url}` in `~/.coworkit/config.json`.
- **Direct (legacy custom-app) flow** — `{store, token}` in `~/.coworkit/config.json`.

## Run all checks

```bash
python3 - <<'PY'
import json, os, sys, urllib.request

CFG = os.path.expanduser('~/.coworkit/config.json')

def fail(msg, hint=None):
    print(f"❌ {msg}")
    if hint:
        print(f"   → {hint}")
    sys.exit(1)

# 1. Config file exists + valid JSON
if not os.path.exists(CFG):
    fail("Config file not found at ~/.coworkit/config.json",
         "Run /shopify-auth-setup (recommended) or /shopify-connect.")
try:
    cfg = json.load(open(CFG))
except Exception as e:
    fail(f"Config file contains invalid JSON: {e}",
         "Re-run /shopify-auth-setup to regenerate it.")

print("✓ Config file exists and is valid JSON")

# 2. Identify transport
store = cfg.get('store')
has_key = bool(cfg.get('connection_key') and cfg.get('proxy_url'))
has_token = bool(cfg.get('token'))

if not store:
    fail("`store` missing from config",
         "Re-run /shopify-auth-setup or /shopify-connect.")

if has_key:
    mode = 'proxy'
    print(f"✓ Transport: Coworkit proxy ({cfg['proxy_url']})")
    print(f"✓ Key prefix: {cfg['connection_key'][:12]}…")
elif has_token:
    mode = 'direct'
    t = cfg['token']
    print(f"✓ Transport: direct Admin API token (legacy)")
    print(f"✓ Token: {t[:10]}...{t[-4:]}")
else:
    fail("Config present but has neither `connection_key` nor `token`",
         "Re-run /shopify-auth-setup.")

print(f"✓ Store: {store}")

# 3. Test the API with a cheap query
q = {"query": "{ shop { name myshopifyDomain currencyCode } }"}
if mode == 'proxy':
    req = urllib.request.Request(
        cfg['proxy_url'],
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'Authorization': f"Bearer {cfg['connection_key']}"},
        method='POST',
    )
else:
    req = urllib.request.Request(
        f"https://{store}/admin/api/2025-04/graphql.json",
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'X-Shopify-Access-Token': cfg['token']},
        method='POST',
    )

try:
    with urllib.request.urlopen(req, timeout=15) as r:
        body = json.loads(r.read())
except urllib.error.HTTPError as e:
    code = e.code
    text = e.read().decode(errors='replace')
    if code == 401 and mode == 'proxy':
        fail(f"HTTP 401 from proxy: {text[:200]}",
             "Your connection key was revoked or the Coworkit app was reinstalled. Run /shopify-auth-setup to get a new code.")
    if code == 401 and mode == 'direct':
        fail(f"HTTP 401 from Shopify: {text[:200]}",
             "Your Admin API token is invalid or expired. Re-issue it in Shopify admin → Settings → Apps and sales channels → Develop apps.")
    if code == 403:
        fail(f"HTTP 403: {text[:200]}",
             "Missing Admin API scope. Reinstall the Coworkit app (proxy flow) or adjust scopes in your Custom App (direct flow).")
    fail(f"HTTP {code}: {text[:200]}")
except Exception as e:
    fail(f"Request failed: {e}",
         "Check that the store domain is correct (must be <name>.myshopify.com).")

if body.get('errors'):
    fail(f"GraphQL errors: {json.dumps(body['errors'])[:300]}")

shop = body.get('data', {}).get('shop', {})
if not shop:
    fail(f"Unexpected response: {json.dumps(body)[:300]}")

print(f"✓ Live API working — shop: {shop.get('name')!r} ({shop.get('myshopifyDomain')}, {shop.get('currencyCode')})")
print()
print("All checks passed. You can use /shopify-query, /shopify-store, etc.")
PY
```

## Common failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `Config file not found` | First-time setup or config deleted | Run `/shopify-auth-setup` (recommended) or `/shopify-connect` |
| `HTTP 401` on proxy flow | Connection key revoked or app reinstalled | `/shopify-auth-setup` → generate new code |
| `HTTP 401` on direct flow | Admin API token expired/regenerated | Re-issue token in Shopify admin → Settings → Apps and sales channels → Develop apps |
| `HTTP 403` | Missing Admin API scope | Reinstall Coworkit app to accept new scopes, or update Custom App scopes |
| `Request failed: getaddrinfo …` | Wrong store domain | `store` must be `<name>.myshopify.com`, not your custom domain |
| `Non-expiring access tokens are no longer accepted` | Old `shpat_*` token from pre-2025 custom app | Re-issue the Custom App token, or switch to `/shopify-auth-setup` |

If the check still fails after following the fix, run this command again with the `verbose` argument to capture full response bodies.
