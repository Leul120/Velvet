-- Demo members for asymmetric discovery (men browse women)
-- Fixed UUIDs for local testing

INSERT INTO users (id, phone_e164, status, role, display_name, date_of_birth, gender, preferred_locale, legal_accepted_version, legal_accepted_at)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', '+251911100001', 'ACTIVE', 'MEMBER', 'Abel Demo', '1994-03-12', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', '+251911100002', 'ACTIVE', 'MEMBER', 'Dawit Demo', '1992-07-21', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', '+251911200001', 'ACTIVE', 'MEMBER', 'Sara Demo', '1996-01-08', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', '+251911200002', 'ACTIVE', 'MEMBER', 'Hanna Demo', '1995-11-30', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', '+251911200003', 'ACTIVE', 'MEMBER', 'Liya Demo', '1998-05-14', 'FEMALE', 'en', 'v1-2026-08', NOW())
ON CONFLICT (phone_e164) DO UPDATE SET
  gender = EXCLUDED.gender,
  display_name = EXCLUDED.display_name,
  date_of_birth = EXCLUDED.date_of_birth,
  status = 'ACTIVE',
  legal_accepted_version = EXCLUDED.legal_accepted_version,
  legal_accepted_at = COALESCE(users.legal_accepted_at, NOW());

INSERT INTO member_profiles (user_id, bio_en, bio_am, city, interests, photo_urls)
SELECT u.id, v.bio_en, v.bio_am, v.city, v.interests::jsonb, '[]'::jsonb
FROM (
  VALUES
    ('+251911100001', 'Addis-based, loves jazz cafés and hiking Entoto.', 'አዲስ አበባ', 'Addis Ababa', '["music","outdoors"]'),
    ('+251911100002', 'Engineer who hosts board-game nights.', 'ኢንጂነር', 'Addis Ababa', '["games","coffee"]'),
    ('+251911200001', 'Designer. Weekend markets and tiramisu.', 'ዲዛይነር', 'Addis Ababa', '["design","food"]'),
    ('+251911200002', 'Reads Amharic poetry; quiet dinners preferred.', 'ግጥም ትወዳለች', 'Addis Ababa', '["books","art"]'),
    ('+251911200003', 'Runs mornings around Friendship Park.', 'ሩጫ', 'Addis Ababa', '["fitness","travel"]')
) AS v(phone, bio_en, bio_am, city, interests)
JOIN users u ON u.phone_e164 = v.phone
ON CONFLICT (user_id) DO UPDATE SET
  bio_en = EXCLUDED.bio_en,
  bio_am = EXCLUDED.bio_am,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests;

-- Elite unlimited for demo accounts so discovery works
INSERT INTO subscriptions (user_id, plan_id, status, starts_at, ends_at, matches_used)
SELECT u.id, p.id, 'ACTIVE', NOW() - INTERVAL '1 day', NOW() + INTERVAL '60 days', 0
FROM users u
CROSS JOIN subscription_plans p
WHERE u.phone_e164 IN ('+251911100001', '+251911100002', '+251911200001', '+251911200002', '+251911200003')
  AND p.code = 'ELITE'
  AND NOT EXISTS (
    SELECT 1 FROM subscriptions s WHERE s.user_id = u.id AND s.status = 'ACTIVE' AND s.ends_at > NOW()
  );
