-- Allow CBE payments and NO_TOKEN notification outbox rows (dev/local without push tokens).
ALTER TABLE notification_outbox DROP CONSTRAINT IF EXISTS notification_status_chk;
ALTER TABLE notification_outbox
    ADD CONSTRAINT notification_status_chk
    CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'NO_TOKEN'));

ALTER TABLE payment_intents DROP CONSTRAINT IF EXISTS payment_provider_chk;
ALTER TABLE payment_intents
    ADD CONSTRAINT payment_provider_chk
    CHECK (provider IN ('TELEBIRR', 'CBE'));
