# Shopify Liquid: Advanced Topics

## Render vs. Include

### Include: Duplicates Code

`include` merges the snippet into the current template (creates a copy of the code):

```liquid
{% include 'product-card', product: product %}
```

This is fine for small snippets but can cause code duplication.

### Render: Better for Large Snippets

`render` isolates the snippet (preferred approach):

```liquid
{% render 'product-card', product: product %}
```

Key differences:
- `render` has isolated scope (doesn't access parent variables)
- `render` can't set variables in parent scope
- `render` is generally better for reusability

Pass only needed variables:
```liquid
{% render 'product-card',
  product: product,
  show_rating: true,
  compact_view: false
%}
```

Use `render` for:
- Reusable components
- Large snippets
- Components from multiple places

Use `include` for:
- Small templating helpers
- Localized code that needs parent context

## Content for Header

Insert required Shopify scripts and meta tags in the theme header:

```liquid
<!-- In your theme's layout file (usually theme.liquid) -->
<head>
  {{ content_for_header }}
  <title>{{ page_title }}</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
</head>
```

The `{{ content_for_header }}` tag automatically includes:
- Shopify-hosted tracking scripts
- Analytics code
- Discount code meta tags
- Shop pay setup
- Pixel events

Never remove or replace `content_for_header`.

## Metafield Rendering Best Practices

### Display Different Metafield Types

```liquid
{% assign color_meta = product.metafields.custom.color_field %}

{% case color_meta.type %}
  {% when 'single_line_text_field' %}
    <p>{{ color_meta.value }}</p>
  
  {% when 'multi_line_text_field' %}
    <div class="description">{{ color_meta.value | newline_to_br }}</div>
  
  {% when 'number_integer' %}
    <p>Quantity: {{ color_meta.value }}</p>
  
  {% when 'rich_text_field' %}
    {{ color_meta.value }}
  
  {% when 'date' %}
    <p>Date: {{ color_meta.value | date: "%B %d, %Y" }}</p>
  
  {% when 'product_reference' %}
    {% assign referenced_product = color_meta.value %}
    <p><a href="{{ referenced_product.url }}">{{ referenced_product.title }}</a></p>
  
  {% when 'list.product_reference' %}
    <ul>
    {% for prod in color_meta.value %}
      <li><a href="{{ prod.url }}">{{ prod.title }}</a></li>
    {% endfor %}
    </ul>
{% endcase %}
```

### Null Checking

Always check if metafield exists:

```liquid
{% if product.metafields.namespace.key %}
  {{ product.metafields.namespace.key.value }}
{% else %}
  <p>Not available</p>
{% endif %}
```

## Performance Optimization

### Lazy Load Images

```liquid
<img
  src="{{ image | image_url: width: 300 }}"
  alt="{{ image.alt }}"
  loading="lazy"
  width="{{ image.width }}"
  height="{{ image.height }}"
>
```

### Limit Loop Iterations

```liquid
{% for product in collection.products limit: 12 %}
  {% render 'product-card', product: product %}
{% endfor %}
```

### Cache Expensive Computations

```liquid
{% assign discount_percentage = product.compare_at_price | minus: product.price | divided_by: product.compare_at_price | times: 100 %}

{% if discount_percentage > 20 %}
  <span class="discount">{{ discount_percentage | round }}% OFF</span>
{% endif %}
```

### Use Snippet Caching

In theme settings or app configuration:
```liquid
{% render 'price-badge', product: product %}
```

## Predictive Search

Implement predictive search (Shopify Search & Discovery):

```liquid
<form action="/search" method="get" role="search">
  <input
    type="text"
    name="q"
    placeholder="Search products..."
    autocomplete="off"
    data-predictive-search-input
  >
  <button type="submit">Search</button>

  <div data-predictive-search-results class="predictive-search-results"></div>
</form>

<script src="{{ 'predictive-search.js' | asset_url }}"></script>
```

The `{{ 'predictive-search.js' | asset_url }}` file should handle the API calls to Shopify's search endpoint.

## Customer Accounts

Access customer data in logged-in templates:

```liquid
{% if customer %}
  <p>Welcome, {{ customer.first_name }} {{ customer.last_name }}!</p>
  <p>Email: {{ customer.email }}</p>
  <p>Total Orders: {{ customer.orders | size }}</p>

  <h3>Order History</h3>
  <ul>
  {% for order in customer.orders %}
    <li>
      Order #{{ order.order_number }} - {{ order.created_at | date: "%B %d, %Y" }}
      <p>Total: {{ order.total_price | money }}</p>
    </li>
  {% endfor %}
  </ul>

  <h3>Addresses</h3>
  <ul>
  {% for address in customer.addresses %}
    <li>
      {{ address.street }}, {{ address.city }}, {{ address.province }}
      {% if address == customer.default_address %}
        <span>(Default)</span>
      {% endif %}
    </li>
  {% endfor %}
  </ul>
{% else %}
  <p><a href="/account/login">Log in</a> to view your account.</p>
{% endif %}
```

## Internationalization and Localization

### Use Locale Context

```liquid
<p>Current locale: {{ localization.country.iso_code }}</p>
<p>Currency: {{ shop.currency }}</p>

{% if localization.available_countries %}
  <select id="country-selector">
    {% for country in localization.available_countries %}
      <option
        value="{{ country.url }}"
        {% if country.iso_code == localization.country.iso_code %}selected{% endif %}
      >
        {{ country.name }}
      </option>
    {% endfor %}
  </select>
{% endif %}
```

### Store Settings for Translations

Define translations in `config/settings_schema.json`:

```json
{
  "name": "Translations",
  "settings": [
    {
      "type": "text",
      "id": "button_text_en",
      "label": "Button Text (English)"
    },
    {
      "type": "text",
      "id": "button_text_fr",
      "label": "Button Text (French)"
    }
  ]
}
```

Use in theme:
```liquid
{% assign button_text = section.settings.button_text_en %}
{% if request.locale.iso_code == 'fr' %}
  {% assign button_text = section.settings.button_text_fr %}
{% endif %}

<button>{{ button_text }}</button>
```

## Advanced Section Settings

### Conditional Settings

Show settings based on other settings:

```json
{
  "settings": [
    {
      "type": "checkbox",
      "id": "show_reviews",
      "label": "Show Reviews"
    },
    {
      "type": "range",
      "id": "review_count",
      "label": "Number of Reviews",
      "min": 1,
      "max": 10,
      "default": 5,
      "info": "Only shown when reviews are enabled"
    }
  ]
}
```

Use in template:
```liquid
{% if section.settings.show_reviews %}
  <div class="reviews">
    {% for i in (1..section.settings.review_count) %}
      <!-- Render review -->
    {% endfor %}
  </div>
{% endif %}
```

## Form Submission Handling

Handle form errors and submission:

```liquid
<form method="POST" action="/cart/add" id="product-form">
  {% unless product.available %}
    <p class="error">This product is out of stock</p>
  {% endunless %}

  {% if form.errors %}
    <ul class="errors">
    {% for field in form.errors %}
      <li>{{ field }}: {{ form.errors[field] }}</li>
    {% endfor %}
    </ul>
  {% endif %}

  <select name="id">
    {% for variant in product.variants %}
      <option value="{{ variant.id }}">
        {{ variant.title }} - {{ variant.price | money }}
      </option>
    {% endfor %}
  </select>

  <input type="number" name="quantity" value="1" min="1" max="{{ product.selected_variant.inventory_quantity }}">
  
  <button type="submit" {% unless product.available %}disabled{% endunless %}>
    Add to Cart
  </button>
</form>
```

## AJAX Requests

Fetch data dynamically without page reload:

```liquid
<div id="product-recommendations"></div>

<script>
  async function loadRecommendations() {
    const response = await fetch('/recommendations/products?product_id={{ product.id }}&limit=4');
    const html = await response.text();
    document.getElementById('product-recommendations').innerHTML = html;
  }
  
  // Load on page load or user scroll
  document.addEventListener('DOMContentLoaded', loadRecommendations);
</script>
```

Create a recommendation template at `/sections/product-recommendations.json`:
```json
{
  "type": "apps",
  "settings": [],
  "blocks": []
}
```

## Theme Settings Best Practices

Always provide sensible defaults:

```json
{
  "settings": [
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Shop Our Collection"
    },
    {
      "type": "color",
      "id": "bg_color",
      "label": "Background Color",
      "default": "#ffffff"
    },
    {
      "type": "range",
      "id": "padding",
      "label": "Padding",
      "default": 20,
      "min": 0,
      "max": 100,
      "step": 5
    }
  ]
}
```

Use in template:
```liquid
<div style="background-color: {{ section.settings.bg_color }}; padding: {{ section.settings.padding }}px;">
  <h2>{{ section.settings.heading }}</h2>
</div>
```
