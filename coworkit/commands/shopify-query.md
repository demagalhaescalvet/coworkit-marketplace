---
description: Build and explain a Shopify GraphQL query or mutation
argument-hint: [describe what you want to query]
allowed-tools: Bash
---

Build a Shopify GraphQL Admin API query or mutation based on: $ARGUMENTS

Follow these steps:

1. Determine whether this is a query (read) or mutation (write)
2. Identify the correct resource and fields from the Admin API schema
3. Write the complete GraphQL operation with proper variables
4. Include pagination (cursor-based) if the query returns a list
5. For mutations, always include the `userErrors` field
6. Explain the query structure and any important considerations (rate limits, required scopes)

Use the shopify-dev-mcp tools to validate the query against current API schemas when available.

Output the query in a code block, followed by example variables if applicable, and a brief explanation of what it does.

## Live Execution

After building the query, ask the user if they want to run it against their store. If yes:

1. Read the store credentials:
```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
```

2. If config file doesn't exist, tell the user to run `/shopify-connect` first.

3. Execute the query via direct API call:
```bash
curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "<the-query>", "variables": {<variables-if-any>}}' | python3 -m json.tool
```

4. For mutations: **always confirm with the user before executing** — show them exactly what will change.
5. Present results in a clean, readable format (tables for lists, summaries for single resources).
6. Check for `userErrors` in mutation responses — a 200 HTTP status does not mean the operation succeeded.
