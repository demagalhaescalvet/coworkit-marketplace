---
name: shopify-custom-data
description: Triggers on "custom data", "metafield", "metaobject", "store custom attributes", "extend Shopify data". Learn how to model and store custom data using Metafields and Metaobjects in Shopify.
version: 0.1.0
---

# Shopify Custom Data: Metafields and Metaobjects

Custom data extends Shopify's built-in resources with your app-specific information. Use Metafields for simple key-value storage and Metaobjects for complex, structured data with their own lifecycle.

## Live Custom Data Tools (MCP)

When the Coworkit MCP server is connected, you can **read and write custom data directly** on the live store:

| Tool | Description |
|------|-------------|
| `shopify_get_metafield_definitions` | List metafield definitions by owner type (PRODUCT, CUSTOMER, ORDER, etc.) |
| `shopify_get_metafields` | Read metafield values for any resource by GID |
| `shopify_set_metafield` | Create or update metafield values (batch up to 25) |
| `shopify_get_metaobject_definitions` | List all metaobject type schemas in the store |
| `shopify_get_metaobjects` | List metaobject instances by type handle |

### Quick Start
1. **Discover schema** → `shopify_get_metafield_definitions` with `owner_type: "PRODUCT"` to see what custom fields exist
2. **Read values** → `shopify_get_metafields` with a product GID to see actual data
3. **Write values** → `shopify_set_metafield` to create or update values

## Three-Step Workflow

### Step 1: Define Your Custom Data

Define custom data in `shopify.app.toml` using the `$app` namespace. The `$app` namespace is app-specific and private to your application.

```toml
# Simple metafield definitions
[[metafields]]
namespace = "$app"
key = "product_rating"
description = "Average product rating from external source"
type = "number_decimal"
owner_type = "PRODUCT"

[[metafields]]
namespace = "$app"
key = "wholesale_price"
description = "Wholesale pricing for B2B customers"
type = "money"
owner_type = "PRODUCT_VARIANT"

[[metafields]]
namespace = "$app"
key = "loyalty_points"
description = "Loyalty points balance for customer"
type = "number_integer"
owner_type = "CUSTOMER"

[[metafields]]
namespace = "$app"
key = "custom_shipping_info"
description = "Custom shipping requirements"
type = "json"
owner_type = "ORDER"

# Metaobject definitions
[[metaobjects]]
name = "Product Review"
key = "product_review"
fields = [
  { name = "reviewer_name", type = "single_line_text_field" },
  { name = "review_text", type = "multi_line_text_field" },
  { name = "rating", type = "number_integer" },
  { name = "verified_purchase", type = "boolean" },
  { name = "review_date", type = "date_time" }
]

[[metaobjects]]
name = "Sustainability Info"
key = "sustainability"
fields = [
  { name = "carbon_offset_grams", type = "number_integer" },
  { name = "recyclable_packaging", type = "boolean" },
  { name = "certification_name", type = "single_line_text_field" },
  { name = "certification_url", type = "url" }
]
```

### Step 2: Write (Set) Custom Data

Use `metafieldsSet` mutation to create or update metafields. The owner ID determines which resource the data attaches to.

```graphql
mutation SetProductMetafields($ownerId: ID!, $metafields: [MetafieldsSetInput!]!) {
  metafieldsSet(ownerId: $ownerId, metafields: $metafields) {
    metafields {
      id
      namespace
      key
      value
      type
    }
    userErrors {
      field
      message
      code
    }
  }
}
```

Variables:
```json
{
  "ownerId": "gid://shopify/Product/123",
  "metafields": [
    {
      "namespace": "$app",
      "key": "product_rating",
      "type": "number_decimal",
      "value": "4.5"
    },
    {
      "namespace": "$app",
      "key": "wholesale_price",
      "type": "money",
      "value": "{\"amount\":\"15.00\",\"currencyCode\":\"USD\"}"
    }
  ]
}
```

For complex data, use JSON type with stringified objects:

```json
{
  "ownerId": "gid://shopify/Order/456",
  "metafields": [
    {
      "namespace": "$app",
      "key": "custom_shipping_info",
      "type": "json",
      "value": "{\"carrier\":\"FedEx\",\"tracking_required\":true,\"special_handling\":\"fragile\"}"
    }
  ]
}
```

Create Metaobject entries using `metaobjectUpsert`:

```graphql
mutation UpsertSustainabilityInfo($input: MetaobjectInput!) {
  metaobjectUpsert(input: $input) {
    metaobject {
      id
      type
      fields {
        key
        value
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
    "type": "sustainability",
    "fields": [
      { "key": "carbon_offset_grams", "value": "500" },
      { "key": "recyclable_packaging", "value": "true" },
      { "key": "certification_name", "value": "Carbon Trust Certified" },
      { "key": "certification_url", "value": "https://example.com/cert" }
    ]
  }
}
```

### Step 3: Read Custom Data

Query metafields on any resource:

```graphql
query GetProductMetafields($id: ID!) {
  product(id: $id) {
    id
    title
    metafields(namespace: "$app", first: 10) {
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

Query metaobjects by type:

```graphql
query GetSustainabilityData {
  metaobjects(type: "sustainability", first: 10) {
    edges {
      node {
        id
        type
        fields {
          key
          value
        }
      }
    }
  }
}
```

## Supported Data Types

| Type | Use Case | Example |
|------|----------|---------|
| `single_line_text_field` | Short text, codes, tags | SKU, category |
| `multi_line_text_field` | Long text, descriptions | Reviews, notes |
| `number_integer` | Whole numbers | Ratings, counts, inventory |
| `number_decimal` | Decimal values | Prices, weights, ratings |
| `boolean` | True/false flags | Feature toggles |
| `date` | Dates only (YYYY-MM-DD) | Launch dates |
| `date_time` | Dates with time (ISO 8601) | Timestamps |
| `url` | URLs | Links to resources |
| `json` | Structured objects | Complex configurations |
| `money` | Currency amounts | Prices, costs |
| `file` | File references | Uploads, documents |
| `rich_text_field` | Formatted text | Marketing copy |
| `color` | Color values (hex) | Brand colors |
| `list` | Collections of values | Tags, categories |

## Owner Types

Attach custom data to different resource types:

| Owner Type | Use Case | Example |
|-----------|----------|---------|
| `PRODUCT` | Product-level data | Ratings, certifications |
| `PRODUCT_VARIANT` | Variant-specific data | SKU-specific costs |
| `ORDER` | Order-level data | Special instructions |
| `ORDER_LINE_ITEM` | Item-specific data | Gift message, customization |
| `CUSTOMER` | Customer profile data | Loyalty points, preferences |
| `SHOP` | Store-wide settings | Global preferences |
| `COLLECTION` | Collection data | Custom banners, rules |
| `DRAFT_ORDER` | Draft order data | Internal notes |

## Admin API vs Storefront API Access

### Admin API: Full Control

Access all metafields and metaobjects in your app backend:

```graphql
query {
  product(id: "gid://shopify/Product/123") {
    metafields(namespace: "$app", first: 10) {
      edges {
        node {
          key
          value
          type
        }
      }
    }
  }
}
```

Include the `read_products` scope in `shopify.app.toml`.

### Storefront API: Public-Only Data

Only expose metafields marked for storefront visibility. Define a public namespace:

```toml
[[metafields]]
namespace = "custom.public"
key = "sustainability_badges"
type = "json"
owner_type = "PRODUCT"
visibility = "STOREFRONT"
```

Query on the Storefront API:

```graphql
query {
  product(id: "gid://shopify/Product/123") {
    metafields(namespace: "custom.public", first: 5) {
      edges {
        node {
          key
          value
        }
      }
    }
  }
}
```

**Note:** The `$app` namespace is always private to the Admin API. Only expose data intentionally.

## Validation and Best Practices

### Type Validation

Shopify validates types automatically. This mutation will fail:

```graphql
mutation {
  metafieldsSet(
    ownerId: "gid://shopify/Product/123"
    metafields: [
      {
        namespace: "$app"
        key: "product_rating"
        type: "number_decimal"
        value: "not a number"
      }
    ]
  ) {
    metafields { id }
    userErrors { message }
  }
}
```

### JSON Validation

For JSON types, pass valid JSON strings:

```graphql
mutation {
  metafieldsSet(
    ownerId: "gid://shopify/Product/123"
    metafields: [
      {
        namespace: "$app"
        key: "config"
        type: "json"
        value: "{\"key\":\"value\"}"
      }
    ]
  ) {
    metafields { id }
    userErrors { message }
  }
}
```

### Storage Limits

- Each metafield value is limited to 5MB
- Maximum 100 metafields per resource (across all namespaces)
- Metaobjects have no field limits

### Naming Conventions

Use snake_case for keys:

```toml
[[metafields]]
namespace = "$app"
key = "product_rating"
key = "is_featured"
```

## Querying Multiple Resources with Metafields

Use fragments to fetch metafields with products efficiently:

```graphql
fragment ProductWithMetafields on Product {
  id
  title
  metafields(namespace: "$app", first: 10) {
    edges {
      node {
        key
        value
        type
      }
    }
  }
}

query {
  products(first: 10) {
    edges {
      node {
        ...ProductWithMetafields
      }
    }
  }
}
```

## Metaobject Relationships

Link metaobjects to products or other resources:

```toml
[[metaobjects]]
name = "Product Review"
key = "product_review"
fields = [
  { name = "product", type = "product_reference" },
  { name = "reviewer_name", type = "single_line_text_field" },
  { name = "rating", type = "number_integer" }
]
```

Create with a product reference:

```graphql
mutation {
  metaobjectUpsert(
    input: {
      type: "product_review"
      fields: [
        { key: "product", value: "gid://shopify/Product/123" },
        { key: "reviewer_name", value: "Jane Doe" },
        { key: "rating", value: "5" }
      ]
    }
  ) {
    metaobject {
      id
      fields { key value }
    }
  }
}
```

## Common Patterns

### Storing External Ratings

```toml
[[metafields]]
namespace = "$app"
key = "external_rating"
type = "number_decimal"
owner_type = "PRODUCT"

[[metafields]]
namespace = "$app"
key = "rating_source"
type = "single_line_text_field"
owner_type = "PRODUCT"
```

### B2B Wholesale Pricing

```toml
[[metafields]]
namespace = "$app"
key = "wholesale_price"
type = "money"
owner_type = "PRODUCT_VARIANT"

[[metafields]]
namespace = "$app"
key = "minimum_quantity"
type = "number_integer"
owner_type = "PRODUCT_VARIANT"
```

### Loyalty Programs

```toml
[[metafields]]
namespace = "$app"
key = "loyalty_tier"
type = "single_line_text_field"
owner_type = "CUSTOMER"

[[metafields]]
namespace = "$app"
key = "loyalty_points"
type = "number_integer"
owner_type = "CUSTOMER"
```

## Error Handling

Always check `userErrors` in responses:

```javascript
const response = await fetch(endpoint, {
  method: 'POST',
  headers: { ... },
  body: JSON.stringify({ query, variables })
});

const json = await response.json();
if (json.data?.metafieldsSet?.userErrors?.length > 0) {
  const errors = json.data.metafieldsSet.userErrors;
  console.error('Metafield errors:', errors.map(e => e.message));
}
```

## Next Steps

- See `custom-data-patterns.md` for GraphQL CRUD examples and advanced patterns
- Explore [Shopify Metafields documentation](https://shopify.dev/api/admin-graphql/2024-10/objects/metafield)
- Design your data model before defining metafields
- Consider Metaobjects for complex, frequently-queried data structures
