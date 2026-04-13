# Coworkit Plugin Marketplace

Plugins for [Claude Cowork](https://claude.com/product/cowork) that connect your Shopify store to AI.

## Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| **[coworkit](./coworkit)** | Build Shopify apps and manage stores directly from Cowork. 40+ MCP tools, SessionStart hook support, live Admin API access, plus 16 skills for Admin API, Functions, Liquid, store operations, and advanced development. Secure GraphQL variable handling and comprehensive error diagnostics. | 6.0.0 |

## Features

- **40+ MCP Tools**: Complete Shopify API coverage with validated queries and mutations
- **16 Skills**: Admin API, Functions, Liquid, Store Management, Customer Account, Checkout Extensions, Polaris Components, Payments Apps, Partner API, Custom Data, Hydrogen, Storefront GraphQL, POS UI, and more
- **7 Commands**: shopify-query, shopify-store, shopify-setup, shopify-connect, shopify-validate, shopify-auth-setup, shopify-scaffold
- **GraphQL Security**: Safe variable handling with built-in injection prevention
- **SessionStart Hook**: Initialize Cowork context with environment variables and configuration
- **Advanced Diagnostics**: Comprehensive error reporting and connection troubleshooting

## Installation

1. Open **Claude desktop app**
2. Switch to **Cowork** mode
3. Go to **Plugins** in the sidebar
4. Click **Add marketplace** and enter: `github:demagalhaescalvet/coworkit-marketplace`
5. Install the **Coworkit** plugin

## Skills

| Skill | Purpose |
|-------|---------|
| **shopify-admin** | Query and mutate Shopify Admin API with GraphQL |
| **shopify-functions** | Build custom Functions for discounts, shipping, payments, cart transforms |
| **shopify-liquid** | Develop Shopify theme templates with Liquid |
| **shopify-store-management** | Manage products, orders, customers, inventory |
| **shopify-dev** | App development fundamentals and best practices |
| **shopify-hydrogen** | Build headless storefronts with Hydrogen |
| **shopify-storefront-graphql** | Query storefront data for custom experiences |
| **shopify-polaris-admin-extensions** | Build admin UI extensions with Polaris |
| **shopify-polaris-app-home** | Create app home pages with Polaris components |
| **shopify-polaris-checkout-extensions** | Customize checkout with Polaris checkout extensions |
| **shopify-polaris-customer-account-extensions** | Build customer account extensions |
| **shopify-pos-ui** | Develop POS UI extensions |
| **shopify-payments-apps** | Integrate payment methods and solutions |
| **shopify-partner** | Access Partner API for app and store management |
| **shopify-custom-data** | Work with Shopify metafields and custom data |
| **shopify-customer** | Access Customer Account API for customer data |

## Requirements

- A Shopify store with the [Coworkit app](https://lestcoworkit.com) installed
- Claude desktop app with Cowork mode
