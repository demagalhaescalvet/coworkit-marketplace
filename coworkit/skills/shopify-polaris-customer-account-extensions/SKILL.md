---
name: shopify-polaris-customer-account-extensions
description: Triggers on "create customer account extension", "customize account page", "add account features", "build account UI", "extend customer dashboard". Build custom pages and functionality for Shopify customer account sections using Polaris web components.
version: 0.1.0
---

# Shopify Polaris Customer Account Extensions

Customer account extensions let you customize and extend the customer account pages with custom functionality, data, and UI. This skill covers installation points, extension targets, Polaris components, and patterns for enhancing the customer account experience.

## Installation Points

Customer account extensions can be installed at various points throughout the customer portal:

### Order Index Page
Customize the page showing all customer orders.

```bash
shopify app generate extension --template customer_account_ui_extension
```

Use cases: Add order tracking, reorder buttons, order analytics, order filters

### Order Status Page
Customize the individual order detail page.

Use cases: Add custom fulfillment tracking, delivery updates, return information

### Profile Pages
Customize customer profile and account settings pages.

Use cases: Loyalty program info, subscription management, preference center

## Extension Targets

Extensions can target specific sections within installation points:

| Target | Location | Use Case |
|--------|----------|----------|
| `order.index.footer` | Below orders list | Additional info, promotions |
| `order.status.footer` | Below order details | Tracking, updates, support |
| `order.status.cart_line_item` | Within order items | Item details, reviews, support |
| `profile.footer` | Below profile info | Settings, preferences, integrations |
| `profile.page` | Full profile page | Custom dashboard, analytics |
| `account.page` | Account settings | Custom settings, management |
| `order.status.payment_details` | Payment section | Payment info, receipts |
| `order.status.fulfillment` | Fulfillment section | Delivery tracking, updates |

## Polaris Web Components for Customer Accounts

All Polaris web components are globally registered with the `s-` prefix.

### Text and Display Components

```html
<s-text variant="headingXl">Account Dashboard</s-text>
<s-text variant="headingLg">Your Orders</s-text>
<s-text variant="headingMd">Order Details</s-text>
<s-text variant="bodyMd">Order information</s-text>
<s-text variant="bodySm">Supporting text</s-text>
<s-text tone="subdued">Disabled or secondary text</s-text>
<s-text tone="success">Success message</s-text>
<s-text tone="warning">Warning message</s-text>
<s-text tone="critical">Error message</s-text>
```

### Button Components

```html
<s-button kind="primary" onclick="handleAction()">
  Primary Action
</s-button>

<s-button kind="secondary" onclick="handleSecondary()">
  Secondary Action
</s-button>

<s-button kind="tertiary" onclick="handleTertiary()">
  Tertiary Action
</s-button>

<s-button kind="plain" onclick="handlePlain()">
  Plain Link
</s-button>
```

### Form Components

**Text Field:**
```html
<s-text-field
  label="Email"
  type="email"
  placeholder="customer@example.com"
  value="{{email}}"
  onchange="handleEmailChange(event)"
/>
```

**Select Dropdown:**
```html
<s-select
  label="Sort Orders By"
  value="{{sortOption}}"
  onchange="handleSortChange(event)"
>
  <option value="date-desc">Newest First</option>
  <option value="date-asc">Oldest First</option>
  <option value="total-high">Highest Total</option>
  <option value="total-low">Lowest Total</option>
</s-select>
```

**Checkbox:**
```html
<s-checkbox
  label="Notify me of order updates"
  checked="{{notificationsEnabled}}"
  onchange="handleNotificationChange(event)"
/>
```

**Text Area:**
```html
<s-text-area
  label="Leave a Review"
  placeholder="Share your feedback..."
  rows="4"
  maxlength="500"
  onchange="handleReviewChange(event)"
/>
```

### Layout Components

**Block Stack (Vertical):**
```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Order Information</s-text>
  <s-text>Order ID: #12345</s-text>
  <s-text>Date: January 15, 2024</s-text>
  <s-text>Total: $199.99</s-text>
</s-block-stack>
```

**Inline Stack (Horizontal):**
```html
<s-inline-stack gap="base" align="space-between">
  <s-text>Subtotal</s-text>
  <s-text>$150.00</s-text>
</s-inline-stack>
```

**Box (Container):**
```html
<s-box padding="loose" background-color="bg-surface">
  <s-block-stack gap="base">
    <s-text variant="headingMd">Order Summary</s-text>
  </s-block-stack>
</s-box>
```

### Feedback Components

**Banner:**
```html
<s-banner kind="success" title="Order Confirmed">
  Your order has been successfully placed.
</s-banner>

<s-banner kind="info" title="Shipping Information">
  Your order is on its way!
</s-banner>

<s-banner kind="warning" title="Delivery Delay">
  Expected delivery is delayed by 2 days.
</s-banner>

<s-banner kind="critical" title="Order Issue">
  There's a problem with your order.
</s-banner>
```

**Badge:**
```html
<s-badge kind="success">Delivered</s-badge>
<s-badge kind="warning">Processing</s-badge>
<s-badge kind="critical">Cancelled</s-badge>
<s-badge kind="info">Pending</s-badge>
```

### Media Components

**Image:**
```html
<s-image
  src="{{productImage}}"
  alt="Product image"
  width="200"
  height="200"
/>
```

**Avatar:**
```html
<s-avatar
  initials="JD"
  size="large"
/>
```

## Available APIs

Customer account extensions have access to these APIs:

| API | Purpose | Example |
|-----|---------|---------|
| `Analytics` | Track customer behavior | `analytics.trackEvent()` |
| `Authentication` | Access customer data | `auth.getCustomer()` |
| `Customer Privacy` | Respect privacy settings | `privacy.getConsent()` |
| `Localization` | Support multiple languages | `localization.getLanguage()` |
| `Customer Data` | Query customer information | `customer.orders` |

## Building Customer Account Extensions

### Order List with Actions

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Your Orders</s-text>

  {{#if orders.length > 0}}
    <s-block-stack gap="base">
      {{#each orders}}
        <s-box padding="base" background-color="bg-surface">
          <s-inline-stack gap="base" align="space-between">
            <s-block-stack gap="extra-tight">
              <s-text variant="headingMd">#{{this.number}}</s-text>
              <s-text variant="bodySm" tone="subdued">
                {{this.createdAt | date}}
              </s-text>
              <s-text variant="bodySm">
                {{this.lineItems.length}} item(s) - ${{this.totalPrice}}
              </s-text>
            </s-block-stack>
            <s-block-stack gap="extra-tight" align="end">
              <s-badge kind="{{this.statusKind}}">
                {{this.status}}
              </s-badge>
              <s-button
                kind="secondary"
                onclick="viewOrderDetails('{{this.id}}')"
              >
                View Order
              </s-button>
            </s-block-stack>
          </s-inline-stack>
        </s-box>
      {{/each}}
    </s-block-stack>
  {{else}}
    <s-text tone="subdued">No orders found</s-text>
  {{/if}}
</s-block-stack>
```

### Order Tracking Timeline

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Order Status</s-text>

  <s-block-stack gap="base">
    {{#each trackingEvents}}
      <s-box padding="base" background-color="bg-surface">
        <s-inline-stack gap="base">
          <s-badge kind="{{this.statusKind}}">
            {{this.status}}
          </s-badge>
          <s-block-stack gap="extra-tight">
            <s-text variant="headingMd">{{this.title}}</s-text>
            <s-text variant="bodySm" tone="subdued">
              {{this.timestamp | dateTime}}
            </s-text>
            {{#if this.description}}
              <s-text variant="bodySm">{{this.description}}</s-text>
            {{/if}}
          </s-block-stack>
        </s-inline-stack>
      </s-box>
    {{/each}}
  </s-block-stack>
</s-block-stack>
```

### Loyalty Program Section

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-text variant="headingMd">Loyalty Points</s-text>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Current Balance</s-text>
      <s-text variant="headingLg">{{loyaltyPoints}}</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Next Tier</s-text>
      <s-text>{{pointsUntilNextTier}} points</s-text>
    </s-inline-stack>

    <s-block-stack gap="base">
      <s-text>Points Earned This Year</s-text>
      <s-box style="background: linear-gradient(to right, #4CAF50 {{percentToNextTier}}%, #eee {{percentToNextTier}}%); height: 8px; border-radius: 4px;" />
    </s-block-stack>

    <s-text variant="bodySm" tone="subdued">
      1 point = $0.01 off future purchases
    </s-text>

    <s-button kind="secondary" onclick="viewRewards()">
      View Rewards
    </s-button>
  </s-block-stack>
</s-box>
```

### Subscription Management

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Active Subscriptions</s-text>

  {{#each subscriptions}}
    <s-box padding="base" background-color="bg-surface">
      <s-block-stack gap="base">
        <s-inline-stack gap="base" align="space-between">
          <s-text variant="headingMd">{{this.productName}}</s-text>
          <s-badge kind="{{this.statusKind}}">{{this.status}}</s-badge>
        </s-inline-stack>

        <s-inline-stack gap="base" align="space-between">
          <s-text>Next Delivery</s-text>
          <s-text>{{this.nextDeliveryDate | date}}</s-text>
        </s-inline-stack>

        <s-inline-stack gap="base" align="space-between">
          <s-text>Frequency</s-text>
          <s-text>Every {{this.frequency}} {{this.frequencyUnit}}</s-text>
        </s-inline-stack>

        <s-inline-stack gap="base">
          <s-button kind="secondary" onclick="editSubscription('{{this.id}}')">
            Edit
          </s-button>
          <s-button kind="tertiary" onclick="pauseSubscription('{{this.id}}')">
            Pause
          </s-button>
          <s-button kind="destructive" onclick="cancelSubscription('{{this.id}}')">
            Cancel
          </s-button>
        </s-inline-stack>
      </s-block-stack>
    </s-box>
  {{/each}}
</s-block-stack>
```

### Account Preferences

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Notification Preferences</s-text>

  <s-block-stack gap="base">
    <s-checkbox
      label="Order confirmation emails"
      checked="{{notifyOrderConfirmation}}"
      onchange="handlePreferenceChange('orderConfirmation', event)"
    />

    <s-checkbox
      label="Shipping and delivery updates"
      checked="{{notifyShipping}}"
      onchange="handlePreferenceChange('shipping', event)"
    />

    <s-checkbox
      label="Order status changes"
      checked="{{notifyStatus}}"
      onchange="handlePreferenceChange('status', event)"
    />

    <s-checkbox
      label="Promotional emails and offers"
      checked="{{notifyPromo}}"
      onchange="handlePreferenceChange('promo', event)"
    />

    <s-checkbox
      label="Account notifications"
      checked="{{notifyAccount}}"
      onchange="handlePreferenceChange('account', event)"
    />
  </s-block-stack>

  {{#if preferencesUpdated}}
    <s-banner kind="success" title="Preferences Saved">
      Your notification preferences have been updated.
    </s-banner>
  {{/if}}
</s-block-stack>
```

## Attribute Syntax

All attributes use kebab-case naming:

```html
<s-text-field label="Name" type="text" required />
<s-checkbox label="Subscribe" checked="true" />
<s-block-stack gap="loose" align="stretch">
<s-button kind="primary" onclick="handleClick()">Action</s-button>
```

## API Access Patterns

### Access Customer Data

```javascript
const { customer } = useCustomerData();

const customerEmail = customer?.email;
const customerName = customer?.firstName;
const orders = customer?.orders;
```

### Track Customer Actions

```javascript
const { analytics } = useAnalytics();

const trackAction = (actionName, properties) => {
  analytics.trackEvent({
    name: actionName,
    properties: properties
  });
};
```

### Support Internationalization

```javascript
const { localization } = useLocalization();

const locale = localization.getLanguage();
const formatCurrency = (amount) => {
  return localization.formatCurrency(amount);
};
```

## Important Rules

- **No HTML comments**: Avoid HTML comments in account code. Use tooltips instead.
- **kebab-case attributes**: All custom attributes must be kebab-case.
- **Global components**: Polaris components are pre-registered—no imports needed.
- **Respect privacy**: Always check customer privacy preferences.
- **Mobile-first design**: Extensions should work on mobile devices.
- **Performance**: Keep component renders lightweight and efficient.

## Next Steps

- See `customer-account-extensions-patterns.md` for implementation examples.
- Review the [Shopify Customer Account Extensions documentation](https://shopify.dev/docs/apps/customer-accounts) for complete API reference.
- Test extensions with real customer account data.
- Monitor customer account page performance.
