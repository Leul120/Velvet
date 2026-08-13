-- Gender for asymmetric discovery (men browse women; women respond to likes)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS gender VARCHAR(16);

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_gender_chk;

ALTER TABLE users
    ADD CONSTRAINT users_gender_chk CHECK (
        gender IS NULL OR gender IN ('MALE', 'FEMALE')
    );

CREATE INDEX IF NOT EXISTS idx_users_gender ON users(gender);
