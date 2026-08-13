-- Phase 15b: CBE receipt proof fields for membership payments
ALTER TABLE payment_intents
    ADD COLUMN IF NOT EXISTS receipt_url TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_intents_cbe_ref
    ON payment_intents (provider, provider_ref)
    WHERE provider_ref IS NOT NULL AND provider = 'CBE' AND status = 'PAID';
