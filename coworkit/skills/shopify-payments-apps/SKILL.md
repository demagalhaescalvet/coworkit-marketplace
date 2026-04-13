---
name: shopify-payments-apps
description: Building payment provider integrations with Shopify Payments Apps API. Covers payment session lifecycle, operations (authorize, capture, refund, void), payment methods, 3D Secure, fraud prevention, and PCI compliance.
version: 0.1.0
---

# Shopify Payments Apps API

This skill covers building payment provider integrations with the Shopify Payments Apps API. Use this for implementing payment gateways, processing card payments, handling refunds, and managing payment session lifecycles.

## Payments Apps API Overview

The Payments Apps API enables third-party payment providers to process payments directly within Shopify checkouts and post-purchase flows.

### Key Components

| Component | Purpose |
|-----------|---------|
| Payment Session | Container for payment operation lifecycle |
| Payment Methods | Card, wallet, alternative payment types |
| Operations | Authorize, capture, refund, void transactions |
| Webhooks | Real-time payment event notifications |
| PCI Compliance | Secure handling without storing card data |

## Payment Session Lifecycle

All payments follow this state machine:

```
PENDING → AUTHORIZED → CAPTURED → SETTLED
   ↓           ↓           ↓
 VOIDED    VOIDED    PARTIALLY_REFUNDED
                    FULLY_REFUNDED
```

### State Transitions

| From State | To State | Operation | Use Case |
|-----------|----------|-----------|----------|
| PENDING | AUTHORIZED | authorize() | Customer approves payment |
| AUTHORIZED | CAPTURED | capture() | Merchant fulfills order |
| AUTHORIZED | VOIDED | void() | Cancel before capture |
| CAPTURED | REFUNDED | refund() | Return/cancellation |
| SETTLED | REFUNDED | refund() | Customer gets money back |

## GraphQL Schema for Payments

### Payment Session Structure

```graphql
type PaymentSession {
  id: ID!
  gid: ID!
  status: PaymentSessionStatus!
  amount: Money!
  test: Boolean!
  merchantReference: String!
  idempotencyKey: String!
  sourceIdentifier: String
  paymentMethod: PaymentMethod!
  gateway: PaymentGateway!
  errorMessages: [String!]!
  operations: [PaymentOperation!]!
  authorizedAmount: Money
  capturedAmount: Money
  refundedAmount: Money
  voidedAmount: Money
  nextOperations: [PaymentSessionOperation!]!
  userErrors: [PaymentSessionError!]!
}

enum PaymentSessionStatus {
  PENDING
  AUTHORIZED
  CAPTURED
  VOIDED
  PARTIALLY_REFUNDED
  FULLY_REFUNDED
  DECLINED
  SESSION_ERROR
  EXPIRED
  UNKNOWN
}

enum PaymentSessionOperation {
  AUTHORIZE
  AUTHORIZE_AND_CAPTURE
  CAPTURE
  VOID
  REFUND
  CONFIRM_PAYMENT_METHOD
}
```

## Payment Methods

### Supported Payment Methods

```graphql
union PaymentMethod = 
  | CardPaymentMethod
  | WalletPaymentMethod
  | AlternativePaymentMethod

type CardPaymentMethod {
  digitalWallet: DigitalWallet
  brand: CardBrand!
  lastDigits: String!
  expiryMonth: Int!
  expiryYear: Int!
  billingAddress: MailingAddress
  threeDSecureAuthenticationData: ThreeDSecureAuthenticationData
}

type WalletPaymentMethod {
  walletType: WalletType!
  lastDigits: String
  billingAddress: MailingAddress
}

enum CardBrand {
  VISA
  MASTERCARD
  AMERICAN_EXPRESS
  DISCOVER
  DINERS_CLUB
  JCB
  UNIONPAY
  INTERAC
}

enum WalletType {
  APPLE_PAY
  GOOGLE_PAY
  FACEBOOK_PAY
  SHOPIFY_PAY
  KLARNA
  PAYPAL
  AMAZON_PAY
  AFFIRM
}
```

## Core Payment Operations

### Authorize Payment

Reserves funds without capturing:

```graphql
mutation {
  paymentSessionAuthorize(input: {
    paymentSessionId: "gid://shopify/PaymentSession/123"
  }) {
    paymentSession {
      id
      status
      authorizedAmount {
        amount
        currencyCode
      }
      nextOperations
    }
    userErrors {
      field
      message
    }
  }
}
```

Implementation:

```typescript
async function authorizePayment(sessionId: string) {
  const mutation = `
    mutation {
      paymentSessionAuthorize(input: {
        paymentSessionId: "${sessionId}"
      }) {
        paymentSession {
          id
          status
          authorizedAmount { amount currencyCode }
          nextOperations
        }
        userErrors { field message }
      }
    }
  `;

  const result = await graphqlRequest(mutation);
  
  if (result.userErrors?.length > 0) {
    throw new PaymentError(result.userErrors[0].message);
  }

  return result.paymentSession;
}
```

### Capture Payment

Move authorized funds to captured state:

```graphql
mutation {
  paymentSessionCapture(input: {
    paymentSessionId: "gid://shopify/PaymentSession/123"
    amount: "99.99"
  }) {
    paymentSession {
      id
      status
      capturedAmount { amount currencyCode }
    }
    userErrors { field message }
  }
}
```

### Void Authorization

Cancel authorized payment:

```graphql
mutation {
  paymentSessionVoid(input: {
    paymentSessionId: "gid://shopify/PaymentSession/123"
  }) {
    paymentSession {
      id
      status
      voidedAmount { amount currencyCode }
    }
    userErrors { field message }
  }
}
```

### Refund Payment

Return captured funds to customer:

```graphql
mutation {
  paymentSessionRefund(input: {
    paymentSessionId: "gid://shopify/PaymentSession/123"
    amount: "50.00"
  }) {
    paymentSession {
      id
      status
      refundedAmount { amount currencyCode }
    }
    userErrors { field message }
  }
}
```

## 3D Secure Authentication

### 3D Secure Data Structure

```graphql
type ThreeDSecureAuthenticationData {
  authenticateProtocolVersion: String
  authenticationStatus: AuthenticationStatus
  authenticationFlow: AuthenticationFlow
  authenticateResultCode: String
}

enum AuthenticationStatus {
  Y  # Successful authentication
  N  # Failed authentication
  U  # Unable to authenticate
  A  # Authentication attempted (ACS unavailable)
}

enum AuthenticationFlow {
  FRICTIONLESS
  CHALLENGE
  DECOUPLED
}
```

### Process 3D Secure Payment

```typescript
async function handle3DSecurePayment(session) {
  const threeDData = session.paymentMethod.threeDSecureAuthenticationData;

  // Check if 3D Secure was completed
  if (threeDData?.authenticationStatus === 'Y') {
    // Authentication successful - proceed with authorization
    return await authorizePayment(session.id);
  } else if (threeDData?.authenticationStatus === 'N') {
    // Authentication failed - decline payment
    throw new PaymentDeclinedError('3D Secure authentication failed');
  } else if (threeDData?.authenticationStatus === 'A') {
    // Attempted but ACS unavailable - may proceed based on risk assessment
    if (shouldProceedWithoutAuth(session)) {
      return await authorizePayment(session.id);
    } else {
      throw new PaymentDeclinedError('3D Secure unavailable');
    }
  }
}

function shouldProceedWithoutAuth(session) {
  // Risk-based decision logic
  const amount = parseFloat(session.amount.amount);
  const isKnownCustomer = checkCustomerHistory(session.merchantReference);
  
  return amount < 100 || isKnownCustomer;
}
```

## Fraud Prevention

### Fraud Detection Signals

```graphql
type PaymentSession {
  riskLevel: RiskLevel
  riskSignals: [RiskSignal!]!
  merchantRecommendation: MerchantRecommendation
}

enum RiskLevel {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

type RiskSignal {
  signal: String!
  description: String!
  severity: Severity!
}

enum Severity {
  INFO
  WARNING
  CRITICAL
}

enum MerchantRecommendation {
  ACCEPT
  REVIEW
  DECLINE
  ACCEPT_WITH_CAUTION
}
```

### Implement Fraud Check

```typescript
async function evaluateFraudRisk(session) {
  const riskData = {
    amount: parseFloat(session.amount.amount),
    currency: session.amount.currencyCode,
    signals: session.riskSignals,
    recommendation: session.merchantRecommendation,
    riskLevel: session.riskLevel,
  };

  // Log for analysis
  await logFraudMetrics(riskData);

  // Make decision
  if (riskData.riskLevel === 'CRITICAL') {
    // Require manual review
    await createFraudReview(session);
    return { proceed: false, reason: 'Critical risk level' };
  }

  if (riskData.recommendation === 'DECLINE') {
    return { proceed: false, reason: 'High fraud risk' };
  }

  if (riskData.recommendation === 'REVIEW') {
    // Implement additional verification
    return { proceed: true, requiresVerification: true };
  }

  return { proceed: true };
}
```

## Webhook Notifications

### Payment Event Webhooks

```typescript
// Register webhook
export async function registerPaymentWebhook() {
  const webhooks = [
    'payment_sessions/authorize',
    'payment_sessions/capture',
    'payment_sessions/refund',
    'payment_sessions/void',
    'payment_sessions/decline',
    'payment_sessions/expire',
  ];

  for (const topic of webhooks) {
    await registerWebhook(topic, '/webhooks/payment');
  }
}

// Handle webhook
export async function handlePaymentWebhook(request) {
  const event = await verifyWebhookSignature(request);
  
  switch (event.topic) {
    case 'payment_sessions/authorize':
      return handleAuthorize(event.data);
    
    case 'payment_sessions/capture':
      return handleCapture(event.data);
    
    case 'payment_sessions/refund':
      return handleRefund(event.data);
    
    case 'payment_sessions/decline':
      return handleDecline(event.data);
    
    case 'payment_sessions/expire':
      return handleExpire(event.data);
  }
}

async function handleAuthorize(data) {
  const { paymentSessionId, authorizedAmount, timestamp } = data;
  
  // Update order status
  await updateOrder(paymentSessionId, {
    status: 'payment_authorized',
    authorizedAmount,
    authorizedAt: timestamp,
  });

  // Store for reconciliation
  await logPaymentEvent('authorize', {
    sessionId: paymentSessionId,
    amount: authorizedAmount,
    timestamp,
  });
}
```

## Error Handling

### Payment Error Types

```typescript
class PaymentError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'PaymentError';
  }
}

class PaymentDeclinedError extends PaymentError {
  constructor(reason: string) {
    super(`Payment declined: ${reason}`);
    this.name = 'PaymentDeclinedError';
  }
}

class PaymentGatewayError extends PaymentError {
  constructor(message: string) {
    super(`Gateway error: ${message}`);
    this.name = 'PaymentGatewayError';
  }
}

class PaymentValidationError extends PaymentError {
  constructor(field: string, message: string) {
    super(`Validation error on ${field}: ${message}`);
    this.name = 'PaymentValidationError';
    this.field = field;
  }
}
```

### Error Handling Pattern

```typescript
async function processPayment(session) {
  try {
    // Validate payment data
    if (!session.paymentMethod) {
      throw new PaymentValidationError('paymentMethod', 'Missing payment method');
    }

    // Authorize
    const authorized = await authorizePayment(session.id);
    
    if (!authorized) {
      throw new PaymentDeclinedError('Authorization failed');
    }

    // Capture
    const captured = await capturePayment(session.id);
    
    return { success: true, sessionId: session.id };
  } catch (error) {
    if (error instanceof PaymentDeclinedError) {
      // Log decline, notify merchant
      await logPaymentDecline(session.id, error.message);
      return { success: false, reason: error.message };
    } else if (error instanceof PaymentValidationError) {
      // Return validation error to user
      return { success: false, field: error.field, reason: error.message };
    } else if (error instanceof PaymentGatewayError) {
      // Retry or fallback
      return { success: false, retryable: true, reason: error.message };
    } else {
      // Unexpected error
      console.error('Unexpected payment error:', error);
      throw error;
    }
  }
}
```

## PCI Compliance

### Secure Implementation Practices

**DO:**
- Keep all card data server-side
- Use Shopify's tokenized payment methods
- Validate HMAC signatures on webhooks
- Implement proper logging without card data
- Use TLS 1.2+ for all connections
- Rotate API credentials regularly

**DON'T:**
- Never log full card numbers or CVV
- Never store unencrypted payment data
- Never transmit sensitive data unencrypted
- Never use deprecated payment APIs
- Never hardcode credentials
- Never access customer data directly

### Secure Webhook Validation

```typescript
import crypto from 'crypto';

function verifyWebhookSignature(request) {
  const hmacHeader = request.headers['x-shopify-hmac-sha256'];
  const body = request.body;
  const secret = process.env.SHOPIFY_WEBHOOK_SECRET;

  const hash = crypto
    .createHmac('sha256', secret)
    .update(body, 'utf8')
    .digest('base64');

  if (hash !== hmacHeader) {
    throw new Error('Invalid webhook signature');
  }

  return JSON.parse(body);
}
```

## Testing and Debugging

### Test Cards

```
Visa:              4111 1111 1111 1111
Mastercard:        5555 5555 5555 4444
Amex:              3782 822463 10005
3D Secure Testing: Use test environments
```

### Enable Test Mode

```graphql
query {
  paymentSession(id: "gid://shopify/PaymentSession/123") {
    test  # true in test environment
  }
}
```

### Logging Pattern

```typescript
async function logPaymentOperation(operation, details) {
  // Never log sensitive card data
  const safeDetails = {
    ...details,
    cardNumber: details.cardNumber ? 
      `****${details.cardNumber.slice(-4)}` : 
      undefined,
    cvv: undefined, // Never log CVV
  };

  await db.paymentLog.create({
    operation,
    details: safeDetails,
    timestamp: new Date(),
  });
}
```

## Next Steps

- See `payments-apps-patterns.md` for implementation examples
- Review [Payments Apps API docs](https://shopify.dev/docs/api/payments-apps) for latest spec
- Test with Shopify's payment sandbox environment
- Implement comprehensive logging and monitoring
- Plan for PCI DSS compliance audit
