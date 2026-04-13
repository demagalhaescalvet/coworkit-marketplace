---
description: Connect to a Shopify store for live API access
argument-hint: [store-domain]
allowed-tools: Bash
---

Connect to a Shopify store for live query execution.

## Check for Existing Connection

First, check if a connection already exists:
```bash
if [ -f ~/.coworkit/config.json ]; then
  STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
  echo "Currently connected to: $STORE"
fi
```

If connected, ask if the user wants to switch stores or reconnect.

## New Connection Flow

If the user provided a store domain in the arguments ($ARGUMENTS), use it. Otherwise, ask for it.

Then ask for their Admin API access token. If they don't have one, guide them:

1. In Shopify admin: **Settings → Apps and sales channels → Develop apps**
2. Click **Create an app** → name it "Cowork Access"
3. Click **Configure Admin API scopes** → select the scopes they need:
   - Products: `read_products`, `write_products`
   - Orders: `read_orders`, `write_orders`
   - Customers: `read_customers`, `write_customers`
   - Inventory: `read_inventory`, `write_inventory`
4. Click **Save**, then **Install app**
5. Reveal and copy the **Admin API access token** (shown only once)

Once they provide the token and store domain, save the config:
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

## Verify Connection

```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "{ shop { name myshopifyDomain currencyCode } }"}' | python3 -m json.tool
```

Show the store name and confirm the connection is active.

If it fails:
- 401 → invalid token (may need to regenerate in Shopify admin)
- Connection error → check the store domain
- 403 → insufficient scopes (need to reconfigure the Custom App)
