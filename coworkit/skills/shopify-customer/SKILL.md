---
name: shopify-customer
description: Triggers on "Customer Account API", "customer data", "order history", "customer returns", "customer addresses", "payment methods", "customer account". Build customer-facing experiences with the Shopify Customer Account API for authentication and personalized data access.
version: 0.1.0
---

# Shopify Customer Account API

The Customer Account API enables you to build customer-facing storefronts and apps where customers access only their own data. Authentication is handled by Shopify, ensuring customers see only their orders, addresses, payment methods, and account details.

## Core Concepts

### Authentication Model

Unlike the Admin API (merchant-facing), the Customer Account API uses customer authentication via OAuth or login:

- Customers log in with their Shopify account credentials
- Access tokens are tied to individual customer profiles
- Customers can only query their own data—no merchant cross-selling
- Perfect for custom storefronts, account portals, and customer apps

### Use Cases

- Order history and tracking pages
- Account management (address book, payment methods)
- Return management and order reviews
- Personalized product recommendations
- Subscription management
- Wallet and payment settings

## API Endpoints and Setup

### Enable Customer Account API

In your `shopify.app.toml`:

```toml
scopes = "customer_account_api:read"

[[auth]]
redirect_uris = ["https://example.com/auth/callback"]
```

### GraphQL Endpoint

```
https://{shop}/account/customer/graphql.json
```

Use the customer's access token:

```javascript
const response = await fetch(
  `https://${shopName}/account/customer/graphql.json`,
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${customerAccessToken}`,
    },
    body: JSON.stringify({ query }),
  }
);
```

## Customer Authentication Flow

### Step 1: Direct Customer to Login

Create a login URL:

```
https://{shop}/account/customer/oauth/authorize?
  client_id={your_app_id}&
  redirect_uri={your_callback_url}&
  scope=customer_account_api:read&
  response_type=code&
  state={random_state}
```

### Step 2: Exchange Code for Token

```javascript
const response = await fetch(
  `https://${shop}/account/customer/oauth/token`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'authorization_code',
      client_id: process.env.SHOPIFY_APP_ID,
      client_secret: process.env.SHOPIFY_APP_SECRET,
      code: authCode,
      redirect_uri: callbackUrl,
    }),
  }
);

const { access_token, refresh_token, expires_in } = await response.json();
```

### Step 3: Use Token for Queries

```graphql
{
  customer {
    id
    email
    firstName
    lastName
  }
}
```

## Core Queries

### Get Customer Profile

```graphql
query {
  customer {
    id
    email
    firstName
    lastName
    phone
    defaultAddress {
      id
      formatted
      city
      province
      country
      zip
    }
  }
}
```

### Get Customer's Orders

```graphql
query GetCustomerOrders($first: Int!, $after: String) {
  customer {
    orders(first: $first, after: $after) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          id
          orderNumber
          processedAt
          statusUrl
          currencyCode
          totalPrice
          subtotalPrice
          totalShipping
          totalTax
          lineItems(first: 10) {
            edges {
              node {
                title
                quantity
                variant {
                  title
                  sku
                  image {
                    url
                  }
                }
              }
            }
          }
          fulfillmentOrders {
            status
            lineItems(first: 5) {
              edges {
                node {
                  lineItem {
                    title
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

### Get Order Details

```graphql
query GetOrderDetails($id: ID!) {
  order(id: $id) {
    id
    orderNumber
    processedAt
    statusUrl
    fulfillmentOrders {
      status
      deliveryExpectations {
        estimatedDeliveryDate
      }
    }
    lineItems(first: 10) {
      edges {
        node {
          title
          quantity
          originalTotalPrice
          variant {
            id
            title
            sku
            image {
              url
              altText
            }
          }
        }
      }
    }
    shippingAddress {
      firstName
      lastName
      formatted
      city
      province
      country
      zip
      phone
    }
  }
}
```

### Get Address Book

```graphql
query {
  customer {
    addresses(first: 10) {
      edges {
        node {
          id
          formatted
          firstName
          lastName
          address1
          address2
          city
          province
          country
          zip
          phone
        }
      }
    }
    defaultAddress {
      id
    }
  }
}
```

### Get Payment Methods

```graphql
query {
  customer {
    paymentMethods(first: 5) {
      edges {
        node {
          id
          instrument {
            __typename
            ... on PaymentCard {
              brand
              expiryMonth
              expiryYear
              lastDigits
            }
          }
          billingAddress {
            formatted
          }
        }
      }
    }
  }
}
```

## Order Management Mutations

### Update Delivery Address (Pre-Fulfillment)

```graphql
mutation UpdateShippingAddress($address: MailingAddressInput!) {
  orderUpdate(
    input: {
      shippingAddress: $address
    }
  ) {
    order {
      id
      shippingAddress {
        formatted
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
  "address": {
    "firstName": "Jane",
    "lastName": "Doe",
    "address1": "123 Main St",
    "address2": "Suite 100",
    "city": "Portland",
    "province": "OR",
    "country": "US",
    "zip": "97214",
    "phone": "555-123-4567"
  }
}
```

## Returns and Refunds

### Query Return Status

```graphql
query GetReturnStatus($id: ID!) {
  order(id: $id) {
    id
    returns(first: 10) {
      edges {
        node {
          id
          status
          returnLineItems(first: 10) {
            edges {
              node {
                lineItem {
                  title
                  quantity
                }
                quantity
                reason
              }
            }
          }
        }
      }
    }
  }
}
```

### Request Return

```graphql
mutation RequestReturn($orderId: ID!, $lineItems: [ReturnLineItemInput!]!) {
  returnCreate(
    input: {
      orderId: $orderId
      lineItems: $lineItems
    }
  ) {
    return {
      id
      status
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
  "orderId": "gid://shopify/Order/123456",
  "lineItems": [
    {
      "lineItemId": "gid://shopify/LineItem/789",
      "quantity": 1,
      "reason": "WRONG_ITEM"
    }
  ]
}
```

## Address Management

### Add Address to Customer

```graphql
mutation AddAddress($address: MailingAddressInput!) {
  customerAddressCreate(address: $address) {
    address {
      id
      formatted
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
  "address": {
    "firstName": "John",
    "lastName": "Smith",
    "address1": "456 Oak Ave",
    "city": "Seattle",
    "province": "WA",
    "country": "US",
    "zip": "98101",
    "phone": "555-987-6543"
  }
}
```

### Update Address

```graphql
mutation UpdateAddress($id: ID!, $address: MailingAddressInput!) {
  customerAddressUpdate(id: $id, address: $address) {
    address {
      id
      formatted
    }
    userErrors {
      message
    }
  }
}
```

### Delete Address

```graphql
mutation DeleteAddress($id: ID!) {
  customerAddressDelete(id: $id) {
    deletedId
    userErrors {
      message
    }
  }
}
```

### Set Default Address

```graphql
mutation SetDefaultAddress($id: ID!) {
  customerDefaultAddressUpdate(addressId: $id) {
    customer {
      defaultAddress {
        id
      }
    }
    userErrors {
      message
    }
  }
}
```

## Customer Account Extensions

Use Customer Account Extensions to add custom sections to the customer account pages:

```toml
[[extensions]]
type = "customer_account_ui_extension"
name = "loyalty_rewards"
handle = "loyalty-rewards"
development_store_enabled = true

[[extensions.settings]]
key = "tier_colors"
type = "object"
```

## Fulfillment and Tracking

### Track Order Fulfillment

```graphql
query TrackOrder($id: ID!) {
  order(id: $id) {
    id
    orderNumber
    fulfillmentOrders {
      status
      fulfillments {
        id
        status
        trackingInfo {
          number
          company
          url
        }
      }
    }
  }
}
```

### Get Tracking Information

```graphql
query {
  customer {
    orders(first: 5) {
      edges {
        node {
          id
          orderNumber
          fulfillmentOrders {
            status
            deliveryExpectations {
              estimatedDeliveryDate
            }
            fulfillments {
              status
              trackingInfo {
                number
                company
                url
              }
            }
          }
        }
      }
    }
  }
}
```

## Pagination Pattern

### Page Through Orders

```graphql
query PageOrders($first: Int!, $after: String) {
  customer {
    orders(first: $first, after: $after) {
      pageInfo {
        hasNextPage
        hasPreviousPage
        startCursor
        endCursor
      }
      edges {
        cursor
        node {
          id
          orderNumber
          processedAt
          totalPrice
        }
      }
    }
  }
}
```

## Error Handling

Always check for errors in customer data queries:

```javascript
const response = await fetch(endpoint, {
  method: 'POST',
  headers: { ... },
  body: JSON.stringify({ query })
});

const json = await response.json();

if (json.errors) {
  // GraphQL errors (auth failures, validation)
  console.error('GraphQL Errors:', json.errors);
  if (json.errors[0].extensions?.code === 'UNAUTHENTICATED') {
    // Token expired, refresh or redirect to login
  }
}

if (json.data?.customerAddressUpdate?.userErrors?.length > 0) {
  // User errors (validation failures)
  console.error('User Errors:', json.data.customerAddressUpdate.userErrors);
}
```

## Performance Best Practices

### Only Request Needed Fields

```graphql
# Bad: requests all available fields
query {
  customer {
    id
    email
    firstName
    lastName
    phone
    addresses(first: 10) { ... }
    orders(first: 100) { ... }
    paymentMethods(first: 20) { ... }
  }
}

# Good: request only what you display
query {
  customer {
    email
    addresses(first: 5) {
      edges { node { id formatted } }
    }
  }
}
```

### Use Cursors for Pagination

Always paginate large result sets instead of requesting all items:

```graphql
query {
  customer {
    orders(first: 10) {  # Not first: 1000
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node { id orderNumber }
      }
    }
  }
}
```

## Security Considerations

- Always validate the `state` parameter during OAuth callback
- Refresh tokens before expiration
- Never expose customer access tokens in client-side code
- Use HTTPS for all token exchanges
- Implement proper CORS headers for storefront access

## Next Steps

- See `customer-api-patterns.md` for complete mutation examples and authentication flows
- Review [Shopify Customer Account API docs](https://shopify.dev/api/customer/2024-01)
- Implement Customer Account Extensions for custom account experiences
- Build a secure token refresh mechanism for long-lived sessions
