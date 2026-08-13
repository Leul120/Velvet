-- Private marketplace bookings + per-booking payments

ALTER TABLE bookings ALTER COLUMN venue_id DROP NOT NULL;

ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS meetup_place VARCHAR(280),
    ADD COLUMN IF NOT EXISTS rate_type VARCHAR(16),
    ADD COLUMN IF NOT EXISTS amount_etb INT,
    ADD COLUMN IF NOT EXISTS payment_status VARCHAR(32) NOT NULL DEFAULT 'UNPAID',
    ADD COLUMN IF NOT EXISTS payment_intent_id UUID;

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_rate_type_chk;
ALTER TABLE bookings ADD CONSTRAINT bookings_rate_type_chk
    CHECK (rate_type IS NULL OR rate_type IN ('SESSION', 'OVERNIGHT'));

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_payment_status_chk;
ALTER TABLE bookings ADD CONSTRAINT bookings_payment_status_chk
    CHECK (payment_status IN ('UNPAID', 'PENDING', 'PAID', 'WAIVED'));

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_place_chk;
ALTER TABLE bookings ADD CONSTRAINT bookings_place_chk
    CHECK (venue_id IS NOT NULL OR (meetup_place IS NOT NULL AND length(trim(meetup_place)) > 0));

ALTER TABLE payment_intents ALTER COLUMN plan_id DROP NOT NULL;

ALTER TABLE payment_intents
    ADD COLUMN IF NOT EXISTS purpose VARCHAR(32) NOT NULL DEFAULT 'MEMBERSHIP',
    ADD COLUMN IF NOT EXISTS booking_id UUID REFERENCES bookings(id);

ALTER TABLE payment_intents DROP CONSTRAINT IF EXISTS payment_purpose_chk;
ALTER TABLE payment_intents ADD CONSTRAINT payment_purpose_chk
    CHECK (purpose IN ('MEMBERSHIP', 'BOOKING'));

ALTER TABLE payment_intents DROP CONSTRAINT IF EXISTS payment_purpose_shape_chk;
ALTER TABLE payment_intents ADD CONSTRAINT payment_purpose_shape_chk
    CHECK (
        (purpose = 'MEMBERSHIP' AND plan_id IS NOT NULL)
        OR (purpose = 'BOOKING' AND booking_id IS NOT NULL AND plan_id IS NULL)
    );

ALTER TABLE ledger_entries DROP CONSTRAINT IF EXISTS ledger_type_chk;
ALTER TABLE ledger_entries ADD CONSTRAINT ledger_type_chk
    CHECK (entry_type IN ('SUBSCRIPTION_CHARGE', 'BOOKING_CHARGE', 'REFUND', 'ADJUSTMENT'));
