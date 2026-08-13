-- Preserve an auditable reversal when a previously credited booking is refunded.
ALTER TABLE ledger_entries DROP CONSTRAINT IF EXISTS ledger_type_chk;
ALTER TABLE ledger_entries ADD CONSTRAINT ledger_type_chk CHECK (entry_type IN (
    'SUBSCRIPTION_CHARGE',
    'BOOKING_CHARGE',
    'REFUND',
    'ADJUSTMENT',
    'PERFORMER_CREDIT',
    'PERFORMER_CREDIT_REVERSAL',
    'PLATFORM_FEE',
    'PERFORMER_PAYOUT',
    'PERFORMER_PAYOUT_REVERSAL'
));

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_intents_paid_provider_ref
    ON payment_intents (provider, upper(provider_ref))
    WHERE provider_ref IS NOT NULL AND status = 'PAID';
