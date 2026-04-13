---
name: shopify-polaris-checkout-extensions
description: Triggers on "customize checkout", "add checkout extension", "extend checkout flow", "customize checkout page", "build checkout UI". Build custom functionality at specific checkout flow points using Polaris web components and checkout APIs.
version: 0.1.0
---

# Shopify Polaris Checkout Extensions

Checkout extensions allow you to customize and extend Shopify's checkout experience at specific points in the checkout flow. This skill covers extension targets, Polaris components, APIs, and patterns for enhancing the checkout process.

## Extension Targets

Checkout extensions can be added at various points throughout the checkout flow:

### Address Extension Target
Customize fields and validation on the address section.

```bash
shopify app generate extension --template checkout_ui_extension
```

Use case: Add custom address validation, additional fields, or address-specific messaging.

### Navigation Extension Target
Customize the progress indicator and navigation between checkout steps.

Use case: Add custom progress tracking, step completion indicators, or navigation help text.

### Order Summary Extension Target
Add content to the order summary section showing items, costs, and totals.

Use case: Display discounts, rewards points, loyalty badges, or promotional content.

### Shipping Extension Target
Customize the shipping method selection and delivery options.

Use case: Add custom shipping descriptions, estimated delivery dates, or shipping promotions.

### Payment Extension Target
Add content and information to the payment section.

Use case: Display payment icons, payment terms, security badges, or payment promotions.

## Polaris Web Components for Checkout

Checkout extensions use Polaris web components with the `s-` prefix, registered globally without needing imports.

### Button Components

```html
<s-button
  kind="primary"
  onclick="handleClick()"
>
  Continue
</s-button>
```

### Text and Display Components

```html
<s-text variant="headingMd">Shipping Address</s-text>
<s-text variant="bodyMd" tone="subdued">Enter your delivery address</s-text>
<s-text variant="bodySm">Additional information</s-text>
```

### Form Components

**Text Field:**
```html
<s-text-field
  label="Full Name"
  type="text"
  placeholder="Enter full name"
  onchange="handleChange(event)"
  required
/>
```

**Select Dropdown:**
```html
<s-select
  label="Shipping Method"
  value="{{selectedMethod}}"
  onchange="handleMethodChange(event)"
>
  <option value="standard">Standard (5-7 days)</option>
  <option value="express">Express (2-3 days)</option>
  <option value="overnight">Overnight (1 day)</option>
</s-select>
```

**Checkbox:**
```html
<s-checkbox
  label="Same as shipping address"
  checked="{{sameAddress}}"
  onchange="handleAddressChange(event)"
/>
```

### Layout Components

**Block Stack (Vertical Layout):**
```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Delivery Options</s-text>
  <s-checkbox label="Standard Shipping" />
  <s-checkbox label="Express Shipping" />
  <s-checkbox label="Overnight Shipping" />
</s-block-stack>
```

**Inline Stack (Horizontal Layout):**
```html
<s-inline-stack gap="base" align="center">
  <s-text>Estimated delivery:</s-text>
  <s-text variant="headingMd">{{deliveryDate}}</s-text>
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
<s-banner kind="info" title="Delivery Information">
  Your order will arrive in 5-7 business days.
</s-banner>
```

**Badge:**
```html
<s-badge kind="success">Free Shipping</s-badge>
```

**Text with Tone:**
```html
<s-text tone="subdued">Subtotal</s-text>
<s-text tone="critical">Invalid address</s-text>
```

## Checkout Architecture

### Available APIs

Checkout extensions have access to these APIs:

| API | Purpose | Example |
|-----|---------|---------|
| `Checkout` | Access checkout data and lifecycle | `checkout.deliveryAddress` |
| `Cart` | Access cart items and modifications | `cart.lines` |
| `Buyer` | Access buyer information | `buyer.email` |
| `Shipping` | Access/select shipping methods | `shipping.selectedShippingOption` |
| `Payment` | Handle payment method selection | `payment.selectedMethod` |

### Accessing Checkout Data

```javascript
const { checkout, cart, buyer } = useData();

console.log(checkout.token);
console.log(checkout.deliveryAddress);
console.log(cart.lines); // Array of cart items
console.log(buyer.email);
```

### Updating Checkout Data

```javascript
const { applyAttributeUpdates } = useApplyAttributeUpdates();

applyAttributeUpdates({
  attributes: [
    { key: 'gift_message', value: 'Happy Birthday!' }
  ]
});
```

## Building Checkout Extensions

### Custom Shipping Options Display

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Delivery Method</s-text>
  
  <s-block-stack gap="base">
    {{#each shippingOptions}}
      <s-box 
        padding="base" 
        background-color="{{isSelected ? 'bg-selected' : 'bg-surface'}}"
        onclick="selectShipping({{this.id}})"
        style="cursor: pointer; border: {{isSelected ? '2px solid' : '1px solid'}} #ccc; border-radius: 4px;"
      >
        <s-inline-stack gap="base" align="space-between">
          <s-block-stack gap="extra-tight">
            <s-text variant="headingMd">{{this.title}}</s-text>
            <s-text variant="bodySm" tone="subdued">
              {{this.description}}
            </s-text>
          </s-block-stack>
          <s-text variant="headingMd">${{this.price}}</s-text>
        </s-inline-stack>
      </s-box>
    {{/each}}
  </s-block-stack>
</s-block-stack>
```

### Order Summary Enhancement

```html
<s-box padding="loose">
  <s-block-stack gap="loose">
    <s-text variant="headingMd">Order Summary</s-text>
    
    {{#each cartItems}}
      <s-inline-stack gap="base" align="space-between">
        <s-block-stack gap="extra-tight">
          <s-text>{{this.title}}</s-text>
          <s-text variant="bodySm" tone="subdued">
            Qty: {{this.quantity}}
          </s-text>
        </s-block-stack>
        <s-text>${{this.total}}</s-text>
      </s-inline-stack>
    {{/each}}
    
    <s-divider />
    
    {{#if hasPromotion}}
      <s-inline-stack gap="base" align="space-between">
        <s-text tone="subdued">Discount</s-text>
        <s-text tone="success">-${{discountAmount}}</s-text>
      </s-inline-stack>
    {{/if}}
    
    <s-inline-stack gap="base" align="space-between">
      <s-text>Subtotal</s-text>
      <s-text>${{subtotal}}</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Shipping</s-text>
      <s-text>${{shippingCost}}</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text variant="headingMd">Total</s-text>
      <s-text variant="headingMd">${{total}}</s-text>
    </s-inline-stack>
  </s-block-stack>
</s-box>
```

### Address Validation Extension

```html
<s-block-stack gap="loose">
  <s-text-field
    label="Street Address"
    type="text"
    value="{{address.line1}}"
    onchange="handleAddressChange(event)"
    error="{{addressError}}"
    required
  />

  <s-inline-stack gap="base">
    <s-text-field
      label="City"
      type="text"
      value="{{address.city}}"
      onchange="handleCityChange(event)"
      required
    />
    
    <s-text-field
      label="State"
      type="text"
      value="{{address.province}}"
      onchange="handleProvinceChange(event)"
      required
    />

    <s-text-field
      label="ZIP Code"
      type="text"
      value="{{address.zip}}"
      onchange="handleZipChange(event)"
      error="{{zipError}}"
      required
    />
  </s-inline-stack>

  {{#if addressValidationError}}
    <s-banner kind="critical" title="Address Issue">
      {{addressValidationError}}
    </s-banner>
  {{/if}}
</s-block-stack>
```

### Payment Method Selection

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Payment Method</s-text>
  
  <s-block-stack gap="base">
    <s-box
      padding="base"
      background-color="{{paymentMethod === 'card' ? 'bg-selected' : 'bg-surface'}}"
      onclick="selectPaymentMethod('card')"
      style="cursor: pointer; border: {{paymentMethod === 'card' ? '2px solid' : '1px solid'}} #ccc; border-radius: 4px;"
    >
      <s-inline-stack gap="base">
        <s-text variant="headingMd">Credit Card</s-text>
        <s-text variant="bodySm" tone="subdued">Visa, Mastercard, Amex</s-text>
      </s-inline-stack>
    </s-box>

    <s-box
      padding="base"
      background-color="{{paymentMethod === 'paypal' ? 'bg-selected' : 'bg-surface'}}"
      onclick="selectPaymentMethod('paypal')"
      style="cursor: pointer; border: {{paymentMethod === 'paypal' ? '2px solid' : '1px solid'}} #ccc; border-radius: 4px;"
    >
      <s-inline-stack gap="base">
        <s-text variant="headingMd">PayPal</s-text>
        <s-text variant="bodySm" tone="subdued">Fast and secure</s-text>
      </s-inline-stack>
    </s-box>

    {{#if paymentMethod === 'card'}}
      <s-block-stack gap="base">
        <s-text-field
          label="Card Number"
          type="text"
          placeholder="1234 5678 9012 3456"
          required
        />
        <s-inline-stack gap="base">
          <s-text-field label="MM/YY" type="text" required />
          <s-text-field label="CVC" type="text" required />
        </s-inline-stack>
      </s-block-stack>
    {{/if}}
  </s-block-stack>
</s-block-stack>
```

## Attribute Syntax

All attributes use kebab-case naming:

```html
<s-text-field label="Email" type="email" required />
<s-checkbox label="Accept terms" checked="true" />
<s-button kind="primary" onclick="handle()">Submit</s-button>
```

Boolean attributes:
- Empty: `required`
- String: `required="true"`

## API Access Patterns

### Query Checkout Information

```javascript
const { checkout, cart, buyer } = useData();

const customerEmail = buyer?.email;
const shippingAddress = checkout?.deliveryAddress;
const cartItems = cart?.lines;
const total = checkout?.subtotalPrice;
```

### Update Checkout Attributes

```javascript
const { applyAttributeUpdates } = useApplyAttributeUpdates();

applyAttributeUpdates({
  attributes: [
    { key: 'message', value: 'Gift message text' },
    { key: 'recipient', value: 'John Doe' }
  ]
});
```

### Handle Delivery Option Selection

```javascript
const { applyDeliveryOption } = useApplyDeliveryOption();

const selectDeliveryOption = async (optionId) => {
  try {
    await applyDeliveryOption({
      selectedDeliveryOption: {
        handle: optionId
      }
    });
  } catch (error) {
    console.error('Failed to update delivery', error);
  }
};
```

## Important Rules

- **No HTML comments**: Avoid HTML comments in checkout code. Use tooltips instead.
- **kebab-case attributes**: All custom attributes must be kebab-case.
- **Global components**: Polaris components are pre-registered—no imports needed.
- **Asynchronous updates**: Always handle async operations with proper error handling.
- **Responsive design**: Test on mobile and tablet viewports.

## Next Steps

- See `checkout-extensions-patterns.md` for implementation examples.
- Review the [Shopify Checkout Extensions documentation](https://shopify.dev/docs/apps/checkout) for complete API reference.
- Test extensions using the Shopify checkout development environment.
- Monitor checkout performance and user experience metrics.
