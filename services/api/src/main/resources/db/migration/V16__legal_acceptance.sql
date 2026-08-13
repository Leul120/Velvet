-- Soft-launch: legal consent capture (PDPP-aligned explicit acceptance)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS legal_accepted_version VARCHAR(32),
    ADD COLUMN IF NOT EXISTS legal_accepted_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS legal_acceptances (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_set_version VARCHAR(32) NOT NULL,
    accepted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    source          VARCHAR(32) NOT NULL DEFAULT 'APP',
    UNIQUE (user_id, document_set_version)
);

CREATE INDEX IF NOT EXISTS idx_legal_acceptances_user ON legal_acceptances(user_id);
