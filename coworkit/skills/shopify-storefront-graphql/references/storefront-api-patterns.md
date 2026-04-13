# Shopify Storefront API: Implementation Patterns

## Product Queries

### Get Single Product with Full Details

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

### Get Product List with Pagination

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

Variables:
```json
{
  "first": 10,
  "after": null,
  "sortKey": "TITLE"
}
```

### Product Query with Metafields

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

### Get Collection with Products and Pagination

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

Variables:
```json
{
  "handle": "summer-collection",
  "first": 20,
  "after": null
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

Variables:
```json
{
  "query": "blue shirt",
  "first": 10
}
```

## Cart Operations

### Create Cart Mutation

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

### Add to Cart Mutation

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

Variables:
```json
{
  "cartId": "gid://shopify/Cart/abc123",
  "lines": [
    {
      "merchandiseId": "gid://shopify/ProductVariant/456",
      "quantity": 2
    }
  ]
}
```

### Update Cart Line Quantity

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

### Remove from Cart Mutation

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

Variables:
```json
{
  "cartId": "gid://shopify/Cart/abc123",
  "lineIds": ["gid://shopify/CartLine/def456"]
}
```

### Get Cart Query

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

### Set Buyer Identity Mutation

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

### Query Products by Language

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

### Predictive Search Query

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

Variables:
```json
{
  "query": "blue",
  "limit": 5
}
```

## Pagination Implementation

### JavaScript Pagination Logic

```javascript
let cursor = null;

async function getNextPage() {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'X-Shopify-Storefront-Access-Token': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: GET_PRODUCTS_QUERY,
      variables: {first: 10, after: cursor},
    }),
  });

  const {data, errors} = await response.json();
  
  if (errors) {
    console.error('GraphQL Errors:', errors);
    return [];
  }

  cursor = data.products.pageInfo.endCursor;
  return data.products.edges;
}
```

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

### Comprehensive Error Handling Example

```javascript
const response = await fetch(endpoint, {
  method: 'POST',
  headers: {
    'X-Shopify-Storefront-Access-Token': token,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({query, variables}),
});

const json = await response.json();

// Check for GraphQL errors
if (json.errors) {
  console.error('GraphQL Errors:', json.errors);
  json.errors.forEach(error => {
    console.error(`Error: ${error.message}`);
  });
}

// Check for mutation errors
if (json.data?.cartLinesAdd?.userErrors?.length > 0) {
  const errors = json.data.cartLinesAdd.userErrors;
  errors.forEach(error => {
    console.error(`Field: ${error.field}, Message: ${error.message}`);
  });
}

// Successful response
if (!json.errors && json.data) {
  return json.data;
}
```

## Image Optimization

### Image Transform in Query

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

## Bulk Operations Pattern

### Fetch Multiple Products by Handle

```graphql
query GetProducts {
  product1: productByHandle(handle: "shirt") {
    id
    title
    priceRange {
      minVariantPrice {
        amount
      }
    }
  }
  product2: productByHandle(handle: "pants") {
    id
    title
    priceRange {
      minVariantPrice {
        amount
      }
    }
  }
  product3: productByHandle(handle: "jacket") {
    id
    title
    priceRange {
      minVariantPrice {
        amount
      }
    }
  }
}
```
