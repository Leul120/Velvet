-- A paid session is only settled after both participants confirm checkout.
ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS performer_checked_out_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS client_checked_out_at TIMESTAMPTZ;
