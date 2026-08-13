ALTER TABLE payment_intents DROP CONSTRAINT payment_status_chk;
ALTER TABLE payment_intents ADD CONSTRAINT payment_status_chk CHECK (status IN (
    'PENDING', 'CHECKOUT', 'PAID', 'FAILED', 'CANCELLED', 'EXPIRED', 'REFUND_PENDING', 'REFUNDED'
));
