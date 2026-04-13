---
name: shopify-hydrogen
description: Triggers on "Hydrogen", "headless storefront", "React storefront", "Hydrogen components", "Storefront API", "custom storefront". Build fast, dynamic headless storefronts with Shopify Hydrogen framework using React and Remix.
version: 0.1.0
---

# Shopify Hydrogen: Building Headless Storefronts

Hydrogen is Shopify's opinionated React framework for building custom storefronts with server-side rendering, performance optimizations, and Storefront API integration built-in. It combines Remix for routing and data loading with specialized Hydrogen components.

## Important: Use @shopify/hydrogen, Not hydrogen-react

Always use the full Hydrogen framework package for building storefronts:

```bash
npm create @shopify/hydrogen@latest
npm install @shopify/hydrogen
```

The `hydrogen-react` package is for component composition only and lacks the full framework setup, routing, and optimization features.

## Core Architecture

### File Structure

```
my-hydrogen-storefront/
├── hydrogen.config.js
├── remix.config.js
├── app/
│   ├── root.jsx                 # Root layout
│   ├── routes/
│   │   ├── index.jsx           # Home page
│   │   ├── products._index.jsx  # All products
│   │   ├── products.$handle.jsx # Product detail
│   │   ├── cart.jsx            # Cart page
│   │   └── account/
│   │       ├── index.jsx
│   │       ├── orders.jsx
│   │       └── profile.jsx
│   ├── components/             # Reusable components
│   ├── lib/                    # Utilities
│   └── styles/
├── server.js
└── package.json
```

## Hydrogen Components (Data Display)

Hydrogen provides optimized components that RENDER data, not FETCH it. Data comes from loaders.

### Image Component

```jsx
import {Image} from '@shopify/hydrogen';

export default function ProductCard({product}) {
  return (
    <Image
      data={product.featuredImage}
      alt={product.title}
      width={300}
      height={300}
    />
  );
}
```

### Video Component

```jsx
import {Video} from '@shopify/hydrogen';

export default function ProductVideo({video}) {
  return (
    <Video
      data={video}
      width={600}
      height={400}
      controls
    />
  );
}
```

### Money Component

Formats currency consistently:

```jsx
import {Money} from '@shopify/hydrogen';

export default function Price({price}) {
  return (
    <Money
      data={price}
      as="span"
    />
  );
}
```

### ShopPay Component

Enables Shop Pay button in your storefront:

```jsx
import {ShopPayButton} from '@shopify/hydrogen';

export default function BuyButton({variantId, shop}) {
  return (
    <ShopPayButton
      variantIds={[variantId]}
      storeDomain={shop.myshopifyDomain}
    />
  );
}
```

## Remix Data Loading Pattern

### Loader Pattern: Fetch Data on Server

Data comes from Remix loaders, executed on the server:

```jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData} from '@remix-run/react';
import {Image, Money} from '@shopify/hydrogen';

export async function loader({context, params}) {
  const {storefront} = context;
  const {handle} = params;

  // Fetch on server, never expose to client
  const product = await storefront.query(PRODUCT_QUERY, {
    variables: {handle},
  });

  return json({product});
}

export default function ProductPage() {
  const {product} = useLoaderData();

  return (
    <div>
      <h1>{product.title}</h1>
      <Image data={product.featuredImage} alt={product.title} />
      <Money data={product.priceRange.minVariantPrice} />
    </div>
  );
}
```

### Storefront API Query in Loader

```jsx
const PRODUCT_QUERY = `#graphql
  query GetProduct($handle: String!) {
    product(handle: $handle) {
      id
      title
      handle
      description
      featuredImage {
        url
        altText
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
            image {
              url
              altText
            }
          }
        }
      }
    }
  }
`;

export async function loader({context, params}) {
  return json({
    product: await context.storefront.query(PRODUCT_QUERY, {
      variables: {handle: params.handle},
    }),
  });
}
```

## Routing with Remix

### Basic Routes

```jsx
// app/routes/index.jsx - Home page
export default function Home() {
  return <h1>Welcome</h1>;
}

// app/routes/products._index.jsx - Products list
export async function loader({context}) {
  const {products} = await context.storefront.query(`
    query {
      products(first: 10) {
        edges { node { id title handle } }
      }
    }
  `);
  return json({products});
}

// app/routes/products.$handle.jsx - Product detail
export async function loader({context, params}) {
  // Fetch specific product
  return json({product: await getProduct(params.handle)});
}
```

### Dynamic Routes

```jsx
// app/routes/collections.$handle.jsx
export async function loader({context, params}) {
  const {collection} = await context.storefront.query(
    COLLECTION_QUERY,
    {variables: {handle: params.handle}}
  );
  return json({collection});
}

export default function CollectionPage() {
  const {collection} = useLoaderData();
  return (
    <div>
      <h1>{collection.title}</h1>
      {collection.products.edges.map(({node}) => (
        <ProductCard key={node.id} product={node} />
      ))}
    </div>
  );
}
```

## Cart Operations

### Fetch Cart Data

```jsx
const CART_QUERY = `#graphql
  query GetCart($id: ID!) {
    cart(id: $id) {
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
                  handle
                  title
                }
                image {
                  url
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
        totalAmount {
          amount
          currencyCode
        }
        totalTaxAmount {
          amount
        }
      }
    }
  }
`;
```

### Cart Mutations

```jsx
export async function action({context, request}) {
  const {storefront} = context;

  if (request.method === 'POST') {
    const formData = await request.formData();
    const action = formData.get('action');

    if (action === 'add-to-cart') {
      const result = await storefront.mutate(ADD_TO_CART_MUTATION, {
        variables: {
          cartId: formData.get('cartId'),
          lines: [{
            merchandiseId: formData.get('variantId'),
            quantity: 1,
          }],
        },
      });
      return json({cart: result.cartLinesAdd.cart});
    }
  }
}

const ADD_TO_CART_MUTATION = `#graphql
  mutation AddToCart($cartId: ID!, $lines: [CartLineInput!]!) {
    cartLinesAdd(cartId: $cartId, lines: $lines) {
      cart {
        id
        lines(first: 10) {
          edges { node { id quantity } }
        }
      }
    }
  }
`;
```

## Analytics Integration

### Use Analytics API

```jsx
import {useServerAnalytics} from '@shopify/hydrogen';

export default function ProductPage() {
  const {product} = useLoaderData();
  const {publish} = useServerAnalytics();

  useEffect(() => {
    // Track page view
    publish({
      '@context': 'https://schema.org',
      '@type': 'Product',
      name: product.title,
      url: window.location.href,
    });
  }, [product]);

  return <div>{product.title}</div>;
}
```

## Customer Accounts

### Use Customer Account API

```jsx
// Get customer profile in loader
export async function loader({context}) {
  const {customer} = await context.storefront.query(
    CUSTOMER_QUERY,
    {
      variables: {customerAccessToken: context.customerAccessToken},
    }
  );
  return json({customer});
}

// Customer order history
const CUSTOMER_ORDERS = `#graphql
  query {
    customer(customerAccessToken: $token) {
      id
      email
      orders(first: 10) {
        edges {
          node {
            id
            orderNumber
            processedAt
            totalPrice {
              amount
            }
          }
        }
      }
    }
  }
`;
```

## B2B, Bundles, and Subscriptions

### B2B Pricing with Metafields

```jsx
export async function loader({context, params}) {
  const product = await context.storefront.query(
    PRODUCT_WITH_B2B_QUERY,
    {variables: {handle: params.handle}}
  );

  const wholesalePrice = product.metafield({
    namespace: '$app',
    key: 'wholesale_price',
  });

  return json({product, wholesalePrice});
}

const PRODUCT_WITH_B2B_QUERY = `#graphql
  query GetProduct($handle: String!) {
    product(handle: $handle) {
      id
      title
      metafield(namespace: "$app", key: "wholesale_price") {
        value
      }
    }
  }
`;
```

### Bundle Handling

```jsx
export default function BundleProduct({product}) {
  const [selectedItems, setSelectedItems] = useState([]);

  const handleAddToCart = async (cartId) => {
    const bundleLines = selectedItems.map(itemId => ({
      merchandiseId: itemId,
      quantity: 1,
    }));

    await fetch('/cart', {
      method: 'POST',
      body: JSON.stringify({
        cartId,
        lines: bundleLines,
      }),
    });
  };

  return (
    <div>
      <h1>{product.title}</h1>
      {product.options.map(option => (
        <div key={option.id}>
          <label>{option.name}</label>
          {option.values.map(value => (
            <input
              key={value}
              type="checkbox"
              value={value}
              onChange={() => toggleItem(value)}
            />
          ))}
        </div>
      ))}
      <button onClick={() => handleAddToCart(cartId)}>
        Add Bundle to Cart
      </button>
    </div>
  );
}
```

### Subscription Products

```jsx
const SUBSCRIPTION_VARIANT_QUERY = `#graphql
  query GetSubscriptionVariant($handle: String!) {
    product(handle: $handle) {
      id
      sellingPlanGroups(first: 5) {
        edges {
          node {
            id
            name
            sellingPlans(first: 5) {
              edges {
                node {
                  id
                  name
                  billingPolicy {
                    interval
                    intervalCount
                  }
                }
              }
            }
          }
        }
      }
    }
  }
`;

export default function SubscriptionProduct({product}) {
  const [selectedPlan, setSelectedPlan] = useState(null);

  return (
    <div>
      <h1>{product.title}</h1>
      {product.sellingPlanGroups?.map(group => (
        <div key={group.id}>
          {group.sellingPlans.map(plan => (
            <label key={plan.id}>
              <input
                type="radio"
                value={plan.id}
                onChange={() => setSelectedPlan(plan)}
              />
              {plan.name}
            </label>
          ))}
        </div>
      ))}
    </div>
  );
}
```

## Performance Optimization

### Defer Non-Critical Data

```jsx
import {defer} from '@shopify/remix-oxygen';
import {Await} from '@remix-run/react';
import {Suspense} from 'react';

export async function loader({context}) {
  return defer({
    // Critical data fetched immediately
    product: getProduct(context),
    // Non-critical data loaded in background
    recommendations: getRecommendations(context),
  });
}

export default function ProductPage() {
  const {product, recommendations} = useLoaderData();

  return (
    <div>
      {/* Product renders immediately */}
      <ProductDetails product={product} />

      {/* Recommendations stream in */}
      <Suspense fallback={<div>Loading recommendations...</div>}>
        <Await resolve={recommendations}>
          {(recs) => <RecommendationsList items={recs} />}
        </Await>
      </Suspense>
    </div>
  );
}
```

### Server-Side Rendering (SSR)

Hydrogen handles SSR by default with Remix:

```jsx
// This route is server-rendered (fast initial page load)
export default function Page() {
  const {product} = useLoaderData(); // Data from server
  return <ProductDetail product={product} />;
}
```

## Environment Setup

### hydrogen.config.js

```javascript
export default {
  session: {
    cookieName: 'hydrogen-session',
    secret: process.env.SESSION_SECRET,
    expirationTime: 30 * 24 * 60 * 60,
  },
  storefront: {
    // Uses environment variables
    apiUrl: process.env.STOREFRONT_API_URL,
    accessToken: process.env.STOREFRONT_ACCESS_TOKEN,
    apiVersion: '2024-01',
  },
};
```

### .env File

```
STOREFRONT_API_URL=https://your-store.myshopify.com/api/2024-01/graphql.json
STOREFRONT_ACCESS_TOKEN=your_public_access_token
SESSION_SECRET=your_secret_key
```

## Next Steps

- See `hydrogen-patterns.md` for component integration examples and loader patterns
- Review [Hydrogen documentation](https://hydrogen.shopify.dev)
- Explore [Remix documentation](https://remix.run) for routing and data loading
- Deploy with Oxygen for optimal Hydrogen performance
- Implement Customer Account Extensions for custom account pages
