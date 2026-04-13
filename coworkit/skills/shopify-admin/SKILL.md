---
name: shopify-admin
description: Triggers on "query Shopify API", "build a GraphQL query", "fetch products from Shopify", "create a mutation", "use the Admin API", "paginate results". Use the Shopify GraphQL Admin API to query and mutate store data, including products, orders, customers, and more.
version: 0.1.0
---

# Shopify GraphQL Admin API

The Shopify GraphQL Admin API is the primary interface for building Shopify apps and integrations. This skill covers querying and mutating store data, handling pagination, bulk operations, and common patterns.

## API Basics

### Endpoint and Versioning

The Admin API uses versioned endpoints:
```
https://{shop}.myshopify.com/admin/api/{version}/graphql.json
```

Use stable versions like `2024-10` or `2024-07`. Check [Shopify API versioning](https://shopify.dev/api/admin-rest/2024-10) for the latest stable version.

### Authentication

Authenticate using an access token (from a custom app or public app):
```javascript
const response = await fetch(
  `https://${shopName}/admin/api/2024-10/graphql.json`,
  {
    method: 'POST',
    headers: {
      'X-Shopify-Access-Token': accessToken,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query }),
  }
);
```

## Query Structure and Connections

### Basic Query Pattern

Use the `connections` pattern for paginated results:
```graphql
{
  products(first: 10, after: "cursor") {
    pageInfo {
      hasNextPage
      hasPreviousPage
    }
    edges {
      cursor
      node {
        id
        title
        handle
        vendor
      }
    }
  }
}
```

### Global IDs

Resources use global IDs (base64-encoded). Always fetch the `id` field:
```graphql
{
  products(first: 1) {
    edges {
      node {
        id  # Global ID: gid://shopify/Product/123456789
        legacyResourceId  # Numeric ID: 123456789
      }
    }
  }
}
```

## Cursor-Based Pagination

Shopify uses cursor-based pagination for efficient handling of large datasets.

### Forward Pagination

```graphql
{
  products(first: 10, after: "eyJkaXJlY3Rpb24iOiJuZXh0IiwibGFzdElkIjoxMjM0LCJsYXN0VmFsdWUiOiIyMDI0LTAxLTAxIn0=") {
    pageInfo {
      hasNextPage
      hasPreviousPage
      endCursor
      startCursor
    }
    edges {
      cursor
      node {
        id
        title
      }
    }
  }
}
```

### Backward Pagination

```graphql
{
  products(last: 10, before: "cursor") {
    pageInfo {
      hasNextPage
      hasPreviousPage
    }
    edges {
      node {
        id
        title
      }
    }
  }
}
```

## Bulk Operations

For processing large datasets, use the Bulk Operations API to avoid rate limits:

```graphql
mutation {
  bulkOperationRunQuery(
    query: """
      {
        products {
          edges {
            node {
              id
              title
              vendor
            }
          }
        }
      }
    """
  ) {
    bulkOperation {
      id
      status
      objectCount
    }
    userErrors {
      field
      message
    }
  }
}
```

Poll for completion:
```graphql
{
  node(id: "gid://shopify/BulkOperation/123") {
    ... on BulkOperation {
      id
      status  # CREATED, RUNNING, COMPLETED, FAILED, CANCELED
      objectCount
      fileSize
      url
    }
  }
}
```

Download the JSONL file from the URL and process results.

## Common Patterns

### Metafields

Store custom data on resources:
```graphql
mutation {
  productUpdate(
    input: {
      id: "gid://shopify/Product/123"
      metafields: [
        {
          namespace: "custom"
          key: "color_family"
          value: "blue"
          type: "single_line_text_field"
        }
      ]
    }
  ) {
    product {
      id
      metafields(first: 10) {
        edges {
          node {
            namespace
            key
            value
          }
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

### Webhooks

Register webhooks via API:
```graphql
mutation {
  webhookSubscriptionCreate(
    topic: PRODUCTS_UPDATE
    webhookSubscription: {
      callbackUrl: "https://example.com/webhooks/products"
      format: JSON
    }
  ) {
    webhookSubscription {
      id
      topic
      callbackUrl
      format
    }
    userErrors {
      field
      message
    }
  }
}
```

### Rate Limits

The Admin API uses a leaky bucket algorithm. Check the response headers:
```
X-Shopify-Shop-Api-Call-Limit: 32/40
```

Wait if approaching the limit. The `throttleStatus` field in mutations shows your current rate:
```graphql
mutation {
  productUpdate(input: {...}) {
    product { id }
    userErrors { message }
  }
}
```

## Key Resources

| Resource | Common Operations | Notes |
|----------|-------------------|-------|
| Products | List, get, create, update variants, manage images | Support metafields and custom attributes |
| Orders | List, get, fulfill, refund, add notes | Use ORDERS read scope |
| Customers | Search, get, create, add addresses | Search with prefix matching |
| Collections | List, create, add products | Smart collections defined by rules |
| Inventory | Adjust levels, query by location | Track across multiple locations |
| Fulfillments | Create, get, update tracking | Mark orders as fulfilled |
| Variants | Get, update, set prices | Manage SKUs and barcodes |
| Discounts | Create, list, apply codes | Basic and automatic discounts |

## Fragments for Reusable Queries

Define fragments to reduce repetition:

```graphql
fragment ProductFields on Product {
  id
  title
  handle
  vendor
  productType
  status
}

query {
  products(first: 10) {
    edges {
      node {
        ...ProductFields
        variants(first: 5) {
          edges {
            node {
              id
              title
              price
              sku
            }
          }
        }
      }
    }
  }
}
```

## Error Handling

Always check for `userErrors`:

```javascript
const json = await response.json();
if (json.errors) {
  console.error('GraphQL Errors:', json.errors);
}
if (json.data && json.data.productUpdate?.userErrors.length > 0) {
  console.error('User Errors:', json.data.productUpdate.userErrors);
}
```

## Next Steps

- See `admin-api-patterns.md` for advanced patterns like staged uploads, app subscriptions, and access scope management.
- Explore the [official Admin API docs](https://shopify.dev/api/admin-graphql/2024-10) for the complete schema.
- Use the [Shopify CLI](https://shopify.dev/docs/apps/tools/cli) to scaffold apps and test queries locally.
