# Shopify Development Patterns & CLI Reference

## CLI Commands Quick Reference

### App Management

```bash
# Create new app
shopify app create --name my-app --template remix

# Start development server
shopify app dev

# Deploy to production
shopify app deploy

# Build locally
npm run build

# Run tests
npm test
```

### Extension Generation

```bash
# Generate extension
shopify app generate extension --type <type>

# Generate webhook handler
shopify app generate webhook --topic orders/create

# Generate admin link
shopify app generate admin --route /admin/custom
```

### Authentication

```bash
# Login to Partner account
shopify auth login

# Check current auth status
shopify auth whoami

# Logout
shopify auth logout
```

## App Lifecycle Patterns

### Development to Production Flow

```
1. Local Development
   ├─ shopify app dev
   ├─ Access test store at https://localhost:3000
   └─ Webhooks tunnel via ngrok

2. Testing
   ├─ Unit tests (Jest)
   ├─ Integration tests (test stores)
   └─ Manual testing on dev store

3. Staging
   ├─ Deploy to staging environment
   ├─ Full QA testing
   └─ Performance validation

4. Production
   ├─ shopify app deploy
   ├─ Version released to App Store
   └─ Monitor metrics
```

### Environment Setup

**.env** file for local development:

```bash
SHOPIFY_API_KEY=<key>
SHOPIFY_API_SECRET=<secret>
SHOPIFY_API_VERSION=2025-04
SHOPIFY_API_SCOPES=write_products,read_orders
```

## Common Patterns

### API Request Pattern

```typescript
// Using Admin API
async function getProducts(client) {
  const query = `
    query {
      products(first: 10) {
        edges {
          node {
            id
            title
          }
        }
      }
    }
  `;

  const response = await client.request(query);
  return response.data.products.edges;
}
```

### Error Handling Pattern

```typescript
try {
  const result = await apiCall();
  return json({ success: true, data: result });
} catch (error) {
  console.error('API Error:', error);
  return json(
    { error: error.message },
    { status: error.status || 500 }
  );
}
```

### Loading States Pattern

```typescript
import { useEffect, useState } from 'react';

export function DataComponent() {
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setIsLoading(true);
        const response = await fetch('/api/data');
        if (!response.ok) throw new Error('Failed to load');
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    }

    fetchData();
  }, []);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>{/* render data */}</div>;
}
```

## Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Performance optimized
- [ ] Security audit complete
- [ ] Environment variables set
- [ ] Webhooks configured
- [ ] Logging configured
- [ ] Error handling in place
- [ ] Documentation updated
- [ ] Version bumped (semantic versioning)

## Troubleshooting Common Issues

### Port 3000 Already in Use

```bash
# Kill process on port 3000
lsof -i :3000 | grep LISTEN | awk '{print $2}' | xargs kill -9

# Or use different port
shopify app dev --port 3001
```

### Webhook Not Receiving Events

1. Check ngrok tunnel is active
2. Verify webhook URL in shopify.app.toml
3. Confirm HMAC validation
4. Check store has test orders

### Session Token Invalid

1. Verify app is embedded in admin
2. Check session token scope matches API scopes
3. Ensure token not expired (tokens expire after 30 minutes)
4. Verify backend validates token correctly

## Performance Optimization Tips

- Use GraphQL batch queries for multiple products
- Implement pagination (first, after, before)
- Cache store-level data (metafields, settings)
- Use bulk operations for bulk product updates
- Minimize API calls in event handlers
- Defer non-critical webhooks
- Use CDN for static assets

## Security Checklist

- [ ] Store API credentials in environment variables
- [ ] Validate webhook HMAC signatures
- [ ] Use HTTPS for all requests
- [ ] Implement rate limiting
- [ ] Sanitize user input
- [ ] Use parameterized queries
- [ ] Rotate API credentials regularly
- [ ] Audit API scopes (least privilege)
