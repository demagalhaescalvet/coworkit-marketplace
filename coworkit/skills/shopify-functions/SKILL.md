---
name: shopify-functions
description: Triggers on "create a Shopify Function", "build a custom discount", "customize shipping rates", "validate payment", "write a cart transform". Learn to build Shopify Functions for custom business logic in discounts, shipping, payments, and cart operations.
version: 0.1.0
---

# Shopify Functions

Shopify Functions let you customize backend logic without modifying Shopify core systems. This skill covers function types, setup, input queries, implementation, and testing.

## Function Types

| Function Type | Purpose | Trigger | Output |
|---------------|---------|---------|--------|
| `product-discount` | Custom product discounts | Cart operations | Discount amount |
| `order-discount` | Order-level discounts | Cart operations | Discount amount |
| `shipping-discount` | Shipping rate adjustments | Shipping calculation | Discount amount |
| `payment-method` | Payment method filtering | Checkout | Allowed/hidden methods |
| `delivery-customization` | Delivery option filtering | Checkout | Available options |
| `cart-transform` | Modify cart lines | Cart operations | Modified cart state |
| `fulfillment-constraint` | Inventory/fulfillment rules | Fulfillment | Constraints |
| `order-routing` | Route orders to locations | Order creation | Fulfillment location |

## Project Setup

### Initialize a Function

```bash
shopify app generate extension --type function --language javascript
# or
shopify app generate extension --type function --language rust
```

### Project Structure

```
extensions/my-function/
├── input.graphql          # Query for function input
├── src/
│   └── index.js           # Function implementation (JS)
│   └── lib.rs             # Function implementation (Rust)
├── shopify.function.toml  # Function configuration
└── README.md
```

## Input Query

Define what data the function receives via `input.graphql`:

```graphql
# extensions/product-discount-function/input.graphql
query Input {
  cart {
    lines {
      quantity
      merchandise {
        ... on ProductVariant {
          id
          product {
            title
            handle
          }
          price {
            amount
          }
        }
      }
    }
  }
}
```

## Function Logic: JavaScript

### Product Discount Example

```javascript
// extensions/product-discount-function/src/index.js

/**
 * Apply 10% discount to products with tag "sale"
 */
export function run(input) {
  const discounts = [];

  input.cart.lines.forEach((line, index) => {
    // Check if product has "sale" tag
    if (line.merchandise.product?.tags?.includes('sale')) {
      const discountAmount = {
        percentage: {
          value: '10.0',
        },
      };

      discounts.push({
        targets: [
          {
            lineItem: {
              index: index.toString(),
            },
          },
        ],
        value: discountAmount,
        message: '10% off sale items',
      });
    }
  });

  return {
    discounts: discounts,
  };
}
```

### Shipping Discount Example

```javascript
// extensions/shipping-discount-function/src/index.js

/**
 * Free shipping for orders over $100
 */
export function run(input) {
  const cartTotal = input.cart.cost.subtotalAmount.amount;

  if (cartTotal >= 100) {
    return {
      discounts: [
        {
          targets: [
            {
              shippingMethod: {
                handle: input.shipping.shippingMethod.handle,
              },
            },
          ],
          value: {
            percentage: {
              value: '100.0',
            },
          },
          message: 'Free shipping on orders over $100',
        },
      ],
    };
  }

  return {
    discounts: [],
  };
}
```

### Cart Transform Example

```javascript
// extensions/cart-transform-function/src/index.js

/**
 * Bundle products: buy product A, get product B at 50% off
 */
export function run(input) {
  const operations = [];

  // Find if bundle trigger product (A) is in cart
  const bundleTriggerIndex = input.cart.lines.findIndex(
    (line) => line.merchandise.product?.id === 'gid://shopify/Product/123'
  );

  // If trigger exists, apply discount to bundle product (B)
  if (bundleTriggerIndex >= 0) {
    input.cart.lines.forEach((line, index) => {
      if (
        line.merchandise.product?.id === 'gid://shopify/Product/456' &&
        index !== bundleTriggerIndex
      ) {
        operations.push({
          update: {
            line: {
              index: index.toString(),
            },
            price: {
              percentageDeduction: {
                value: '50.0',
              },
            },
          },
        });
      }
    });
  }

  return {
    operations: operations,
  };
}
```

## Function Logic: Rust

### Basic Rust Implementation

```rust
// extensions/product-discount-function/src/lib.rs

use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct Input {
    pub cart: Cart,
}

#[derive(Debug, Deserialize)]
pub struct Cart {
    pub lines: Vec<CartLine>,
}

#[derive(Debug, Deserialize)]
pub struct CartLine {
    pub index: i32,
    pub merchandise: Merchandise,
}

#[derive(Debug, Deserialize)]
pub struct Merchandise {
    pub product: Option<Product>,
}

#[derive(Debug, Deserialize)]
pub struct Product {
    pub title: String,
    pub tags: Option<Vec<String>>,
}

#[derive(Debug, Serialize)]
pub struct FunctionResult {
    pub discounts: Vec<Discount>,
}

#[derive(Debug, Serialize)]
pub struct Discount {
    pub targets: Vec<Target>,
    pub value: Value,
    pub message: String,
}

#[derive(Debug, Serialize)]
pub struct Target {
    pub line_item: LineItem,
}

#[derive(Debug, Serialize)]
pub struct LineItem {
    pub index: String,
}

#[derive(Debug, Serialize)]
pub struct Value {
    pub percentage: Percentage,
}

#[derive(Debug, Serialize)]
pub struct Percentage {
    pub value: String,
}

#[no_mangle]
pub fn run(input: Input) -> FunctionResult {
    let mut discounts = vec![];

    for line in input.cart.lines {
        if let Some(product) = &line.merchandise.product {
            if let Some(tags) = &product.tags {
                if tags.contains(&"sale".to_string()) {
                    discounts.push(Discount {
                        targets: vec![Target {
                            line_item: LineItem {
                                index: line.index.to_string(),
                            },
                        }],
                        value: Value {
                            percentage: Percentage {
                                value: "10.0".to_string(),
                            },
                        },
                        message: "10% off sale items".to_string(),
                    });
                }
            }
        }
    }

    FunctionResult { discounts }
}
```

## Configuration: TOML

Configure the function in `shopify.function.toml`:

```toml
# extensions/product-discount-function/shopify.function.toml
name = "Product Discount"
description = "Apply discounts to products based on custom rules"
spec_version = "1.0"

[[extensions]]
type = "function"
name = "Product Discount"
handle = "product-discount"
build = { interpreter = "node", command = "npm run build" }
input_query = "input.graphql"
function_type = "product-discount"
API_version = "2024-10"

[[configuration]]
key = "discount_percentage"
type = "string"
name = "Discount Percentage"
description = "Percentage discount to apply"
default_value = "10"
```

## Testing Functions

### Local Testing

```bash
shopify function test
```

Create test input in `input.json`:

```json
{
  "cart": {
    "lines": [
      {
        "quantity": 1,
        "merchandise": {
          "id": "gid://shopify/ProductVariant/456",
          "product": {
            "title": "Sale Product",
            "tags": ["sale"]
          },
          "price": {
            "amount": "50.00"
          }
        }
      }
    ],
    "cost": {
      "subtotalAmount": {
        "amount": "50.00"
      }
    }
  }
}
```

Run test:
```bash
shopify function run --input input.json
```

### Automated Testing

```javascript
// extensions/product-discount-function/src/index.test.js
import { run } from './index';

describe('Product Discount Function', () => {
  it('applies discount to sale items', () => {
    const input = {
      cart: {
        lines: [
          {
            index: 0,
            merchandise: {
              product: {
                title: 'Sale Product',
                tags: ['sale'],
              },
            },
          },
        ],
      },
    };

    const result = run(input);

    expect(result.discounts).toHaveLength(1);
    expect(result.discounts[0].value.percentage.value).toBe('10.0');
  });

  it('ignores non-sale items', () => {
    const input = {
      cart: {
        lines: [
          {
            index: 0,
            merchandise: {
              product: {
                title: 'Regular Product',
                tags: [],
              },
            },
          },
        ],
      },
    };

    const result = run(input);

    expect(result.discounts).toHaveLength(0);
  });
});
```

## Performance Constraints

All Shopify Functions must adhere to strict performance limits:

- **Execution time**: Max 10ms
- **Memory**: Max 1MB
- **Output size**: Max response payload

Optimize code to stay within limits:

```javascript
// Good: Early exit to reduce processing
export function run(input) {
  // Exit early if cart is empty
  if (!input.cart?.lines || input.cart.lines.length === 0) {
    return { discounts: [] };
  }

  // Process only what's needed
  const discounts = input.cart.lines
    .filter((line) => shouldApplyDiscount(line))
    .map((line) => createDiscount(line));

  return { discounts };
}

// Avoid: Complex nested loops or expensive operations
function shouldApplyDiscount(line) {
  // Simple condition check
  return line.merchandise?.product?.tags?.includes('sale');
}

function createDiscount(line) {
  return {
    targets: [{ lineItem: { index: line.index.toString() } }],
    value: { percentage: { value: '10.0' } },
  };
}
```

## Deployment

### Deploy Function

```bash
shopify app deploy
```

This deploys the function to Shopify and makes it available for use.

### Enable in Store

1. Go to Shopify admin
2. Navigate to the app
3. Enable the function in settings
4. Configure rules/conditions as needed

## Next Steps

- See `functions-advanced.md` for advanced patterns like metafield configuration, cart transforms, and testing strategies.
- Review the [official Functions docs](https://shopify.dev/docs/api/functions) for complete API reference.
- Check [function examples](https://github.com/Shopify/function-examples) for community patterns and best practices.
