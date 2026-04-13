---
description: Connect your Shopify store via the Toolkit Auth app
allowed-tools: Bash, Read, Write
---

Guide the user through connecting their Shopify store to Cowork using the Coworkit app.

## Step 1: Check Existing Connection

Run this to check if already connected:
```bash
if [ -f ~/.coworkit/config.json ]; then
  echo "CONNECTED"
  cat ~/.coworkit/config.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Store: {d[\"store\"]}'); print(f'Token: {d[\"token\"][:10]}...{d[\"token\"][-4:]}')"
else
  echo "NOT_CONNECTED"
fi
```

If already connected, tell the user their store is connected and show the store domain. Ask if they want to reconnect or switch stores.

If not connected, proceed to Step 2.

## Step 2: Guide Installation

Tell the user:

1. Go to the Coworkit app in your Shopify admin (Apps → Cowork Acceso, or install from the partner dashboard)
2. The app dashboard shows your store connection status and access token
3. Click **"Reveal"** to show your access token
4. Click **"Copy Setup Command"** to copy the one-liner configuration command
5. Paste the command in your terminal — it creates `~/.coworkit/config.json` with your store credentials

## Step 3: Verify Connection

After the user pastes the command, verify it worked:
```bash
if [ -f ~/.coworkit/config.json ]; then
  cat ~/.coworkit/config.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'✅ Connected to {d[\"store\"]}')"
else
  echo "❌ Config file not found. Please paste the setup command from the app."
fi
```

## Step 4: Test Live Connection

Run a quick test query using the MCP tool `shopify_get_shop` to confirm the API connection is working.

If it succeeds, congratulate the user. They can now use commands like "show my products", "check recent orders", etc.

If it fails with 401, the token may be expired — ask them to reinstall the app and get a new token.
