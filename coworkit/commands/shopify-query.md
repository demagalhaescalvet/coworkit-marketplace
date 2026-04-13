---
description: Build and explain a Shopify GraphQL query or mutation
argument-hint: [describe what you want to query]
allowed-tools: Bash
---

Build a Shopify GraphQL Admin API query or mutation based on: $ARGUMENTS

Follow these steps:

1. Determine whether this is a query (read) or mutation (write)
2. Identify the correct resource and fields from the Admin API schema
3. Write the complete GraphQL operation with proper variables
4. Include pagination (cursor-based) if the query returns a list
5. For mutations, always include the `userErrors` field
6. Explain the query structure and any important considerations (rate limits, required scopes)

Use the shopify-dev-mcp tools to validate the query against current API schemas when available.

Output the query in a code block, followed by example variables if applicable, and a brief explanation of what it does.

## Live Execution

After building the query, ask the user if they want to run it against their store. If yes, use the snippet below. It supports two transports:

- **Proxy transport (default, App Store flow)** — uses `connection_key` + `proxy_url` from `~/.coworkit/config.json`. The Coworkit server handles token refresh and forwards the GraphQL call to Shopify.
- **Direct transport (legacy custom-app flow)** — uses `token` + `store` from `~/.coworkit/config.json` and hits Shopify directly.

```bash
python3 - <<'PY' <<QUERY
{"query": "<the-query>", "variables": {<variables-if-any>}}
QUERY
import json, os, sys, urllib.request

cfg_path = os.path.expanduser('~/.coworkit/config.json')
if not os.path.exists(cfg_path):
    print('❌ Not connected. Run /shopify-auth-setup first.'); sys.exit(1)
cfg = json.load(open(cfg_path))

payload = sys.stdin.read().encode()

if cfg.get('connection_key') and cfg.get('proxy_url'):
    req = urllib.request.Request(
        cfg['proxy_url'],
        data=payload,
        headers={
            'Content-Type': 'application/json',
            'Authorization': f"Bearer {cfg['connection_key']}",
        },
        method='POST',
    )
elif cfg.get('token') and cfg.get('store'):
    req = urllib.request.Request(
        f"https://{cfg['store']}/admin/api/2025-04/graphql.json",
        data=payload,
        headers={
            'Content-Type': 'application/json',
            'X-Shopify-Access-Token': cfg['token'],
        },
        method='POST',
    )
else:
    print('❌ No usable credentials in config.json. Run /shopify-auth-setup.'); sys.exit(1)

try:
    with urllib.request.urlopen(req, timeout=30) as r:
        print(json.dumps(json.loads(r.read()), indent=2))
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode(errors='replace')}")
    sys.exit(1)
PY
```

Rules when presenting results:

1. **Always confirm mutations with the user before executing** — show them exactly what will change.
2. Present results in a clean, readable format (tables for lists, summaries for single resources).
3. Check for `userErrors` in mutation responses — a 200 HTTP status does not mean the operation succeeded.
4. If the proxy returns 401, the connection key was revoked or the Coworkit app was reinstalled — ask the user to re-run `/shopify-auth-setup`.
5. If Shopify returns 403, explain which scope is missing and ask the user to either (a) reinstall the Coworkit app to accept new scopes, or (b) add the scope in their Custom App settings if they're on the direct-token flow.
