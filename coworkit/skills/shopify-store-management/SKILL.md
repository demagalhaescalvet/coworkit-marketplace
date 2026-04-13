---
name: shopify-store-management
description: Triggers on "manage my Shopify store", "create a product", "update inventory", "check orders", "manage customers". Master Shopify store operations including product management, orders, inventory, customers, and collections.
version: 0.1.0
---

# Shopify Store Management

Manage your Shopify store using the Admin API. This skill covers day-to-day operations including product management, orders, inventory, customers, and collections.

## Creating Products

### Create a Basic Product

```graphql
mutation CreateProduct {
  productCreate(
    input: {
      title: "Winter Beanie"
      handle: "winter-beanie"
      vendor: "Acme Apparel"
      productType: "Hats"
      status: ACTIVE
      tags: ["winter", "new"]
    }
  ) {
    product {
      id
      title
      handle
      vendor
      status
    }
    userErrors {
      field
      message
    }
  }
}
```

### Create Product with Variants

```graphql
mutation CreateProductWithVariants {
  productCreate(
    input: {
      title: "T-Shirt"
      vendor: "Cool Apparel"
      variants: [
        {
          title: "Red / Small"
          color: "Red"
          size: "Small"
          price: "29.99"
          sku: "TSHIRT-RED-SM"
        }
        {
          title: "Red / Medium"
          color: "Red"
          size: "Medium"
          price: "29.99"
          sku: "TSHIRT-RED-MD"
        }
        {
          title: "Blue / Small"
          color: "Blue"
          size: "Small"
          price: "29.99"
          sku: "TSHIRT-BLUE-SM"
        }
      ]
    }
  ) {
    product {
      id
      title
      variants(first: 10) {
        edges {
          node {
            id
            title
            price
            sku
          }
        }
      }
    }
  }
}
```

### Manage Product Images

```graphql
mutation {
  productCreate(
    input: {
      title: "Product with Images"
      images: [
        {
          src: "https://example.com/image1.jpg"
          alt: "Product front view"
        }
        {
          src: "https://example.com/image2.jpg"
          alt: "Product back view"
        }
      ]
    }
  ) {
    product {
      id
      images(first: 10) {
        edges {
          node {
            id
            url
            alt
          }
        }
      }
    }
  }
}
```

## Managing Variants

### Update Variant Price and SKU

```graphql
mutation UpdateVariant {
  productVariantUpdate(
    input: {
      id: "gid://shopify/ProductVariant/456"
      price: "39.99"
      sku: "NEW-SKU-123"
      barcode: "123456789"
    }
  ) {
    productVariant {
      id
      title
      price
      sku
      barcode
    }
    userErrors {
      field
      message
    }
  }
}
```

### Create Additional Variants

```graphql
mutation {
  productVariantsBulkCreate(
    productId: "gid://shopify/Product/123"
    variants: [
      {
        title: "Green / Large"
        price: "34.99"
        sku: "TSHIRT-GREEN-LG"
      }
      {
        title: "Yellow / Large"
        price: "34.99"
        sku: "TSHIRT-YELLOW-LG"
      }
    ]
  ) {
    productVariants {
      id
      title
      price
      sku
    }
    userErrors {
      message
    }
  }
}
```

## Managing Orders

### Query Recent Orders

```graphql
query GetOrders {
  orders(
    first: 10
    sortKey: CREATED_AT
    reverse: true
  ) {
    edges {
      node {
        id
        orderNumber
        createdAt
        customer {
          firstName
          lastName
          email
        }
        lineItems(first: 10) {
          edges {
            node {
              id
              title
              quantity
              originalUnitPrice
            }
          }
        }
        total {
          amount
          currencyCode
        }
        fulfillmentStatus
      }
    }
  }
}
```

### Create Fulfillment

```graphql
mutation CreateFulfillment {
  fulfillmentCreate(
    lineItemsToFulfill: [
      {
        id: "gid://shopify/LineItem/123"
        quantity: 1
      }
    ]
    trackingInfo: {
      number: "1Z123456789"
      company: UPS
      url: "https://tracking.ups.com"
    }
    notifyCustomer: true
  ) {
    fulfillment {
      id
      status
      createdAt
    }
    userErrors {
      message
    }
  }
}
```

### Add Order Notes

```graphql
mutation {
  orderUpdate(
    input: {
      id: "gid://shopify/Order/123"
      note: "Customer requested gift wrapping"
    }
  ) {
    order {
      id
      note
    }
    userErrors {
      message
    }
  }
}
```

## Managing Inventory

### Adjust Inventory Levels

```graphql
mutation AdjustInventory {
  inventoryAdjustQuantities(
    reason: CORRECTION
    quantityAdjustments: [
      {
        inventoryItemId: "gid://shopify/InventoryItem/789"
        availableDelta: 10
      }
    ]
  ) {
    inventoryAdjustmentGroup {
      createdAt
      reason
      quantityAdjustments {
        inventoryItem {
          id
          sku
        }
        quantity
      }
    }
    userErrors {
      message
    }
  }
}
```

### Query Inventory by Location

```graphql
query GetInventoryByLocation {
  locations(first: 50) {
    edges {
      node {
        id
        name
        address {
          address1
          city
          country
        }
        inventoryLevels(first: 50, query: "sku:TSHIRT-*") {
          edges {
            node {
              id
              available
              inventoryItem {
                id
                sku
                title
              }
            }
          }
        }
      }
    }
  }
}
```

## Managing Customers

### Search Customers

```graphql
query SearchCustomers {
  customers(
    first: 10
    query: "email:john@example.com"
  ) {
    edges {
      node {
        id
        firstName
        lastName
        email
        phone
        numberOfOrders
        totalSpent {
          amount
          currencyCode
        }
        addresses(first: 10) {
          edges {
            node {
              id
              address1
              city
              country
              isDefault
            }
          }
        }
      }
    }
  }
}
```

### Create Customer

```graphql
mutation CreateCustomer {
  customerCreate(
    input: {
      firstName: "John"
      lastName: "Doe"
      email: "john@example.com"
      phone: "+1234567890"
      defaultAddress: {
        address1: "123 Main St"
        city: "Springfield"
        province: "IL"
        country: "United States"
        zip: "62701"
      }
    }
  ) {
    customer {
      id
      firstName
      lastName
      email
      defaultAddress {
        id
        address1
        city
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

### Add Customer Address

```graphql
mutation AddCustomerAddress {
  customerAddressCreate(
    customerId: "gid://shopify/Customer/123"
    address: {
      address1: "456 Oak Ave"
      city: "Shelbyville"
      province: "IL"
      country: "United States"
      zip: "62702"
    }
  ) {
    customerAddress {
      id
      address1
      city
    }
    userErrors {
      message
    }
  }
}
```

## Managing Collections

### Create a Collection

```graphql
mutation CreateCollection {
  collectionCreate(
    input: {
      title: "Summer Sale"
      handle: "summer-sale"
      descriptionHtml: "<p>Great summer deals!</p>"
      sortOrder: BEST_SELLING
      image: {
        src: "https://example.com/summer.jpg"
        alt: "Summer Sale"
      }
    }
  ) {
    collection {
      id
      title
      handle
      products(first: 10) {
        edges {
          node {
            id
            title
          }
        }
      }
    }
    userErrors {
      message
    }
  }
}
```

### Add Products to Collection

```graphql
mutation AddProductsToCollection {
  collectionAddProducts(
    id: "gid://shopify/Collection/123"
    productIds: [
      "gid://shopify/Product/111"
      "gid://shopify/Product/222"
      "gid://shopify/Product/333"
    ]
  ) {
    collection {
      id
      products(first: 10) {
        edges {
          node {
            id
            title
          }
        }
      }
    }
    userErrors {
      message
    }
  }
}
```

### Create Smart Collection

```graphql
mutation CreateSmartCollection {
  smartCollectionCreate(
    input: {
      title: "Products Under $50"
      handle: "under-50"
      ruleSet: {
        appliedDisjunctively: false
        rules: [
          {
            column: PRICE
            relation: LESS_THAN
            condition: "50"
          }
        ]
      }
      sortOrder: PRICE_ASC
    }
  ) {
    smartCollection {
      id
      title
      rules {
        column
        relation
        condition
      }
    }
    userErrors {
      message
    }
  }
}
```

## Common Operations Checklist

### Daily Store Management

```
Product Management:
[ ] Check low-stock items and reorder
[ ] Review new product submissions
[ ] Update seasonal collections
[ ] Manage product descriptions and images

Order Management:
[ ] Process new orders
[ ] Create fulfillments with tracking
[ ] Add order notes for special requests
[ ] Handle refunds/returns

Inventory:
[ ] Adjust stock levels for received inventory
[ ] Check inventory across locations
[ ] Alert when items fall below minimum threshold

Customer Service:
[ ] Respond to customer messages
[ ] Update customer information
[ ] Process customer returns

Analytics:
[ ] Check sales metrics
[ ] Review product performance
[ ] Monitor conversion rates
```

## Next Steps

- See `store-operations.md` for advanced operations like bulk imports, discount management, and multi-location inventory.
- Review the [Admin API docs](https://shopify.dev/api/admin-graphql) for complete query and mutation reference.
- Use the [Shopify CLI](https://shopify.dev/docs/apps/tools/cli) to test queries in your development store.
