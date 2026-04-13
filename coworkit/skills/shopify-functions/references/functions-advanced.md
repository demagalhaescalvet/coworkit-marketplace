# Advanced Shopify Functions Patterns

## Testing Strategies

### Unit Testing with Jest

```javascript
// extensions/product-discount-function/src/index.test.js
import { run } from './index';

describe('Product Discount Function - Advanced', () => {
  it('handles null merchandise gracefully', () => {
    const input = {
      cart: {
        lines: [
          {
            index: 0,
            merchandise: null,
          },
        ],
      },
    };
    expect(() => run(input)).not.toThrow();
  });

  it('respects quantity multipliers', () => {
    const input = {
      cart: {
        lines: [
          {
            index: 0,
            quantity: 5,
            merchandise: {
              product: {
                tags: ['bulk'],
                price: { amount: '10.00' },
              },
            },
          },
        ],
      },
    };
    const result = run(input);
    expect(result.discounts[0].value).toMatch(/bulk/i);
  });
});
```

### Integration Testing

Test against actual Shopify Function runtime via:

```bash
shopify function test --input examples/bulk-order.json
```

## Debugging Techniques

### Logging to Stdout

```javascript
export function run(input) {
  console.log('Cart lines:', input.cart.lines.length);
  const discounts = [];
  
  input.cart.lines.forEach((line) => {
    console.log(`Processing line ${line.index}`);
    // Apply logic
  });
  
  console.log('Total discounts:', discounts.length);
  return { discounts };
}
```

Functions output to stderr; check via `shopify function test --verbose`.

### Common Debug Patterns

- Verify input shape matches `input.graphql`
- Confirm output structure matches function type spec
- Check for null/undefined values in nested objects
- Validate GID formats for entities

## Performance Optimization

### Memory-Efficient Filtering

```javascript
export function run(input) {
  // Bad: Creates intermediate array
  const processed = input.cart.lines
    .map(line => ({ ...line, processed: true }))
    .filter(line => line.merchandise?.product?.tags?.includes('sale'));
  
  // Good: Single pass, no intermediate structures
  const discounts = [];
  for (const line of input.cart.lines) {
    if (line.merchandise?.product?.tags?.includes('sale')) {
      discounts.push({
        targets: [{ lineItem: { index: line.index.toString() } }],
        value: { percentage: { value: '10.0' } },
      });
    }
  }
  return { discounts };
}
```

### Avoid N+1 Queries

Functions receive all data in `input`; don't attempt API calls within the function. Fetch needed data upfront via `input.graphql`.

## API Versioning

Update API version in `shopify.function.toml`:

```toml
API_version = "2025-04"
```

Current stable: `2025-04`
Long-term support: `2025-04`, `2024-07`

Monitor [Shopify API lifecycle](https://shopify.dev/docs/api/admin/migrations) for deprecations.

## Error Handling

### Defensive Null Checks

```javascript
export function run(input) {
  const cartTotal = input?.cart?.cost?.subtotalAmount?.amount;
  
  if (!cartTotal || cartTotal < 0) {
    return { discounts: [] };
  }
  
  return { discounts: [...] };
}
```

### Validation Assertions

```rust
// Rust: Compile-time safety
pub fn run(input: Input) -> FunctionResult {
    let total: f64 = input.cart.cost
        .subtotal_amount
        .parse()
        .unwrap_or(0.0);
    
    // Type-safe, no runtime null checks needed
}
```

## Common Gotchas

1. **10ms Timeout**: Functions exceeding 10ms abort silently. No discounts applied.
2. **1MB Memory Limit**: Avoid large data structures or recursion.
3. **Index Strings**: Line indices must be strings, not numbers.
4. **GID Format**: Entity IDs are global GIDs (gid://shopify/Product/123), not numeric.
5. **Floating Point**: Use strings for currency to avoid rounding errors.
6. **No External APIs**: Functions cannot make HTTP calls.
7. **Input Immutability**: Don't mutate input; return new output objects.

## Metafield Configuration

Bind functions to metafield data:

```toml
[[configuration]]
key = "bulk_discount_threshold"
type = "number_decimal"
name = "Bulk Threshold"
description = "Minimum quantity for bulk discount"
default_value = "10"
```

Access via `input.cart.lines[].merchandise.product.metafields`.
