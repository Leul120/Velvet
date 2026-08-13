-- Device push tokens for FCM / HTTP push gateway
CREATE TABLE device_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    token           VARCHAR(512) NOT NULL,
    platform        VARCHAR(32) NOT NULL DEFAULT 'android',
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT device_tokens_token_uq UNIQUE (token)
);

CREATE INDEX idx_device_tokens_user ON device_tokens(user_id) WHERE active = TRUE;
CREATE INDEX idx_device_tokens_staff ON device_tokens(user_id, active);
