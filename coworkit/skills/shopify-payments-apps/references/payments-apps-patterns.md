# Payments Apps Implementation Patterns

## Complete Payment Processing Flow

### End-to-End Payment Handler

```typescript
async function handleCheckoutPayment(checkoutId: string, sessionData: PaymentSession) {
  const orderId = `order-${Date.now()}`;

  try {
    // Step 1: Validate payment method
    if (!sessionData.paymentMethod) {
      throw new PaymentValidationError('paymentMethod', 'Missing payment method');
    }

    // Step 2: Assess fraud risk
    const fraudCheck = await evaluateFraudRisk(sessionData);
    if (!fraudCheck.proceed) {
      throw new PaymentDeclinedError(fraudCheck.reason);
    }

    // Step 3: Handle 3D Secure if required
    if (sessionData.paymentMethod.threeDSecureAuthenticationData) {
      await validate3DSecure(sessionData);
    }

    // Step 4: Authorize payment
    const authorized = await authorizePayment(sessionData.id);
    if (!authorized) {
      throw new PaymentDeclinedError('Authorization failed');
    }

    // Step 5: Capture payment
    const captured = await capturePayment(sessionData.id);
    if (!captured) {
      // Rollback: void authorization
      await voidPayment(sessionData.id);
      throw new PaymentGatewayError('Capture failed after authorization');
    }

    // Step 6: Create order and fulfill
    await createOrder(orderId, {
      checkoutId,
      sessionId: sessionData.id,
      amount: sessionData.amount.amount,
      status: 'payment_captured',
    });

    // Step 7: Log success
    await logPaymentSuccess(sessionData.id, orderId);

    return { success: true, orderId };
  } catch (error) {
    // Handle error and cleanup
    await handlePaymentError(sessionData.id, error);
    throw error;
  }
}

async function handlePaymentError(sessionId: string, error: Error) {
  if (error instanceof PaymentDeclinedError) {
    await logPaymentDecline(sessionId, error.message);
  } else if (error instanceof PaymentGatewayError) {
    // Attempt void if authorization succeeded
    try {
      await voidPayment(sessionId);
    } catch (voidError) {
      console.error('Failed to void payment:', voidError);
    }
  }
}
```

## Payment Session Query Pattern

### Query Full Session Data

```graphql
query GetPaymentSession($id: ID!) {
  paymentSession(id: $id) {
    id
    gid
    status
    amount { amount currencyCode }
    test
    merchantReference
    idempotencyKey
    paymentMethod {
      __typename
      ... on CardPaymentMethod {
        brand
        lastDigits
        expiryMonth
        expiryYear
        billingAddress {
          address1
          city
          province
          country
          zip
        }
        threeDSecureAuthenticationData {
          authenticationStatus
          authenticationFlow
        }
      }
      ... on WalletPaymentMethod {
        walletType
        lastDigits
      }
    }
    authorizedAmount { amount }
    capturedAmount { amount }
    refundedAmount { amount }
    voidedAmount { amount }
    nextOperations
    riskLevel
    riskSignals {
      signal
      severity
    }
  }
}
```

## Partial Refund Pattern

### Handle Returns and Partial Refunds

```typescript
async function processPartialRefund(sessionId: string, refundAmount: string) {
  try {
    // Check current refund status
    const session = await queryPaymentSession(sessionId);
    
    const capturedAmount = parseFloat(session.capturedAmount.amount);
    constAlreadyRefunded = parseFloat(session.refundedAmount.amount || '0');
    const refundingAmount = parseFloat(refundAmount);

    const totalRefunding = AlreadyRefunded + refundingAmount;

    if (totalRefunding > capturedAmount) {
      throw new PaymentValidationError(
        'refundAmount',
        `Cannot refund ${refundingAmount} - only ${capturedAmount - AlreadyRefunded} available`
      );
    }

    // Process refund
    const refund = await refundPayment(sessionId, refundAmount);

    // Update order
    await updateOrder(sessionId, {
      refundedAmount: totalRefunding,
      refundStatus: totalRefunding === capturedAmount ? 'fully_refunded' : 'partially_refunded',
    });

    // Log refund
    await logPaymentEvent('refund', {
      sessionId,
      refundAmount,
      totalRefunded: totalRefunding,
      timestamp: new Date(),
    });

    return { success: true, refundedAmount: refundingAmount };
  } catch (error) {
    console.error('Refund error:', error);
    throw error;
  }
}
```

## Wallet Payment Handling

### Apple Pay / Google Pay / Shopify Pay Processing

```typescript
async function handleWalletPayment(sessionData: PaymentSession) {
  const walletMethod = sessionData.paymentMethod as WalletPaymentMethod;

  const walletConfig = {
    APPLE_PAY: {
      requiresNetworkTokenization: true,
      requiresAddressVerification: true,
    },
    GOOGLE_PAY: {
      requiresNetworkTokenization: true,
      requiresAddressVerification: false,
    },
    SHOPIFY_PAY: {
      requiresNetworkTokenization: true,
      requiresAddressVerification: false,
    },
    KLARNA: {
      requiresNetworkTokenization: false,
      supportedCountries: ['US', 'UK', 'DE', 'SE'],
    },
  };

  const config = walletConfig[walletMethod.walletType];

  if (!config) {
    throw new PaymentValidationError('walletType', `Unsupported wallet: ${walletMethod.walletType}`);
  }

  // Verify address if required
  if (config.requiresAddressVerification && sessionData.paymentMethod.billingAddress) {
    await verifyBillingAddress(sessionData.paymentMethod.billingAddress);
  }

  // Process authorization
  return await authorizePayment(sessionData.id);
}
```

## Alternative Payment Methods

### Regional Payment Method Support

```typescript
const alternativePayments = {
  US: ['AFFIRM', 'AFTERPAY', 'KLARNA'],
  EU: ['KLARNA', 'GIROPAY', 'IDEAL', 'SEPA'],
  APAC: ['PAYPAY', 'ALIPAY', 'WECHAT_PAY'],
  LATAM: ['BOLETO', 'PIX'],
};

async function validateAlternativePayment(
  paymentMethod: AlternativePaymentMethod,
  billingCountry: string
) {
  const supportedMethods = alternativePayments[billingCountry] || [];

  if (!supportedMethods.includes(paymentMethod.type)) {
    throw new PaymentValidationError(
      'paymentMethod',
      `${paymentMethod.type} not supported in ${billingCountry}`
    );
  }

  // Additional validation by type
  switch (paymentMethod.type) {
    case 'AFFIRM':
      return validateAffirmPayment(paymentMethod);
    case 'KLARNA':
      return validateKlarnaPayment(paymentMethod);
    case 'BOLETO':
      return validateBoletoPayment(paymentMethod);
    default:
      return true;
  }
}
```

## Reconciliation Pattern

### Daily Payment Reconciliation

```typescript
async function reconcilePayments(date: Date) {
  const transactions = await db.paymentLog.find({
    timestamp: { $gte: date, $lt: new Date(date.getTime() + 24 * 60 * 60 * 1000) },
  });

  const reconciled = {
    authorized: 0,
    captured: 0,
    voided: 0,
    refunded: 0,
    failed: 0,
    totalAuthorized: 0,
    totalCaptured: 0,
    totalRefunded: 0,
    discrepancies: [],
  };

  for (const transaction of transactions) {
    const session = await queryPaymentSession(transaction.sessionId);

    switch (transaction.operation) {
      case 'authorize':
        reconciled.authorized++;
        reconciled.totalAuthorized += parseFloat(session.authorizedAmount?.amount || '0');
        break;
      case 'capture':
        reconciled.captured++;
        reconciled.totalCaptured += parseFloat(session.capturedAmount?.amount || '0');
        break;
      case 'refund':
        reconciled.refunded++;
        reconciled.totalRefunded += parseFloat(session.refundedAmount?.amount || '0');
        break;
      case 'void':
        reconciled.voided++;
        break;
      case 'decline':
        reconciled.failed++;
        break;
    }

    // Check for inconsistencies
    if (session.status === 'AUTHORIZED' && !session.nextOperations.includes('CAPTURE')) {
      reconciled.discrepancies.push({
        sessionId: transaction.sessionId,
        issue: 'Authorized but capture not available',
      });
    }
  }

  // Report
  await generateReconciliationReport(date, reconciled);
  return reconciled;
}
```

## Monitoring and Analytics

### Payment Metrics Dashboard

```typescript
async function collectPaymentMetrics(timeRange = '24h') {
  const metrics = {
    summary: {
      totalTransactions: 0,
      totalRevenue: 0,
      averageOrderValue: 0,
      successRate: 0,
    },
    byStatus: {},
    byPaymentMethod: {},
    byRiskLevel: {},
    errors: [],
    trends: [],
  };

  // Collect transaction data
  const transactions = await db.paymentLog.aggregate([
    {
      $match: {
        timestamp: { $gte: new Date(Date.now() - parseTimeRange(timeRange)) },
      },
    },
    {
      $group: {
        _id: '$operation',
        count: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
      },
    },
  ]);

  // Process metrics
  for (const transaction of transactions) {
    metrics.byStatus[transaction._id] = {
      count: transaction.count,
      amount: transaction.totalAmount,
    };

    if (transaction._id === 'capture') {
      metrics.summary.totalRevenue = transaction.totalAmount;
      metrics.summary.totalTransactions = transaction.count;
      metrics.summary.averageOrderValue = transaction.totalAmount / transaction.count;
    }
  }

  // Calculate success rate
  const successful = (metrics.byStatus.capture?.count || 0) + (metrics.byStatus.refund?.count || 0);
  const total = metrics.summary.totalTransactions + (metrics.byStatus.decline?.count || 0);
  metrics.summary.successRate = (successful / total) * 100;

  return metrics;
}
```

## Webhook Retry Logic

### Robust Webhook Handling

```typescript
async function handlePaymentWebhookWithRetry(
  event: WebhookEvent,
  maxRetries = 3
) {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      // Verify signature
      await verifyWebhookSignature(event);

      // Process by topic
      switch (event.topic) {
        case 'payment_sessions/authorize':
          await handleAuthorize(event.data);
          break;
        case 'payment_sessions/capture':
          await handleCapture(event.data);
          break;
        case 'payment_sessions/refund':
          await handleRefund(event.data);
          break;
        default:
          throw new Error(`Unknown webhook topic: ${event.topic}`);
      }

      // Success
      await logWebhookProcessed(event.id);
      return { success: true };
    } catch (error) {
      lastError = error;
      const backoffMs = Math.pow(2, attempt) * 1000;
      
      if (attempt < maxRetries - 1) {
        console.log(`Webhook retry ${attempt + 1}/${maxRetries} after ${backoffMs}ms`);
        await delay(backoffMs);
      }
    }
  }

  // All retries failed
  await logWebhookError(event.id, lastError?.message || 'Unknown error');
  throw new Error(`Webhook processing failed after ${maxRetries} attempts: ${lastError?.message}`);
}

function delay(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

## Session Timeout Handling

### Handle Expired Payment Sessions

```typescript
async function cleanupExpiredSessions() {
  const expiredSessions = await queryPaymentSessions({
    status: 'EXPIRED',
    createdBefore: new Date(Date.now() - 24 * 60 * 60 * 1000),
  });

  for (const session of expiredSessions) {
    // Update order status
    await updateOrder(session.merchantReference, {
      status: 'payment_expired',
      expiresAt: session.expiresAt,
    });

    // Notify customer
    await sendEmailNotification(session.merchantReference, {
      type: 'payment_expired',
      message: 'Your checkout session has expired. Please try again.',
    });

    // Log cleanup
    await logSessionCleanup(session.id);
  }

  return expiredSessions.length;
}
```
