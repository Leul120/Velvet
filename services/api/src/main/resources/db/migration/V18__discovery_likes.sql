-- Discovery likes, preferences, member location, match source
ALTER TABLE member_profiles
    ADD COLUMN IF NOT EXISTS last_lat DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS last_lng DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS location_updated_at TIMESTAMPTZ;

CREATE TABLE member_preferences (
    user_id            UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    min_age            INT NOT NULL DEFAULT 21,
    max_age            INT NOT NULL DEFAULT 55,
    max_distance_km    INT NOT NULL DEFAULT 50,
    cities             JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT member_preferences_age_chk CHECK (min_age >= 21 AND max_age >= min_age AND max_age <= 99),
    CONSTRAINT member_preferences_distance_chk CHECK (max_distance_km >= 1 AND max_distance_km <= 500)
);

CREATE TABLE member_likes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action          VARCHAR(16) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT member_likes_action_chk CHECK (action IN ('LIKE', 'PASS')),
    CONSTRAINT member_likes_distinct_chk CHECK (from_user_id <> to_user_id),
    UNIQUE (from_user_id, to_user_id)
);

CREATE INDEX idx_member_likes_to ON member_likes(to_user_id);
CREATE INDEX idx_member_likes_from ON member_likes(from_user_id);

ALTER TABLE match_proposals
    ADD COLUMN IF NOT EXISTS source VARCHAR(16) NOT NULL DEFAULT 'CONCIERGE';

ALTER TABLE match_proposals
    DROP CONSTRAINT IF EXISTS match_proposals_source_chk;

ALTER TABLE match_proposals
    ADD CONSTRAINT match_proposals_source_chk CHECK (source IN ('CONCIERGE', 'DISCOVERY'));
