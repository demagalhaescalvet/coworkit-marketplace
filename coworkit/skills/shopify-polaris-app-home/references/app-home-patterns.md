# App Home Patterns & Examples

Reference guide with comprehensive component examples and UI patterns for Shopify app dashboards.

## Component Examples

### Text Variants and Tones

```html
<s-block-stack gap="loose">
  <s-text variant="headingXl">Extra Large Heading</s-text>
  <s-text variant="headingLg">Large Heading</s-text>
  <s-text variant="headingMd">Medium Heading</s-text>
  <s-text variant="headingSm">Small Heading</s-text>
  <s-text variant="bodyMd">Regular paragraph text</s-text>
  <s-text variant="bodySm">Small text</s-text>
  
  <s-text tone="subdued">Subtle gray text</s-text>
  <s-text tone="success">Success green text</s-text>
  <s-text tone="warning">Warning orange text</s-text>
  <s-text tone="critical">Error red text</s-text>
</s-block-stack>
```

### Button Combinations

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Button Styles</s-text>
  
  <s-block-stack gap="base">
    <s-button kind="primary">Primary Action</s-button>
    <s-button kind="secondary">Secondary Action</s-button>
    <s-button kind="tertiary">Tertiary Action</s-button>
    <s-button kind="plain">Plain Link</s-button>
    <s-button kind="destructive">Delete Action</s-button>
  </s-block-stack>

  <s-text variant="headingMd">Disabled States</s-text>
  
  <s-block-stack gap="base">
    <s-button kind="primary" disabled>Primary Disabled</s-button>
    <s-button kind="secondary" disabled>Secondary Disabled</s-button>
  </s-block-stack>
</s-block-stack>
```

### Form Components Grid

```html
<s-block-stack gap="loose">
  <s-text-field
    label="Text Input"
    type="text"
    placeholder="Enter text"
  />

  <s-text-field
    label="Email Input"
    type="email"
    placeholder="your@email.com"
  />

  <s-text-field
    label="Password Input"
    type="password"
    placeholder="Enter password"
  />

  <s-text-field
    label="Number Input"
    type="number"
    min="0"
    max="100"
  />

  <s-select label="Choose an option">
    <option value="option1">Option 1</option>
    <option value="option2">Option 2</option>
    <option value="option3">Option 3</option>
  </s-select>

  <s-text-area
    label="Message"
    placeholder="Enter your message..."
    rows="4"
  />

  <s-checkbox label="I agree to the terms" />
  <s-checkbox label="Subscribe to updates" />
</s-block-stack>
```

### Spacing and Layout

```html
<s-block-stack gap="extra-loose">
  <s-text variant="headingMd">Extra Loose Gap</s-text>
  <s-box padding="base" background-color="bg-surface">Content 1</s-box>
  <s-box padding="base" background-color="bg-surface">Content 2</s-box>
</s-block-stack>

<s-block-stack gap="loose">
  <s-text variant="headingMd">Loose Gap</s-text>
  <s-box padding="base" background-color="bg-surface">Content 1</s-box>
  <s-box padding="base" background-color="bg-surface">Content 2</s-box>
</s-block-stack>

<s-block-stack gap="base">
  <s-text variant="headingMd">Base Gap</s-text>
  <s-box padding="base" background-color="bg-surface">Content 1</s-box>
  <s-box padding="base" background-color="bg-surface">Content 2</s-box>
</s-block-stack>

<s-block-stack gap="tight">
  <s-text variant="headingMd">Tight Gap</s-text>
  <s-box padding="base" background-color="bg-surface">Content 1</s-box>
  <s-box padding="base" background-color="bg-surface">Content 2</s-box>
</s-block-stack>
```

### Card Layouts

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Feature Card</s-text>

  <s-box padding="loose" background-color="bg-surface-secondary">
    <s-block-stack gap="base">
      <s-text variant="headingMd">Premium Feature</s-text>
      <s-text variant="bodyMd" tone="subdued">
        Upgrade your account to unlock this feature.
      </s-text>
      <s-button kind="primary" onclick="upgradePlan()">
        Upgrade Now
      </s-button>
    </s-block-stack>
  </s-box>
</s-block-stack>
```

### Stat Cards

```html
<s-inline-stack gap="base">
  <s-box padding="loose" background-color="bg-surface" style="flex: 1;">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Total Users</s-text>
      <s-text variant="headingXl">1,234</s-text>
      <s-inline-stack gap="extra-tight" align="center">
        <s-text tone="success">↑ 12%</s-text>
        <s-text variant="bodySm" tone="subdued">vs last month</s-text>
      </s-inline-stack>
    </s-block-stack>
  </s-box>

  <s-box padding="loose" background-color="bg-surface" style="flex: 1;">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Active Sessions</s-text>
      <s-text variant="headingXl">567</s-text>
      <s-inline-stack gap="extra-tight" align="center">
        <s-text tone="success">↑ 8%</s-text>
        <s-text variant="bodySm" tone="subdued">vs last month</s-text>
      </s-inline-stack>
    </s-block-stack>
  </s-box>

  <s-box padding="loose" background-color="bg-surface" style="flex: 1;">
    <s-block-stack gap="tight" align="center">
      <s-text variant="bodySm" tone="subdued">Revenue</s-text>
      <s-text variant="headingXl">$45.2K</s-text>
      <s-inline-stack gap="extra-tight" align="center">
        <s-text tone="critical">↓ 3%</s-text>
        <s-text variant="bodySm" tone="subdued">vs last month</s-text>
      </s-inline-stack>
    </s-block-stack>
  </s-box>
</s-inline-stack>
```

### Two-Column Layout

```html
<s-inline-stack gap="loose">
  <s-block-stack gap="base" style="flex: 1;">
    <s-text variant="headingMd">Left Column</s-text>
    <s-box padding="base" background-color="bg-surface">
      <s-text>Content on the left</s-text>
    </s-box>
  </s-block-stack>

  <s-block-stack gap="base" style="flex: 1;">
    <s-text variant="headingMd">Right Column</s-text>
    <s-box padding="base" background-color="bg-surface">
      <s-text>Content on the right</s-text>
    </s-box>
  </s-block-stack>
</s-inline-stack>
```

## UI Pattern Examples

### Navigation Bar

```html
<s-box padding="base" background-color="bg-surface-secondary">
  <s-inline-stack gap="base" align="space-between">
    <s-text variant="headingMd">{{appName}}</s-text>
    <s-inline-stack gap="base">
      <s-button kind="{{isActive('dashboard') ? 'primary' : 'secondary'}}" onclick="navigate('dashboard')">
        Dashboard
      </s-button>
      <s-button kind="{{isActive('settings') ? 'primary' : 'secondary'}}" onclick="navigate('settings')">
        Settings
      </s-button>
      <s-button kind="{{isActive('help') ? 'primary' : 'secondary'}}" onclick="navigate('help')">
        Help
      </s-button>
    </s-inline-stack>
  </s-inline-stack>
</s-box>
```

### Alert/Status Banner

```html
{{#if hasAlert}}
  <s-banner kind="{{alertKind}}" title="{{alertTitle}}" onclose="closeAlert()">
    {{alertMessage}}
  </s-banner>
{{/if}}
```

### Modal Dialog

```html
{{#if showModal}}
  <s-box style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000;">
    <s-box padding="loose" background-color="bg-surface" style="width: 500px; max-width: 90%; border-radius: 8px;">
      <s-block-stack gap="loose">
        <s-inline-stack gap="base" align="space-between">
          <s-text variant="headingMd">{{modalTitle}}</s-text>
          <s-button kind="plain" onclick="closeModal()">×</s-button>
        </s-inline-stack>

        <s-text variant="bodyMd">{{modalContent}}</s-text>

        <s-inline-stack gap="base" align="end">
          <s-button kind="secondary" onclick="closeModal()">
            Cancel
          </s-button>
          <s-button kind="primary" onclick="confirmModal()">
            {{modalActionText}}
          </s-button>
        </s-inline-stack>
      </s-block-stack>
    </s-box>
  </s-box>
{{/if}}
```

### Accordion/Collapsible

```html
<s-block-stack gap="base">
  {{#each sections}}
    <s-box padding="base" background-color="bg-surface">
      <s-block-stack gap="base">
        <s-button
          kind="plain"
          onclick="toggleSection('{{this.id}}')"
          style="text-align: left; width: 100%;"
        >
          <s-inline-stack gap="base" align="space-between" style="width: 100%;">
            <s-text variant="headingMd">{{this.title}}</s-text>
            <s-text>{{isOpen ? '▼' : '▶'}}</s-text>
          </s-inline-stack>
        </s-button>

        {{#if isOpen}}
          <s-divider />
          <s-text variant="bodyMd">{{this.content}}</s-text>
        {{/if}}
      </s-block-stack>
    </s-box>
  {{/each}}
</s-block-stack>
```

### Pagination

```html
<s-block-stack gap="loose">
  <s-inline-stack gap="base" align="end">
    <s-button
      kind="secondary"
      onclick="previousPage()"
      disabled="{{currentPage === 1}}"
    >
      Previous
    </s-button>

    <s-text variant="bodyMd">
      Page {{currentPage}} of {{totalPages}}
    </s-text>

    <s-button
      kind="secondary"
      onclick="nextPage()"
      disabled="{{currentPage === totalPages}}"
    >
      Next
    </s-button>
  </s-inline-stack>
</s-block-stack>
```

### Badge List

```html
<s-block-stack gap="base">
  <s-text variant="headingMd">Tags</s-text>

  <s-inline-stack gap="base" style="flex-wrap: wrap;">
    {{#each tags}}
      <s-badge kind="{{this.kind}}">
        {{this.label}}
      </s-badge>
    {{/each}}
  </s-inline-stack>
</s-block-stack>
```

## JavaScript Integration Examples

### State Management

```javascript
const [state, setState] = useState({
  isLoading: false,
  error: null,
  data: null,
  selectedTab: 'dashboard'
});

const updateState = (updates) => {
  setState({
    ...state,
    ...updates
  });
};
```

### Data Fetching

```javascript
const fetchAppData = async () => {
  try {
    updateState({ isLoading: true, error: null });
    
    const response = await fetch('/api/app/data');
    const data = await response.json();
    
    updateState({ data, isLoading: false });
  } catch (error) {
    updateState({ error: error.message, isLoading: false });
  }
};
```

### Event Handling

```javascript
const handleFormSubmit = (event) => {
  event.preventDefault();
  
  const formData = new FormData(event.target);
  const data = Object.fromEntries(formData);
  
  submitForm(data);
};
```

## Best Practices

1. Use consistent spacing and padding throughout
2. Employ meaningful colors for different states (success, warning, error)
3. Provide clear visual hierarchy with typography
4. Ensure responsive behavior on all screen sizes
5. Include loading states for async operations
6. Show clear feedback for user actions
7. Use appropriate form validation
8. Keep modals simple and focused
9. Implement proper error handling
10. Test with real data and edge cases
