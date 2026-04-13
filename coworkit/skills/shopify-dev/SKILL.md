---
name: shopify-dev
description: General-purpose Shopify development knowledge covering CLI usage, app architecture, App Bridge communication, testing strategies, and deployment patterns for embedded apps and extensions.
version: 0.1.0
---

# Shopify Development

This skill covers core Shopify app development concepts, CLI workflows, and best practices for building production-ready applications. Use this skill for questions about app architecture, CLI commands, embedded apps, OAuth flows, webhooks, and deployment strategies.

## Shopify CLI Overview

The Shopify CLI is your primary tool for scaffolding, developing, and deploying Shopify apps and extensions.

### Installation

```bash
# macOS
brew tap shopify/shopify
brew install shopify-cli

# Linux/WSL
curl -fsSL https://shopify-cli-releases.s3.us-east-1.amazonaws.com/v3/shopify-cli-linux.zip -o shopify-cli.zip
unzip shopify-cli.zip
cd shopify-cli-*/bin
sudo mv shopify /usr/local/bin

# Verify installation
shopify version
```

### Authentication

```bash
# Authenticate with Shopify Partner account
shopify auth login

# Verify authentication status
shopify auth whoami

# Logout
shopify auth logout
```

## App Project Structure

### Create a New App

```bash
shopify app create

# Prompts:
# 1. App name
# 2. Template: remix (Node.js + Remix), node (Node.js + Express), php, or go
# 3. Optional: include sample extensions
```

### Generated Project Layout

```
my-app/
├── shopify.app.toml          # App configuration
├── .env                      # Environment variables
├── .env.example              # Template for .env
├── web/
│   ├── frontend/             # React frontend (Remix)
│   │   ├── routes/
│   │   ├── components/
│   │   └── styles/
│   ├── backend/              # Node.js backend
│   │   ├── index.ts
│   │   └── middleware/
│   └── package.json
├── extensions/               # App extensions
│   ├── my-extension/
│   │   └── shopify.extension.toml
├── remix.config.js           # Remix configuration
└── tsconfig.json
```

## App Types and Architecture

### Embedded Apps

Embedded apps run within the Shopify Admin and use the Polaris design system.

```bash
# Create an embedded app with default Remix template
shopify app create --name my-app --template remix
```

**Key characteristics:**
- Loaded in Shopify Admin UI via iframe
- Session token authentication (sessionToken API)
- Access to Shopify Admin APIs
- Use App Bridge for admin communication
- App icons and navigation

### Custom Apps

Custom apps are installed directly on a store for admin use or API access.

```bash
# Via Admin dashboard:
# Settings > Apps and integrations > Develop apps > Create an app
```

**Key characteristics:**
- Store-specific (not shared across multiple stores)
- Direct Admin API access
- No iframe embedding
- Admin and merchant APIs available

### Public Apps

Public apps are distributed through the Shopify App Store.

**Requirements:**
- Partner account in good standing
- Stripe account for billing (if charging)
- Privacy policy and terms of service
- Public listing with clear description
- Support contact information

## OAuth and Authentication

### Session Token Flow (Embedded Apps)

For embedded apps running in the Admin:

```typescript
// Frontend: Obtain session token
import { useAppBridge } from '@shopify/app-bridge-react';

export function MyComponent() {
  const app = useAppBridge();

  const getSessionToken = async () => {
    const token = await app.getSessionToken();
    // Send to backend in Authorization header
    return token;
  };

  return <button onClick={getSessionToken}>Get Token</button>;
}
```

```typescript
// Backend: Verify session token
import { shopifyApp } from '@shopify/shopify-app-express';

const shopify = shopifyApp({
  apiKey: process.env.SHOPIFY_API_KEY,
  apiSecret: process.env.SHOPIFY_API_SECRET,
  scopes: ['write_products', 'read_orders'],
  distribution: {
    apiVersion: '2025-04',
  },
});

app.post('/api/products', async (req, res) => {
  // Session token validation happens automatically
  const { session } = req;
  const client = new shopify.rest.Client({
    session: session,
  });
  // Use client to make API calls
});
```

### OAuth Code Exchange (Public Apps)

```typescript
// After merchant clicks "Install"
// 1. Redirect to authorize URL
const authorizeUrl = `https://${shop}/admin/oauth/authorize?client_id=${apiKey}&scope=${scopes}&redirect_uri=${redirectUri}`;

// 2. Shopify redirects back with code
// 3. Backend exchanges code for access token
const response = await fetch(`https://${shop}/admin/oauth/access_token`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    client_id: process.env.SHOPIFY_API_KEY,
    client_secret: process.env.SHOPIFY_API_SECRET,
    code: req.query.code,
  }),
});

const { access_token, scope } = await response.json();
// Store access_token securely (encrypted database)
```

## Webhooks

Webhooks allow your app to react to events in Shopify.

### Register Webhooks

```bash
shopify app generate webhook --topic orders/create
```

### Webhook Configuration (shopify.app.toml)

```toml
scopes = "write_products,read_orders,write_orders"

webhooks = [
  { topics = "orders/create", uri = "/webhooks/orders-create" },
  { topics = "orders/updated", uri = "/webhooks/orders-updated" },
  { topics = "products/create", uri = "/webhooks/products-create" },
  { topics = "customers/create", uri = "/webhooks/customers-create" }
]
```

### Webhook Handler

```typescript
// pages/webhooks/orders-create.ts
import { json } from '@remix-run/node';
import type { LoaderFunctionArgs } from '@remix-run/node';

export async function loader({ request }: LoaderFunctionArgs) {
  if (request.method !== 'POST') {
    return json({ error: 'Method not allowed' }, { status: 405 });
  }

  const payload = await request.json();
  const orderId = payload.id;
  const status = payload.financial_status;

  // Process webhook (e.g., save to database, trigger action)
  console.log(`Order ${orderId} created with status: ${status}`);

  return json({ success: true });
}
```

## App Bridge Integration

App Bridge enables communication between your embedded app and the Shopify Admin.

### Core App Bridge APIs

```typescript
import { useAppBridge } from '@shopify/app-bridge-react';

export function MyComponent() {
  const app = useAppBridge();

  // Notifications
  app.dispatch({
    type: 'notification',
    payload: {
      title: 'Success',
      message: 'Product updated',
      notificationType: 'success',
      duration: 5,
    },
  });

  // Navigation (modal)
  app.dispatch({
    type: 'modal',
    payload: {
      isOpen: true,
      title: 'Create Product',
    },
  });

  // Resource picker (products, customers, etc.)
  const { resourcePicker } = app.modal;
  resourcePicker({
    resources: {
      products: {
        action: 'select',
        onSelection: (resources) => {
          console.log('Selected products:', resources.products);
        },
      },
    },
  });
}
```

### Session Token Usage

```typescript
// Get current user and shop context
const app = useAppBridge();
const token = await app.getSessionToken();

// Verify in backend - token automatically decoded by middleware
const response = await fetch('/api/my-endpoint', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({ /* data */ }),
});
```

## Testing Apps

### Local Development

```bash
# Start development server with hot reload
shopify app dev

# This:
# 1. Creates a test app on your Partner account
# 2. Starts local development server on localhost:3000
# 3. Tunnels requests through Shopify
# 4. Creates ngrok tunnel for webhooks
```

### Automated Testing

```typescript
// Example: Jest + React Testing Library
import { render, screen } from '@testing-library/react';
import { useAppBridge } from '@shopify/app-bridge-react';
import MyComponent from '../MyComponent';

jest.mock('@shopify/app-bridge-react');

describe('MyComponent', () => {
  beforeEach(() => {
    const mockApp = {
      getSessionToken: jest.fn().mockResolvedValue('test-token'),
    };
    (useAppBridge as jest.Mock).mockReturnValue(mockApp);
  });

  it('renders successfully', () => {
    render(<MyComponent />);
    expect(screen.getByText(/my content/i)).toBeInTheDocument();
  });
});
```

### Store Testing

```bash
# Create test store on Partner dashboard
# Settings > Development stores

# Install app on test store:
shopify app dev --store your-test-store.myshopify.com
```

## Deployment

### Build for Production

```bash
npm run build
```

### Deploy to Shopify

```bash
# Deploy all extensions and app
shopify app deploy

# Deploy specific extension only
shopify app deploy --extensions my-extension
```

### Post-Deployment

1. **Verify deployment**: Check Partner dashboard for version updates
2. **Monitor performance**: Use Shopify admin logs and error tracking
3. **Release notes**: Document changes for merchants
4. **Version management**: Use semantic versioning (major.minor.patch)

## Configuration: shopify.app.toml

```toml
scopes = "write_products,read_orders,write_orders,read_customers"

webhooks = [
  { topics = "orders/create", uri = "/webhooks/orders-create" },
  { topics = "products/update", uri = "/webhooks/products-update" }
]

[build]
dev_store_url = "my-dev-store.myshopify.com"
api_version = "2025-04"

[[extensions]]
type = "product_subscription"
name = "My Subscription Extension"
handle = "my-subscription"
```

## Extension Generation

### Generate Extension Types

```bash
# Product subscription
shopify app generate extension --type product_subscription

# Checkout UI
shopify app generate extension --type checkout_ui_extension

# Post-purchase
shopify app generate extension --type post_purchase

# Function (discounts, shipping, payments)
shopify app generate extension --type function --function-type product-discount
```

## Best Practices

### Security

- Store access tokens in encrypted database
- Use session tokens for embedded app auth
- Validate webhook HMAC signatures
- Implement CSRF protection
- Use HTTPS only (Shopify enforces)
- Rotate API credentials regularly

### Performance

- Minimize API calls - use bulk operations
- Cache merchant data where appropriate
- Use GraphQL batch queries
- Implement rate-limit handling
- Optimize database queries
- Use CDN for static assets

### User Experience

- Implement loading states
- Show clear error messages
- Use Polaris components consistently
- Provide help/documentation
- Handle network failures gracefully
- Log errors for debugging

## Next Steps

- See `dev-patterns.md` for CLI commands reference and common patterns
- Review [Shopify app development docs](https://shopify.dev/docs/apps) for complete API reference
- Check [app examples](https://github.com/Shopify/shopify-app-js) for working implementations
- Explore [Polaris design system](https://polaris.shopify.com) for UI components
