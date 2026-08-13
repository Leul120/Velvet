-- Wave 2: chat windowing + concierge meeting tasks
ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS messages_purged_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS concierge_tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    match_id        UUID NOT NULL,
    task_type       VARCHAR(32) NOT NULL,
    due_at          TIMESTAMPTZ NOT NULL,
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    notes           TEXT,
    ack_by          UUID REFERENCES users(id),
    ack_at          TIMESTAMPTZ,
    escalated_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT concierge_tasks_type_chk CHECK (task_type IN (
        'PRE_CALL', 'ARRIVAL_CHECK', 'FOLLOW_UP'
    )),
    CONSTRAINT concierge_tasks_status_chk CHECK (status IN (
        'OPEN', 'ACKED', 'DONE', 'ESCALATED'
    )),
    UNIQUE (booking_id, task_type)
);

CREATE INDEX IF NOT EXISTS idx_concierge_tasks_status_due
    ON concierge_tasks (status, due_at);

CREATE INDEX IF NOT EXISTS idx_bookings_status_starts
    ON bookings (status, starts_at);
