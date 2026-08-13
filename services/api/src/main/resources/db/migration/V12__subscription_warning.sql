-- Phase 12: subscription renewal warning marker
ALTER TABLE subscriptions
    ADD COLUMN IF NOT EXISTS warning_sent_at TIMESTAMPTZ;
