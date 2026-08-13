-- Phase 11: blocks, member inbox, concierge notes
CREATE TABLE member_blocks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id      UUID NOT NULL REFERENCES users(id),
    blocked_id      UUID NOT NULL REFERENCES users(id),
    reason          VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT member_blocks_pair_uq UNIQUE (blocker_id, blocked_id),
    CONSTRAINT member_blocks_self_chk CHECK (blocker_id <> blocked_id)
);

CREATE INDEX idx_member_blocks_blocked ON member_blocks(blocked_id);

CREATE TABLE member_notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    subject         VARCHAR(255) NOT NULL,
    body            TEXT NOT NULL,
    related_type    VARCHAR(64),
    related_id      VARCHAR(64),
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_member_notifications_user ON member_notifications(user_id, created_at DESC);
CREATE INDEX idx_member_notifications_unread ON member_notifications(user_id) WHERE read_at IS NULL;

ALTER TABLE member_profiles
    ADD COLUMN IF NOT EXISTS concierge_notes TEXT;
