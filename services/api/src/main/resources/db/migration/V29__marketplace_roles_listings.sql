-- Adult marketplace: CLIENT / PERFORMER roles + performer listing economics

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_chk;
ALTER TABLE users ADD CONSTRAINT users_role_chk CHECK (role IN (
    'MEMBER', 'SUBSCRIBER', 'CLIENT', 'PERFORMER', 'CONCIERGE', 'ADMIN', 'VENUE_PARTNER'
));

-- Map existing gendered members onto marketplace roles (keep paid SUBSCRIBER clients)
UPDATE users SET role = 'CLIENT'
WHERE gender = 'MALE' AND role = 'MEMBER';

UPDATE users SET role = 'PERFORMER'
WHERE gender = 'FEMALE' AND role IN ('MEMBER', 'SUBSCRIBER');

ALTER TABLE member_profiles
    ADD COLUMN IF NOT EXISTS session_rate_etb INT,
    ADD COLUMN IF NOT EXISTS overnight_rate_etb INT,
    ADD COLUMN IF NOT EXISTS availability_note VARCHAR(280),
    ADD COLUMN IF NOT EXISTS listing_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Demo performer rates for seeded women (when present)
UPDATE member_profiles SET
    session_rate_etb = 3500 + ((ABS(HASHTEXT(user_id::text)) % 8) * 500),
    overnight_rate_etb = 12000 + ((ABS(HASHTEXT(user_id::text)) % 6) * 1500),
    availability_note = 'Tonight · hotel or private suite'
WHERE user_id IN (SELECT id FROM users WHERE gender = 'FEMALE');
