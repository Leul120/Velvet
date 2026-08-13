-- Verified listings ops: availability calendar + payout admin notes + ledger reversal

ALTER TABLE ledger_entries DROP CONSTRAINT IF EXISTS ledger_type_chk;
ALTER TABLE ledger_entries ADD CONSTRAINT ledger_type_chk CHECK (entry_type IN (
    'SUBSCRIPTION_CHARGE',
    'BOOKING_CHARGE',
    'REFUND',
    'ADJUSTMENT',
    'PERFORMER_CREDIT',
    'PLATFORM_FEE',
    'PERFORMER_PAYOUT',
    'PERFORMER_PAYOUT_REVERSAL'
));

ALTER TABLE payout_requests
    ADD COLUMN IF NOT EXISTS admin_notes VARCHAR(500),
    ADD COLUMN IF NOT EXISTS processed_by UUID;

CREATE INDEX IF NOT EXISTS idx_payout_requests_status ON payout_requests(status, created_at DESC);

CREATE TABLE IF NOT EXISTS availability_windows (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    note VARCHAR(140),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT availability_windows_range_chk CHECK (ends_at > starts_at)
);

CREATE INDEX IF NOT EXISTS idx_availability_windows_user_starts
    ON availability_windows(user_id, starts_at);
