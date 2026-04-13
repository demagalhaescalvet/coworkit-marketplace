---
name: shopify-pos-ui
description: Building retail point-of-sale applications with POS UI components. Covers 34+ extension targets, Polaris web components with s- prefix, CLI scaffolding, type-safe Preact code generation, and post-purchase/return flows.
version: 0.1.0
---

# Shopify POS UI

This skill covers building retail point-of-sale applications using Shopify's POS UI framework. Use this when building extensions for retail operations, customer management, product details, checkout, returns, and receipt customization.

## POS UI Overview

Shopify POS UI enables developers to extend the point-of-sale terminal experience with custom applications and workflows.

### Key Features

- **34+ Extension Targets**: Tiles, modals, blocks, menu items across home, customer, product, order, and return flows
- **Polaris Web Components**: Pre-built UI components with `s-` prefix (s-tile, s-modal, s-button)
- **Type-Safe Preact**: Full TypeScript support for reactive components
- **Native Performance**: Optimized for retail environments
- **Offline Support**: Work without internet connectivity
- **Touch-Optimized**: Designed for retail touch interfaces

## Extension Targets

### Home Screen (8+ targets)

```
- pos:home:tile              # Main tile on home screen
- pos:home:modal             # Modal from home context
- pos:home:action-list       # Action menu items
- pos:home:quick-action      # Quick action buttons
- pos:home:status-bar-item   # Status bar component
- pos:home:footer-action     # Footer action item
```

### Customer Details (8+ targets)

```
- pos:customer:details:tile           # Tile in customer details
- pos:customer:details:modal          # Modal in customer view
- pos:customer:details:action-list    # Customer actions menu
- pos:customer:details:footer-action  # Footer action in customer view
```

### Product Details (6+ targets)

```
- pos:product:details:tile           # Tile in product details
- pos:product:details:modal          # Modal in product view
- pos:product:details:action-list    # Product actions menu
- pos:product:details:footer-action  # Footer action in product view
```

### Order Details (6+ targets)

```
- pos:order:details:tile           # Tile in order details
- pos:order:details:modal          # Modal in order view
- pos:order:details:action-list    # Order actions menu
- pos:order:details:footer-action  # Footer action in order view
```

### Post-Purchase (2+ targets)

```
- pos:order:post-purchase:modal        # Post-purchase custom flow
- pos:order:post-purchase:action-list  # Post-purchase actions
```

### Returns & Refunds (2+ targets)

```
- pos:return:details:tile       # Tile in return view
- pos:return:details:modal      # Return custom flow
```

### Receipt (2+ targets)

```
- pos:receipt:modal             # Custom receipt modal
- pos:receipt:action-list       # Receipt-related actions
```

## Project Setup

### Generate POS Extension

```bash
shopify app generate extension --type pos_ui

# Prompts:
# 1. Extension name (e.g., "Custom Home Tile")
# 2. Extension target (e.g., "pos:home:tile")
# 3. Language (TypeScript recommended)
```

### Project Structure

```
extensions/my-pos-extension/
├── src/
│   ├── index.tsx              # Entry point (Preact component)
│   ├── index.ts               # Alternative JS entry
│   └── styles.css             # Component styles
├── shopify.extension.toml      # Extension configuration
├── tsconfig.json              # TypeScript config
├── package.json               # Dependencies
└── README.md
```

## Polaris Web Components

### Component Library

All POS UI components use `s-` prefix (s for Shopify):

| Component | Purpose | Example |
|-----------|---------|---------|
| s-tile | Card/container component | Home screen tiles, details tiles |
| s-modal | Dialog/modal overlay | Actions, confirmations |
| s-button | Interactive button | Actions, navigation |
| s-badge | Status indicator | Order status, labels |
| s-text | Typography | Text blocks, labels |
| s-input | Form input | Search, text entry |
| s-checkbox | Boolean selection | Multi-select, filters |
| s-radio | Single selection | Option groups |
| s-select | Dropdown menu | Category selection |

### Basic Tile Component

```typescript
import { mount } from 'shopify-pos-ui/preact';
import { h } from 'preact';

function HomeTile() {
  return (
    <s-tile heading="Sales Summary">
      <div style={{ padding: '16px' }}>
        <s-text>Today's Sales: $1,234.56</s-text>
        <s-text>Transactions: 12</s-text>
      </div>
    </s-tile>
  );
}

mount(HomeTile, { target: 'pos:home:tile' });
```

### Modal Component

```typescript
import { mount } from 'shopify-pos-ui/preact';
import { h, useState } from 'preact';

function CustomModal() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <s-button onClick={() => setIsOpen(true)}>
        Open Custom Modal
      </s-button>

      {isOpen && (
        <s-modal heading="Custom Action" onClose={() => setIsOpen(false)}>
          <div style={{ padding: '16px' }}>
            <s-text>Your custom content here</s-text>
            <s-button onClick={() => setIsOpen(false)}>Close</s-button>
          </div>
        </s-modal>
      )}
    </>
  );
}

mount(CustomModal, { target: 'pos:home:modal' });
```

## State Management

### Using Preact Hooks

```typescript
import { h, useState, useEffect } from 'preact';

function ProductTile() {
  const [inventory, setInventory] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function loadInventory() {
      try {
        setLoading(true);
        const response = await fetch('/api/inventory');
        const data = await response.json();
        setInventory(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    loadInventory();
  }, []);

  if (loading) return <s-text>Loading...</s-text>;
  if (error) return <s-text>Error: {error}</s-text>;

  return (
    <s-tile heading="Inventory">
      <s-text>{inventory?.count || 0} in stock</s-text>
    </s-tile>
  );
}
```

## POS API Integration

### Access POS Context

```typescript
import { usePOS } from 'shopify-pos-ui/preact';

function CustomerActionTile() {
  const pos = usePOS();

  // Access current context
  const { customer, product, order, cart } = pos.context;

  // Perform actions
  const handleAddNote = async () => {
    await pos.actions.customer.addNote({
      customerId: customer.id,
      note: 'VIP customer - provide white glove service',
    });
  };

  return (
    <s-button onClick={handleAddNote}>
      Add VIP Note
    </s-button>
  );
}
```

### Common POS Actions

```typescript
// Customer actions
pos.actions.customer.addNote({ customerId, note });
pos.actions.customer.addTag({ customerId, tag });
pos.actions.customer.applyDiscount({ customerId, discountCode });

// Product actions
pos.actions.product.updatePrice({ productId, variantId, newPrice });
pos.actions.product.toggleInventory({ productId, variantId, quantity });

// Order actions
pos.actions.order.addDiscount({ orderId, amount });
pos.actions.order.applyGiftCard({ orderId, giftCardCode });
pos.actions.order.createRefund({ orderId, lineItems });

// Cart actions
pos.actions.cart.addItem({ variantId, quantity });
pos.actions.cart.removeItem({ lineItemId });
pos.actions.cart.updateQuantity({ lineItemId, quantity });
```

## Type-Safe Development

### TypeScript Setup

```typescript
// types.ts
interface Customer {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string;
  totalSpent: number;
  totalOrders: number;
  tags: string[];
  notes: string;
}

interface Product {
  id: string;
  title: string;
  handle: string;
  variants: ProductVariant[];
  images: ProductImage[];
  category: string;
  vendor: string;
}

interface ProductVariant {
  id: string;
  title: string;
  sku: string;
  price: number;
  inventory: number;
}

// Component with types
interface CustomerTileProps {
  customer: Customer;
}

function CustomerTile({ customer }: CustomerTileProps) {
  return (
    <s-tile heading={`${customer.firstName} ${customer.lastName}`}>
      <s-text>Phone: {customer.phone}</s-text>
      <s-text>Total Orders: {customer.totalOrders}</s-text>
      <s-text>Lifetime Value: ${customer.totalSpent}</s-text>
    </s-tile>
  );
}
```

## Post-Purchase Flows

### Post-Purchase Modal

```typescript
import { h, useState } from 'preact';
import { mount } from 'shopify-pos-ui/preact';

function PostPurchaseFlow() {
  const pos = usePOS();
  const { order } = pos.context;
  const [step, setStep] = useState<'receipt' | 'survey' | 'receipt'>('receipt');

  if (step === 'receipt') {
    return (
      <s-modal heading="Order Complete" onClose={() => pos.actions.dismiss()}>
        <div style={{ padding: '16px' }}>
          <s-text size="large">Order #{order.number}</s-text>
          <s-text>Total: ${order.total}</s-text>
          <s-button onClick={() => setStep('survey')}>
            Collect Feedback
          </s-button>
          <s-button onClick={() => pos.actions.dismiss()}>Done</s-button>
        </div>
      </s-modal>
    );
  }

  if (step === 'survey') {
    return (
      <s-modal heading="Feedback" onClose={() => pos.actions.dismiss()}>
        <div style={{ padding: '16px' }}>
          <s-text>How was your experience?</s-text>
          <div style={{ display: 'flex', gap: '8px' }}>
            {[1, 2, 3, 4, 5].map(rating => (
              <s-button
                key={rating}
                onClick={() => submitFeedback(rating)}
              >
                {rating}
              </s-button>
            ))}
          </div>
        </div>
      </s-modal>
    );
  }
}

mount(PostPurchaseFlow, { target: 'pos:order:post-purchase:modal' });
```

## Return and Refund Extensions

### Return Details Tile

```typescript
function ReturnDetailsTile() {
  const pos = usePOS();
  const { returnItem } = pos.context;

  const handleApproveReturn = async () => {
    await pos.actions.return.approve({
      returnId: returnItem.id,
      restockItems: true,
    });
  };

  return (
    <s-tile heading="Return Details">
      <s-text>Reason: {returnItem.reason}</s-text>
      <s-text>Amount: ${returnItem.amount}</s-text>
      <s-text>Status: {returnItem.status}</s-text>
      <s-button onClick={handleApproveReturn}>
        Approve Return
      </s-button>
    </s-tile>
  );
}

mount(ReturnDetailsTile, { target: 'pos:return:details:tile' });
```

## Receipt Customization

### Custom Receipt Modal

```typescript
function CustomReceiptModal() {
  const pos = usePOS();
  const { order } = pos.context;

  const handlePrint = async () => {
    await pos.actions.receipt.print({
      orderId: order.id,
      format: 'thermal',
      copies: 1,
    });
  };

  const handleEmail = async () => {
    await pos.actions.receipt.email({
      orderId: order.id,
      to: order.email,
    });
  };

  return (
    <s-modal heading="Receipt Options" onClose={() => pos.actions.dismiss()}>
      <div style={{ padding: '16px' }}>
        <s-button onClick={handlePrint}>Print Receipt</s-button>
        <s-button onClick={handleEmail}>Email Receipt</s-button>
        <s-button onClick={() => pos.actions.dismiss()}>Done</s-button>
      </div>
    </s-modal>
  );
}

mount(CustomReceiptModal, { target: 'pos:receipt:modal' });
```

## Configuration

### shopify.extension.toml

```toml
name = "Custom Home Tile"
description = "Display custom sales metrics on POS home screen"
type = "pos_ui"
handle = "custom-home-tile"

[[targets]]
id = "pos:home:tile"

[development]
resource = "index.tsx"
port = 3000

[build]
command = "npm run build"
path = "dist/index.js"
```

## Styling

### CSS Styling Pattern

```typescript
import styles from './styles.css?module';
import { h } from 'preact';

function StyledTile() {
  return (
    <s-tile heading="Styled Content" class={styles.tile}>
      <div class={styles.content}>
        <s-text class={styles.title}>Sales Today</s-text>
        <s-text class={styles.amount}>$1,234.56</s-text>
      </div>
    </s-tile>
  );
}
```

```css
/* styles.css */
.tile {
  background-color: #f5f5f5;
  border-radius: 8px;
}

.content {
  padding: 16px;
}

.title {
  font-weight: 600;
  margin-bottom: 8px;
}

.amount {
  font-size: 24px;
  color: #008000;
  font-weight: bold;
}
```

## Best Practices

### Performance

- Minimize API calls - batch requests when possible
- Use local state for UI-only data
- Implement loading states
- Cache results appropriately
- Avoid large component trees

### User Experience

- Touch-friendly button sizes (min 44x44px)
- Clear visual feedback for actions
- Descriptive error messages
- Loading and empty states
- Keyboard accessibility

### Security

- Validate all user input
- Use secure API endpoints
- Never expose sensitive data in UI
- Implement proper authentication
- Log sensitive operations

## Testing

### Unit Testing with Preact

```typescript
import { render } from '@testing-library/preact';
import { h } from 'preact';
import TileComponent from './TileComponent';

describe('TileComponent', () => {
  it('renders tile with heading', () => {
    const { getByText } = render(<TileComponent heading="Test" />);
    expect(getByText('Test')).toBeInTheDocument();
  });

  it('handles button click', async () => {
    const handleClick = jest.fn();
    const { getByText } = render(
      <TileComponent onAction={handleClick} />
    );

    await userEvent.click(getByText('Action'));
    expect(handleClick).toHaveBeenCalled();
  });
});
```

## Deployment

### Build and Deploy

```bash
# Build extension
npm run build

# Deploy to Shopify
shopify app deploy --extensions custom-home-tile

# Install on POS terminal
# 1. Go to POS Settings
# 2. Navigate to Apps
# 3. Install extension
# 4. Configure permissions
```

## Next Steps

- See `pos-ui-patterns.md` for real-world implementation examples
- Review [POS UI docs](https://shopify.dev/docs/api/pos-ui) for complete API reference
- Explore [Polaris web components](https://polaris.shopify.com) for UI patterns
- Test on POS simulator and retail terminals
- Monitor performance in production environments
