# POS UI Implementation Patterns

## Complete Home Screen Extension

### Sales Dashboard Tile

```typescript
import { h, useState, useEffect } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';
import styles from './styles.css?module';

interface SalesMetrics {
  todaySales: number;
  todayTransactions: number;
  averageTransactionValue: number;
  topProduct: string;
  topProductSales: number;
}

function SalesDashboardTile() {
  const pos = usePOS();
  const [metrics, setMetrics] = useState<SalesMetrics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadMetrics() {
      try {
        const response = await fetch('/api/pos/sales-metrics');
        const data = await response.json();
        setMetrics(data);
      } catch (error) {
        console.error('Error loading metrics:', error);
      } finally {
        setLoading(false);
      }
    }

    loadMetrics();

    // Refresh every 5 minutes
    const interval = setInterval(loadMetrics, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <s-tile heading="Sales"><s-text>Loading...</s-text></s-tile>;
  }

  if (!metrics) {
    return <s-tile heading="Sales"><s-text>No data</s-text></s-tile>;
  }

  return (
    <s-tile heading="Today's Sales" class={styles.salesTile}>
      <div class={styles.metricGrid}>
        <div class={styles.metric}>
          <s-text class={styles.label}>Total Sales</s-text>
          <s-text class={styles.value}>
            ${metrics.todaySales.toFixed(2)}
          </s-text>
        </div>

        <div class={styles.metric}>
          <s-text class={styles.label}>Transactions</s-text>
          <s-text class={styles.value}>{metrics.todayTransactions}</s-text>
        </div>

        <div class={styles.metric}>
          <s-text class={styles.label}>Average Order</s-text>
          <s-text class={styles.value}>
            ${metrics.averageTransactionValue.toFixed(2)}
          </s-text>
        </div>

        <div class={styles.metric}>
          <s-text class={styles.label}>Top Product</s-text>
          <s-text class={styles.value}>{metrics.topProduct}</s-text>
          <s-text class={styles.subtext}>
            ${metrics.topProductSales.toFixed(2)}
          </s-text>
        </div>
      </div>

      <div style={{ marginTop: '16px' }}>
        <s-button onClick={() => pos.actions.navigate('/analytics')}>
          View Full Report
        </s-button>
      </div>
    </s-tile>
  );
}

mount(SalesDashboardTile, { target: 'pos:home:tile' });
```

### CSS for Dashboard

```css
.salesTile {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 16px;
}

.metricGrid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin: 16px 0;
}

.metric {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 12px;
  text-align: center;
}

.label {
  font-size: 12px;
  opacity: 0.8;
  display: block;
  margin-bottom: 4px;
}

.value {
  font-size: 20px;
  font-weight: bold;
  color: white;
  display: block;
}

.subtext {
  font-size: 12px;
  opacity: 0.7;
}
```

## Customer Action Extensions

### VIP Customer Actions Modal

```typescript
import { h, useState } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';

function VIPCustomerActionsModal() {
  const pos = usePOS();
  const { customer } = pos.context;
  const [action, setAction] = useState<string | null>(null);

  const isVIP = customer.tags.includes('vip') || 
                customer.totalOrders >= 10 ||
                customer.totalSpent >= 5000;

  const handleAddVIPNote = async () => {
    await pos.actions.customer.addNote({
      customerId: customer.id,
      note: `[VIP] - ${new Date().toISOString()}`,
    });
    setAction('note-added');
  };

  const handleApplyDiscount = async () => {
    const discountCode = `VIP-${customer.id.slice(-6)}`;
    await pos.actions.customer.applyDiscount({
      customerId: customer.id,
      discountCode,
    });
    setAction('discount-applied');
  };

  const handleAddLoyaltyPoints = async () => {
    const points = Math.floor(customer.totalSpent / 10);
    await pos.actions.customer.updateProperty({
      customerId: customer.id,
      property: 'loyalty_points',
      value: (customer.properties.loyalty_points || 0) + points,
    });
    setAction('points-added');
  };

  if (action) {
    return (
      <s-modal heading="Action Complete" onClose={() => pos.actions.dismiss()}>
        <div style={{ padding: '16px', textAlign: 'center' }}>
          <s-text>✓ {action.replace('-', ' ')}</s-text>
          <s-button onClick={() => pos.actions.dismiss()} 
                    style={{ marginTop: '16px' }}>
            Done
          </s-button>
        </div>
      </s-modal>
    );
  }

  if (!isVIP) {
    return (
      <s-modal heading="Customer Actions" onClose={() => pos.actions.dismiss()}>
        <div style={{ padding: '16px' }}>
          <s-text>Not a VIP customer</s-text>
        </div>
      </s-modal>
    );
  }

  return (
    <s-modal heading="VIP Customer Actions" onClose={() => pos.actions.dismiss()}>
      <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <s-button onClick={handleAddVIPNote}>Add VIP Note</s-button>
        <s-button onClick={handleApplyDiscount}>Apply VIP Discount</s-button>
        <s-button onClick={handleAddLoyaltyPoints}>Award Loyalty Points</s-button>
      </div>
    </s-modal>
  );
}

mount(VIPCustomerActionsModal, { 
  target: 'pos:customer:details:modal' 
});
```

## Product Inventory Extension

### Quick Inventory Check Tile

```typescript
import { h, useState } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';

interface Location {
  id: string;
  name: string;
  inventory: number;
}

function ProductInventoryTile() {
  const pos = usePOS();
  const { product } = pos.context;
  const [selectedVariant, setSelectedVariant] = useState(product.variants[0]);
  const [locations, setLocations] = useState<Location[]>([]);

  const loadInventory = async (variantId: string) => {
    const response = await fetch(`/api/pos/inventory/${variantId}`);
    const data = await response.json();
    setLocations(data.locations);
  };

  const handleVariantChange = (variantId: string) => {
    const variant = product.variants.find(v => v.id === variantId);
    if (variant) {
      setSelectedVariant(variant);
      loadInventory(variantId);
    }
  };

  return (
    <s-tile heading="Inventory" style={{ minHeight: '200px' }}>
      <div style={{ padding: '16px' }}>
        <s-select 
          onChange={(e) => handleVariantChange(e.target.value)}
          value={selectedVariant.id}
        >
          {product.variants.map(v => (
            <option key={v.id} value={v.id}>
              {v.title} - {v.sku}
            </option>
          ))}
        </s-select>

        <div style={{ marginTop: '16px' }}>
          {locations.map(location => (
            <div key={location.id} style={{ 
              display: 'flex', 
              justifyContent: 'space-between',
              padding: '8px 0',
              borderBottom: '1px solid #eee'
            }}>
              <s-text>{location.name}</s-text>
              <s-badge 
                tone={location.inventory > 5 ? 'success' : 'warning'}
              >
                {location.inventory} in stock
              </s-badge>
            </div>
          ))}
        </div>

        <s-button 
          onClick={() => pos.actions.navigate(`/transfer/${selectedVariant.id}`)}
          style={{ marginTop: '16px', width: '100%' }}
        >
          Transfer Stock
        </s-button>
      </div>
    </s-tile>
  );
}

mount(ProductInventoryTile, { 
  target: 'pos:product:details:tile' 
});
```

## Order Management Extension

### Post-Purchase Upsell Modal

```typescript
import { h, useState } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';

interface UpsellItem {
  id: string;
  title: string;
  price: number;
  image: string;
}

function PostPurchaseUpsellModal() {
  const pos = usePOS();
  const { order } = pos.context;
  const [upsells, setUpsells] = useState<UpsellItem[]>([]);
  const [selected, setSelected] = useState<Set<string>>(new Set());

  const handleAddUpsells = async () => {
    const selectedItems = Array.from(selected);
    
    for (const itemId of selectedItems) {
      await pos.actions.cart.addItem({
        variantId: itemId,
        quantity: 1,
      });
    }

    await pos.actions.notify({
      type: 'success',
      message: `Added ${selectedItems.length} items to cart`,
    });

    pos.actions.dismiss();
  };

  const toggleSelection = (itemId: string) => {
    const newSelected = new Set(selected);
    if (newSelected.has(itemId)) {
      newSelected.delete(itemId);
    } else {
      newSelected.add(itemId);
    }
    setSelected(newSelected);
  };

  return (
    <s-modal 
      heading="Add Complementary Items?" 
      onClose={() => pos.actions.dismiss()}
    >
      <div style={{ padding: '16px' }}>
        {upsells.map(item => (
          <div 
            key={item.id}
            style={{
              display: 'flex',
              gap: '12px',
              padding: '12px',
              border: '1px solid #eee',
              borderRadius: '4px',
              marginBottom: '8px',
              alignItems: 'center',
              cursor: 'pointer',
              backgroundColor: selected.has(item.id) ? '#f0f0f0' : 'white',
            }}
            onClick={() => toggleSelection(item.id)}
          >
            <s-checkbox checked={selected.has(item.id)} />
            <img src={item.image} alt={item.title} style={{ width: '40px', height: '40px' }} />
            <div style={{ flex: 1 }}>
              <s-text>{item.title}</s-text>
              <s-text>${item.price.toFixed(2)}</s-text>
            </div>
          </div>
        ))}

        <div style={{ display: 'flex', gap: '8px', marginTop: '16px' }}>
          <s-button 
            onClick={handleAddUpsells}
            disabled={selected.size === 0}
          >
            Add ({selected.size})
          </s-button>
          <s-button onClick={() => pos.actions.dismiss()}>Skip</s-button>
        </div>
      </div>
    </s-modal>
  );
}

mount(PostPurchaseUpsellModal, { 
  target: 'pos:order:post-purchase:modal' 
});
```

## Receipt Customization

### Custom Receipt Footer

```typescript
import { h } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';

function CustomReceiptFooter() {
  const pos = usePOS();
  const { order } = pos.context;

  const getReceiptMessage = () => {
    if (order.total > 500) {
      return 'Thank you for your large purchase! Contact us for volume discounts.';
    }
    if (order.customer.totalOrders > 5) {
      return 'Welcome back, loyal customer! Your next purchase gets 10% off.';
    }
    return 'Thank you for your purchase! Visit us again soon.';
  };

  return (
    <div style={{ 
      padding: '20px',
      textAlign: 'center',
      fontSize: '12px',
      lineHeight: '1.6',
      borderTop: '2px dashed #000',
    }}>
      <s-text style={{ marginBottom: '10px', fontWeight: 'bold' }}>
        {getReceiptMessage()}
      </s-text>
      
      <s-text>Website: www.example.com</s-text>
      <s-text>Phone: (555) 123-4567</s-text>
      <s-text style={{ marginTop: '10px' }}>
        Order #{order.number} • {new Date().toLocaleDateString()}
      </s-text>
    </div>
  );
}

mount(CustomReceiptFooter, { 
  target: 'pos:receipt:modal' 
});
```

## Return Management

### Return Inspection Tile

```typescript
import { h, useState } from 'preact';
import { mount } from 'shopify-pos-ui/preact';
import { usePOS } from 'shopify-pos-ui/preact';

function ReturnInspectionTile() {
  const pos = usePOS();
  const { returnItem } = pos.context;
  const [condition, setCondition] = useState<string>('');
  const [notes, setNotes] = useState<string>('');

  const handleApproveReturn = async () => {
    await pos.actions.return.approve({
      returnId: returnItem.id,
      condition,
      notes,
      restockItems: condition === 'like_new',
    });

    pos.actions.notify({
      type: 'success',
      message: 'Return approved and processed',
    });
  };

  const handleDenyReturn = async () => {
    await pos.actions.return.deny({
      returnId: returnItem.id,
      reason: notes,
    });

    pos.actions.notify({
      type: 'info',
      message: 'Return denied',
    });
  };

  return (
    <s-tile heading="Return Inspection">
      <div style={{ padding: '16px' }}>
        <div style={{ marginBottom: '16px' }}>
          <s-text><strong>Item:</strong> {returnItem.product.title}</s-text>
          <s-text><strong>Reason:</strong> {returnItem.reason}</s-text>
          <s-text><strong>Amount:</strong> ${returnItem.amount}</s-text>
        </div>

        <div style={{ marginBottom: '16px' }}>
          <s-text style={{ marginBottom: '8px' }}>Condition:</s-text>
          <div style={{ display: 'flex', gap: '8px' }}>
            {['like_new', 'good', 'fair', 'damaged'].map(cond => (
              <s-button
                key={cond}
                onClick={() => setCondition(cond)}
                type={condition === cond ? 'primary' : 'secondary'}
              >
                {cond.replace('_', ' ')}
              </s-button>
            ))}
          </div>
        </div>

        <s-input
          type="textarea"
          placeholder="Add notes..."
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          style={{ marginBottom: '16px', minHeight: '60px' }}
        />

        <div style={{ display: 'flex', gap: '8px' }}>
          <s-button onClick={handleApproveReturn} tone="positive">
            Approve
          </s-button>
          <s-button onClick={handleDenyReturn} tone="negative">
            Deny
          </s-button>
        </div>
      </div>
    </s-tile>
  );
}

mount(ReturnInspectionTile, { 
  target: 'pos:return:details:tile' 
});
```

## Quick Start Command Reference

```bash
# Create new POS extension
shopify app generate extension --type pos_ui

# Build extension
npm run build

# Deploy to Shopify
shopify app deploy --extensions my-extension-name

# View in POS
# 1. Settings > Apps
# 2. Find and install extension
# 3. Enable on POS device
```

## Common Extension Targets Reference

```
HOME SCREEN:
  - pos:home:tile                Home screen tile
  - pos:home:modal               Home modal
  - pos:home:action-list         Home actions menu

CUSTOMER CONTEXT:
  - pos:customer:details:tile    Customer details tile
  - pos:customer:details:modal   Customer modal

PRODUCT CONTEXT:
  - pos:product:details:tile     Product details tile

ORDER CONTEXT:
  - pos:order:details:tile       Order details tile
  - pos:order:post-purchase:modal  Post-purchase modal

RETURNS:
  - pos:return:details:tile      Return details tile

RECEIPT:
  - pos:receipt:modal            Custom receipt
```
