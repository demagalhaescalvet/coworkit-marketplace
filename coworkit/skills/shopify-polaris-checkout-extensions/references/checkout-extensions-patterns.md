# Checkout Extensions Patterns & Examples

Reference guide with practical implementation examples for Shopify checkout extensions.

## Extension Scaffolding

### Generate a Checkout UI Extension

```bash
shopify app generate extension --template checkout_ui_extension
```

This creates a new checkout extension with base structure and necessary files.

**File structure:**
```
extensions/
  my-checkout-extension/
    src/
      index.jsx
    shopify.app.toml
```

## Component Usage Examples

### Basic Address Form

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Delivery Address</s-text>

  <s-text-field
    label="Street Address"
    type="text"
    placeholder="123 Main St"
    required
  />

  <s-inline-stack gap="base">
    <s-text-field
      label="City"
      type="text"
      placeholder="New York"
      required
    />

    <s-text-field
      label="State/Province"
      type="text"
      placeholder="NY"
      required
    />

    <s-text-field
      label="ZIP/Postal Code"
      type="text"
      placeholder="10001"
      required
    />
  </s-inline-stack>

  <s-text-field
    label="Country"
    type="text"
    placeholder="United States"
    required
  />
</s-block-stack>
```

### Shipping Method Selection with Pricing

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Shipping Method</s-text>

  <s-block-stack gap="base">
    <s-box
      padding="base"
      background-color="bg-surface"
      style="border: 1px solid #ccc; border-radius: 4px;"
    >
      <s-inline-stack gap="base" align="space-between">
        <s-block-stack gap="extra-tight">
          <s-text variant="headingMd">Standard Shipping</s-text>
          <s-text variant="bodySm" tone="subdued">Arrives in 5-7 business days</s-text>
        </s-block-stack>
        <s-text variant="headingMd">$9.99</s-text>
      </s-inline-stack>
    </s-box>

    <s-box
      padding="base"
      background-color="bg-surface"
      style="border: 1px solid #ccc; border-radius: 4px;"
    >
      <s-inline-stack gap="base" align="space-between">
        <s-block-stack gap="extra-tight">
          <s-text variant="headingMd">Express Shipping</s-text>
          <s-text variant="bodySm" tone="subdued">Arrives in 2-3 business days</s-text>
        </s-block-stack>
        <s-text variant="headingMd">$24.99</s-text>
      </s-inline-stack>
    </s-box>

    <s-box
      padding="base"
      background-color="bg-surface"
      style="border: 1px solid #ccc; border-radius: 4px;"
    >
      <s-inline-stack gap="base" align="space-between">
        <s-block-stack gap="extra-tight">
          <s-text variant="headingMd">Overnight Shipping</s-text>
          <s-text variant="bodySm" tone="subdued">Arrives tomorrow</s-text>
        </s-block-stack>
        <s-text variant="headingMd">$49.99</s-text>
      </s-inline-stack>
    </s-box>
  </s-block-stack>
</s-block-stack>
```

### Order Summary Display

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-text variant="headingMd">Order Summary</s-text>

    <s-block-stack gap="base">
      <s-inline-stack gap="base" align="space-between">
        <s-text>Item 1 (Qty: 2)</s-text>
        <s-text>$49.98</s-text>
      </s-inline-stack>

      <s-inline-stack gap="base" align="space-between">
        <s-text>Item 2 (Qty: 1)</s-text>
        <s-text>$29.99</s-text>
      </s-inline-stack>
    </s-block-stack>

    <s-divider />

    <s-inline-stack gap="base" align="space-between">
      <s-text>Subtotal</s-text>
      <s-text>$79.97</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Shipping</s-text>
      <s-text>$9.99</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Tax</s-text>
      <s-text>$6.98</s-text>
    </s-inline-stack>

    <s-divider />

    <s-inline-stack gap="base" align="space-between">
      <s-text variant="headingMd">Total</s-text>
      <s-text variant="headingMd">$96.94</s-text>
    </s-inline-stack>
  </s-block-stack>
</s-box>
```

### Gift Message Form

```html
<s-box padding="base">
  <s-block-stack gap="loose">
    <s-checkbox
      label="This is a gift"
      checked="{{isGift}}"
      onchange="handleGiftChange(event)"
    />

    {{#if isGift}}
      <s-text-area
        label="Gift Message"
        placeholder="Write a message for the recipient..."
        rows="3"
        maxlength="250"
      />

      <s-text-field
        label="From"
        type="text"
        placeholder="Your name"
      />

      <s-checkbox
        label="Hide price from packing slip"
      />
    {{/if}}
  </s-block-stack>
</s-box>
```

### Delivery Date Picker

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Preferred Delivery Date</s-text>

  <s-select label="Select a date">
    <option value="2024-01-15">Monday, January 15 - Standard</option>
    <option value="2024-01-13">Saturday, January 13 - Express</option>
    <option value="2024-01-12">Friday, January 12 - Overnight</option>
  </s-select>

  <s-text variant="bodySm" tone="subdued">
    Delivery date is estimated and may vary.
  </s-text>
</s-block-stack>
```

### Promotional Banner in Checkout

```html
{{#if hasEligiblePromotion}}
  <s-banner kind="info" title="Great News!">
    You qualify for free shipping on this order!
  </s-banner>
{{/if}}

{{#if hasDiscount}}
  <s-banner kind="success" title="Discount Applied">
    {{discountCode}} discount of ${{discountAmount}} has been applied.
  </s-banner>
{{/if}}

{{#if freeShippingThreshold}}
  <s-banner kind="warning" title="Almost There">
    Add ${{remainingAmount}} more to qualify for free shipping.
  </s-banner>
{{/if}}
```

### Loyalty Program Display

```html
<s-box padding="base" background-color="bg-surface">
  <s-block-stack gap="base">
    <s-text variant="headingMd">Loyalty Rewards</s-text>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Current Points</s-text>
      <s-text variant="headingMd">{{loyaltyPoints}}</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Points This Order</s-text>
      <s-badge kind="success">+{{pointsEarned}}</s-badge>
    </s-inline-stack>

    <s-text variant="bodySm" tone="subdued">
      1 point = $0.01 off future orders
    </s-text>

    {{#if canRedeemPoints}}
      <s-checkbox
        label="Redeem {{availablePoints}} points for ${{pointsValue}} off"
      />
    {{/if}}
  </s-block-stack>
</s-box>
```

### Payment Method Icons

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Accepted Payment Methods</s-text>

  <s-inline-stack gap="base">
    <s-image
      src="https://example.com/visa.svg"
      alt="Visa"
      width="40"
      height="25"
    />
    <s-image
      src="https://example.com/mastercard.svg"
      alt="Mastercard"
      width="40"
      height="25"
    />
    <s-image
      src="https://example.com/amex.svg"
      alt="American Express"
      width="40"
      height="25"
    />
    <s-image
      src="https://example.com/paypal.svg"
      alt="PayPal"
      width="40"
      height="25"
    />
  </s-inline-stack>
</s-block-stack>
```

## JavaScript Integration Examples

### Handle Form Input Changes

```javascript
const handleAddressChange = (event) => {
  const { value } = event.target;
  setAddress({
    ...address,
    line1: value
  });
};

const handleCityChange = (event) => {
  const { value } = event.target;
  setAddress({
    ...address,
    city: value
  });
};
```

### Validate Address Format

```javascript
const validateAddress = (address) => {
  const errors = {};

  if (!address.line1 || address.line1.trim().length === 0) {
    errors.line1 = 'Street address is required';
  }

  if (!address.city || address.city.trim().length === 0) {
    errors.city = 'City is required';
  }

  if (!address.zipCode || !/^\d{5}(-\d{4})?$/.test(address.zipCode)) {
    errors.zipCode = 'Valid ZIP code is required';
  }

  return errors;
};
```

### Submit Checkout Extension Data

```javascript
const submitCheckoutData = async (data) => {
  try {
    const { applyAttributeUpdates } = useApplyAttributeUpdates();
    
    await applyAttributeUpdates({
      attributes: Object.entries(data).map(([key, value]) => ({
        key,
        value: String(value)
      }))
    });

    setSuccess(true);
  } catch (error) {
    console.error('Failed to update checkout:', error);
    setError('Failed to save information');
  }
};
```

### Handle Shipping Selection

```javascript
const handleShippingSelect = async (shippingOptionId) => {
  try {
    setLoading(true);
    
    const { applyDeliveryOption } = useApplyDeliveryOption();
    
    await applyDeliveryOption({
      selectedDeliveryOption: {
        handle: shippingOptionId
      }
    });

    setSelectedShipping(shippingOptionId);
  } catch (error) {
    setError('Failed to update shipping method');
  } finally {
    setLoading(false);
  }
};
```

## Error Handling Patterns

### Validation Error Display

```html
{{#if errors.email}}
  <s-text-field
    label="Email"
    type="email"
    error="{{errors.email}}"
    required
  />
{{else}}
  <s-text-field
    label="Email"
    type="email"
    required
  />
{{/if}}

{{#if errors.address}}
  <s-banner kind="critical" title="Address Error">
    {{errors.address}}
  </s-banner>
{{/if}}
```

### Loading State in Extension

```html
{{#if isLoading}}
  <s-box padding="loose">
    <s-block-stack gap="base" align="center">
      <s-spinner size="large" />
      <s-text variant="bodyMd">Updating checkout...</s-text>
    </s-block-stack>
  </s-box>
{{else}}
  <!-- Form content here -->
{{/if}}
```

## Best Practices

1. Always validate input before submission
2. Provide clear feedback for every user action
3. Show loading states during async operations
4. Handle errors gracefully with helpful messages
5. Test on various screen sizes and devices
6. Keep form fields focused and organized
7. Use appropriate component spacing for readability
8. Provide helpful hints for complex fields
9. Minimize checkout friction and steps
10. Test with real checkout data
