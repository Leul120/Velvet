-- Verification, venues, curated matches
CREATE TABLE verification_cases (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status          VARCHAR(32) NOT NULL DEFAULT 'SUBMITTED',
    id_document_url TEXT,
    selfie_url      TEXT,
    notes           TEXT,
    reviewer_id     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT verification_status_chk CHECK (status IN (
        'DRAFT', 'SUBMITTED', 'IN_REVIEW', 'APPROVED', 'REJECTED'
    ))
);

CREATE INDEX idx_verification_cases_status ON verification_cases(status);
CREATE INDEX idx_verification_cases_user ON verification_cases(user_id);

CREATE TABLE venues (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(160) NOT NULL,
    name_am         VARCHAR(160),
    city            VARCHAR(64) NOT NULL DEFAULT 'Addis Ababa',
    category        VARCHAR(64) NOT NULL DEFAULT 'RESTAURANT',
    address_line    VARCHAR(255) NOT NULL,
    privacy_level   VARCHAR(32) NOT NULL DEFAULT 'STANDARD',
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT venues_category_chk CHECK (category IN (
        'RESTAURANT', 'CAFE', 'HOTEL', 'CLUB', 'CULTURAL'
    )),
    CONSTRAINT venues_privacy_chk CHECK (privacy_level IN (
        'STANDARD', 'DISCREET', 'PRIVATE_ROOM'
    ))
);

CREATE TABLE match_proposals (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_a_id     UUID NOT NULL REFERENCES users(id),
    member_b_id     UUID NOT NULL REFERENCES users(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'PROPOSED',
    curator_id      UUID REFERENCES users(id),
    intro_note_en   TEXT,
    intro_note_am   TEXT,
    suggested_venue_id UUID REFERENCES venues(id),
    expires_at      TIMESTAMPTZ NOT NULL,
    a_responded_at  TIMESTAMPTZ,
    b_responded_at  TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT match_status_chk CHECK (status IN (
        'PROPOSED', 'ACCEPTED_A', 'ACCEPTED_B', 'MUTUAL', 'DECLINED', 'EXPIRED', 'CANCELLED'
    )),
    CONSTRAINT match_distinct_members CHECK (member_a_id <> member_b_id)
);

CREATE INDEX idx_match_proposals_a ON match_proposals(member_a_id, status);
CREATE INDEX idx_match_proposals_b ON match_proposals(member_b_id, status);
CREATE INDEX idx_match_proposals_expires ON match_proposals(expires_at);
