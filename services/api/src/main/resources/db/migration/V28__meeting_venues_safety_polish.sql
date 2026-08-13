-- Soft-launch: rich venues, meeting feedback, trip shares with concierge

ALTER TABLE venues
    ADD COLUMN IF NOT EXISTS area VARCHAR(64),
    ADD COLUMN IF NOT EXISTS price_band VARCHAR(32) NOT NULL DEFAULT 'MODERATE',
    ADD COLUMN IF NOT EXISTS vibe VARCHAR(32) NOT NULL DEFAULT 'BALANCED',
    ADD COLUMN IF NOT EXISTS photo_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS verified BOOLEAN NOT NULL DEFAULT TRUE;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'venues_price_band_chk') THEN
        ALTER TABLE venues ADD CONSTRAINT venues_price_band_chk
            CHECK (price_band IN ('BUDGET', 'MODERATE', 'UPSCALE'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'venues_vibe_chk') THEN
        ALTER TABLE venues ADD CONSTRAINT venues_vibe_chk
            CHECK (vibe IN ('QUIET', 'BALANCED', 'LIVELY'));
    END IF;
END $$;

UPDATE venues SET
    area = 'Bishoftu',
    price_band = 'UPSCALE',
    vibe = 'QUIET',
    photo_urls = '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=70"]'::jsonb,
    verified = TRUE
WHERE name ILIKE 'Kuriftu%';

UPDATE venues SET
    area = 'Piazza',
    price_band = 'BUDGET',
    vibe = 'QUIET',
    photo_urls = '["https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=70"]'::jsonb,
    verified = TRUE
WHERE name ILIKE 'Tomoca%';

UPDATE venues SET
    area = 'Kazanchis',
    price_band = 'UPSCALE',
    vibe = 'BALANCED',
    photo_urls = '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=70"]'::jsonb,
    verified = TRUE
WHERE name ILIKE 'Sheraton%';

UPDATE venues SET
    area = 'Bole',
    price_band = 'MODERATE',
    vibe = 'LIVELY',
    photo_urls = '["https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=70"]'::jsonb,
    verified = TRUE
WHERE name ILIKE 'Dashen%';

CREATE TABLE IF NOT EXISTS meeting_feedback (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    felt_safe       BOOLEAN NOT NULL,
    would_meet_again BOOLEAN NOT NULL,
    venue_ok        BOOLEAN NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT meeting_feedback_booking_user_uq UNIQUE (booking_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_meeting_feedback_booking ON meeting_feedback(booking_id);

CREATE TABLE IF NOT EXISTS trip_shares (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id      UUID REFERENCES bookings(id) ON DELETE SET NULL,
    match_id        UUID,
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    eta_minutes     INTEGER,
    note            TEXT,
    status          VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT trip_shares_status_chk CHECK (status IN ('ACTIVE', 'ARRIVED', 'CANCELLED'))
);

CREATE INDEX IF NOT EXISTS idx_trip_shares_user ON trip_shares(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_trip_shares_booking ON trip_shares(booking_id);
