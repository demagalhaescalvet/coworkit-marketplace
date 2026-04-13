#!/bin/bash
# Coworkit SessionStart Hook
# Loads store context into the conversation when a new Cowork session begins.
# This gives Claude immediate awareness of the connected store.

CONFIG_FILE="$HOME/.coworkit/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "⚠️  Coworkit is not connected to a Shopify store."
  echo "Run /shopify-auth-setup or visit the Coworkit app in your Shopify admin to set up the connection."
  exit 0
fi

# Read config once, let python emit shell-safe KEY=VALUE lines.
# Supports both the new connection-key flow and the legacy direct-token flow.
eval "$(python3 - "$CONFIG_FILE" <<'PY'
import json, os, shlex, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    sys.stderr.write(f"Config parse error: {e}\n")
    raise SystemExit(0)

def emit(k, v):
    print(f"{k}={shlex.quote(str(v))}")

emit("STORE", d.get("store", "unknown"))
emit("ROLE", d.get("userRole", "unknown"))
emit("STAFF", d.get("staffName", ""))
emit("SCOPES", d.get("scopes", ""))
if d.get("connection_key"):
    emit("AUTH_MODE", "proxy")
    emit("KEY_PREFIX", d["connection_key"][:12])
elif d.get("token"):
    emit("AUTH_MODE", "direct")
    emit("KEY_PREFIX", "")
else:
    emit("AUTH_MODE", "unknown")
    emit("KEY_PREFIX", "")
PY
)"

echo "🏪 Coworkit connected to **${STORE}**"
echo "   Role: ${ROLE} ${STAFF:+($STAFF)}"
if [ "$AUTH_MODE" = "proxy" ]; then
  echo "   Auth: connection key (${KEY_PREFIX}…) via Admin API proxy"
elif [ "$AUTH_MODE" = "direct" ]; then
  echo "   Auth: direct Admin API token (legacy custom app)"
else
  echo "   Auth: ⚠️  unknown — run /shopify-auth-setup to fix"
fi
echo "   MCP: shopify-mcp-server (24 tools, 3 resources)"
echo "   Skills: 16 | Commands: 7"
echo ""
echo "Available tool categories:"
echo "  • Store: shopify_get_shop, shopify_graphql"
echo "  • Products: shopify_get_products, shopify_get_product"
echo "  • Orders: shopify_get_orders, shopify_get_order, shopify_create_fulfillment"
echo "  • Customers: shopify_get_customers"
echo "  • Inventory: shopify_get_inventory, shopify_update_inventory"
echo "  • Discounts: shopify_get_discounts, shopify_create_discount_code, shopify_create_automatic_discount"
echo "  • Draft Orders: shopify_get_draft_orders, shopify_create_draft_order, shopify_complete_draft_order"
echo "  • Collections: shopify_get_collections"
echo "  • Theme: shopify_get_themes, shopify_get_theme_files, shopify_read_theme_file, shopify_write_theme_file"
echo "  • Custom Data: shopify_get_metafields, shopify_set_metafield, shopify_get_metaobjects"
echo "  • Storefront API: shopify_storefront_graphql, shopify_storefront_products"
echo "  • Translations: shopify_get_translations, shopify_set_translations"
echo "  • Files: shopify_get_files, shopify_upload_file"
echo "  • Pages & Blog: shopify_get_pages, shopify_create_page, shopify_get_blogs, shopify_create_article"
echo "  • Webhooks: shopify_get_webhooks, shopify_create_webhook"
echo "  • Bulk: shopify_bulk_query, shopify_bulk_status"
