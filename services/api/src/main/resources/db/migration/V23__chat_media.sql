-- Chat exclusive media attachments (image / video / audio / file)
ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS media_type VARCHAR(16);

ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS media_url TEXT;

ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS media_name VARCHAR(255);

ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS media_mime VARCHAR(120);

ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_media_type_chk;

ALTER TABLE messages
    ADD CONSTRAINT messages_media_type_chk
    CHECK (media_type IS NULL OR media_type IN ('IMAGE', 'VIDEO', 'AUDIO', 'FILE'));

-- Allow empty caption when media is present
ALTER TABLE messages ALTER COLUMN body DROP NOT NULL;

ALTER TABLE messages ALTER COLUMN body SET DEFAULT '';
