---
description: Validate Shopify code (GraphQL, Liquid, extensions)
argument-hint: [file or code to validate]
---

Validate the following Shopify code: $ARGUMENTS

Determine the code type (GraphQL query, Liquid template, extension config, or Function) and validate accordingly:

**GraphQL**: Check field names, argument types, and variable definitions against the Admin API or Storefront API schema. Flag deprecated fields. Verify pagination patterns use cursor-based approach.

**Liquid**: Check for valid tags, filters, and objects. Verify section schema JSON is valid. Flag deprecated tags or filters. Check for performance issues (nested loops, excessive API calls).

**Extensions (TOML)**: Verify targeting is valid, API version is current, and required fields are present.

**Functions**: Verify input query matches the function API, check output structure matches expected schema, flag performance concerns.

Use the shopify-dev-mcp tools to validate against live schemas when available. Present issues grouped by severity (Error, Warning, Info) with specific line references and suggested fixes.
