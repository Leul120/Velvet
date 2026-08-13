-- Bookings (public venues only) + moderated chat
CREATE TABLE bookings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id        UUID NOT NULL UNIQUE REFERENCES match_proposals(id),
    venue_id        UUID NOT NULL REFERENCES venues(id),
    proposed_by     UUID NOT NULL REFERENCES users(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'PROPOSED',
    starts_at       TIMESTAMPTZ NOT NULL,
    notes           TEXT,
    confirmed_at    TIMESTAMPTZ,
    cancelled_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT booking_status_chk CHECK (status IN (
        'PROPOSED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED', 'NO_SHOW'
    ))
);

CREATE INDEX idx_bookings_match ON bookings(match_id);
CREATE INDEX idx_bookings_venue ON bookings(venue_id);

CREATE TABLE chat_threads (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id        UUID NOT NULL UNIQUE REFERENCES match_proposals(id),
    member_a_id     UUID NOT NULL REFERENCES users(id),
    member_b_id     UUID NOT NULL REFERENCES users(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chat_thread_status_chk CHECK (status IN ('OPEN', 'LOCKED', 'CLOSED'))
);

CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id       UUID NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,
    sender_id       UUID NOT NULL REFERENCES users(id),
    body            TEXT NOT NULL,
    moderation_status VARCHAR(32) NOT NULL DEFAULT 'ALLOWED',
    moderation_flags  JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT messages_moderation_chk CHECK (moderation_status IN (
        'ALLOWED', 'HELD', 'BLOCKED'
    ))
);

CREATE INDEX idx_messages_thread ON messages(thread_id, created_at);

CREATE TABLE moderation_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id      UUID REFERENCES messages(id),
    user_id         UUID REFERENCES users(id),
    action          VARCHAR(64) NOT NULL,
    detail          TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE icebreakers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text_en         TEXT NOT NULL,
    text_am         TEXT NOT NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO icebreakers (text_en, text_am) VALUES
('What cafe or restaurant in Addis do you love most?', 'በአዲስ አበባ ከሚወዷቸው ካፌዎች ወይም ሬስቶራንቶች የትኛው ነው?'),
('Which cultural event would you enjoy attending together?', 'አብረው መሄድ የሚፈልጉት የባህል ዝግጅት ምንድን ነው?'),
('Coffee or tea — and where should we meet first?', 'ቡና ወይስ ሻይ — የት ማግኘት ይሻላል?');
