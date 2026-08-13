-- Local discover filters, like context, photo quality gate
ALTER TABLE member_preferences
    ADD COLUMN IF NOT EXISTS preferred_languages JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS intents JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS verified_only BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE member_likes
    ADD COLUMN IF NOT EXISTS liked_photo_index SMALLINT,
    ADD COLUMN IF NOT EXISTS liked_prompt_key VARCHAR(64);

ALTER TABLE member_profiles
    ADD COLUMN IF NOT EXISTS photo_quality_status VARCHAR(32) NOT NULL DEFAULT 'APPROVED',
    ADD COLUMN IF NOT EXISTS photo_quality_notes VARCHAR(500);

-- Grandfather existing profiles as approved for soft launch
UPDATE member_profiles
SET photo_quality_status = 'APPROVED'
WHERE photo_quality_status IS NULL OR photo_quality_status = '';
