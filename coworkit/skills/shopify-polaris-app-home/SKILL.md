---
name: shopify-polaris-app-home
description: Triggers on "build app dashboard", "create app home page", "design app UI", "build app interface", "customize app home". Build beautiful and functional dashboards for Shopify apps using Polaris web components.
version: 0.1.0
---

# Shopify Polaris App Home

App Home pages are the main dashboard users see when they open your Shopify app. This skill covers Polaris web components, layout patterns, APIs, and best practices for creating engaging app dashboards.

## Polaris Web Components

All Polaris components are globally registered with the `s-` prefix. No imports are required.

### Text and Display Components

```html
<s-text variant="headingXl">App Title</s-text>
<s-text variant="headingLg">Section Title</s-text>
<s-text variant="headingMd">Subsection Title</s-text>
<s-text variant="bodyMd">Regular text content</s-text>
<s-text variant="bodySm">Small supporting text</s-text>

<s-text tone="subdued">Subtle text</s-text>
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

<s-button kind="destructive" onclick="handleDelete()">
  Delete
</s-button>
```

### Form Components

**Text Field:**
```html
<s-text-field
  label="Business Name"
  type="text"
  placeholder="Enter your business name"
  value="{{businessName}}"
  onchange="handleBusinessNameChange(event)"
  required
/>
```

**Select Dropdown:**
```html
<s-select
  label="Category"
  value="{{selectedCategory}}"
  onchange="handleCategoryChange(event)"
>
  <option value="retail">Retail</option>
  <option value="services">Services</option>
  <option value="digital">Digital Products</option>
</s-select>
```

**Checkbox:**
```html
<s-checkbox
  label="Enable notifications"
  checked="{{notificationsEnabled}}"
  onchange="handleNotificationChange(event)"
/>
```

**Text Area:**
```html
<s-text-area
  label="App Description"
  placeholder="Describe your app..."
  rows="4"
  onchange="handleDescriptionChange(event)"
/>
```

### Layout Components

**Block Stack (Vertical Layout):**
```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Dashboard</s-text>
  <s-text>Content here</s-text>
  <s-button>Action</s-button>
</s-block-stack>
```

**Inline Stack (Horizontal Layout):**
```html
<s-inline-stack gap="base" align="center">
  <s-text>Label:</s-text>
  <s-text variant="headingMd">Value</s-text>
</s-inline-stack>
```

**Box (Container):**
```html
<s-box padding="loose" background-color="bg-surface">
  <s-block-stack gap="base">
    <s-text variant="headingMd">Card Title</s-text>
    <s-text>Card content</s-text>
  </s-block-stack>
</s-box>
```

### Feedback Components

**Banner:**
```html
<s-banner kind="success" title="Success!">
  Your changes have been saved.
</s-banner>

<s-banner kind="info" title="Information">
  Here's some helpful information.
</s-banner>

<s-banner kind="warning" title="Warning">
  Please review this carefully.
</s-banner>

<s-banner kind="critical" title="Error">
  Something went wrong.
</s-banner>
```

**Badge:**
```html
<s-badge kind="success">Active</s-badge>
<s-badge kind="warning">Pending</s-badge>
<s-badge kind="critical">Error</s-badge>
<s-badge kind="info">Info</s-badge>
```

**Spinner:**
```html
<s-spinner size="small" />
<s-spinner size="large" />
```

### Media Components

**Image:**
```html
<s-image
  src="https://example.com/image.png"
  alt="Description"
  width="200"
  height="200"
/>
```

**Avatar:**
```html
<s-avatar
  initials="JD"
  size="base"
/>
```

**Divider:**
```html
<s-divider />
```

## Available APIs

App Home extensions have access to these APIs:

| API | Purpose | Example |
|-----|---------|---------|
| `App` | Access app information | `app.getAppName()` |
| `Config` | App configuration | `config.apiKey` |
| `Environment` | Environment details | `env.isDevelopment` |
| `Intents` | Navigate within app | `intents.navigate()` |
| `Modal` | Open modals | `modal.open()` |
| `Navigation` | Route handling | `navigation.push()` |
| `Picker` | Select resources | `picker.selectProduct()` |

## Building App Home Pages

### Account Connection Setup

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-text variant="headingMd">Connect Your Account</s-text>

    {{#if !isConnected}}
      <s-text variant="bodyMd">
        Connect your business account to get started with {{appName}}.
      </s-text>

      <s-block-stack gap="base">
        <s-text-field
          label="API Key"
          type="password"
          placeholder="Enter your API key"
          value="{{apiKey}}"
          onchange="handleApiKeyChange(event)"
          required
        />

        <s-text-field
          label="API Secret"
          type="password"
          placeholder="Enter your API secret"
          value="{{apiSecret}}"
          onchange="handleApiSecretChange(event)"
          required
        />

        <s-checkbox
          label="I have verified these credentials"
          checked="{{credentialsVerified}}"
          onchange="handleCredentialsVerified(event)"
        />

        <s-button
          kind="primary"
          onclick="connectAccount()"
          disabled="{{!credentialsVerified}}"
        >
          Connect Account
        </s-button>
      </s-block-stack>
    {{else}}
      <s-inline-stack gap="base" align="space-between">
        <s-block-stack gap="tight">
          <s-text variant="headingMd">{{connectedAccount}}</s-text>
          <s-text variant="bodySm" tone="subdued">Connected</s-text>
        </s-block-stack>
        <s-badge kind="success">Connected</s-badge>
      </s-inline-stack>

      <s-button kind="secondary" onclick="disconnectAccount()">
        Disconnect Account
      </s-button>
    {{/if}}
  </s-block-stack>
</s-box>
```

### KPI Dashboard

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Key Metrics</s-text>

  <s-inline-stack gap="base">
    <s-box padding="loose" background-color="bg-surface">
      <s-block-stack gap="tight" align="center">
        <s-text variant="bodySm" tone="subdued">Total Revenue</s-text>
        <s-text variant="headingXl">${{totalRevenue}}</s-text>
        <s-badge kind="{{revenueChangeKind}}">
          {{revenueChange}}%
        </s-badge>
      </s-block-stack>
    </s-box>

    <s-box padding="loose" background-color="bg-surface">
      <s-block-stack gap="tight" align="center">
        <s-text variant="bodySm" tone="subdued">Active Users</s-text>
        <s-text variant="headingXl">{{activeUsers}}</s-text>
        <s-badge kind="{{usersChangeKind}}">
          {{usersChange}}%
        </s-badge>
      </s-block-stack>
    </s-box>

    <s-box padding="loose" background-color="bg-surface">
      <s-block-stack gap="tight" align="center">
        <s-text variant="bodySm" tone="subdued">Conversion Rate</s-text>
        <s-text variant="headingXl">{{conversionRate}}%</s-text>
        <s-badge kind="{{conversionChangeKind}}">
          {{conversionChange}}%
        </s-badge>
      </s-block-stack>
    </s-box>
  </s-inline-stack>
</s-block-stack>
```

### App Card - Quick Info

```html
<s-box padding="loose" background-color="bg-surface-secondary">
  <s-block-stack gap="loose">
    <s-inline-stack gap="base" align="space-between">
      <s-block-stack gap="tight">
        <s-text variant="headingMd">{{appName}}</s-text>
        <s-text variant="bodySm" tone="subdued">Version {{appVersion}}</s-text>
      </s-block-stack>
      <s-badge kind="{{statusKind}}">{{status}}</s-badge>
    </s-inline-stack>

    <s-text variant="bodyMd">
      {{appDescription}}
    </s-text>

    <s-inline-stack gap="base">
      <s-button kind="secondary" onclick="openSettings()">
        Settings
      </s-button>
      <s-button kind="secondary" onclick="viewDocumentation()">
        Help & Support
      </s-button>
    </s-inline-stack>

    {{#if hasUpdate}}
      <s-banner kind="info" title="Update Available">
        A new version of {{appName}} is available.
        <s-button kind="secondary" onclick="updateApp()">
          Update Now
        </s-button>
      </s-banner>
    {{/if}}
  </s-block-stack>
</s-box>
```

### Empty State

```html
<s-box padding="loose">
  <s-block-stack gap="loose" align="center">
    <s-text variant="headingMd">Get Started with {{appName}}</s-text>

    <s-text variant="bodyMd" tone="subdued">
      No data to display yet. Complete the setup steps to begin.
    </s-text>

    <s-block-stack gap="base">
      <s-button kind="primary" onclick="startSetup()">
        Start Setup Guide
      </s-button>
      <s-button kind="secondary" onclick="viewDocumentation()">
        View Documentation
      </s-button>
    </s-block-stack>
  </s-block-stack>
</s-box>
```

### Index Table - Data Display

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Recent Activities</s-text>

  <s-box>
    <table style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr style="border-bottom: 2px solid #ccc;">
          <th style="text-align: left; padding: 12px;">Item</th>
          <th style="text-align: left; padding: 12px;">Status</th>
          <th style="text-align: left; padding: 12px;">Date</th>
          <th style="text-align: center; padding: 12px;">Action</th>
        </tr>
      </thead>
      <tbody>
        {{#each activities}}
          <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 12px;">{{this.name}}</td>
            <td style="padding: 12px;">
              <s-badge kind="{{this.statusKind}}">
                {{this.status}}
              </s-badge>
            </td>
            <td style="padding: 12px;">{{this.date | dateFormat}}</td>
            <td style="padding: 12px; text-align: center;">
              <s-button
                kind="plain"
                onclick="viewActivity('{{this.id}}')"
              >
                View
              </s-button>
            </td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </s-box>

  {{#if hasMore}}
    <s-button kind="secondary" onclick="loadMore()">
      Load More
    </s-button>
  {{/if}}
</s-block-stack>
```

### Setup Guide

```html
<s-block-stack gap="loose">
  <s-text variant="headingMd">Setup Wizard</s-text>

  <s-block-stack gap="base">
    {{#each setupSteps}}
      <s-box padding="base" background-color="bg-surface">
        <s-inline-stack gap="base" align="space-between">
          <s-block-stack gap="extra-tight">
            <s-inline-stack gap="base" align="center">
              <s-badge kind="{{this.completedKind}}">
                {{this.stepNumber}}
              </s-badge>
              <s-text variant="headingMd">{{this.title}}</s-text>
            </s-inline-stack>
            <s-text variant="bodySm" tone="subdued">
              {{this.description}}
            </s-text>
          </s-block-stack>
          {{#if !this.completed}}
            <s-button
              kind="primary"
              onclick="startStep('{{this.id}}')"
            >
              Start
            </s-button>
          {{else}}
            <s-badge kind="success">Completed</s-badge>
          {{/if}}
        </s-inline-stack>
      </s-box>
    {{/each}}
  </s-block-stack>

  <s-inline-stack gap="base" align="space-between">
    <s-text variant="bodySm" tone="subdued">
      {{completedSteps}} of {{totalSteps}} complete
    </s-text>
    <s-text variant="bodySm">
      {{progressPercent}}%
    </s-text>
  </s-inline-stack>

  <s-box style="background: linear-gradient(to right, #4CAF50 {{progressPercent}}%, #eee {{progressPercent}}%); height: 6px; border-radius: 3px;" />
</s-block-stack>
```

## Attribute Syntax

All attributes use kebab-case naming:

```html
<s-text-field label="Email" type="email" required />
<s-checkbox label="Agree to terms" checked="true" />
<s-block-stack gap="loose" align="stretch">
<s-button kind="primary" onclick="handleClick()">Submit</s-button>
```

## API Access Patterns

### Navigate Within App

```javascript
const { navigation } = useIntents();

const navigateToPage = (pageName) => {
  navigation.navigate({
    name: pageName
  });
};
```

### Open Modal Dialog

```javascript
const { modal } = useModal();

const openSettings = async () => {
  const result = await modal.open({
    title: 'Settings',
    body: 'Configure app settings',
    actions: [
      { label: 'Cancel', type: 'secondary' },
      { label: 'Save', type: 'primary' }
    ]
  });
};
```

### Pick a Resource

```javascript
const { picker } = usePicker();

const selectProduct = async () => {
  const product = await picker.selectProduct();
  console.log('Selected:', product);
};
```

### Access App Configuration

```javascript
const { config } = useConfig();

const apiKey = config.apiKey;
const apiEndpoint = config.apiEndpoint;
```

## Important Rules

- **No HTML comments**: Avoid HTML comments in app code. Use tooltips instead.
- **kebab-case attributes**: All custom attributes must be kebab-case.
- **Global components**: Polaris components are pre-registered—no imports needed.
- **Responsive design**: Test on mobile, tablet, and desktop viewports.
- **Performance**: Keep renders lightweight and efficient.
- **User feedback**: Always show loading states and confirm actions.

## UI Patterns to Implement

1. **Account Connection** - Onboarding flow for connecting external services
2. **KPI Dashboard** - Key metrics and performance indicators
3. **Empty State** - Helpful message when no data exists
4. **Setup Guide** - Step-by-step onboarding wizard
5. **Data Table** - Displaying lists of items with actions
6. **Form Inputs** - Collecting user configuration and preferences
7. **Notifications** - Feedback banners for actions and errors

## Next Steps

- See `app-home-patterns.md` for comprehensive component examples.
- Review the [Shopify App Home documentation](https://shopify.dev/docs/apps) for complete API reference.
- Test app home on different devices and screen sizes.
- Monitor user engagement and feedback.
