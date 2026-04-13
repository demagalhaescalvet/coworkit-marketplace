---
name: shopify-storefront-graphql
description: Triggers on "Storefront API", "custom storefront", "product queries", "collection queries", "cart mutations", "storefront GraphQL". Query and mutate the Storefront API to build custom storefronts with full data control.
version: 0.1.0
---

# Shopify Storefront API

The Storefront API is a public GraphQL API designed for custom storefronts, mobile apps, and any client-side application. It provides read access to product data and write access to cart operations, with no authentication required for public queries.

## API Basics

### Endpoint

```
https://{shop}.myshopify.com/api/{version}/graphql.json
```

Example:
```
https://my-store.myshopify.com/api/2024-01/graphql.json
```

### Authentication with Storefront Access Token

```javascript
const response = await fetch(
  'https://my-store.myshopify.com/api/2024-01/graphql.json',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': 'public_access_token',
    },
    body: JSON.stringify({query}),
  }
);
```

### Public vs Private Tokens

- **Public token**: Used for client-side queries (product browsing, cart operations)
- **Private token**: Only used server-side; provides additional scopes
- Most Storefront API queries use the public token

## Product Queries

### Get Single Product

```graphql
query GetProduct($handle: String!) {
  productByHandle(handle: $handle) {
    id
    title
    description
    handle
    vendor
    productType
    images(first: 10) {
      edges {
        node {
          id
          url
          altText
        }
      }
    }
    priceRange {
      minVariantPrice {
        amount
        currencyCode
      }
      maxVariantPrice {
        amount
        currencyCode
      }
    }
    variants(first: 10) {
      edges {
        node {
          id
          title
          availableForSale
          selectedOptions {
            name
            value
          }
          price {
            amount
            currencyCode
          }
          sku
          image {
            url
            altText
          }
        }
      }
    }
    options {
      id
      name
      values
    }
  }
}
```

### Get Product List

```graphql
query GetProducts($first: Int!, $after: String, $sortKey: ProductSortKeys) {
  products(
    first: $first
    after: $after
    sortKey: $sortKey
    reverse: false
  ) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        title
        handle
        description
        images(first: 3) {
          edges {
            node {
              url
              altText
            }
          }
        }
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
          maxVariantPrice {
            amount
            currencyCode
          }
        }
      }
    }
  }
}
```

### Get Product with Metafields

```graphql
query GetProductWithMetafields($handle: String!) {
  productByHandle(handle: $handle) {
    id
    title
    metafield(namespace: "custom", key: "featured") {
      value
    }
    metafields(namespace: "custom", first: 5) {
      edges {
        node {
          id
          key
          value
        }
      }
    }
  }
}
```

## Collection Queries

### Get Collections List

```graphql
query GetCollections($first: Int!, $after: String) {
  collections(first: $first, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        title
        handle
        description
        image {
          url
          altText
        }
      }
    }
  }
}
```

### Get Collection with Products

```graphql
query GetCollection($handle: String!, $first: Int!, $after: String) {
  collectionByHandle(handle: $handle) {
    id
    title
    description
    image {
      url
      altText
    }
    products(first: $first, after: $after) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          id
          title
          handle
          images(first: 1) {
            edges {
              node {
                url
              }
            }
          }
          priceRange {
            minVariantPrice {
              amount
            }
          }
        }
      }
    }
  }
}
```

## Search Queries

### Search Products

```graphql
query Search($query: String!, $first: Int!) {
  search(query: $query, first: $first, types: PRODUCT) {
    edges {
      node {
        ... on Product {
          id
          title
          handle
          images(first: 1) {
            edges {
              node {
                url
              }
            }
          }
          priceRange {
            minVariantPrice {
              amount
            }
          }
        }
      }
    }
  }
}
```

## Cart Operations

### Create Cart

```graphql
mutation CreateCart($input: CartInput!) {
  cartCreate(input: $input) {
    cart {
      id
      checkoutUrl
      lines(first: 10) {
        edges {
          node {
            id
            quantity
            merchandise {
              ... on ProductVariant {
                id
                title
              }
            }
          }
        }
      }
      cost {
        subtotalAmount {
          amount
          currencyCode
        }
        totalAmount {
          amount
          currencyCode
        }
      }
    }
  }
}
```

Variables:
```json
{
  "input": {
    "lines": [
      {
        "merchandiseId": "gid://shopify/ProductVariant/123",
        "quantity": 1
      }
    ]
  }
}
```

### Add to Cart

```graphql
mutation AddToCart($cartId: ID!, $lines: [CartLineInput!]!) {
  cartLinesAdd(cartId: $cartId, lines: $lines) {
    cart {
      id
      lines(first: 10) {
        edges {
          node {
            id
            quantity
            merchandise {
              ... on ProductVariant {
                id
                title
                product {
                  title
                }
              }
            }
            cost {
              totalAmount {
                amount
                currencyCode
              }
            }
          }
        }
      }
      cost {
        totalAmount {
          amount
          currencyCode
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

### Update Cart Line

```graphql
mutation UpdateCartLine($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
  cartLinesUpdate(cartId: $cartId, lines: $lines) {
    cart {
      id
      lines(first: 10) {
        edges {
          node {
            id
            quantity
          }
        }
      }
    }
    userErrors {
      message
    }
  }
}
```

Variables:
```json
{
  "cartId": "gid://shopify/Cart/abc123",
  "lines": [
    {
      "id": "gid://shopify/CartLine/def456",
      "quantity": 5
    }
  ]
}
```

### Remove from Cart

```graphql
mutation RemoveFromCart($cartId: ID!, $lineIds: [ID!]!) {
  cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
    cart {
      id
      lines(first: 10) {
        edges {
          node {
            id
          }
        }
      }
    }
    userErrors {
      message
    }
  }
}
```

### Get Cart

```graphql
query GetCart($cartId: ID!) {
  cart(id: $cartId) {
    id
    checkoutUrl
    lines(first: 10) {
      edges {
        node {
          id
          quantity
          merchandise {
            ... on ProductVariant {
              id
              title
              sku
              image {
                url
              }
              product {
                title
                handle
              }
            }
          }
          cost {
            totalAmount {
              amount
              currencyCode
            }
          }
        }
      }
    }
    cost {
      subtotalAmount {
        amount
        currencyCode
      }
      totalTaxAmount {
        amount
      }
      totalAmount {
        amount
        currencyCode
      }
    }
  }
}
```

## Buyer Identity

### Set Buyer Identity

Use for customer email, shipping address, and preferred language:

```graphql
mutation SetBuyerIdentity($cartId: ID!, $buyerIdentity: CartBuyerIdentityInput!) {
  cartBuyerIdentityUpdate(cartId: $cartId, buyerIdentity: $buyerIdentity) {
    cart {
      id
      buyerIdentity {
        email
        phone
        countryCode
      }
    }
  }
}
```

Variables:
```json
{
  "cartId": "gid://shopify/Cart/abc123",
  "buyerIdentity": {
    "email": "customer@example.com",
    "phone": "+1-555-123-4567",
    "countryCode": "US"
  }
}
```

## Localization

### Query by Language

```graphql
query GetProductLocalized($handle: String!, $language: LanguageCode!) {
  productByHandle(handle: $handle) {
    id
    title(language: $language)
    description(language: $language)
  }
}
```

Variables:
```json
{
  "handle": "my-product",
  "language": "ES"
}
```

## Predictive Search

### Predict Search Results

For real-time autocomplete:

```graphql
query PredictiveSearch($query: String!, $limit: Int!) {
  predictiveSearch(query: $query, limit: $limit) {
    products {
      id
      title
      handle
      image {
        url
      }
    }
    queries {
      text
    }
    collections {
      id
      title
      handle
    }
  }
}
```

## Pagination Patterns

### Cursor-Based Pagination

```graphql
query GetProductsPage($first: Int!, $after: String) {
  products(first: $first, after: $after) {
    pageInfo {
      hasNextPage
      hasPreviousPage
      startCursor
      endCursor
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

Pagination logic:

```javascript
let cursor = null;

async function getNextPage() {
  const response = await fetch(endpoint, {
    method: 'POST',
    body: JSON.stringify({
      query: GET_PRODUCTS_QUERY,
      variables: {first: 10, after: cursor},
    }),
  });

  const {data} = await response.json();
  cursor = data.products.pageInfo.endCursor;
  return data.products.edges;
}
```

## Storefront Access Token Types

### Public Token (Client-Side)

```javascript
// Safe to expose in browser code
const token = 'e6f...'; // ~32 chars

// Scopes: product reads, cart operations
```

### Private Token (Server-Side)

```javascript
// Never expose to client
const token = 'shppa_...'; // longer, more scopes
```

Use private token for sensitive operations like applying discounts or accessing customer data.

## Shop Information

### Get Shop Details

```graphql
query GetShop {
  shop {
    id
    name
    primaryDomain {
      url
    }
    paymentSettings {
      acceptedCardBrands
      cardPaymentMethods
    }
    shippingPolicy {
      body
    }
    privacyPolicy {
      body
    }
    refundPolicy {
      body
    }
  }
}
```

## Error Handling

Always check for errors in Storefront API responses:

```javascript
const response = await fetch(endpoint, {
  method: 'POST',
  headers: {
    'X-Shopify-Storefront-Access-Token': token,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({query}),
});

const json = await response.json();

// Check for GraphQL errors
if (json.errors) {
  console.error('GraphQL Errors:', json.errors);
}

// Check for mutation errors
if (json.data?.cartLinesAdd?.userErrors?.length > 0) {
  const errors = json.data.cartLinesAdd.userErrors;
  console.error('Cart Errors:', errors);
}
```

## Performance Best Practices

### Minimize Query Size

```graphql
# Good: Only request needed fields
query {
  productByHandle(handle: "shirt") {
    id
    title
    price {
      amount
    }
  }
}

# Bad: Requests unnecessary data
query {
  productByHandle(handle: "shirt") {
    id
    title
    description
    vendor
    productType
    collections(first: 10) { ... }
    variants(first: 100) { ... }
  }
}
```

### Use Image Optimization

```graphql
{
  products(first: 10) {
    edges {
      node {
        images(first: 1) {
          edges {
            node {
              url(transform: {maxWidth: 300, maxHeight: 300})
            }
          }
        }
      }
    }
  }
}
```

## Deprecation and Versioning

Use latest stable API version. Current stable: `2024-01`

```javascript
// Recommended
https://shop.myshopify.com/api/2024-01/graphql.json

// Avoid deprecated versions
https://shop.myshopify.com/api/2023-07/graphql.json
```

## Next Steps

- See `storefront-api-patterns.md` for complete examples and advanced patterns
- Review [Shopify Storefront API docs](https://shopify.dev/api/storefront/2024-01)
- Build custom checkout experiences with cart operations
- Implement predictive search for better UX
- Use Admin API on your backend for inventory management
