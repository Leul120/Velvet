-- Soft geofence + notification outbox for concierge alerts
ALTER TABLE venues ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS geofence_meters INT NOT NULL DEFAULT 400;

UPDATE venues SET latitude = 9.0108, longitude = 38.7612 WHERE name ILIKE '%Tomoca%';
UPDATE venues SET latitude = 9.0150, longitude = 38.7630 WHERE name ILIKE '%Sheraton%';
UPDATE venues SET latitude = 8.9806, longitude = 38.7578 WHERE name ILIKE '%Dashen%';
UPDATE venues SET latitude = 8.7520, longitude = 39.0080 WHERE name ILIKE '%Kuriftu%';

CREATE TABLE notification_outbox (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel         VARCHAR(32) NOT NULL,
    recipient       VARCHAR(128) NOT NULL,
    subject         VARCHAR(255),
    body            TEXT NOT NULL,
    related_type    VARCHAR(64),
    related_id      VARCHAR(64),
    status          VARCHAR(32) NOT NULL DEFAULT 'SENT',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT notification_channel_chk CHECK (channel IN ('SMS', 'PUSH', 'EMAIL', 'LOG')),
    CONSTRAINT notification_status_chk CHECK (status IN ('PENDING', 'SENT', 'FAILED'))
);

CREATE INDEX idx_notification_outbox_created ON notification_outbox(created_at DESC);
