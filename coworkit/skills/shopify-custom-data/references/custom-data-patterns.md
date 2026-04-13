# Shopify Custom Data: GraphQL Patterns

## Metafields CRUD Operations

### Create or Update a Single Metafield

```graphql
mutation SetProductRating($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "product_rating"
        type: "number_decimal"
        value: "4.8"
      }
    ]
  ) {
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
  "ownerId": "gid://shopify/Product/456789"
}
```

### Batch Update Multiple Metafields

```graphql
mutation BatchUpdateMetafields($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "wholesale_price"
        type: "money"
        value: "{\"amount\":\"12.50\",\"currencyCode\":\"USD\"}"
      },
      {
        namespace: "$app"
        key: "minimum_order"
        type: "number_integer"
        value: "10"
      },
      {
        namespace: "$app"
        key: "bulk_discount"
        type: "number_decimal"
        value: "0.15"
      }
    ]
  ) {
    metafields {
      id
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

### Delete a Metafield

Set the value to null to remove a metafield:

```graphql
mutation DeleteMetafield($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        id: "gid://shopify/Metafield/87654321"
      }
    ]
  ) {
    metafields {
      id
    }
    userErrors {
      message
    }
  }
}
```

### Read Metafields from a Product

```graphql
query GetProductMetafields($id: ID!) {
  product(id: $id) {
    id
    title
    metafields(namespace: "$app", first: 25) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          id
          namespace
          key
          value
          type
          createdAt
          updatedAt
        }
      }
    }
  }
}
```

### Read Metafields from Multiple Resources

```graphql
query GetCustomerMetafields($customerId: ID!) {
  customer(id: $customerId) {
    id
    email
    firstName
    lastName
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

## Metaobject CRUD Operations

### Create a New Metaobject

```graphql
mutation CreateProductReview($input: MetaobjectInput!) {
  metaobjectUpsert(input: $input) {
    metaobject {
      id
      type
      fields {
        key
        value
      }
      createdAt
      updatedAt
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
  "input": {
    "type": "product_review",
    "fields": [
      {
        "key": "reviewer_name",
        "value": "Sarah Johnson"
      },
      {
        "key": "review_text",
        "value": "Great product! Exactly what I needed."
      },
      {
        "key": "rating",
        "value": "5"
      },
      {
        "key": "verified_purchase",
        "value": "true"
      },
      {
        "key": "review_date",
        "value": "2024-04-13T10:30:00Z"
      }
    ]
  }
}
```

### Update an Existing Metaobject

```graphql
mutation UpdateReview($input: MetaobjectInput!) {
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
    "id": "gid://shopify/Metaobject/product_review/123456",
    "type": "product_review",
    "fields": [
      {
        "key": "rating",
        "value": "4"
      },
      {
        "key": "review_text",
        "value": "Updated: Still great but minor issues noticed"
      }
    ]
  }
}
```

### Query Metaobjects by Type

```graphql
query GetProductReviews($after: String) {
  metaobjects(type: "product_review", first: 10, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        type
        fields {
          key
          value
        }
        createdAt
        updatedAt
      }
    }
  }
}
```

### Query Metaobject by ID

```graphql
query GetReviewById($id: ID!) {
  metaobject(id: $id) {
    id
    type
    fields {
      key
      value
    }
  }
}
```

### Delete a Metaobject

```graphql
mutation DeleteMetaobject($id: ID!) {
  metaobjectDelete(id: $id) {
    deletedId
    userErrors {
      message
    }
  }
}
```

## Complex Data Patterns

### Storing Nested JSON Objects

```graphql
mutation SetComplexConfig($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "shipping_config"
        type: "json"
        value: "{\"regions\":[{\"name\":\"US\",\"cost\":10.00,\"days\":3},{\"name\":\"EU\",\"cost\":15.00,\"days\":5}],\"free_shipping_threshold\":50.00}"
      }
    ]
  ) {
    metafields {
      id
      value
    }
    userErrors {
      message
    }
  }
}
```

### Array of Values

```graphql
mutation SetTags($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "product_tags"
        type: "json"
        value: "[\"eco-friendly\",\"bestseller\",\"limited-edition\"]"
      }
    ]
  ) {
    metafields {
      id
    }
    userErrors {
      message
    }
  }
}
```

## Pagination Patterns

### Paginate Through Metafields

```graphql
query PaginateMetafields($id: ID!, $after: String) {
  product(id: $id) {
    id
    metafields(namespace: "$app", first: 10, after: $after) {
      pageInfo {
        hasNextPage
        hasPreviousPage
        startCursor
        endCursor
      }
      edges {
        cursor
        node {
          key
          value
        }
      }
    }
  }
}
```

### Paginate Through Metaobjects

```graphql
query PaginateMetaobjects($type: String!, $after: String) {
  metaobjects(type: $type, first: 20, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        fields {
          key
          value
        }
      }
    }
  }
}
```

## Reference Patterns

### Link Metaobject to Product

```graphql
mutation CreateProductLink($input: MetaobjectInput!) {
  metaobjectUpsert(input: $input) {
    metaobject {
      id
      fields {
        key
        value
      }
    }
  }
}
```

Variables:
```json
{
  "input": {
    "type": "product_review",
    "fields": [
      {
        "key": "product_id",
        "value": "gid://shopify/Product/789012"
      },
      {
        "key": "reviewer_name",
        "value": "John Doe"
      },
      {
        "key": "rating",
        "value": "4"
      }
    ]
  }
}
```

## Bulk Query Patterns

### Get Products with Custom Metadata

```graphql
query {
  products(first: 50) {
    edges {
      node {
        id
        title
        metafields(namespace: "$app", first: 5) {
          edges {
            node {
              key
              value
              type
            }
          }
        }
        variants(first: 5) {
          edges {
            node {
              id
              title
              metafields(namespace: "$app", first: 3) {
                edges {
                  node {
                    key
                    value
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Combine Metaobjects with Products

```graphql
query {
  products(first: 20) {
    edges {
      node {
        id
        title
      }
    }
  }
  metaobjects(type: "product_review", first: 20) {
    edges {
      node {
        id
        fields {
          key
          value
        }
      }
    }
  }
}
```

## Type Safety Examples

### Money Type

```graphql
mutation SetMoneyMetafield($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "cost_per_unit"
        type: "money"
        value: "{\"amount\":\"29.99\",\"currencyCode\":\"USD\"}"
      }
    ]
  ) {
    metafields {
      id
      value
    }
    userErrors {
      message
    }
  }
}
```

### Date Type

```graphql
mutation SetDateMetafield($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "launch_date"
        type: "date"
        value: "2024-06-15"
      }
    ]
  ) {
    metafields {
      id
    }
    userErrors {
      message
    }
  }
}
```

### DateTime Type

```graphql
mutation SetDateTimeMetafield($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "last_restocked"
        type: "date_time"
        value: "2024-04-13T15:30:00Z"
      }
    ]
  ) {
    metafields {
      id
    }
    userErrors {
      message
    }
  }
}
```

### Boolean Type

```graphql
mutation SetBooleanMetafield($ownerId: ID!) {
  metafieldsSet(
    ownerId: $ownerId
    metafields: [
      {
        namespace: "$app"
        key: "is_sustainable"
        type: "boolean"
        value: "true"
      }
    ]
  ) {
    metafields {
      id
    }
    userErrors {
      message
    }
  }
}
```
