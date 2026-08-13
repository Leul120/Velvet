-- VELVET Ethiopia — core schema (Phase 1: identity + invites)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE invites (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(64) NOT NULL UNIQUE,
    issuer_user_id  UUID,
    max_uses        INT NOT NULL DEFAULT 1,
    use_count       INT NOT NULL DEFAULT 0,
    expires_at      TIMESTAMPTZ,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_e164      VARCHAR(20) NOT NULL UNIQUE,
    email           VARCHAR(255),
    status          VARCHAR(32) NOT NULL DEFAULT 'APPLIED',
    role            VARCHAR(32) NOT NULL DEFAULT 'MEMBER',
    display_name    VARCHAR(120),
    date_of_birth   DATE,
    preferred_locale VARCHAR(8) NOT NULL DEFAULT 'am',
    invite_id       UUID REFERENCES invites(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT users_status_chk CHECK (status IN (
        'INVITED', 'APPLIED', 'UNDER_REVIEW', 'VERIFIED', 'ACTIVE', 'SUSPENDED', 'BANNED', 'WITHDRAWN'
    )),
    CONSTRAINT users_role_chk CHECK (role IN ('MEMBER', 'SUBSCRIBER', 'CONCIERGE', 'ADMIN', 'VENUE_PARTNER'))
);

CREATE INDEX idx_users_status ON users(status);

ALTER TABLE invites
    ADD CONSTRAINT invites_issuer_fk FOREIGN KEY (issuer_user_id) REFERENCES users(id);

CREATE TABLE devices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id       VARCHAR(128) NOT NULL,
    platform        VARCHAR(32) NOT NULL,
    push_token      VARCHAR(512),
    last_seen_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, device_id)
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(128) NOT NULL UNIQUE,
    device_id       VARCHAR(128),
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);

CREATE TABLE member_profiles (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    bio_en          TEXT,
    bio_am          TEXT,
    city            VARCHAR(64) NOT NULL DEFAULT 'Addis Ababa',
    interests       JSONB NOT NULL DEFAULT '[]'::jsonb,
    photo_urls      JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id   UUID,
    action          VARCHAR(64) NOT NULL,
    entity_type     VARCHAR(64),
    entity_id       VARCHAR(64),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
