-- Phase 9: booking reminders + report triage staff fields
ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS reminder_24h_sent_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS reminder_2h_sent_at TIMESTAMPTZ;

ALTER TABLE safety_reports
    ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS staff_notes TEXT;

CREATE INDEX IF NOT EXISTS idx_bookings_reminders
    ON bookings(status, starts_at)
    WHERE status = 'CONFIRMED';
