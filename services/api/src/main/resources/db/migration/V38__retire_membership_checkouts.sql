-- Velvet charges per confirmed session. Do not leave legacy subscription
-- checkouts payable after the pricing-model change.
UPDATE payment_intents
SET status = 'CANCELLED'
WHERE purpose = 'MEMBERSHIP'
  AND status IN ('PENDING', 'CHECKOUT', 'FAILED');
