---
name: shopify-partner
description: Querying Partner Dashboard data via the Partner API GraphQL. Covers app management, analytics, themes, transactions, payouts, affiliate tracking, and shop organization data.
version: 0.1.0
---

# Shopify Partner API

This skill covers the Partner API for accessing Partner Dashboard data. Use this when you need to query app performance, theme data, organization information, transaction history, or affiliate tracking from a Partner account perspective (not merchant-level).

## Partner API Overview

The Partner API is a GraphQL API exclusively for Shopify Partners to manage and analyze their business data.

### Key Differences from Admin API

| Feature | Admin API | Partner API |
|---------|-----------|------------|
| Authentication | Per-store access tokens | Partner API credentials |
| Scope | Single store data | Multi-app/multi-store data |
| Use Cases | Merchant app operations | Partner business management |
| Authentication Flow | OAuth per store | API credentials once |

## Authentication

### Get API Credentials

1. Log into Partner Dashboard
2. Go to **Apps and sales channels > Develop apps > Create an app**
3. Navigate to **Configuration** tab
4. Copy **API key** and **API secret**
5. Generate access scopes

### Authenticate API Requests

```typescript
import fetch from 'node-fetch';

const PARTNER_API_KEY = process.env.SHOPIFY_PARTNER_API_KEY;
const PARTNER_API_SECRET = process.env.SHOPIFY_PARTNER_API_SECRET;

async function makePartnerAPIRequest(query) {
  const response = await fetch('https://api.shopify.com/graphql/2024-10.json', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Shopify-Access-Token': PARTNER_API_SECRET,
    },
    body: JSON.stringify({ query }),
  });

  const result = await response.json();
  if (result.errors) {
    console.error('GraphQL Error:', result.errors);
  }
  return result.data;
}
```

## App Management Queries

### List All Apps

```graphql
query {
  apps(first: 10) {
    edges {
      node {
        id
        title
        handle
        status
        icon {
          originalSrc
        }
        appStore {
          approvalStatus
          isListed
          launchDate
        }
        createdAt
        updatedAt
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

### Get App Details

```graphql
query GetApp($appId: ID!) {
  app(id: $appId) {
    id
    title
    handle
    description
    documentation {
      url
    }
    icon {
      originalSrc
    }
    appStore {
      approvalStatus
      isListed
      pricingPlans {
        id
        title
        description
        price {
          amount
          currencyCode
        }
        returnUrl
      }
    }
    createdAt
    updatedAt
  }
}
```

Variables:
```json
{
  "appId": "gid://shopify/App/1234567890"
}
```

## App Analytics

### Get App Installation Analytics

```graphql
query {
  app(id: "gid://shopify/App/1234567890") {
    id
    title
    installation {
      installedCount
      activeCount
      uninstalledCount
    }
    analytics {
      installCount
      uninstallCount
      activeStoreCount
      shopifyPlusCount
      developmentStoreCount
    }
  }
}
```

### Get Revenue Data

```graphql
query {
  app(id: "gid://shopify/App/1234567890") {
    id
    title
    revenue {
      totalAmount {
        amount
        currencyCode
      }
      amount {
        amount
        currencyCode
      }
      lineItems {
        amount {
          amount
          currencyCode
        }
        description
      }
    }
  }
}
```

### Track Install Sources

```graphql
query {
  appInstallations(first: 100, sort: CREATED_AT_DESC) {
    edges {
      node {
        id
        shop {
          id
          name
          domain
        }
        status
        createdAt
        uninstalledAt
        activationAttempts {
          occurredAt
          status
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

## Theme Management via Partner API

### List All Themes

```graphql
query {
  themes(first: 50) {
    edges {
      node {
        id
        title
        handle
        createdAt
        updatedAt
        assetCount
        previewUrl
        role
      }
    }
  }
}
```

### Get Theme Details

```graphql
query GetTheme($themeId: ID!) {
  theme(id: $themeId) {
    id
    title
    description
    handle
    previewUrl
    assetCount
    assets(first: 50) {
      edges {
        node {
          key
          size
          contentType
        }
      }
    }
  }
}
```

## Shop and Organization Queries

### List Connected Shops

```graphql
query {
  shops(first: 100) {
    edges {
      node {
        id
        name
        domain
        myshopifyDomain
        plan {
          displayName
        }
        email
        phoneNumber
        timeZone
        ianaTimeZone
        createdAt
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

### Get Shop Details

```graphql
query GetShop($shopId: ID!) {
  shop(id: $shopId) {
    id
    name
    domain
    myshopifyDomain
    plan {
      displayName
      category
    }
    email
    phoneNumber
    address {
      address1
      city
      province
      country
      zip
    }
    createdAt
  }
}
```

### List Organizations

```graphql
query {
  organizations {
    edges {
      node {
        id
        name
        type
        apps {
          id
          title
        }
        createdAt
      }
    }
  }
}
```

## Transaction and Payout Workflows

### Get Billing Data

```graphql
query {
  app(id: "gid://shopify/App/1234567890") {
    id
    title
    billing {
      currentPlan {
        id
        title
        price {
          amount
          currencyCode
        }
      }
      upcomingBillingCycle {
        beginDate
        endDate
        estimatedAmount {
          amount
          currencyCode
        }
      }
    }
  }
}
```

### Get Payout Information

```graphql
query {
  payouts(first: 50, sort: CREATED_AT_DESC) {
    edges {
      node {
        id
        status
        amount {
          amount
          currencyCode
        }
        initiatedAt
        completedAt
        transactionId
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

### List Transactions

```graphql
query {
  transactions(first: 100, sort: CREATED_AT_DESC) {
    edges {
      node {
        id
        type
        amount {
          amount
          currencyCode
        }
        app {
          id
          title
        }
        shop {
          name
          domain
        }
        billingCycle {
          beginDate
          endDate
        }
        createdAt
      }
    }
  }
}
```

## Affiliate and Referral Tracking

### Get Affiliate Program Data

```graphql
query {
  affiliateProgram {
    id
    name
    commission {
      rate
      type
    }
    status
    createdAt
  }
}
```

### List Referrals

```graphql
query {
  referrals(first: 50) {
    edges {
      node {
        id
        status
        shop {
          name
          domain
        }
        convertedAt
        commission {
          amount {
            amount
            currencyCode
          }
          rate
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

## Mutations: Common Operations

### Update App Details

```graphql
mutation UpdateApp($input: AppUpdateInput!) {
  appUpdate(input: $input) {
    app {
      id
      title
      description
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
    "id": "gid://shopify/App/1234567890",
    "title": "My Updated App",
    "description": "New description"
  }
}
```

### Manage App Access Scopes

```graphql
mutation UpdateAppScopes($appId: ID!, $scopes: [String!]!) {
  appRequestedAccessScopes(appId: $appId, scopes: $scopes) {
    app {
      id
      requestedScopes
    }
  }
}
```

## Pagination Patterns

### Cursor-Based Pagination

```typescript
async function getAllApps() {
  let hasNextPage = true;
  let endCursor = null;
  let allApps = [];

  while (hasNextPage) {
    const query = `
      query {
        apps(first: 50, after: ${endCursor ? `"${endCursor}"` : 'null'}) {
          edges {
            node {
              id
              title
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    `;

    const result = await makePartnerAPIRequest(query);
    const { apps } = result;

    allApps = allApps.concat(
      apps.edges.map(edge => edge.node)
    );

    hasNextPage = apps.pageInfo.hasNextPage;
    endCursor = apps.pageInfo.endCursor;
  }

  return allApps;
}
```

## Error Handling

```typescript
async function safePartnerAPICall(query, variables = {}) {
  try {
    const response = await fetch('https://api.shopify.com/graphql/2024-10.json', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Access-Token': process.env.SHOPIFY_PARTNER_API_SECRET,
      },
      body: JSON.stringify({ query, variables }),
    });

    const result = await response.json();

    if (result.errors) {
      throw new Error(`GraphQL Error: ${JSON.stringify(result.errors)}`);
    }

    return result.data;
  } catch (error) {
    console.error('Partner API Error:', error);
    throw error;
  }
}
```

## Best Practices

### Rate Limiting

- Partner API has rate limits (typically 2,000 points per minute)
- Batch queries when possible
- Implement exponential backoff for retries
- Cache results in database when appropriate

### Data Synchronization

- Query analytics daily for accurate reporting
- Store results in database for historical analysis
- Use cursors properly for pagination
- Monitor for new fields in API responses

### Security

- Never expose Partner API credentials in frontend code
- Store secrets in environment variables
- Use least-privilege scopes
- Rotate credentials regularly
- Audit API access logs

## Next Steps

- See `partner-api-patterns.md` for real-world query examples
- Review [official Partner API docs](https://shopify.dev/docs/api/partner) for latest schema
- Check [Partner Dashboard](https://partners.shopify.com) for live API testing
- Implement proper error handling and retry logic
