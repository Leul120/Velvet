-- Richer demo roster with public portrait photos (Unsplash) for local/device testing.
-- Login with invite VELVET-SEED and any phone below; OTP is logged by the API.

-- Extra men (+ existing aa01–aa02 from V20)
INSERT INTO users (id, phone_e164, status, role, display_name, date_of_birth, gender, preferred_locale, legal_accepted_version, legal_accepted_at)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', '+251911100003', 'ACTIVE', 'MEMBER', 'Yonas Demo', '1991-09-04', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', '+251911100004', 'ACTIVE', 'MEMBER', 'Kidus Demo', '1995-02-18', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', '+251911100005', 'ACTIVE', 'MEMBER', 'Nahom Demo', '1993-12-01', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', '+251911100006', 'ACTIVE', 'MEMBER', 'Samson Demo', '1990-06-27', 'MALE', 'en', 'v1-2026-08', NOW()),
  -- Extra women (+ existing bb01–bb03 from V20)
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', '+251911200004', 'ACTIVE', 'MEMBER', 'Mariam Demo', '1997-04-22', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', '+251911200005', 'ACTIVE', 'MEMBER', 'Betel Demo', '1994-08-09', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', '+251911200006', 'ACTIVE', 'MEMBER', 'Selam Demo', '1999-01-17', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', '+251911200007', 'ACTIVE', 'MEMBER', 'Helen Demo', '1996-10-03', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', '+251911200008', 'ACTIVE', 'MEMBER', 'Rahel Demo', '1993-03-28', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', '+251911200009', 'ACTIVE', 'MEMBER', 'Nardos Demo', '1998-07-11', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', '+251911200010', 'ACTIVE', 'MEMBER', 'Tigist Demo', '1995-12-19', 'FEMALE', 'en', 'v1-2026-08', NOW())
ON CONFLICT (phone_e164) DO UPDATE SET
  gender = EXCLUDED.gender,
  display_name = EXCLUDED.display_name,
  date_of_birth = EXCLUDED.date_of_birth,
  status = 'ACTIVE',
  legal_accepted_version = EXCLUDED.legal_accepted_version,
  legal_accepted_at = COALESCE(users.legal_accepted_at, NOW());

-- Profiles + 2–3 real portrait URLs each (HTTPS Unsplash CDN)
INSERT INTO member_profiles (
  user_id, bio_en, bio_am, city, interests, photo_urls,
  last_lat, last_lng, location_updated_at
)
SELECT u.id, v.bio_en, v.bio_am, v.city, v.interests::jsonb, v.photos::jsonb,
       v.lat, v.lng, NOW()
FROM (
  VALUES
    -- Men
    ('+251911100001',
     'Addis-based, loves jazz cafés and hiking Entoto.',
     'አዲስ አበባ — ጃዝና ተራራ',
     'Addis Ababa', '["Coffee","Music","Hiking"]',
     '["https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0350, 38.7500),
    ('+251911100002',
     'Engineer who hosts board-game nights and specialty coffee.',
     'ኢንጂነር — ቡናና ጨዋታ',
     'Addis Ababa', '["Coffee","Tech","Games"]',
     '["https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0220, 38.7460),
    ('+251911100003',
     'Architect. Slow Sundays, galleries, and long walks in Piazza.',
     'አርክቴክት — ጥበብና ጉዞ',
     'Addis Ababa', '["Art","Travel","Books"]',
     '["https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0405, 38.7615),
    ('+251911100004',
     'Chef experimenting with modern Ethiopian plates.',
     'ሼፍ — ዘመናዊ የኢትዮጵያ ምግብ',
     'Addis Ababa', '["Food","Music","Coffee"]',
     '["https://images.unsplash.com/photo-1463453091185-61582044d556?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1488161628813-04466f872be2?auto=format&fit=crop&w=800&h=1000&q=80"]',
     8.9950, 38.7890),
    ('+251911100005',
     'Product designer. Climbing walls mid-week, vinyl on weekends.',
     'ዲዛይነር — መውጣትና ሙዚቃ',
     'Bole', '["Fitness","Music","Design"]',
     '["https://images.unsplash.com/photo-1492288991661-058aa541ff43?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=800&h=1000&q=80"]',
     8.9880, 38.7895),
    ('+251911100006',
     'Finance by day, football and street photography by night.',
     'ፎቶግራፊ እና እግር ኳስ',
     'Addis Ababa', '["Fitness","Travel","Film"]',
     '["https://images.unsplash.com/photo-1504257432389-52343af06d0e?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1499996860823-5214fcc65f8f?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0100, 38.7700),
    -- Women
    ('+251911200001',
     'Designer. Weekend markets and tiramisu.',
     'ዲዛይነር — ገበያና ጣፋጭ',
     'Addis Ababa', '["Design","Food","Art"]',
     '["https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0285, 38.7525),
    ('+251911200002',
     'Reads Amharic poetry; quiet dinners preferred.',
     'ግጥም እና ጸጥ ያለ እራት',
     'Addis Ababa', '["Books","Art","Coffee"]',
     '["https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0180, 38.7410),
    ('+251911200003',
     'Runs mornings around Friendship Park.',
     'ሩጫ በጓደኝነት ፓርክ',
     'Addis Ababa', '["Fitness","Travel","Music"]',
     '["https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0450, 38.7350),
    ('+251911200004',
     'UX researcher who collects vinyl and good espresso.',
     'UX — ቪኒልና ኤስፕሬሶ',
     'Bole', '["Music","Coffee","Tech"]',
     '["https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?auto=format&fit=crop&w=800&h=1000&q=80"]',
     8.9945, 38.7870),
    ('+251911200005',
     'Lawyer. Sunday brunch, Amharic theatre, and city walks.',
     'ጠበቃ — ቲያትርና እግር ጉዞ',
     'Addis Ababa', '["Books","Art","Food"]',
     '["https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0320, 38.7630),
    ('+251911200006',
     'Medical resident. Soft playlists and highland weekends.',
     'ሐኪም — ሙዚቃና ተራራ',
     'Addis Ababa', '["Hiking","Music","Faith"]',
     '["https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0080, 38.7550),
    ('+251911200007',
     'Photographer documenting Addis street life.',
     'ፎቶግራፈር — የከተማ ሕይወት',
     'Piazza', '["Film","Travel","Art"]',
     '["https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1506863530036-1efeddceb993?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1525134479668-1bee5c7c6845?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0375, 38.7520),
    ('+251911200008',
     'Ballet teacher. Strong coffee, soft evenings.',
     'ባሌት — ቡናና ጸጥታ',
     'Addis Ababa', '["Dance","Coffee","Fitness"]',
     '["https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0155, 38.7485),
    ('+251911200009',
     'Startup ops. Farmers markets and late bookstore visits.',
     'ስታርትአፕ — ገበያና መጽሐፍት',
     'Kazanchis', '["Books","Food","Travel"]',
     '["https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0125, 38.7635),
    ('+251911200010',
     'Journalist. Conversations over kitfo and jazz.',
     'ጋዜጠኛ — ኪትፎና ጃዝ',
     'Addis Ababa', '["Music","Food","Books"]',
     '["https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&h=1000&q=80","https://images.unsplash.com/photo-1614283233556-f35b0c801304?auto=format&fit=crop&w=800&h=1000&q=80"]',
     9.0260, 38.7405)
) AS v(phone, bio_en, bio_am, city, interests, photos, lat, lng)
JOIN users u ON u.phone_e164 = v.phone
ON CONFLICT (user_id) DO UPDATE SET
  bio_en = EXCLUDED.bio_en,
  bio_am = EXCLUDED.bio_am,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  photo_urls = EXCLUDED.photo_urls,
  last_lat = EXCLUDED.last_lat,
  last_lng = EXCLUDED.last_lng,
  location_updated_at = NOW();

-- Preferences for men (browse women nearby)
INSERT INTO member_preferences (user_id, min_age, max_age, max_distance_km, cities)
SELECT u.id, 21, 40, 40, '["Addis Ababa","Bole","Piazza","Kazanchis"]'::jsonb
FROM users u
WHERE u.phone_e164 LIKE '+251911100%'
ON CONFLICT (user_id) DO UPDATE SET
  min_age = EXCLUDED.min_age,
  max_age = EXCLUDED.max_age,
  max_distance_km = EXCLUDED.max_distance_km,
  cities = EXCLUDED.cities,
  updated_at = NOW();

-- Soft prefs for women (used if they ever set filters)
INSERT INTO member_preferences (user_id, min_age, max_age, max_distance_km, cities)
SELECT u.id, 25, 45, 50, '[]'::jsonb
FROM users u
WHERE u.phone_e164 LIKE '+251911200%'
ON CONFLICT (user_id) DO NOTHING;

-- Elite for every demo member
INSERT INTO subscriptions (user_id, plan_id, status, starts_at, ends_at, matches_used)
SELECT u.id, p.id, 'ACTIVE', NOW() - INTERVAL '1 day', NOW() + INTERVAL '90 days', 0
FROM users u
CROSS JOIN subscription_plans p
WHERE (u.phone_e164 LIKE '+251911100%' OR u.phone_e164 LIKE '+251911200%')
  AND p.code = 'ELITE'
  AND NOT EXISTS (
    SELECT 1 FROM subscriptions s WHERE s.user_id = u.id AND s.status = 'ACTIVE' AND s.ends_at > NOW()
  );

-- Seed inbound likes so women have a "Likes you" queue
INSERT INTO member_likes (from_user_id, to_user_id, action)
SELECT m.id, w.id, 'LIKE'
FROM (VALUES
  ('+251911100001', '+251911200001'),
  ('+251911100001', '+251911200004'),
  ('+251911100001', '+251911200007'),
  ('+251911100002', '+251911200001'),
  ('+251911100002', '+251911200003'),
  ('+251911100002', '+251911200006'),
  ('+251911100003', '+251911200002'),
  ('+251911100003', '+251911200005'),
  ('+251911100003', '+251911200008'),
  ('+251911100004', '+251911200001'),
  ('+251911100004', '+251911200009'),
  ('+251911100005', '+251911200003'),
  ('+251911100005', '+251911200010'),
  ('+251911100006', '+251911200004'),
  ('+251911100006', '+251911200007')
) AS pairs(from_phone, to_phone)
JOIN users m ON m.phone_e164 = pairs.from_phone
JOIN users w ON w.phone_e164 = pairs.to_phone
ON CONFLICT (from_user_id, to_user_id) DO UPDATE SET action = 'LIKE';

-- One open concierge intro for Abel ↔ Selam (awaiting responses)
INSERT INTO match_proposals (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at
)
SELECT
  'cccccccc-cccc-cccc-cccc-cccccccccc01',
  (SELECT id FROM users WHERE phone_e164 = '+251911100001'),
  (SELECT id FROM users WHERE phone_e164 = '+251911200006'),
  'PROPOSED',
  'Both love highland weekends and quiet playlists — worth a coffee at a partner venue.',
  'ሁለቱም ተራራ እና ጸጥ ያለ ሙዚቃ ይወዳሉ — በአጋር ቦታ ቡና ይገባቸዋል።',
  NOW() + INTERVAL '7 days',
  'CONCIERGE',
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM match_proposals WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccc01'
);

-- Mutual discovery match Abel ↔ Sara for chat/booking tests
INSERT INTO match_proposals (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at, a_responded_at, b_responded_at, updated_at
)
SELECT
  'cccccccc-cccc-cccc-cccc-cccccccccc02',
  (SELECT id FROM users WHERE phone_e164 = '+251911100001'),
  (SELECT id FROM users WHERE phone_e164 = '+251911200001'),
  'MUTUAL',
  'You both said yes — plan a venue meeting when you are ready.',
  'ሁለታችሁም ተስማምታችኋል — ስብሰባ አቅዱ።',
  NOW() + INTERVAL '30 days',
  'DISCOVERY',
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '1 day',
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM match_proposals WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccc02'
);
