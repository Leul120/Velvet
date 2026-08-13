-- Safety: panic alerts + reports; booking check-in timestamp already via status
CREATE TABLE panic_alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    booking_id      UUID REFERENCES bookings(id),
    match_id        UUID REFERENCES match_proposals(id),
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    note            TEXT,
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT panic_status_chk CHECK (status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'FALSE_ALARM'))
);

CREATE INDEX idx_panic_alerts_status ON panic_alerts(status, created_at DESC);

CREATE TABLE safety_reports (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id     UUID NOT NULL REFERENCES users(id),
    reported_user_id UUID REFERENCES users(id),
    match_id        UUID REFERENCES match_proposals(id),
    booking_id      UUID REFERENCES bookings(id),
    category        VARCHAR(64) NOT NULL,
    details         TEXT NOT NULL,
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT report_status_chk CHECK (status IN ('OPEN', 'TRIAGED', 'RESOLVED', 'DISMISSED')),
    CONSTRAINT report_category_chk CHECK (category IN (
        'HARASSMENT', 'NO_SHOW', 'UNSAFE', 'POLICY', 'OTHER'
    ))
);

CREATE INDEX idx_safety_reports_status ON safety_reports(status, created_at DESC);

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMPTZ;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS checked_out_at TIMESTAMPTZ;
