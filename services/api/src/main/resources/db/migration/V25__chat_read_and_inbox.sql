-- Chat read receipts + thread activity for match inbox turn indicators
ALTER TABLE chat_threads
    ADD COLUMN IF NOT EXISTS a_last_read_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS b_last_read_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_messages_thread_created
    ON messages (thread_id, created_at DESC);
