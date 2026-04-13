---
description: Guided setup for the Shopify Toolkit plugin
allowed-tools: Bash, Read, Write
---

Run the Shopify Toolkit onboarding flow. Guide the user step by step through setup and end with a live demo.

## Step 1: Welcome

Welcome the user to the Shopify Toolkit. Briefly explain that this plugin lets them:
- Build Shopify apps (Liquid, Polaris, Hydrogen, Functions)
- Manage their store directly (products, orders, inventory, customers)
- Query and validate against live Shopify API schemas

## Step 2: Check Prerequisites

Run this check:

**Node.js 18+:**
```bash
node --version
```
- If missing or below v18: instruct to install from nodejs.org
- If OK: confirm with a checkmark

That's the only prerequisite. The Shopify Dev MCP server uses npx (bundled with Node.js).

## Step 3: Pick a connection flow

There are two ways to give this plugin access to a store. Ask the user which one they want:

**Option A — Coworkit app (recommended).** The user installs the public Coworkit app on their store from the Shopify App Store. The app handles OAuth, stores the offline token server-side, refreshes it automatically, and exposes a one-time **connection code** the user pastes into their terminal. This is the only flow that works with Shopify's 2025+ expiring-token requirements without manual re-issuance.

→ Hand off to `/shopify-auth-setup`, which walks the user through installing the app, generating the connection code, pasting the setup command, and verifying the connection.

**Option B — Custom App (direct token, advanced).** The user manually creates a Custom App in their Shopify admin and gives this plugin the Admin API access token directly. Works, but the token is an expiring token that must be re-issued periodically, and the user is responsible for scope changes. Use this only when installing the Coworkit app isn't possible.

→ If the user chooses this, continue with Step 3b below. Otherwise, run `/shopify-auth-setup` and skip to Step 5.

## Step 3b (only for Custom App flow)

Walk the user through creating a Custom App one step at a time:

**Open Custom Apps settings:** "In your Shopify admin, go to **Settings → Apps and sales channels → Develop apps**." If they see "Allow custom app development", they need to click it first (store-owner permission required).

**Create the app:** "Click **Create an app**, name it 'Cowork Access', click Create app."

**Configure Admin API scopes:** select at least:
- `read_products` + `write_products` — Manage products
- `read_orders` + `write_orders` — View and manage orders
- `read_customers` + `write_customers` — View and manage customers
- `read_inventory` + `write_inventory` — Manage stock levels
- `read_content` + `write_content` — Metaobjects and pages

Click **Save**.

**Install the app:** click the **Install app** button at the top, then confirm.

**Copy the token:** "Reveal and copy the **Admin API access token** — it's only shown once."

**Provide the token and store domain**, then save the config:

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

Remind the user: this token is an **expiring** token under Shopify's current rules. When it stops working, they'll need to re-issue it from the same Custom App page.

## Step 4: Verify Connection

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
        method='POST')
elif cfg.get('token') and cfg.get('store'):
    req = urllib.request.Request(
        f"https://{cfg['store']}/admin/api/2025-04/graphql.json",
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'X-Shopify-Access-Token': cfg['token']},
        method='POST')
else:
    print('❌ No usable credentials'); sys.exit(1)

try:
    with urllib.request.urlopen(req, timeout=10) as r:
        print(json.dumps(json.loads(r.read()), indent=2))
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode(errors='replace')}")
PY
```

If successful, show the store name and currency. If it fails, troubleshoot via `/shopify-diagnose`.

## Step 5: Live Demo

Fetch the first 5 products to demonstrate it works. Use the same Python transport selector:

```bash
python3 - <<'PY'
import json, os, sys, urllib.request
cfg = json.load(open(os.path.expanduser('~/.coworkit/config.json')))
q = {"query": "{ products(first: 5) { edges { node { title status totalInventory priceRangeV2 { minVariantPrice { amount currencyCode } } } } } }"}

if cfg.get('connection_key') and cfg.get('proxy_url'):
    req = urllib.request.Request(cfg['proxy_url'], data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'Authorization': f"Bearer {cfg['connection_key']}"}, method='POST')
else:
    req = urllib.request.Request(f"https://{cfg['store']}/admin/api/2025-04/graphql.json",
        data=json.dumps(q).encode(),
        headers={'Content-Type': 'application/json',
                 'X-Shopify-Access-Token': cfg['token']}, method='POST')

with urllib.request.urlopen(req, timeout=15) as r:
    print(json.dumps(json.loads(r.read()), indent=2))
PY
```

Present results in a clean table:

| Product | Status | Inventory | Price |
|---------|--------|-----------|-------|
| ... | ... | ... | ... |

If the store has no products, mention they can create one with `/shopify-store create product`.

## Step 6: Tour of Commands

Introduce the available commands with practical examples:

- `/shopify-auth-setup` — Connect (or reconnect) via the Coworkit app
- `/shopify-connect` — Manually configure a Custom App (direct token) connection
- `/shopify-diagnose` — Troubleshoot a broken connection
- `/shopify-query` — "Show me all orders from this week" → builds and runs the query
- `/shopify-store` — "Create a product called Summer Hat at $29.99" → creates it directly
- `/shopify-validate` — "Check if this Liquid template is correct" → validates against schemas
- `/shopify-scaffold` — "Generate a new checkout extension" → scaffolds the project

## Step 7: Wrap Up

Congratulate the user — they're all set. Suggest a few things to try:

- "Show me my recent orders"
- "How many products do I have in inventory?"
- "Build a discount function that gives 10% off orders over $100"

End with: "Just ask me anything about your Shopify store or app development — I'm ready to help."
