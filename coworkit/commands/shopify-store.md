---
description: Manage Shopify store resources (products, orders, etc.)
argument-hint: [action: create/update/list/delete] [resource]
allowed-tools: Bash
---

Manage Shopify store resources based on: $ARGUMENTS

Parse the requested action and resource, then:

1. Build the appropriate GraphQL Admin API query or mutation
2. Include all relevant fields for the operation
3. Handle pagination for list operations
4. Include proper error handling (userErrors)
5. Determine the required access scopes for the operation

For bulk operations (importing many products, updating many variants), recommend the Bulk Operations API instead of individual mutations.

Always confirm destructive operations (delete, archive) before proceeding. For create/update operations, show the complete mutation before executing.

## Live Execution

This command executes operations against the user's connected store. It supports two transports:

- **Proxy transport (default, App Store flow)**: sends requests to `config.proxy_url` with `Authorization: Bearer <connection_key>`. The Coworkit server handles token refresh and forwards to Shopify.
- **Direct transport (legacy custom-app flow)**: sends requests directly to `{store}/admin/api/.../graphql.json` with `X-Shopify-Access-Token: <token>`.

The script below picks the right transport based on what's in `config.json`.

```bash
python3 - <<'PY' <<QUERY
{"query": "<query-or-mutation>", "variables": {<variables>}}
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
3. Check `userErrors` in mutation responses — show actionable error messages if present.
4. If the proxy returns 401, the connection key was revoked or the Coworkit app was reinstalled — ask the user to re-run `/shopify-auth-setup`.
5. If Shopify returns 403, explain which scope is missing and ask the user to either (a) reinstall the Coworkit app to accept new scopes, or (b) add the scope in their Custom App settings if they're on the direct-token flow.
