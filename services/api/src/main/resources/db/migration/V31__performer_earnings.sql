-- Performer earnings / payouts from paid bookings

ALTER TABLE ledger_entries
    ADD COLUMN IF NOT EXISTS booking_id UUID REFERENCES bookings(id);

ALTER TABLE ledger_entries DROP CONSTRAINT IF EXISTS ledger_type_chk;
ALTER TABLE ledger_entries ADD CONSTRAINT ledger_type_chk
    CHECK (entry_type IN (
        'SUBSCRIPTION_CHARGE',
        'BOOKING_CHARGE',
        'PERFORMER_CREDIT',
        'PLATFORM_FEE',
        'PERFORMER_PAYOUT',
        'REFUND',
        'ADJUSTMENT'
    ));

CREATE TABLE IF NOT EXISTS payout_requests (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id),
    amount_etb          NUMERIC(12,2) NOT NULL,
    status              VARCHAR(32) NOT NULL DEFAULT 'REQUESTED',
    destination_note    VARCHAR(280),
    ledger_entry_id     UUID REFERENCES ledger_entries(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at        TIMESTAMPTZ,
    CONSTRAINT payout_status_chk CHECK (status IN ('REQUESTED', 'PAID', 'REJECTED', 'CANCELLED')),
    CONSTRAINT payout_amount_chk CHECK (amount_etb > 0)
);

CREATE INDEX IF NOT EXISTS idx_payout_requests_user ON payout_requests(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ledger_user_type ON ledger_entries(user_id, entry_type);
CREATE UNIQUE INDEX IF NOT EXISTS idx_ledger_performer_credit_booking
    ON ledger_entries(booking_id, entry_type)
    WHERE entry_type = 'PERFORMER_CREDIT' AND booking_id IS NOT NULL;
