-- Phase 14: seed venue partner + invite for local desk testing
INSERT INTO users (phone_e164, status, role, display_name, preferred_locale)
SELECT '+251911000010', 'ACTIVE', 'VENUE_PARTNER', 'Kuriftu Partner Desk', 'en'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone_e164 = '+251911000010');

UPDATE venues
SET partner_user_id = (SELECT id FROM users WHERE phone_e164 = '+251911000010')
WHERE name ILIKE 'Kuriftu%'
  AND partner_user_id IS NULL;
