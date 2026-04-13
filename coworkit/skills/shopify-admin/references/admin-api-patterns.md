# Shopify Admin API: Advanced Patterns

## Input Objects and Complex Mutations

### Structured Product Updates

Use input objects for complex nested data:

```graphql
mutation UpdateProductWithVariants($input: ProductInput!) {
  productUpdate(input: $input) {
    product {
      id
      title
      variants(first: 10) {
        edges {
          node {
            id
            title
            price
            sku
            image {
              id
              url
            }
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

Variables:
```json
{
  "input": {
    "id": "gid://shopify/Product/123",
    "title": "Updated Product",
    "variants": [
      {
        "id": "gid://shopify/ProductVariant/456",
        "title": "Red - Small",
        "price": "29.99",
        "sku": "RED-SM"
      }
    ]
  }
}
```

## Staged Uploads for File Handling

Upload images and files using staged uploads:

```graphql
mutation {
  stagedUploadsCreate(
    input: {
      resource: PRODUCT_IMAGE
      filename: "product.jpg"
      mimeType: "image/jpeg"
      httpMethod: POST
    }
  ) {
    stagedTargets {
      url
      resourceUrl
      parameters {
        name
        value
      }
    }
    userErrors {
      message
    }
  }
}
```

Use the returned `url` and `parameters` to upload the file via POST:

```javascript
const formData = new FormData();
formData.append('file', imageBlob);
stagedTargets.parameters.forEach(param => {
  formData.append(param.name, param.value);
});

const uploadResponse = await fetch(stagedTargets.url, {
  method: 'POST',
  body: formData,
});

// Then create product with the resourceUrl
const createProductResponse = await fetch(
  `https://${shop}/admin/api/2025-04/graphql.json`,
  {
    method: 'POST',
    headers: {
      'X-Shopify-Access-Token': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: `
        mutation {
          productCreate(
            input: {
              title: "My Product"
              images: [
                {
                  src: "${stagedTargets.resourceUrl}"
                }
              ]
            }
          ) {
            product { id }
          }
        }
      `,
    }),
  }
);
```

## Access Scopes Reference

Apps declare required scopes in `shopify.app.toml`. Include only necessary scopes:

| Scope | Purpose |
|-------|---------|
| `read_products` | Read product data |
| `write_products` | Create and modify products |
| `read_orders` | Read order data |
| `write_orders` | Create and modify orders |
| `read_customers` | Read customer data |
| `write_customers` | Create and modify customers |
| `read_inventory` | Read inventory and locations |
| `write_inventory` | Adjust inventory levels |
| `read_discounts` | Read discount codes |
| `write_discounts` | Create and modify discounts |
| `read_fulfillments` | Read fulfillment data |
| `write_fulfillments` | Create and modify fulfillments |
| `read_analytics` | Access analytics data |
| `read_checkouts` | Read checkout data |

Example `shopify.app.toml`:
```toml
scopes = "write_products,read_orders,write_orders,read_inventory"
```

## Metafields: Advanced Usage

### Define Metafield Types in TOML

In `shopify.app.toml`:
```toml
[[metafields]]
namespace = "inventory_management"
key = "warehouse_location"
description = "Warehouse location for product"
type = "single_line_text_field"
owner_type = "PRODUCT"

[[metafields]]
namespace = "inventory_management"
key = "reorder_level"
description = "Reorder threshold quantity"
type = "number_integer"
owner_type = "PRODUCT"
```

### Query and Update Metafields

```graphql
query {
  product(id: "gid://shopify/Product/123") {
    metafields(
      namespace: "inventory_management"
      first: 10
    ) {
      edges {
        node {
          id
          namespace
          key
          value
          type
        }
      }
    }
  }
}
```

```graphql
mutation {
  metafieldsSet(
    ownerId: "gid://shopify/Product/123"
    metafields: [
      {
        namespace: "inventory_management"
        key: "warehouse_location"
        type: "single_line_text_field"
        value: "Warehouse A - Row 5"
      },
      {
        namespace: "inventory_management"
        key: "reorder_level"
        type: "number_integer"
        value: "50"
      }
    ]
  ) {
    metafields {
      id
      namespace
      key
      value
    }
    userErrors {
      field
      message
    }
  }
}
```

## Webhook Registration via API

### Create Webhooks Dynamically

```graphql
mutation {
  webhookSubscriptionCreate(
    topic: PRODUCTS_UPDATE
    webhookSubscription: {
      callbackUrl: "https://example.com/webhooks/products/update"
      format: JSON
      includeFields: ["id", "title", "vendor"]
    }
  ) {
    webhookSubscription {
      id
      topic
      callbackUrl
      format
      includeFields
      createdAt
      updatedAt
    }
    userErrors {
      field
      message
    }
  }
}
```

### Register All Common Webhooks

```javascript
const webhooks = [
  { topic: 'PRODUCTS_CREATE', url: '/webhooks/products/create' },
  { topic: 'PRODUCTS_UPDATE', url: '/webhooks/products/update' },
  { topic: 'PRODUCTS_DELETE', url: '/webhooks/products/delete' },
  { topic: 'ORDERS_CREATE', url: '/webhooks/orders/create' },
  { topic: 'ORDERS_UPDATED', url: '/webhooks/orders/update' },
  { topic: 'FULFILLMENTS_UPDATE', url: '/webhooks/fulfillments/update' },
];

for (const webhook of webhooks) {
  // Create mutation for each topic
}
```

### Webhook TOML Configuration

In `shopify.app.toml`:
```toml
[[webhooks]]
events = ["products/update", "products/delete"]
uri = "api/webhooks/products"

[[webhooks]]
events = ["orders/create", "orders/updated"]
uri = "api/webhooks/orders"

[[webhooks]]
events = ["fulfillments/update"]
uri = "api/webhooks/fulfillments"
```

## Rate Limit Management

### Understanding Rate Limits

- **Leaky bucket algorithm**: 40 points per second
- **Query cost**: Simple fields = 1 point, complex fields/nested = higher
- **Bulk operations**: Don't consume rate limit but have separate limits

### Monitor Rate Limits

Every response includes:
```
X-Shopify-Shop-Api-Call-Limit: {current}/{max}
```

### Implement Rate Limit Handling

```javascript
async function queryWithRateLimit(query, variables) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { ... },
    body: JSON.stringify({ query, variables })
  });

  const limitHeader = response.headers.get('X-Shopify-Shop-Api-Call-Limit');
  const [current, max] = limitHeader.split('/').map(Number);
  
  if (current > max * 0.8) {
    // Back off if approaching limit
    await new Promise(r => setTimeout(r, 5000));
  }
  
  return response.json();
}
```

### Use Bulk Operations for Large Datasets

Bulk operations don't consume rate limits and are optimized for large queries:

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
            variants {
              edges {
                node {
                  id
                  sku
                  price
                }
              }
            }
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
  }
}
```

## App Subscriptions and Billing

### Create a Subscription Plan

In `shopify.app.toml`:
```toml
[[billing_config.monthly_recurring_application_charge]]
name = "Pro Plan"
price = "9.99"
terms = "monthly"
test = true

[[billing_config.monthly_recurring_application_charge]]
name = "Enterprise Plan"
price = "99.99"
terms = "monthly"
test = true
```

### Request Billing via API

```graphql
mutation {
  appSubscriptionCreate(
    name: "Pro Plan"
    returnUrl: "https://example.com/settings"
    lineItems: [
      {
        plan: {
          appRecurringPricingDetails: {
            interval: EVERY_30_DAYS
            chargeAmount: "9.99"
          }
        }
      }
    ]
  ) {
    appSubscription {
      id
      name
      status
      returnUrl
      createdAt
    }
    confirmationUrl
    userErrors {
      field
      message
    }
  }
}
```

### Query Current Subscriptions

```graphql
{
  appInstallation {
    activeSubscriptions {
      name
      status
      returnUrl
      createdAt
    }
  }
}
```

### Handle Subscription Webhooks

Webhook topics:
- `app_subscriptions/update` - Status changes
- `app_subscriptions/delete` - Cancellation

Typical flow:
1. User clicks upgrade button
2. Redirect to confirmation URL
3. User authorizes billing
4. Receive webhook with new status
5. Enable premium features

## Testing and Development

### Use Test Mode

In `shopify.app.toml`:
```toml
[[billing_config.monthly_recurring_application_charge]]
name = "Test Plan"
price = "0.00"
test = true
```

### Mock API Responses

For testing without live API calls:
```javascript
const mockProduct = {
  product: {
    id: 'gid://shopify/Product/123',
    title: 'Test Product',
    vendor: 'Test Vendor',
  }
};

// Use in tests
```
