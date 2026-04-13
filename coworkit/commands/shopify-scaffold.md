---
description: Generate Shopify app, extension, or function scaffolding
allowed-tools: Write, Bash
argument-hint: [type: app|extension|function] [name]
---

Generate scaffolding for a Shopify project based on: $ARGUMENTS

Determine the type and create the appropriate file structure:

**App** (Remix-based):
- Generate `shopify.app.toml` with app configuration
- Create route structure for embedded app (Remix conventions)
- Set up Polaris provider and AppBridge
- Include common pages: index, products, settings

**Extension** (UI extension):
- Generate `shopify.extension.toml` with correct targeting
- Create entry component with appropriate UI extension imports
- Include schema for extension settings
- Set up the correct target based on surface (admin, checkout, customer account)

**Function** (server-side logic):
- Generate `shopify.extension.toml` for function type
- Create input.graphql with appropriate query
- Create run.js (or run.rs) with function skeleton
- Include test scaffolding with sample input

Always use the latest stable API version. Include comments explaining each section. After generating, explain what was created and the next steps to get it running.
