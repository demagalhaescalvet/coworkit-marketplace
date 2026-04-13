---
name: shopify-liquid
description: Triggers on "write Liquid code", "create a Shopify template", "customize a theme", "use Liquid filters", "build a section or snippet". Learn Liquid templating to customize Shopify themes and create dynamic store experiences.
version: 0.1.0
---

# Shopify Liquid Templating

Liquid is Shopify's template language for creating dynamic themes and customizing the storefront. This skill covers Liquid basics, theme architecture, sections, blocks, and common patterns.

## Liquid Basics

### Objects, Tags, and Filters

**Objects** output dynamic content:
```liquid
{{ product.title }}
{{ product.price | money }}
{{ "hello world" | upcase }}
```

**Tags** perform logic and control flow:
```liquid
{% if product.available %}
  In Stock
{% else %}
  Out of Stock
{% endif %}
```

**Filters** transform output:
```liquid
{{ product.title | downcase | replace: " ", "-" }}
{{ product.created_at | date: "%B %d, %Y" }}
{{ cart.total_price | money }}
```

### String and Array Operations

```liquid
{% assign words = "hello world" | split: " " %}
{% for word in words %}
  {{ word | capitalize }}
{% endfor %}

{% assign url = "/products/" | append: product.handle %}
```

### Variable Assignment and Capture

```liquid
{% assign discount = product.price | times: 0.2 %}
{{ product.price | minus: discount }}

{% capture greeting %}
  Hello, {{ customer.first_name }}!
{% endcapture %}
{{ greeting }}
```

## Theme Architecture

Online Store 2.0 themes use a new structure:

```
theme/
  ├── config/
  │   ├── settings_schema.json
  │   └── settings_data.json
  ├── sections/
  │   ├── header.liquid
  │   ├── product-recommendations.liquid
  │   └── ...
  ├── snippets/
  │   ├── product-card.liquid
  │   ├── price-badge.liquid
  │   └── ...
  ├── assets/
  │   ├── styles.css
  │   └── main.js
  └── templates/
      ├── index.json
      ├── product.json
      └── ...
```

## Sections and Blocks

### Define a Section with Schema

Create `sections/featured-products.liquid`:

```liquid
{% comment %}
  Featured Products Section
  Shows a curated list of products
{% endcomment %}

<div class="featured-products" style="padding: {{ section.settings.padding }}px;">
  <h2>{{ section.settings.title }}</h2>
  
  <div class="products-grid">
    {% for block in section.blocks %}
      {% if block.type == 'product' %}
        {% assign product = all_products[block.settings.product] %}
        {% include 'product-card', product: product %}
      {% endif %}
    {% endfor %}
  </div>
</div>

{% schema %}
{
  "name": "Featured Products",
  "settings": [
    {
      "type": "text",
      "id": "title",
      "label": "Section Title",
      "default": "Featured Products"
    },
    {
      "type": "range",
      "id": "padding",
      "label": "Padding (px)",
      "min": 0,
      "max": 100,
      "step": 10,
      "default": 20
    },
    {
      "type": "color",
      "id": "bg_color",
      "label": "Background Color"
    }
  ],
  "blocks": [
    {
      "type": "product",
      "name": "Product",
      "settings": [
        {
          "type": "product",
          "id": "product",
          "label": "Product"
        }
      ]
    }
  ],
  "presets": [
    {
      "name": "Featured Products",
      "blocks": [
        { "type": "product" }
      ]
    }
  ]
}
{% endschema %}
```

### Using Block Settings

Access block settings in loops:
```liquid
{% for block in section.blocks %}
  {% case block.type %}
    {% when 'heading' %}
      <h2>{{ block.settings.title }}</h2>
    {% when 'text' %}
      <p>{{ block.settings.description }}</p>
    {% when 'image' %}
      {% if block.settings.image %}
        <img src="{{ block.settings.image | image_url }}" alt="">
      {% endif %}
  {% endcase %}
{% endfor %}
```

## Key Liquid Objects

| Object | Purpose | Example |
|--------|---------|---------|
| `product` | Current product data | `{{ product.title }}`, `{{ product.variants }}` |
| `collection` | Current collection data | `{{ collection.title }}`, `{{ collection.products }}` |
| `cart` | Shopping cart data | `{{ cart.item_count }}`, `{{ cart.total_price }}` |
| `customer` | Logged-in customer | `{{ customer.first_name }}`, `{{ customer.addresses }}` |
| `shop` | Store information | `{{ shop.name }}`, `{{ shop.url }}` |
| `theme` | Theme settings | `{{ theme.settings.logo }}` |
| `section` | Section configuration | `{{ section.settings }}`, `{{ section.blocks }}` |
| `page` | Page/article data | `{{ page.title }}`, `{{ page.content }}` |
| `image` | Image data | `{{ image.src }}`, `{{ image | image_url: width: 300 }}` |

## Common Filters

| Filter | Purpose | Example |
|--------|---------|---------|
| `money` | Format as currency | `{{ product.price | money }}` |
| `date` | Format dates | `{{ product.created_at | date: "%Y-%m-%d" }}` |
| `upcase` | Convert to uppercase | `{{ product.title | upcase }}` |
| `downcase` | Convert to lowercase | `{{ product.title | downcase }}` |
| `capitalize` | Capitalize first letter | `{{ product.title | capitalize }}` |
| `strip_html` | Remove HTML tags | `{{ product.description | strip_html }}` |
| `truncate` | Limit string length | `{{ product.description | truncate: 100 }}` |
| `url_encode` | URL encode string | `{{ search.terms | url_encode }}` |
| `image_url` | Get image URL | `{{ product.featured_image | image_url: width: 300 }}` |
| `default` | Provide fallback | `{{ product.vendor | default: "Unknown" }}` |
| `size` | Get array/string length | `{{ product.variants | size }}` |
| `join` | Join array elements | `{{ product.tags | join: ", " }}` |

## Control Flow

### Conditionals

```liquid
{% if product.available %}
  <button>Add to Cart</button>
{% elsif product.coming_soon %}
  <p>Coming Soon</p>
{% else %}
  <p>Out of Stock</p>
{% endif %}

{% if customer %}
  <p>Welcome back, {{ customer.first_name }}!</p>
{% endif %}

{% if product.variants.size > 1 %}
  <select>
    {% for variant in product.variants %}
      <option value="{{ variant.id }}">{{ variant.title }}</option>
    {% endfor %}
  </select>
{% endif %}
```

### Loops

```liquid
{% for product in collection.products %}
  <div>{{ product.title }} - {{ product.price | money }}</div>
{% endfor %}

{% for variant in product.variants %}
  {% if forloop.first %}
    <p>First: {{ variant.title }}</p>
  {% endif %}
  {% if forloop.last %}
    <p>Last: {{ variant.title }}</p>
  {% endif %}
{% endfor %}

{% for item in cart.items limit: 5 %}
  {{ item.title }}
{% endfor %}
```

## Including Snippets

Create reusable components in `snippets/product-card.liquid`:

```liquid
{% comment %}
  Product Card Snippet
  Usage: {% include 'product-card', product: product %}
{% endcomment %}

<div class="product-card">
  <a href="{{ product.url }}">
    <img src="{{ product.featured_image | image_url: width: 300 }}" alt="{{ product.title }}">
  </a>
  <h3>{{ product.title }}</h3>
  <p class="price">{{ product.price | money }}</p>
  {% if product.compare_at_price %}
    <p class="compare-price">{{ product.compare_at_price | money }}</p>
  {% endif %}
</div>
```

Use in templates:
```liquid
{% for product in collection.products %}
  {% include 'product-card', product: product %}
{% endfor %}
```

## Metafield Rendering

Access custom data stored on products:

```liquid
{% if product.metafields.custom.color_family %}
  <p>Color Family: {{ product.metafields.custom.color_family.value }}</p>
{% endif %}

{% if product.metafields.inventory_management.warehouse_location %}
  <p>Location: {{ product.metafields.inventory_management.warehouse_location.value }}</p>
{% endif %}
```

Render metafield references (like product links):
```liquid
{% if product.metafields.custom.related_product %}
  {% assign related = product.metafields.custom.related_product.value %}
  <p><a href="{{ related.url }}">{{ related.title }}</a></p>
{% endif %}
```

## Next Steps

- See `liquid-advanced.md` for render vs. include, content_for_header, performance optimization, and customer accounts.
- Review the [official Liquid docs](https://shopify.dev/api/liquid) for complete object and filter reference.
- Use the [Shopify Theme Editor](https://shopify.dev/docs/themes/tools/theme-editor) to edit and preview changes.
