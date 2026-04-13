# Customer Account Extensions Patterns & Examples

Reference guide with practical implementation examples for Shopify customer account extensions.

## Extension Scaffolding

### Generate a Customer Account Extension

```bash
shopify app generate extension --template customer_account_ui_extension
```

This creates a new customer account extension with base structure.

**File structure:**
```
extensions/
  my-account-extension/
    src/
      index.jsx
    shopify.app.toml
```

## Component Usage Examples

### Account Dashboard Header

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="base">
    <s-inline-stack gap="base" align="space-between">
      <s-block-stack gap="tight">
        <s-text variant="headingXl">Welcome, {{customerName}}</s-text>
        <s-text variant="bodyMd" tone="subdued">{{customerEmail}}</s-text>
      </s-block-stack>
      <s-avatar initials="{{initials}}" size="large" />
    </s-inline-stack>
  </s-block-stack>
</s-box>
```

### Orders Summary Cards

```html
<s-inline-stack gap="base">
  <s-box padding="base" background-color="bg-surface">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Total Orders</s-text>
      <s-text variant="headingLg">{{totalOrders}}</s-text>
    </s-block-stack>
  </s-box>

  <s-box padding="base" background-color="bg-surface">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Total Spent</s-text>
      <s-text variant="headingLg">${{totalSpent}}</s-text>
    </s-block-stack>
  </s-box>

  <s-box padding="base" background-color="bg-surface">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Loyalty Points</s-text>
      <s-text variant="headingLg">{{loyaltyPoints}}</s-text>
    </s-block-stack>
  </s-box>
</s-inline-stack>
```

### Reorder Quick Access

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Reorder from Previous Purchases</s-text>

  <s-block-stack gap="base">
    {{#each recentOrders limit=3}}
      <s-box padding="base" background-color="bg-surface">
        <s-inline-stack gap="base" align="space-between">
          <s-block-stack gap="extra-tight">
            <s-text variant="headingMd">#{{this.number}}</s-text>
            <s-text variant="bodySm" tone="subdued">
              {{this.createdAt | dateRelative}}
            </s-text>
            <s-text variant="bodySm">
              {{this.itemCount}} item(s) - ${{this.total}}
            </s-text>
          </s-block-stack>
          <s-button
            kind="secondary"
            onclick="reorderItems('{{this.id}}')"
          >
            Reorder
          </s-button>
        </s-inline-stack>
      </s-box>
    {{/each}}
  </s-block-stack>
</s-block-stack>
```

### Order Timeline with Delivery Map

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Delivery Progress</s-text>

  <s-block-stack gap="base">
    <s-box
      padding="base"
      background-color="{{currentStep >= 0 ? 'bg-success' : 'bg-surface'}}"
      style="border-radius: 4px;"
    >
      <s-text variant="bodyMd">Order Placed</s-text>
      <s-text variant="bodySm" tone="subdued">{{placedDate}}</s-text>
    </s-box>

    <s-text tone="subdued" style="text-align: center;">↓</s-text>

    <s-box
      padding="base"
      background-color="{{currentStep >= 1 ? 'bg-success' : 'bg-surface'}}"
      style="border-radius: 4px;"
    >
      <s-text variant="bodyMd">Processing</s-text>
      <s-text variant="bodySm" tone="subdued">Expected: {{processingDate}}</s-text>
    </s-box>

    <s-text tone="subdued" style="text-align: center;">↓</s-text>

    <s-box
      padding="base"
      background-color="{{currentStep >= 2 ? 'bg-success' : 'bg-surface'}}"
      style="border-radius: 4px;"
    >
      <s-text variant="bodyMd">Shipped</s-text>
      <s-text variant="bodySm" tone="subdued">{{shippedDate}}</s-text>
      {{#if trackingNumber}}
        <s-text variant="bodySm">
          Tracking: {{trackingNumber}}
        </s-text>
      {{/if}}
    </s-box>

    <s-text tone="subdued" style="text-align: center;">↓</s-text>

    <s-box
      padding="base"
      background-color="{{currentStep >= 3 ? 'bg-success' : 'bg-surface'}}"
      style="border-radius: 4px;"
    >
      <s-text variant="bodyMd">Delivered</s-text>
      <s-text variant="bodySm" tone="subdued">Expected: {{deliveryDate}}</s-text>
    </s-box>
  </s-block-stack>
</s-block-stack>
```

### Product Review Form

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">How was {{productName}}?</s-text>

  <s-block-stack gap="base">
    <s-text variant="bodyMd">Rate your experience</s-text>
    
    <s-inline-stack gap="base">
      {{#each [1,2,3,4,5]}}
        <s-button
          kind="{{selectedRating >= this ? 'primary' : 'secondary'}}"
          onclick="setRating({{this}})"
          style="font-size: 24px;"
        >
          {{#if selectedRating >= this}}★{{else}}☆{{/if}}
        </s-button>
      {{/each}}
    </s-inline-stack>

    <s-text-area
      label="Write a Review"
      placeholder="Tell us more about your experience..."
      rows="4"
      maxlength="500"
      onchange="handleReviewChange(event)"
    />

    <s-button kind="primary" onclick="submitReview()">
      Submit Review
    </s-button>
  </s-block-stack>
</s-block-stack>
```

### Address Book Management

```html
<s-block-stack gap="loose">
  <s-inline-stack gap="base" align="space-between">
    <s-text variant="headingMd">Saved Addresses</s-text>
    <s-button kind="secondary" onclick="addNewAddress()">
      Add Address
    </s-button>
  </s-inline-stack>

  <s-block-stack gap="base">
    {{#each addresses}}
      <s-box padding="base" background-color="bg-surface">
        <s-block-stack gap="base">
          <s-text variant="headingMd">{{this.label}}</s-text>
          
          <s-text variant="bodySm">
            {{this.line1}}<br/>
            {{this.city}}, {{this.province}} {{this.zip}}<br/>
            {{this.country}}
          </s-text>

          {{#if this.isDefault}}
            <s-badge kind="success">Default Address</s-badge>
          {{/if}}

          <s-inline-stack gap="base">
            <s-button
              kind="secondary"
              onclick="editAddress('{{this.id}}')"
            >
              Edit
            </s-button>
            {{#if !this.isDefault}}
              <s-button
                kind="tertiary"
                onclick="setDefaultAddress('{{this.id}}')"
              >
                Set as Default
              </s-button>
            {{/if}}
            <s-button
              kind="destructive"
              onclick="deleteAddress('{{this.id}}')"
            >
              Delete
            </s-button>
          </s-inline-stack>
        </s-block-stack>
      </s-box>
    {{/each}}
  </s-block-stack>
</s-block-stack>
```

### Return Request Form

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Request a Return</s-text>

  <s-select
    label="Select Item to Return"
    value="{{selectedItem}}"
    onchange="handleItemSelect(event)"
  >
    {{#each returnableItems}}
      <option value="{{this.id}}">
        {{this.productName}} (Order #{{this.orderNumber}})
      </option>
    {{/each}}
  </s-select>

  <s-text-field
    label="Quantity"
    type="number"
    min="1"
    max="{{maxQty}}"
    value="{{returnQty}}"
    onchange="handleQtyChange(event)"
  />

  <s-select
    label="Reason for Return"
    value="{{returnReason}}"
    onchange="handleReasonChange(event)"
  >
    <option value="damaged">Item Damaged</option>
    <option value="defective">Item Defective</option>
    <option value="not-as-described">Not as Described</option>
    <option value="changed-mind">Changed Mind</option>
    <option value="other">Other</option>
  </s-select>

  <s-text-area
    label="Additional Details"
    placeholder="Describe any damage or issues..."
    rows="3"
    maxlength="300"
    onchange="handleDetailsChange(event)"
  />

  <s-inline-stack gap="base" align="end">
    <s-button onclick="cancelReturn()">Cancel</s-button>
    <s-button kind="primary" onclick="submitReturn()">
      Request Return
    </s-button>
  </s-inline-stack>
</s-block-stack>
```

### Referral Program

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-text variant="headingMd">Share & Earn Rewards</s-text>

    <s-text variant="bodyMd">
      Share your referral link with friends and earn $10 for each successful referral.
    </s-text>

    <s-text-field
      label="Your Referral Link"
      type="text"
      value="{{referralLink}}"
      readonly
    />

    <s-inline-stack gap="base">
      <s-button kind="secondary" onclick="copyLink()">
        {{copyButtonText}}
      </s-button>
      <s-button kind="secondary" onclick="shareViaEmail()">
        Share via Email
      </s-button>
    </s-inline-stack>

    <s-divider />

    <s-text variant="headingMd">Your Referrals</s-text>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Successful Referrals</s-text>
      <s-text variant="headingLg">{{successfulReferrals}}</s-text>
    </s-inline-stack>

    <s-inline-stack gap="base" align="space-between">
      <s-text>Total Earnings</s-text>
      <s-text variant="headingLg">${{referralEarnings}}</s-text>
    </s-inline-stack>

    <s-button kind="secondary" onclick="viewReferralHistory()">
      View Details
    </s-button>
  </s-block-stack>
</s-box>
```

## JavaScript Integration Examples

### Update Account Preferences

```javascript
const updatePreferences = async (preferences) => {
  try {
    setLoading(true);
    
    const response = await fetch('/api/account/preferences', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(preferences)
    });

    if (response.ok) {
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    }
  } catch (error) {
    setError('Failed to update preferences');
  } finally {
    setLoading(false);
  }
};
```

### Fetch Customer Orders

```javascript
const fetchOrders = async () => {
  try {
    setLoading(true);
    
    const response = await fetch('/api/account/orders');
    const data = await response.json();
    
    setOrders(data.orders);
  } catch (error) {
    setError('Failed to load orders');
  } finally {
    setLoading(false);
  }
};
```

### Submit Product Review

```javascript
const submitReview = async (orderId, itemId, review) => {
  try {
    const response = await fetch(`/api/account/reviews`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        orderId,
        itemId,
        rating: review.rating,
        comment: review.comment
      })
    });

    if (response.ok) {
      setSuccess('Review submitted successfully');
      clearForm();
    }
  } catch (error) {
    setError('Failed to submit review');
  }
};
```

## Best Practices

1. Always validate input before submission
2. Provide clear feedback for every user action
3. Show loading states during async operations
4. Handle errors gracefully with helpful messages
5. Test on various screen sizes and devices
6. Respect customer privacy settings
7. Keep forms simple and focused
8. Provide helpful hints for complex tasks
9. Use consistent spacing and typography
10. Test with real customer data
