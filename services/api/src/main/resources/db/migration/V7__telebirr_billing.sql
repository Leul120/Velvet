-- Membership billing via Telebirr (ETB)
CREATE TABLE subscription_plans (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(32) NOT NULL UNIQUE,
    name_en         VARCHAR(120) NOT NULL,
    name_am         VARCHAR(120),
    price_etb       NUMERIC(12,2) NOT NULL,
    match_quota     INT NOT NULL DEFAULT 2,
    duration_days   INT NOT NULL DEFAULT 30,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO subscription_plans (code, name_en, name_am, price_etb, match_quota, duration_days) VALUES
('STANDARD', 'Standard', 'መደበኛ', 6500.00, 2, 30),
('PREMIUM', 'Premium', 'ፕሪሚየም', 13000.00, 4, 30),
('ELITE', 'Elite', 'ኤሊት', 32500.00, -1, 30);

CREATE TABLE payment_intents (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    plan_id         UUID NOT NULL REFERENCES subscription_plans(id),
    provider        VARCHAR(32) NOT NULL DEFAULT 'TELEBIRR',
    merchant_order_id VARCHAR(64) NOT NULL UNIQUE,
    amount_etb      NUMERIC(12,2) NOT NULL,
    currency        VARCHAR(8) NOT NULL DEFAULT 'ETB',
    status          VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    checkout_url    TEXT,
    provider_ref    VARCHAR(128),
    raw_notify      JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at         TIMESTAMPTZ,
    CONSTRAINT payment_status_chk CHECK (status IN (
        'PENDING', 'CHECKOUT', 'PAID', 'FAILED', 'CANCELLED', 'EXPIRED'
    )),
    CONSTRAINT payment_provider_chk CHECK (provider IN ('TELEBIRR'))
);

CREATE INDEX idx_payment_intents_user ON payment_intents(user_id, created_at DESC);

CREATE TABLE subscriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    plan_id         UUID NOT NULL REFERENCES subscription_plans(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    starts_at       TIMESTAMPTZ NOT NULL,
    ends_at         TIMESTAMPTZ NOT NULL,
    matches_used    INT NOT NULL DEFAULT 0,
    payment_intent_id UUID REFERENCES payment_intents(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT subscription_status_chk CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED'))
);

CREATE INDEX idx_subscriptions_user_active ON subscriptions(user_id, status);

CREATE TABLE ledger_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id),
    payment_intent_id UUID REFERENCES payment_intents(id),
    entry_type      VARCHAR(32) NOT NULL,
    amount_etb      NUMERIC(12,2) NOT NULL,
    currency        VARCHAR(8) NOT NULL DEFAULT 'ETB',
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ledger_type_chk CHECK (entry_type IN (
        'SUBSCRIPTION_CHARGE', 'REFUND', 'ADJUSTMENT'
    ))
);
