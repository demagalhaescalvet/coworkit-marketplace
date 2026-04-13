# Shopify Toolkit

Build Shopify apps and manage stores directly from Cowork. Includes skills for every major Shopify surface, slash commands for common workflows, the Shopify Dev MCP server for documentation/schemas, and live Admin API access via the Shopify Toolkit Auth app.

## Requirements

- **Node.js 18+** (required by the MCP servers)

## Getting Started

1. Install the `.plugin` file in Cowork
2. Run `/shopify-auth-setup` to connect your store via the Toolkit Auth app
3. Start managing your store: "show my products", "check recent orders", etc.
4. Or jump straight to building with `/shopify-query` or `/shopify-scaffold`

## Components

### Skills (8)

| Skill | Triggers on |
|-------|-------------|
| **shopify-admin** | GraphQL Admin API queries, mutations, schemas, pagination, bulk operations |
| **shopify-admin-execution** | Executing queries against a live store, fetching real data |
| **shopify-store-api** | Live store queries via MCP tools (products, orders, customers, inventory) |
| **shopify-store-management** | Products, orders, customers, inventory, collections, fulfillments |
| **shopify-liquid** | Liquid templates, theme customization, sections, snippets, filters |
| **shopify-polaris** | Polaris components, UI extensions (admin, checkout, customer account), App Bridge |
| **shopify-hydrogen** | Hydrogen framework, Storefront API, Remix routes, Oxygen deployment |
| **shopify-functions** | Shopify Functions (discounts, shipping, payments, cart transforms) |

### Commands (7)

| Command | Description |
|---------|-------------|
| `/shopify-auth-setup` | Connect your store via the Toolkit Auth app |
| `/shopify-setup` | Guided onboarding: checks prerequisites, connects your store, runs a live demo |
| `/shopify-connect` | Connect to a store or switch stores |
| `/shopify-query` | Build GraphQL queries and execute against your store |
| `/shopify-validate` | Validate Liquid, GraphQL, extensions, or Functions code |
| `/shopify-store` | Manage store resources with live execution (products, orders, etc.) |
| `/shopify-scaffold` | Generate scaffolding for apps, extensions, or functions |

### MCP Servers (2)

| Server | Purpose |
|--------|---------|
| **shopify-dev-mcp** | Search Shopify docs, query GraphQL schemas, validate code |
| **shopify-admin-api** | Live Admin API access (10 tools: products, orders, customers, inventory, collections, custom GraphQL) |

### Hooks

- **SessionStart**: Detects first-time users and offers onboarding automatically

## Security

- Your API token is stored locally with restricted permissions (`chmod 600`)
- Tokens are never logged or exposed in chat
- Mutations always require user confirmation before executing
