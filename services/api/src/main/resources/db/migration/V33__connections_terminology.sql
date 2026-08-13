-- Internal terminology migration. Existing public request compatibility fields
-- continue to be handled in DTOs; this changes only persistence names.
ALTER TABLE match_proposals RENAME TO connections;

ALTER TABLE bookings RENAME COLUMN match_id TO connection_id;
ALTER TABLE chat_threads RENAME COLUMN match_id TO connection_id;
ALTER TABLE subscriptions RENAME COLUMN matches_used TO connections_used;

ALTER INDEX IF EXISTS idx_match_proposals_a RENAME TO idx_connections_a;
ALTER INDEX IF EXISTS idx_match_proposals_b RENAME TO idx_connections_b;
ALTER INDEX IF EXISTS idx_match_proposals_expires RENAME TO idx_connections_expires;
ALTER INDEX IF EXISTS idx_bookings_match RENAME TO idx_bookings_connection;
