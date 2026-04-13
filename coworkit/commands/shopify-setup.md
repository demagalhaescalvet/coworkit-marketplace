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

## Step 3: Connect to Store via Custom App Token

Guide the user through creating a Custom App in their Shopify admin. This is necessary because Cowork runs in a sandboxed environment that cannot open a browser for OAuth. A Custom App provides a static API token that works perfectly here.

Walk them through these steps one at a time, waiting for confirmation at each:

**3a. Open Custom Apps settings:**
Tell the user: "In your Shopify admin, go to **Settings → Apps and sales channels → Develop apps**."
- If they see "Allow custom app development" button, they need to click it first (requires store owner permission)

**3b. Create the app:**
Tell the user: "Click **Create an app**, name it something like 'Cowork Access', and click Create app."

**3c. Configure API scopes:**
Tell the user: "Click **Configure Admin API scopes** and select these scopes:"

Present this checklist:
- `read_products` + `write_products` — Manage products
- `read_orders` + `write_orders` — View and manage orders
- `read_customers` + `write_customers` — View and manage customers
- `read_inventory` + `write_inventory` — Manage stock levels
- `read_content` + `write_content` — Metaobjects and pages

Then: "Click **Save** when done."

**3d. Install the app:**
Tell the user: "Click the **Install app** button at the top, then confirm by clicking **Install**."

**3e. Copy the token:**
Tell the user: "You'll see **Admin API access token** — click **Reveal token once** and copy it. This token is only shown once, so make sure to copy it now."

**3f. Provide the token:**
Ask for two things:
1. The Admin API access token they just copied
2. Their store domain (the `something.myshopify.com` address)

**IMPORTANT**: Once the user provides the token, save it to a config file for this session:
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

## Step 4: Verify Connection

Test the connection with a direct API call:
```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "{ shop { name myshopifyDomain currencyCode } }"}' | python3 -m json.tool
```

If successful, show the store name and currency. If it fails, troubleshoot:
- 401 error → token is invalid or was not copied correctly
- Connection error → store domain is wrong
- 403 error → scopes are insufficient, need to reconfigure

## Step 5: Live Demo

Fetch the first 5 products to demonstrate it works:
```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "{ products(first: 5) { edges { node { title status totalInventory priceRangeV2 { minVariantPrice { amount currencyCode } } } } } }"}' | python3 -m json.tool
```

Present results in a clean table:

| Product | Status | Inventory | Price |
|---------|--------|-----------|-------|
| ... | ... | ... | ... |

If the store has no products, mention they can create one with `/shopify-store create product`.

## Step 6: Tour of Commands

Introduce the available commands with practical examples:

- `/shopify-connect` — Reconnect or switch to a different store
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
