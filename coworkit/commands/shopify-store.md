---
description: Manage Shopify store resources (products, orders, etc.)
argument-hint: [action: create/update/list/delete] [resource]
allowed-tools: Bash
---

Manage Shopify store resources based on: $ARGUMENTS

Parse the requested action and resource, then:

1. Build the appropriate GraphQL Admin API query or mutation
2. Include all relevant fields for the operation
3. Handle pagination for list operations
4. Include proper error handling (userErrors)
5. Determine the required access scopes for the operation

For bulk operations (importing many products, updating many variants), recommend the Bulk Operations API instead of individual mutations.

Always confirm destructive operations (delete, archive) before proceeding. For create/update operations, show the complete mutation before executing.

## Live Execution

This command executes operations directly against the user's connected store:

1. Read the store credentials:
```bash
STORE=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['store'])")
TOKEN=$(cat ~/.coworkit/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
```

2. If config file doesn't exist, tell the user to run `/shopify-connect` first.

3. Execute via direct API call:
```bash
curl -s -X POST "https://${STORE}/admin/api/2025-04/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Access-Token: ${TOKEN}" \
  -d '{"query": "<query-or-mutation>", "variables": {<variables>}}' | python3 -m json.tool
```

4. **Always confirm mutations with the user before executing** — show them exactly what will change
5. Present results in a clean, readable format (tables for lists, summaries for single resources)
6. Check `userErrors` in mutation responses — show actionable error messages if present
7. If the operation fails with 403, explain which scope is missing and how to add it in the Custom App settings
