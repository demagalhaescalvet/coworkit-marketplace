---
description: Troubleshoot Coworkit connection and configuration issues
argument-hint: [optional: verbose for detailed logs]
allowed-tools: Bash
---

Diagnose and troubleshoot Coworkit connection issues with your Shopify store.

## Step 1: Check Configuration File

First, verify the config file exists and has valid JSON:

```bash
if [ ! -f ~/.coworkit/config.json ]; then
  echo "ERROR: Config file not found at ~/.coworkit/config.json"
  echo "Solution: Run /shopify-connect first to set up your store connection."
  exit 1
fi

# Validate JSON
if ! python3 -c "import json; json.load(open('~/.coworkit/config.json'))" 2>/dev/null; then
  echo "ERROR: Config file contains invalid JSON"
  echo "Run /shopify-connect to create a valid config."
  exit 1
fi

echo "✓ Config file exists and is valid JSON"
```

## Step 2: Verify Required Fields

Check that store domain and token are present:

```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('store',''))" 2>/dev/null)
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('token',''))" 2>/dev/null)

if [ -z "$STORE" ]; then
  echo "ERROR: Store domain not found in config"
  echo "Run /shopify-connect to set your store domain."
  exit 1
fi

if [ -z "$TOKEN" ]; then
  echo "ERROR: Admin API token not found in config"
  echo "Run /shopify-connect to set your API token."
  exit 1
fi

echo "✓ Store domain found: $STORE"
echo "✓ API token found (first 10 chars): ${TOKEN:0:10}..."
```

## Step 3: Test GraphQL Connection

Attempt a simple GraphQL query to verify the API connection:

```bash
echo "Testing API connection with a simple query..."

RESPONSE=$(curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "{ shop { name myshopifyDomain currencyCode } }"}')

# Check for errors
if echo "$RESPONSE" | grep -q '"errors"'; then
  ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('errors',[{}])[0].get('message','Unknown error'))" 2>/dev/null)
  echo "ERROR: GraphQL query failed"
  echo "Message: $ERROR_MSG"
  
  if echo "$ERROR_MSG" | grep -iq "unauthorized\|invalid"; then
    echo "SOLUTION: Your API token may be invalid or expired."
    echo "- Go to Shopify admin → Settings → Apps and sales channels → Develop apps"
    echo "- Click on 'Cowork Access' → Admin API access tokens"
    echo "- Regenerate the token and run /shopify-connect"
  fi
  exit 1
fi

# Extract shop name
SHOP_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('shop',{}).get('name','Unknown'))" 2>/dev/null)

echo "✓ GraphQL connection successful"
echo "✓ Connected shop: $SHOP_NAME"
echo "✓ Shop domain: $(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('shop',{}).get('myshopifyDomain','Unknown'))" 2>/dev/null)"
```

## Step 4: Check MCP Server Status

Verify MCP server connectivity (if applicable):

```bash
if command -v ps &> /dev/null; then
  if ps aux | grep -q "shopify.*mcp\|coworkit.*server"; then
    echo "✓ Shopify MCP server appears to be running"
  else
    echo "⚠ Shopify MCP server not detected in running processes"
    echo "Note: This is normal if using cloud-based MCP."
  fi
fi
```

## Summary

If all checks pass:
- Your Coworkit connection is working correctly
- You can now use /shopify-query, /shopify-store, and other commands

If a check fails:
- Follow the specific error message and solution provided above
- Run /shopify-diagnose again to verify the fix
- If issues persist, check your store's API token hasn't been revoked in Shopify admin

## Verbose Mode

For detailed debugging output, re-run with verbose flag for full response bodies and additional diagnostics.
