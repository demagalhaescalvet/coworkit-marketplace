# Shopify Store Management: Advanced Operations

## Bulk Product Import with JSONL

Import large numbers of products using the bulk operations API:

### Prepare JSONL File

Create a JSONL file with product data:

```jsonl
{"__typename":"Product","title":"Blue Widget","handle":"blue-widget","vendor":"Widget Co","productType":"Widgets","tags":["blue","new"]}
{"__typename":"Product","title":"Red Widget","handle":"red-widget","vendor":"Widget Co","productType":"Widgets","tags":["red","sale"]}
{"__typename":"Product","title":"Green Widget","handle":"green-widget","vendor":"Widget Co","productType":"Widgets","tags":["green"]}
```

### Create Bulk Mutation

```graphql
mutation CreateBulkProducts($input: String!) {
  bulkProductsCreate(resources: $input) {
    bulkOperation {
      id
      status
      createdAt
    }
    userErrors {
      field
      message
    }
  }
}
```

### Monitor Bulk Operation

```graphql
query {
  bulkOperation(id: "gid://shopify/BulkOperation/123") {
    id
    status
    objectCount
    url
    createdAt
    completedAt
  }
}
```

### Process Results

Once complete, download and process the results file. It will contain:

```jsonl
{"id":"gid://shopify/Product/123","createdAt":"2024-01-15T10:00:00Z"}
{"id":"gid://shopify/Product/124","createdAt":"2024-01-15T10:00:01Z"}
{"id":"gid://shopify/Product/125","createdAt":"2024-01-15T10:00:02Z"}
```

## Discount Code Management

### Create Basic Discount Code

```graphql
mutation CreateDiscountCode {
  discountCodeBasicCreate(
    basicCodeDiscount: {
      title: "Summer20"
      code: "SUMMER20"
      startsAt: "2024-06-01T00:00:00Z"
      endsAt: "2024-08-31T23:59:59Z"
      customerGets: {
        value: {
          percentage: 0.20
        }
        items: {
          all: true
        }
      }
      customerBuys: {
        value: {
          amount: "0"
        }
        items: {
          all: true
        }
        quantity: "0"
      }
      usageLimit: 100
      appliesOncePerCustomer: true
      recurringCycleLimit: 1
    }
  ) {
    codeDiscount {
      title
      codes(first: 5) {
        edges {
          node {
            code
          }
        }
      }
      startsAt
      endsAt
    }
    userErrors {
      field
      message
    }
  }
}
```

### Create Automatic Discount

Automatic discounts apply without codes:

```graphql
mutation CreateAutomatic {
  discountAutomaticBasicCreate(
    automaticBasicDiscount: {
      title: "Free Shipping Over 100"
      startsAt: "2024-01-01T00:00:00Z"
      customerGets: {
        value: {
          percentage: 1.0
        }
        items: {
          all: true
        }
      }
      customerBuys: {
        value: {
          amount: "100.00"
        }
        items: {
          all: true
        }
      }
      combinesWith: {
        orderDiscounts: true
        productDiscounts: true
        shippingDiscounts: false
      }
    }
  ) {
    automaticDiscountNode {
      id
      automaticDiscount {
        ... on DiscountAutomaticBasic {
          title
          startsAt
          endsAt
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

### Query Discounts

```graphql
query GetDiscounts {
  discountNodes(first: 50) {
    edges {
      node {
        id
        discount {
          ... on DiscountCodeBasic {
            title
            codes(first: 1) {
              edges {
                node {
                  code
                }
              }
            }
            startsAt
            endsAt
            usageLimit
          }
          ... on DiscountAutomaticBasic {
            title
            startsAt
            endsAt
          }
        }
      }
    }
  }
}
```

## Draft Orders

Create orders manually for customers without app:

```graphql
mutation CreateDraftOrder {
  draftOrderCreate(
    input: {
      customerId: "gid://shopify/Customer/123"
      lineItems: [
        {
          variantId: "gid://shopify/ProductVariant/456"
          quantity: 2
          originalUnitPrice: "29.99"
        }
        {
          variantId: "gid://shopify/ProductVariant/789"
          quantity: 1
          originalUnitPrice: "49.99"
        }
      ]
      shippingLine: {
        shippingRateObject: {
          title: "Standard Shipping"
          price: "10.00"
        }
      }
      appliedDiscount: {
        description: "10% off"
        value: {
          percentage: 0.10
        }
      }
      note: "VIP customer - expedite if possible"
    }
  ) {
    draftOrder {
      id
      invoiceUrl
      draftOrderLineItems(first: 10) {
        edges {
          node {
            id
            title
            quantity
            originalUnitPrice
          }
        }
      }
      subtotalPrice {
        amount
      }
      totalPrice {
        amount
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

### Convert Draft to Order

```graphql
mutation CompleteDraftOrder {
  draftOrderComplete(
    id: "gid://shopify/DraftOrder/123"
  ) {
    order {
      id
      orderNumber
      createdAt
      fulfillmentStatus
    }
    userErrors {
      message
    }
  }
}
```

## Refund Processing

### Create Refund

```graphql
mutation CreateRefund {
  refundCreate(
    input: {
      orderId: "gid://shopify/Order/123"
      note: "Customer returned defective item"
      notify: true
      refundLineItems: [
        {
          id: "gid://shopify/LineItem/456"
          quantity: 2
          priceSet: {
            shopMoney: {
              amount: "59.98"
            }
          }
        }
      ]
      shipping: {
        fullRefund: true
      }
    }
  ) {
    refund {
      id
      createdAt
      note
      duties {
        edges {
          node {
            originalUnitPrice {
              amount
            }
          }
        }
      }
      refundLineItems(first: 10) {
        edges {
          node {
            lineItem {
              title
              quantity
            }
            quantity
            priceSet {
              shopMoney {
                amount
              }
            }
          }
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

### Query Refunds

```graphql
query GetRefunds {
  orders(first: 10) {
    edges {
      node {
        id
        orderNumber
        refunds(first: 10) {
          edges {
            node {
              id
              createdAt
              note
              totalRefundedSet {
                shopMoney {
                  amount
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Multi-Location Inventory Management

### Move Inventory Between Locations

```graphql
mutation MoveInventory {
  inventoryTransferMovementCreate(
    input: {
      inventoryItemId: "gid://shopify/InventoryItem/123"
      fromLocationId: "gid://shopify/Location/456"
      toLocationId: "gid://shopify/Location/789"
      quantity: 50
      reference: "Physical transfer from Warehouse A to Warehouse B"
    }
  ) {
    inventoryMovement {
      id
      createdAt
      fromLocation {
        name
      }
      toLocation {
        name
      }
      inventoryItemId
      quantity
    }
    userErrors {
      message
    }
  }
}
```

### Set Inventory at Multiple Locations

```graphql
mutation SetInventoryLevels {
  inventorySetQuantities(
    input: {
      reason: CORRECTION
      quantities: [
        {
          inventoryItemId: "gid://shopify/InventoryItem/123"
          locationId: "gid://shopify/Location/456"
          quantity: 100
        }
        {
          inventoryItemId: "gid://shopify/InventoryItem/123"
          locationId: "gid://shopify/Location/789"
          quantity: 50
        }
        {
          inventoryItemId: "gid://shopify/InventoryItem/123"
          locationId: "gid://shopify/Location/999"
          quantity: 25
        }
      ]
    }
  ) {
    inventoryAdjustmentGroup {
      reason
      createdAt
      quantityAdjustments {
        inventoryItem {
          sku
        }
        location {
          name
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

### Query Inventory Across All Locations

```graphql
query GetAllInventory {
  locations(first: 50) {
    edges {
      node {
        id
        name
        isActive
        inventoryLevels(first: 100) {
          edges {
            node {
              id
              available
              incoming
              inventoryItem {
                id
                sku
                title
                tracked
              }
            }
          }
        }
      }
    }
  }
}
```

## Customer Segmentation

Create customer lists based on purchase behavior:

```graphql
query GetHighValueCustomers {
  customers(
    first: 50
    query: "orders:>5 total_spent:>500"
  ) {
    edges {
      node {
        id
        firstName
        lastName
        email
        totalSpent {
          amount
        }
        numberOfOrders
        lastOrder {
          id
          createdAt
        }
      }
    }
  }
}
```

Use this for:
- VIP customer campaigns
- At-risk customer retention
- Customer tier management
- Loyalty program enrollment

## Fulfillment Tracking

### Update Fulfillment with Advanced Tracking

```graphql
mutation UpdateFulfillment {
  fulfillmentTrackingInfoUpdate(
    id: "gid://shopify/Fulfillment/123"
    trackingInfo: {
      number: "1Z123456789"
      company: FedEx
      url: "https://tracking.fedex.com"
      lineItemsToTrack: [
        {
          id: "gid://shopify/LineItem/456"
          quantity: 2
        }
      ]
    }
    notifyCustomer: true
  ) {
    fulfillment {
      id
      trackingInfo {
        number
        company
        url
      }
      lineItems(first: 10) {
        edges {
          node {
            id
            lineItem {
              title
            }
            quantity
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

## Event Automation

Create webhooks for automated responses:

```javascript
// Handle order fulfillment webhook
app.post('/webhooks/orders/fulfilled', (req, res) => {
  const { order, fulfillments } = req.body;

  // Send tracking email
  sendTrackingEmail(order.customer.email, fulfillments[0].tracking_info);

  // Create follow-up task
  createCustomerFollowUp(order.customer.id, 'Verify delivery received');

  // Log in CRM
  logOrderToCRM(order);

  res.sendStatus(200);
});
```
