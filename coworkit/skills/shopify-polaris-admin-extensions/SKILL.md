---
name: shopify-polaris-admin-extensions
description: Triggers on "create an admin extension", "build admin UI", "add admin actions", "create admin blocks", "build admin interface". Build custom UI and functionality for the Shopify Admin using Polaris web components and extension APIs.
version: 0.1.0
---

# Shopify Polaris Admin Extensions

Admin extensions let you build custom UI and functionality directly into the Shopify Admin. This skill covers extension types, Polaris web components, scaffolding, and common patterns for creating powerful admin tools.

## Extension Types

Shopify supports several types of admin extensions, each designed for specific use cases:

### Admin Actions
Triggered from bulk actions, selection modals, and action menus throughout the admin. Perfect for batch operations on resources.

```bash
shopify app generate extension --template admin_action
```

**Use cases:** bulk updates, exporting selected items, batch operations on products/orders

### Admin Blocks
Blocks appear as customizable sections within the admin dashboard. They can display data, metrics, and interactive controls.

```bash
shopify app generate extension --template admin_block
```

**Use cases:** dashboard widgets, KPI displays, custom analytics, quick-access tools

### Admin Links
Navigation links that appear in the admin sidebar and direct users to custom pages in your app.

```bash
shopify app generate extension --template admin_link
```

**Use cases:** app onboarding, settings pages, help documentation, external integrations

### Print Actions
Custom actions that appear in the print dialog for orders, invoices, and other documents.

```bash
shopify app generate extension --template print_action
```

**Use cases:** custom printing, generating PDFs, document generation, label printing

## Polaris Web Components

All Polaris components are globally registered with the `s-` prefix. No imports are required—just use them directly in your templates.

### Action Components

**Button:**
```html
<s-button
  kind="primary"
  onclick="handleClick()"
>
  Click Me
</s-button>
```

Available kinds: `primary`, `secondary`, `tertiary`, `plain`, `destructive`

**Tooltip:**
```html
<s-tooltip content="Help text here">
  <s-button>Hover for help</s-button>
</s-tooltip>
```

### Form Components

**Text Field:**
```html
<s-text-field
  type="text"
  label="Product Name"
  placeholder="Enter name"
  value="{{productName}}"
  onchange="handleInputChange(event)"
/>
```

**Select Dropdown:**
```html
<s-select
  label="Category"
  value="{{selectedCategory}}"
  onchange="handleSelectChange(event)"
>
  <option value="electronics">Electronics</option>
  <option value="clothing">Clothing</option>
  <option value="home">Home & Garden</option>
</s-select>
```

**Checkbox:**
```html
<s-checkbox
  label="Enable notifications"
  checked="{{isEnabled}}"
  onchange="handleCheckboxChange(event)"
/>
```

**Text Area:**
```html
<s-text-area
  label="Description"
  placeholder="Enter description"
  value="{{description}}"
  rows="5"
  onchange="handleTextAreaChange(event)"
/>
```

### Layout Components

**Box (Container):**
```html
<s-box padding="base">
  <p>Content inside padded container</p>
</s-box>
```

Available padding: `none`, `extra-tight`, `tight`, `base`, `loose`, `extra-loose`

**Inline Stack (Horizontal Layout):**
```html
<s-inline-stack gap="base" align="center">
  <s-button>Button 1</s-button>
  <s-button>Button 2</s-button>
  <s-button>Button 3</s-button>
</s-inline-stack>
```

**Block Stack (Vertical Layout):**
```html
<s-block-stack gap="base">
  <h2>Title</h2>
  <p>Content paragraph</p>
  <s-button>Action</s-button>
</s-block-stack>
```

### Feedback Components

**Banner:**
```html
<s-banner kind="success" title="Success!">
  Your changes have been saved.
</s-banner>
```

Available kinds: `success`, `warning`, `critical`, `info`

**Badge:**
```html
<s-badge kind="success">Active</s-badge>
<s-badge kind="warning">Pending</s-badge>
<s-badge kind="critical">Error</s-badge>
```

**Text:**
```html
<s-text variant="headingXl">Large Heading</s-text>
<s-text variant="headingLg">Medium Heading</s-text>
<s-text variant="bodyMd">Regular text</s-text>
```

### Media Components

**Image:**
```html
<s-image
  src="https://example.com/image.jpg"
  alt="Product image"
  width="300"
  height="300"
/>
```

**Avatar:**
```html
<s-avatar
  initials="AB"
  size="base"
/>
```

## Attribute Syntax

All attributes use kebab-case naming:

```html
<s-button kind="primary" onclick="handle()">Submit</s-button>
<s-text-field label="Email" type="email" />
<s-block-stack gap="base" align="stretch">
```

Boolean attributes can be set as:
- Empty attribute: `disabled`
- String value: `disabled="true"`

## Building an Admin Action Extension

Example: Create an action to export selected products to CSV.

```html
<s-block-stack gap="loose">
  <s-box padding="base" background-color="bg-surface">
    <s-block-stack gap="tight">
      <s-text variant="headingLg">Export Products</s-text>
      <s-text variant="bodyMd">
        You are about to export {{selectedCount}} products.
      </s-text>
    </s-block-stack>
  </s-box>

  <s-block-stack gap="tight">
    <s-select
      label="Format"
      value="{{exportFormat}}"
      onchange="handleFormatChange(event)"
    >
      <option value="csv">CSV</option>
      <option value="json">JSON</option>
      <option value="xlsx">Excel</option>
    </s-select>

    <s-checkbox
      label="Include inventory data"
      checked="{{includeInventory}}"
      onchange="handleInventoryChange(event)"
    />

    <s-checkbox
      label="Include pricing data"
      checked="{{includePricing}}"
      onchange="handlePricingChange(event)"
    />
  </s-block-stack>

  <s-inline-stack gap="base" align="end">
    <s-button onclick="handleCancel()">Cancel</s-button>
    <s-button kind="primary" onclick="handleExport()">
      Export {{selectedCount}} Products
    </s-button>
  </s-inline-stack>
</s-block-stack>
```

## Building an Admin Block Extension

Example: Dashboard widget showing daily sales metrics.

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-block-stack gap="tight">
      <s-text variant="headingMd">Daily Sales</s-text>
      <s-text variant="bodyMd" tone="subdued">
        Last 7 days
      </s-text>
    </s-block-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-box padding="tight" background-color="bg-surface">
        <s-block-stack gap="extra-tight" align="center">
          <s-text variant="bodySm" tone="subdued">Today</s-text>
          <s-text variant="headingLg">${{todayRevenue}}</s-text>
        </s-block-stack>
      </s-box>

      <s-box padding="tight" background-color="bg-surface">
        <s-block-stack gap="extra-tight" align="center">
          <s-text variant="bodySm" tone="subdued">Avg (7d)</s-text>
          <s-text variant="headingLg">${{averageRevenue}}</s-text>
        </s-block-stack>
      </s-box>

      <s-box padding="tight" background-color="bg-surface">
        <s-block-stack gap="extra-tight" align="center">
          <s-text variant="bodySm" tone="subdued">Change</s-text>
          <s-badge kind="{{changeKind}}">{{percentChange}}%</s-badge>
        </s-block-stack>
      </s-box>
    </s-inline-stack>

    <s-button kind="secondary" onclick="handleViewDetails()">
      View Detailed Report
    </s-button>
  </s-block-stack>
</s-box>
```

## Common Patterns

### Form with Validation

```html
<s-block-stack gap="base">
  <s-text-field
    label="Product SKU"
    type="text"
    value="{{sku}}"
    onchange="handleSkuChange(event)"
    error="{{skuError}}"
    required
  />

  <s-text-field
    label="Quantity"
    type="number"
    value="{{quantity}}"
    onchange="handleQuantityChange(event)"
    error="{{quantityError}}"
    min="0"
    required
  />

  <s-inline-stack gap="base" align="end">
    <s-button onclick="handleReset()">Reset</s-button>
    <s-button kind="primary" onclick="handleSubmit()" disabled="{{!isFormValid}}">
      Save Changes
    </s-button>
  </s-inline-stack>
</s-block-stack>
```

### Loading State

```html
{{#if isLoading}}
  <s-box padding="loose" align="center">
    <s-spinner size="large" />
    <s-text variant="bodyMd">Loading data...</s-text>
  </s-box>
{{else}}
  <s-block-stack gap="base">
    <!-- Content here -->
  </s-block-stack>
{{/if}}
```

### Error Handling

```html
{{#if error}}
  <s-banner kind="critical" title="Error" onclose="handleCloseBanner()">
    {{error.message}}
  </s-banner>
{{/if}}

{{#if successMessage}}
  <s-banner kind="success" title="Success!" onclose="handleCloseBanner()">
    {{successMessage}}
  </s-banner>
{{/if}}
```

## API Access in Extensions

Extensions have direct access to Shopify Admin APIs:

```javascript
const response = await shopify.admin.graphql(`
  query GetProducts {
    products(first: 10) {
      edges {
        node {
          id
          title
          handle
        }
      }
    }
  }
`);

await shopify.admin.graphql(`
  mutation UpdateProduct($id: ID!, $input: ProductInput!) {
    productUpdate(id: $id, input: $input) {
      product {
        id
        title
      }
      userErrors {
        field
        message
      }
    }
  }
`, { variables: { id: productId, input: updateData } });
```

## Important Rules

- **No HTML comments**: Do not use HTML comments in extension code. Use component tooltips and help text instead.
- **kebab-case attributes**: All custom attributes must use kebab-case naming.
- **Globally registered components**: Polaris components are pre-registered—no imports needed.
- **Direct API access**: Use `shopify.admin.graphql()` to query and mutate data.

## Next Steps

- See `admin-extensions-patterns.md` for more extension scaffolding examples.
- Review the [Shopify Admin Extensions documentation](https://shopify.dev/docs/apps/admin-extensions) for complete API reference.
- Explore [Polaris design system](https://polaris.shopify.com) for comprehensive component documentation.
- Test extensions locally using `shopify app dev`.
