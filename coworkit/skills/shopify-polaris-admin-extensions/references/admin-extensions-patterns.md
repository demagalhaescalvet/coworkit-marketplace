# Admin Extensions Patterns & Examples

Reference guide with practical scaffolding examples and component usage patterns for Shopify Admin extensions.

## Extension Scaffolding Examples

### Creating an Admin Action Extension

```bash
shopify app generate extension --template admin_action
```

This creates a new admin action extension that can be triggered from bulk actions menus.

**File structure:**
```
extensions/
  my-admin-action/
    src/
      index.jsx
    shopify.app.toml
```

### Creating an Admin Block Extension

```bash
shopify app generate extension --template admin_block
```

Admin blocks appear in customizable dashboard locations.

**File structure:**
```
extensions/
  my-admin-block/
    src/
      index.jsx
    shopify.app.toml
```

### Creating an Admin Link Extension

```bash
shopify app generate extension --template admin_link
```

Admin links appear in the admin navigation sidebar.

**File structure:**
```
extensions/
  my-admin-link/
    src/
      index.jsx
    shopify.app.toml
```

### Creating a Print Action Extension

```bash
shopify app generate extension --template print_action
```

Print actions appear in the print dialog for orders and other documents.

**File structure:**
```
extensions/
  my-print-action/
    src/
      index.jsx
    shopify.app.toml
```

## Component Usage Examples

### Using Buttons with Different Styles

```html
<s-block-stack gap="base">
  <s-button kind="primary">Primary Action</s-button>
  <s-button kind="secondary">Secondary Action</s-button>
  <s-button kind="tertiary">Tertiary Action</s-button>
  <s-button kind="plain">Plain Action</s-button>
  <s-button kind="destructive">Destructive Action</s-button>
</s-block-stack>
```

### Form Input Components

```html
<s-block-stack gap="loose">
  <s-text-field
    label="Email"
    type="email"
    placeholder="customer@example.com"
    required
  />

  <s-text-field
    label="Phone"
    type="tel"
    placeholder="+1 (555) 000-0000"
  />

  <s-select label="Country">
    <option value="us">United States</option>
    <option value="ca">Canada</option>
    <option value="uk">United Kingdom</option>
  </s-select>

  <s-text-area
    label="Notes"
    placeholder="Enter any additional notes..."
    rows="4"
  />
</s-block-stack>
```

### Layout with Spacing

```html
<s-box padding="loose">
  <s-block-stack gap="loose">
    <s-text variant="headingLg">Order Details</s-text>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Order ID:</s-text>
      <s-text variant="headingMd">#12345</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Total:</s-text>
      <s-text variant="headingMd">$199.99</s-text>
    </s-inline-stack>

    <s-divider />

    <s-button kind="primary">View Order</s-button>
  </s-block-stack>
</s-box>
```

### Status Indicators with Badges

```html
<s-inline-stack gap="base" align="center">
  <s-text>Status:</s-text>
  <s-badge kind="success">Completed</s-badge>
</s-inline-stack>

<s-inline-stack gap="base" align="center">
  <s-text>Payment:</s-text>
  <s-badge kind="warning">Pending</s-badge>
</s-inline-stack>

<s-inline-stack gap="base" align="center">
  <s-text>Fulfillment:</s-text>
  <s-badge kind="critical">Delayed</s-badge>
</s-inline-stack>
```

### Conditional Content Display

```html
{{#if order.fulfillmentStatus === 'FULFILLED'}}
  <s-banner kind="success" title="Order Fulfilled">
    This order has been successfully fulfilled.
  </s-banner>
{{else if order.fulfillmentStatus === 'IN_PROGRESS'}}
  <s-banner kind="info" title="Fulfilling">
    This order is currently being fulfilled.
  </s-banner>
{{else}}
  <s-banner kind="warning" title="Not Fulfilled">
    This order has not yet been fulfilled.
  </s-banner>
{{/if}}
```

### Data Grid Display

```html
<s-box padding="base">
  <s-block-stack gap="base">
    <s-text variant="headingMd">Recent Orders</s-text>
    
    <s-box>
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="border-bottom: 1px solid #ccc;">
            <th style="text-align: left; padding: 8px;">Order ID</th>
            <th style="text-align: left; padding: 8px;">Customer</th>
            <th style="text-align: left; padding: 8px;">Total</th>
            <th style="text-align: left; padding: 8px;">Status</th>
          </tr>
        </thead>
        <tbody>
          {{#each orders}}
            <tr style="border-bottom: 1px solid #eee;">
              <td style="padding: 8px;">#{{this.id}}</td>
              <td style="padding: 8px;">{{this.customer}}</td>
              <td style="padding: 8px;">{{this.total}}</td>
              <td style="padding: 8px;">
                <s-badge kind="{{this.statusKind}}">
                  {{this.status}}
                </s-badge>
              </td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    </s-box>
  </s-block-stack>
</s-box>
```

### Modal/Dialog Pattern

```html
{{#if showModal}}
  <s-box padding="base" background-color="bg-overlay">
    <s-box 
      padding="loose" 
      background-color="bg-surface"
      style="border-radius: 8px; max-width: 500px; margin: 0 auto;"
    >
      <s-block-stack gap="loose">
        <s-text variant="headingLg">Confirm Action</s-text>
        
        <s-text variant="bodyMd">
          Are you sure you want to perform this action? This cannot be undone.
        </s-text>

        <s-inline-stack gap="base" align="end">
          <s-button onclick="handleCancel()">Cancel</s-button>
          <s-button kind="destructive" onclick="handleConfirm()">
            Confirm
          </s-button>
        </s-inline-stack>
      </s-block-stack>
    </s-box>
  </s-box>
{{/if}}
```

### Loading and Error States

```html
{{#if isLoading}}
  <s-block-stack gap="base" align="center">
    <s-spinner size="large" />
    <s-text variant="bodyMd">Loading data...</s-text>
  </s-block-stack>
{{else if error}}
  <s-banner kind="critical" title="Error Occurred">
    {{error.message}}
  </s-banner>
{{else}}
  <s-block-stack gap="base">
    <s-text variant="headingMd">Data Loaded</s-text>
    <!-- Content here -->
  </s-block-stack>
{{/if}}
```

## API Integration Patterns

### GraphQL Query Example

```javascript
const result = await shopify.admin.graphql(`
  query GetProduct($id: ID!) {
    product(id: $id) {
      id
      title
      status
      vendor
      variants(first: 5) {
        edges {
          node {
            id
            title
            sku
            inventoryQuantity
          }
        }
      }
    }
  }
`, {
  variables: { id: productId }
});

const { data, errors } = await result.json();
```

### GraphQL Mutation Example

```javascript
const result = await shopify.admin.graphql(`
  mutation UpdateProductStatus($id: ID!, $status: ProductStatus!) {
    productUpdate(id: $id, input: { status: $status }) {
      product {
        id
        status
        updatedAt
      }
      userErrors {
        field
        message
      }
    }
  }
`, {
  variables: { id: productId, status: 'ARCHIVED' }
});

const { data, errors } = await result.json();
```

### Error Handling in API Calls

```javascript
try {
  const result = await shopify.admin.graphql(query, { variables });
  const { data, errors } = await result.json();
  
  if (errors) {
    console.error('GraphQL errors:', errors);
    setErrorMessage('Failed to fetch data. Please try again.');
    return;
  }
  
  setData(data);
} catch (error) {
  console.error('Network error:', error);
  setErrorMessage('Network error. Please check your connection.');
}
```

## Best Practices

1. Always use kebab-case for HTML attributes
2. Keep component hierarchy clean with proper spacing
3. Provide feedback for all user actions
4. Handle loading and error states explicitly
5. Test extensions with realistic data volumes
6. Use tooltips for complex features
7. Keep modal/dialog content focused and concise
8. Validate form input before submission
