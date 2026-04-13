# Shopify Hydrogen: Implementation Patterns

## Component Patterns

### Product Card Component

```jsx
// app/components/ProductCard.jsx
import {Image, Money, Link} from '@shopify/hydrogen';

export default function ProductCard({product}) {
  return (
    <Link to={`/products/${product.handle}`}>
      <div className="product-card">
        <Image
          data={product.featuredImage}
          alt={product.title}
          width={300}
          height={300}
          sizes="(min-width: 64em) 300px, 100vw"
        />
        <h3>{product.title}</h3>
        <Money data={product.priceRange.minVariantPrice} />
      </div>
    </Link>
  );
}
```

### Product Gallery Component

```jsx
// app/components/ProductGallery.jsx
import {Image} from '@shopify/hydrogen';
import {useState} from 'react';

export default function ProductGallery({images}) {
  const [selectedImage, setSelectedImage] = useState(images[0]);

  return (
    <div className="gallery">
      <Image
        data={selectedImage}
        alt={selectedImage.altText}
        width={600}
        height={600}
      />
      <div className="thumbnails">
        {images.map((image) => (
          <button
            key={image.id}
            onClick={() => setSelectedImage(image)}
            className={selectedImage.id === image.id ? 'active' : ''}
          >
            <Image
              data={image}
              alt={image.altText}
              width={100}
              height={100}
            />
          </button>
        ))}
      </div>
    </div>
  );
}
```

### Variant Selector Component

```jsx
// app/components/VariantSelector.jsx
import {useState} from 'react';

export default function VariantSelector({product, onVariantSelect}) {
  const [selections, setSelections] = useState({});

  const handleOptionChange = (optionName, value) => {
    const newSelections = {...selections, [optionName]: value};
    setSelections(newSelections);

    // Find matching variant
    const selectedVariant = product.variants.edges.find(({node}) => {
      return node.selectedOptions.every(({name, value}) => {
        return newSelections[name] === value;
      });
    })?.node;

    onVariantSelect(selectedVariant);
  };

  return (
    <div className="variant-selector">
      {product.options.map((option) => (
        <div key={option.id}>
          <label>{option.name}</label>
          <select
            value={selections[option.name] || ''}
            onChange={(e) => handleOptionChange(option.name, e.target.value)}
          >
            <option value="">Select {option.name}</option>
            {option.values.map((value) => (
              <option key={value} value={value}>
                {value}
              </option>
            ))}
          </select>
        </div>
      ))}
    </div>
  );
}
```

### Price Display Component

```jsx
// app/components/PriceDisplay.jsx
import {Money} from '@shopify/hydrogen';

export default function PriceDisplay({variant, priceRange}) {
  const price = variant?.price || priceRange?.minVariantPrice;

  if (!price) return null;

  return (
    <div className="price">
      {priceRange?.minVariantPrice?.amount === 
       priceRange?.maxVariantPrice?.amount ? (
        <Money data={price} />
      ) : (
        <div>
          <Money data={priceRange.minVariantPrice} /> -{' '}
          <Money data={priceRange.maxVariantPrice} />
        </div>
      )}
    </div>
  );
}
```

## Loader Patterns

### Products List Loader

```jsx
// app/routes/products._index.jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData} from '@remix-run/react';
import ProductCard from '~/components/ProductCard';

export async function loader({context}) {
  const {products} = await context.storefront.query(
    PRODUCTS_QUERY,
    {
      variables: {
        first: 12,
        sortKey: 'TITLE',
      },
    }
  );

  return json({products});
}

export default function ProductsPage() {
  const {products} = useLoaderData();

  return (
    <div>
      <h1>All Products</h1>
      <div className="products-grid">
        {products.edges.map(({node}) => (
          <ProductCard key={node.id} product={node} />
        ))}
      </div>
    </div>
  );
}

const PRODUCTS_QUERY = `#graphql
  query GetProducts($first: Int!, $sortKey: ProductSortKeys) {
    products(first: $first, sortKey: $sortKey) {
      edges {
        node {
          id
          title
          handle
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
        }
      }
    }
  }
`;
```

### Product Detail Loader

```jsx
// app/routes/products.$handle.jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData} from '@remix-run/react';
import {Image, Money} from '@shopify/hydrogen';

export async function loader({context, params}) {
  const {product} = await context.storefront.query(
    PRODUCT_DETAIL_QUERY,
    {
      variables: {handle: params.handle},
    }
  );

  if (!product) {
    throw new Response('Not Found', {status: 404});
  }

  return json({product});
}

export default function ProductPage() {
  const {product} = useLoaderData();

  return (
    <div>
      <h1>{product.title}</h1>
      <Image data={product.featuredImage} alt={product.title} />
      <Money data={product.priceRange.minVariantPrice} />
      <div dangerouslySetInnerHTML={{__html: product.descriptionHtml}} />
    </div>
  );
}

const PRODUCT_DETAIL_QUERY = `#graphql
  query GetProduct($handle: String!) {
    product(handle: $handle) {
      id
      title
      handle
      description
      descriptionHtml
      featuredImage {
        url
        altText
      }
      images(first: 10) {
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
`;
```

### Collection Loader with Pagination

```jsx
// app/routes/collections.$handle.jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData, useSearchParams} from '@remix-run/react';

export async function loader({context, params, request}) {
  const url = new URL(request.url);
  const cursor = url.searchParams.get('cursor');

  const {collection} = await context.storefront.query(
    COLLECTION_QUERY,
    {
      variables: {
        handle: params.handle,
        first: 20,
        after: cursor,
      },
    }
  );

  return json({collection});
}

export default function CollectionPage() {
  const {collection} = useLoaderData();
  const [searchParams] = useSearchParams();

  return (
    <div>
      <h1>{collection.title}</h1>
      <div className="products-grid">
        {collection.products.edges.map(({node}) => (
          <ProductCard key={node.id} product={node} />
        ))}
      </div>
      {collection.products.pageInfo.hasNextPage && (
        <a
          href={`?cursor=${collection.products.pageInfo.endCursor}`}
        >
          Load More
        </a>
      )}
    </div>
  );
}

const COLLECTION_QUERY = `#graphql
  query GetCollection($handle: String!, $first: Int!, $after: String) {
    collection(handle: $handle) {
      id
      title
      description
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
            featuredImage {
              url
              altText
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
`;
```

## Form and Action Patterns

### Add to Cart Form

```jsx
// app/components/AddToCart.jsx
import {useState} from 'react';
import {useFetcher} from '@remix-run/react';

export default function AddToCart({variant, cartId}) {
  const [quantity, setQuantity] = useState(1);
  const fetcher = useFetcher();

  return (
    <fetcher.Form method="post" action="/cart">
      <input type="hidden" name="cartId" value={cartId} />
      <input type="hidden" name="variantId" value={variant?.id} />
      <input type="hidden" name="action" value="add-to-cart" />
      
      <label>
        Quantity:
        <input
          type="number"
          min="1"
          max={variant?.quantityAvailable}
          value={quantity}
          onChange={(e) => setQuantity(parseInt(e.target.value))}
        />
      </label>

      <button type="submit" disabled={!variant?.availableForSale}>
        {fetcher.state === 'submitting' ? 'Adding...' : 'Add to Cart'}
      </button>
    </fetcher.Form>
  );
}
```

### Cart Action Route

```jsx
// app/routes/cart.jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData} from '@remix-run/react';

export async function action({context, request}) {
  if (request.method !== 'POST') {
    return json({error: 'Method not allowed'}, {status: 405});
  }

  const formData = await request.formData();
  const {storefront} = context;
  const action = formData.get('action');

  switch (action) {
    case 'add-to-cart': {
      const result = await storefront.mutate(ADD_TO_CART_MUTATION, {
        variables: {
          cartId: formData.get('cartId'),
          lines: [{
            merchandiseId: formData.get('variantId'),
            quantity: parseInt(formData.get('quantity') || 1),
          }],
        },
      });
      return json({cart: result.cartLinesAdd.cart});
    }

    case 'remove-from-cart': {
      const result = await storefront.mutate(REMOVE_FROM_CART_MUTATION, {
        variables: {
          cartId: formData.get('cartId'),
          lineIds: [formData.get('lineId')],
        },
      });
      return json({cart: result.cartLinesRemove.cart});
    }

    default:
      return json({error: 'Unknown action'}, {status: 400});
  }
}

export async function loader({context}) {
  const {cart} = await context.storefront.query(GET_CART_QUERY);
  return json({cart});
}

export default function CartPage() {
  const {cart} = useLoaderData();

  return (
    <div>
      <h1>Cart</h1>
      {cart?.lines?.edges?.map(({node}) => (
        <CartItem key={node.id} item={node} />
      ))}
    </div>
  );
}

const ADD_TO_CART_MUTATION = `#graphql
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
                }
              }
            }
          }
        }
      }
    }
  }
`;
```

## Search and Filter Patterns

### Search Results Loader

```jsx
// app/routes/search.jsx
import {json} from '@shopify/remix-oxygen';
import {useLoaderData, useSearchParams} from '@remix-run/react';

export async function loader({context, request}) {
  const url = new URL(request.url);
  const query = url.searchParams.get('q');

  if (!query) {
    return json({products: []});
  }

  const {products} = await context.storefront.query(
    SEARCH_QUERY,
    {
      variables: {
        query,
        first: 20,
      },
    }
  );

  return json({products});
}

export default function SearchPage() {
  const {products} = useLoaderData();
  const [searchParams] = useSearchParams();
  const query = searchParams.get('q');

  return (
    <div>
      <h1>Search Results for "{query}"</h1>
      {products.edges.length === 0 ? (
        <p>No products found.</p>
      ) : (
        <div className="products-grid">
          {products.edges.map(({node}) => (
            <ProductCard key={node.id} product={node} />
          ))}
        </div>
      )}
    </div>
  );
}

const SEARCH_QUERY = `#graphql
  query Search($query: String!, $first: Int!) {
    products(first: $first, query: $query) {
      edges {
        node {
          id
          title
          handle
          featuredImage {
            url
            altText
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
`;
```

## Deferred Data Loading Pattern

```jsx
// app/routes/products.$handle.jsx
import {defer} from '@shopify/remix-oxygen';
import {Await} from '@remix-run/react';
import {Suspense} from 'react';

export async function loader({context, params}) {
  const {product} = await context.storefront.query(
    PRODUCT_QUERY,
    {variables: {handle: params.handle}}
  );

  // Load recommendations asynchronously
  const recommendationsPromise = context.storefront.query(
    RECOMMENDATIONS_QUERY,
    {variables: {productId: product.id}}
  );

  return defer({
    product,
    recommendations: recommendationsPromise,
  });
}

export default function ProductPage() {
  const {product, recommendations} = useLoaderData();

  return (
    <div>
      <ProductDetail product={product} />

      <Suspense fallback={<div>Loading recommendations...</div>}>
        <Await resolve={recommendations}>
          {({products}) => (
            <div>
              <h2>You Might Also Like</h2>
              {products.edges.map(({node}) => (
                <ProductCard key={node.id} product={node} />
              ))}
            </div>
          )}
        </Await>
      </Suspense>
    </div>
  );
}
```
