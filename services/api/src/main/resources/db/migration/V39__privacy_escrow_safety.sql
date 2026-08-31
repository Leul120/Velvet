-- V39: Schema migration for Privacy Vaults, Escrow, Available Tonight & Emergency Contacts

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS escrow_release_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS escrow_released_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS disputed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS dispute_notes VARCHAR(500);

ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS private_photo_urls JSONB NOT NULL DEFAULT '[]';
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS available_tonight BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS available_neighborhood VARCHAR(64);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS voice_intro_url VARCHAR(1024);

CREATE TABLE IF NOT EXISTS vault_access_grants (
    id UUID PRIMARY KEY,
    performer_id UUID NOT NULL,
    member_id UUID NOT NULL,
    granted_by UUID NOT NULL,
    reason VARCHAR(120),
    granted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_vault_grant UNIQUE (performer_id, member_id)
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    contact_name VARCHAR(120) NOT NULL,
    contact_phone VARCHAR(32) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
