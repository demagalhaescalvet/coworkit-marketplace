# Shopify Customer Account API: Patterns and Examples

## OAuth Authentication Flow

### Generate Authorization URL

```javascript
const authUrl = `https://${shop}/account/customer/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=customer_account_api:read&state=${randomState}`;

// Redirect customer to authUrl
window.location.href = authUrl;
```

### Handle OAuth Callback

```javascript
// At your callback URL handler
const { code, state } = req.query;

// Verify state matches your session
if (state !== session.state) {
  throw new Error('Invalid state parameter');
}

// Exchange code for token
const tokenResponse = await fetch(
  `https://${shop}/account/customer/oauth/token`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'authorization_code',
      client_id: process.env.SHOPIFY_APP_ID,
      client_secret: process.env.SHOPIFY_APP_SECRET,
      code,
      redirect_uri: redirectUri,
    }),
  }
);

const tokens = await tokenResponse.json();
// Store access_token and refresh_token securely
```

### Refresh Token

```graphql
mutation RefreshToken($token: String!) {
  customerAccessTokenRefresh(refreshToken: $token) {
    accessToken {
      accessToken
      expiresAt
    }
    userErrors {
      message
    }
  }
}
```

## Customer Profile Queries

### Get Full Customer Profile

```graphql
query GetFullProfile {
  customer {
    id
    email
    firstName
    lastName
    phone
    acceptsMarketing
    createdAt
    updatedAt
    defaultAddress {
      id
      firstName
      lastName
      address1
      address2
      city
      province
      country
      zip
      phone
      formatted
    }
  }
}
```

### Get Customer with Orders and Addresses

```graphql
query GetCustomerOverview {
  customer {
    id
    email
    firstName
    lastName
    defaultAddress {
      formatted
    }
    orders(first: 5) {
      edges {
        node {
          id
          orderNumber
          processedAt
          totalPrice
          lineItems(first: 3) {
            edges {
              node {
                title
                quantity
              }
            }
          }
        }
      }
    }
    addresses(first: 3) {
      edges {
        node {
          id
          formatted
        }
      }
    }
  }
}
```

## Order History Queries

### Get All Orders with Pagination

```graphql
query GetOrders($first: Int!, $after: String) {
  customer {
    orders(first: $first, after: $after, sortKey: PROCESSED_AT, reverse: true) {
      pageInfo {
        hasNextPage
        hasPreviousPage
        startCursor
        endCursor
      }
      edges {
        node {
          id
          orderNumber
          processedAt
          statusUrl
          financialStatus
          fulfillmentStatus
          currencyCode
          totalPrice
          subtotalPrice
          totalShipping
          totalTax
          lineItems(first: 10) {
            edges {
              node {
                id
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
            address1
            city
            province
            country
            zip
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
  "after": null
}
```

### Get Single Order with Full Details

```graphql
query GetOrderDetails($id: ID!) {
  order(id: $id) {
    id
    orderNumber
    processedAt
    statusUrl
    financialStatus
    fulfillmentStatus
    currencyCode
    cancelledAt
    cancelReason
    totalPrice
    subtotalPrice
    totalShipping
    totalTax
    totalDiscounts
    note
    lineItems(first: 25) {
      edges {
        node {
          id
          title
          quantity
          originalTotalPrice
          discountedTotalPrice
          variant {
            id
            title
            sku
            barcode
            image {
              url
              altText
            }
          }
        }
      }
    }
    shippingAddress {
      id
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
    billingAddress {
      id
      firstName
      lastName
      address1
      city
      province
      country
      zip
    }
    fulfillmentOrders {
      id
      status
      createdAt
      requestStatus
      lineItems(first: 10) {
        edges {
          node {
            id
            quantity
            lineItem {
              title
            }
          }
        }
      }
      fulfillments(first: 5) {
        edges {
          node {
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
      deliveryExpectations {
        estimatedDeliveryDate
      }
    }
  }
}
```

### Order Fulfillment Tracking

```graphql
query TrackOrder($id: ID!) {
  order(id: $id) {
    id
    orderNumber
    fulfillmentOrders {
      id
      status
      createdAt
      estimatedDeliveryDate
      lineItems(first: 10) {
        edges {
          node {
            lineItem {
              title
              quantity
            }
            quantity
          }
        }
      }
      fulfillments(first: 5) {
        edges {
          node {
            id
            status
            createdAt
            estimatedDeliveryDate
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
```

## Address Management Mutations

### Create New Address

```graphql
mutation CreateAddress($address: MailingAddressInput!) {
  customerAddressCreate(address: $address) {
    address {
      id
      firstName
      lastName
      address1
      address2
      city
      province
      country
      zip
      phone
      formatted
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
  "address": {
    "firstName": "John",
    "lastName": "Doe",
    "address1": "123 Main Street",
    "address2": "Apt 4B",
    "city": "New York",
    "province": "NY",
    "country": "US",
    "zip": "10001",
    "phone": "555-123-4567"
  }
}
```

### Update Existing Address

```graphql
mutation UpdateAddress($id: ID!, $address: MailingAddressInput!) {
  customerAddressUpdate(id: $id, address: $address) {
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
  "id": "gid://shopify/Address/12345",
  "address": {
    "address1": "456 New Lane",
    "city": "Los Angeles",
    "province": "CA",
    "country": "US",
    "zip": "90001"
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
mutation SetDefaultAddress($addressId: ID!) {
  customerDefaultAddressUpdate(addressId: $addressId) {
    customer {
      id
      defaultAddress {
        id
        formatted
      }
    }
    userErrors {
      message
    }
  }
}
```

## Return Management

### Request Return for Order

```graphql
mutation RequestReturn(
  $orderId: ID!,
  $reason: ReturnReason!,
  $lineItems: [ReturnLineItemInput!]!
) {
  returnCreate(
    input: {
      orderId: $orderId,
      reason: $reason,
      lineItems: $lineItems,
    }
  ) {
    return {
      id
      status
      returnLineItems(first: 10) {
        edges {
          node {
            lineItem {
              title
            }
            quantity
            reason
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
  "orderId": "gid://shopify/Order/123456",
  "reason": "WRONG_ITEM",
  "lineItems": [
    {
      "lineItemId": "gid://shopify/LineItem/789",
      "quantity": 1,
      "reason": "WRONG_ITEM"
    }
  ]
}
```

### Query Return Status

```graphql
query GetReturns($orderId: ID!) {
  order(id: $orderId) {
    id
    orderNumber
    returns(first: 10) {
      edges {
        node {
          id
          status
          reason
          createdAt
          returnLineItems(first: 10) {
            edges {
              node {
                lineItem {
                  title
                  quantity
                }
                quantity
                reason
                status
              }
            }
          }
        }
      }
    }
  }
}
```

## Payment Methods

### Get Payment Methods

```graphql
query GetPaymentMethods {
  customer {
    paymentMethods(first: 10) {
      edges {
        node {
          id
          instrument {
            __typename
            ... on PaymentCard {
              brand
              firstDigits
              lastDigits
              expiryMonth
              expiryYear
            }
          }
          billingAddress {
            id
            formatted
          }
          createdAt
        }
      }
    }
  }
}
```

## Notification Preferences

### Update Marketing Preferences

```graphql
mutation UpdateMarketingPreference($acceptsMarketing: Boolean!) {
  customerUpdate(input: { acceptsMarketing: $acceptsMarketing }) {
    customer {
      id
      acceptsMarketing
    }
    userErrors {
      field
      message
    }
  }
}
```

## Batch Queries

### Get Customer and Related Data in One Query

```graphql
query GetCustomerDashboard {
  customer {
    id
    email
    firstName
    lastName
    phone
    defaultAddress {
      id
      formatted
    }
    addresses(first: 5) {
      edges {
        node {
          id
          formatted
        }
      }
    }
    orders(first: 5) {
      edges {
        node {
          id
          orderNumber
          processedAt
          totalPrice
          fulfillmentStatus
        }
      }
    }
    paymentMethods(first: 3) {
      edges {
        node {
          id
          instrument {
            __typename
            ... on PaymentCard {
              lastDigits
              brand
              expiryMonth
              expiryYear
            }
          }
        }
      }
    }
  }
}
```

## Error Handling Examples

### Handle Authentication Errors

```javascript
const response = await fetch(endpoint, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${accessToken}`,
  },
  body: JSON.stringify({ query }),
});

const json = await response.json();

if (json.errors) {
  const error = json.errors[0];
  if (error.extensions?.code === 'UNAUTHENTICATED') {
    // Token expired, refresh or redirect to login
    await refreshToken();
  }
  if (error.extensions?.code === 'ACCESS_DENIED') {
    // Insufficient permissions
    console.error('Access denied:', error.message);
  }
}
```

### Handle Validation Errors

```javascript
if (json.data?.customerAddressCreate?.userErrors?.length > 0) {
  const errors = json.data.customerAddressCreate.userErrors;
  errors.forEach(error => {
    console.error(`${error.field}: ${error.message}`);
  });
}
```
