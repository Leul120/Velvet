-- Phase 13: waitlist, venue partners, staff shifts
CREATE TABLE waitlist_applications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_e164      VARCHAR(32) NOT NULL,
    display_name    VARCHAR(120),
    city            VARCHAR(64) NOT NULL DEFAULT 'Addis Ababa',
    note            TEXT,
    status          VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    invite_code     VARCHAR(64),
    reviewed_by     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT waitlist_status_chk CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT waitlist_phone_uq UNIQUE (phone_e164)
);

CREATE INDEX idx_waitlist_status ON waitlist_applications(status, created_at DESC);

ALTER TABLE venues
    ADD COLUMN IF NOT EXISTS partner_user_id UUID REFERENCES users(id);

CREATE INDEX IF NOT EXISTS idx_venues_partner ON venues(partner_user_id) WHERE partner_user_id IS NOT NULL;

CREATE TABLE staff_shifts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    starts_at       TIMESTAMPTZ NOT NULL,
    ends_at         TIMESTAMPTZ NOT NULL,
    role_label      VARCHAR(64) NOT NULL DEFAULT 'CONCIERGE',
    on_call         BOOLEAN NOT NULL DEFAULT TRUE,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT staff_shifts_window_chk CHECK (ends_at > starts_at)
);

CREATE INDEX idx_staff_shifts_window ON staff_shifts(starts_at, ends_at);
