-- Local demo roster: wipe then reload on every API start (VELVET_SEED_RESET=true).
-- Invite: VELVET-SEED
-- Men:   +251911100001 … +251911100012
-- Women: +251911200001 … +251911200018

DELETE FROM moderation_events
WHERE user_id IN (
        SELECT id FROM users
        WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
           OR id::text LIKE 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa%'
           OR id::text LIKE 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb%'
    )
   OR message_id IN (
        SELECT m.id FROM messages m
        JOIN chat_threads t ON t.id = m.thread_id
        WHERE t.connection_id IN (
            SELECT id FROM connections
            WHERE member_a_id IN (
                    SELECT id FROM users
                    WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
                )
               OR member_b_id IN (
                    SELECT id FROM users
                    WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
                )
               OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
        )
   );

DELETE FROM messages
WHERE thread_id IN (
    SELECT id FROM chat_threads WHERE connection_id IN (
        SELECT id FROM connections
        WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
    )
);

DELETE FROM chat_threads WHERE connection_id IN (
    SELECT id FROM connections
    WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
);

DELETE FROM concierge_tasks WHERE match_id IN (
    SELECT id FROM connections
    WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
) OR booking_id IN (
    SELECT id FROM bookings WHERE connection_id IN (
        SELECT id FROM connections
        WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
    )
);

-- Booking payments and earnings reference bookings. Remove these dependants
-- before resetting the demo bookings, otherwise a restart can fail on a FK.
DELETE FROM payout_requests
WHERE user_id IN (
    SELECT id FROM users
    WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
)
OR ledger_entry_id IN (
    SELECT id FROM ledger_entries
    WHERE booking_id IN (
        SELECT id FROM bookings WHERE connection_id IN (
            SELECT id FROM connections
            WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
               OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
               OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
        )
    )
);

DELETE FROM ledger_entries
WHERE user_id IN (
    SELECT id FROM users
    WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
)
OR booking_id IN (
    SELECT id FROM bookings WHERE connection_id IN (
        SELECT id FROM connections
        WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
    )
);

DELETE FROM payment_intents
WHERE user_id IN (
    SELECT id FROM users
    WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
)
OR booking_id IN (
    SELECT id FROM bookings WHERE connection_id IN (
        SELECT id FROM connections
        WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
    )
);

DELETE FROM bookings WHERE connection_id IN (
    SELECT id FROM connections
    WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
       OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
);

DELETE FROM panic_alerts WHERE user_id IN (
    SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
) OR match_id IN (
    SELECT id FROM connections WHERE id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
);

DELETE FROM safety_reports WHERE reporter_id IN (
    SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
) OR reported_user_id IN (
    SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
);

DELETE FROM member_likes
WHERE from_user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
   OR to_user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');

DELETE FROM member_blocks
WHERE blocker_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
   OR blocked_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');

DELETE FROM member_notifications WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM device_tokens WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM refresh_tokens WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM devices WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM legal_acceptances WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM verification_cases WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM ledger_entries WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM subscriptions WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM payment_intents WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM staff_shifts WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM waitlist_applications WHERE phone_e164 LIKE '+251911300%';

DELETE FROM connections
WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
   OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
   OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%';

DELETE FROM member_preferences WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM availability_windows WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM payout_requests WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM member_profiles WHERE user_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%');
DELETE FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
   OR id::text LIKE 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa%'
   OR id::text LIKE 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb%';

-- Ensure invite stays usable
INSERT INTO invites (code, max_uses, use_count, active)
VALUES ('VELVET-SEED', 10000, 0, TRUE)
ON CONFLICT (code) DO UPDATE SET max_uses = 10000, active = TRUE;

INSERT INTO users (id, phone_e164, status, role, display_name, date_of_birth, gender, preferred_locale, legal_accepted_version, legal_accepted_at)
VALUES
  -- Men (12)
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', '+251911100001', 'ACTIVE', 'CLIENT', 'Abel',   '1994-03-12', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', '+251911100002', 'ACTIVE', 'CLIENT', 'Dawit',  '1992-07-21', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', '+251911100003', 'ACTIVE', 'CLIENT', 'Yonas',  '1991-09-04', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', '+251911100004', 'ACTIVE', 'CLIENT', 'Kidus',  '1995-02-18', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', '+251911100005', 'ACTIVE', 'CLIENT', 'Nahom',  '1993-12-01', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', '+251911100006', 'ACTIVE', 'CLIENT', 'Samson', '1990-06-27', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07', '+251911100007', 'ACTIVE', 'CLIENT', 'Biruk',  '1996-04-09', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', '+251911100008', 'ACTIVE', 'CLIENT', 'Elias',  '1989-11-15', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', '+251911100009', 'ACTIVE', 'CLIENT', 'Henok',  '1997-08-22', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa0a', '+251911100010', 'ACTIVE', 'CLIENT', 'Michael','1993-01-30', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa0b', '+251911100011', 'ACTIVE', 'CLIENT', 'Robel',  '1994-10-05', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa0c', '+251911100012', 'ACTIVE', 'CLIENT', 'Tedros', '1992-05-19', 'MALE', 'en', 'v1-2026-08', NOW()),
  -- Women (18)
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', '+251911200001', 'VERIFIED', 'PERFORMER', 'Sara',   '1996-01-08', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', '+251911200002', 'VERIFIED', 'PERFORMER', 'Hanna',  '1995-11-30', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', '+251911200003', 'VERIFIED', 'PERFORMER', 'Liya',   '1998-05-14', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', '+251911200004', 'VERIFIED', 'PERFORMER', 'Mariam', '1997-04-22', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', '+251911200005', 'VERIFIED', 'PERFORMER', 'Betel',  '1994-08-09', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', '+251911200006', 'VERIFIED', 'PERFORMER', 'Selam',  '1999-01-17', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', '+251911200007', 'VERIFIED', 'PERFORMER', 'Helen',  '1996-10-03', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', '+251911200008', 'VERIFIED', 'PERFORMER', 'Rahel',  '1993-03-28', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', '+251911200009', 'VERIFIED', 'PERFORMER', 'Nardos', '1998-07-11', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', '+251911200010', 'VERIFIED', 'PERFORMER', 'Tigist', '1995-12-19', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', '+251911200011', 'VERIFIED', 'PERFORMER', 'Meron',  '1997-02-26', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', '+251911200012', 'VERIFIED', 'PERFORMER', 'Saron',  '1994-09-13', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', '+251911200013', 'VERIFIED', 'PERFORMER', 'Hiwot',  '1996-06-07', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', '+251911200014', 'VERIFIED', 'PERFORMER', 'Eden',   '1998-12-02', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', '+251911200015', 'VERIFIED', 'PERFORMER', 'Bezawit','1995-03-21', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', '+251911200016', 'VERIFIED', 'PERFORMER', 'Kidist', '1999-08-18', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', '+251911200017', 'VERIFIED', 'PERFORMER', 'Mekdes', '1993-07-29', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', '+251911200018', 'VERIFIED', 'PERFORMER', 'Yordanos','1997-11-04', 'FEMALE', 'am', 'v1-2026-08', NOW());

INSERT INTO member_profiles (
  user_id, bio_en, bio_am, city, interests, photo_urls, last_lat, last_lng, location_updated_at
)
SELECT u.id, v.bio_en, v.bio_am, v.city, v.interests::jsonb, v.photos::jsonb, v.lat, v.lng, NOW()
FROM (
  VALUES
    ('+251911100001', 'Addis-based, loves jazz cafés and hiking Entoto.', 'ጃዝና ተራራ', 'Addis Ababa', '["Coffee","Music","Hiking"]',
     '["https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0350, 38.7500),
    ('+251911100002', 'Engineer who hosts board-game nights and specialty coffee.', 'ቡናና ጨዋታ', 'Addis Ababa', '["Coffee","Tech","Games"]',
     '["https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0220, 38.7460),
    ('+251911100003', 'Architect. Slow Sundays, galleries, Piazza walks.', 'ጥበብና ጉዞ', 'Addis Ababa', '["Art","Travel","Books"]',
     '["https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0405, 38.7615),
    ('+251911100004', 'Chef experimenting with modern Ethiopian plates.', 'ዘመናዊ ምግብ', 'Addis Ababa', '["Food","Music","Coffee"]',
     '["https://images.unsplash.com/photo-1463453091185-61582044d556?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1488161628813-04466f872be2?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9950, 38.7890),
    ('+251911100005', 'Product designer. Climbing walls and vinyl weekends.', 'መውጣትና ሙዚቃ', 'Bole', '["Fitness","Music","Design"]',
     '["https://images.unsplash.com/photo-1492288991661-058aa541ff43?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9880, 38.7895),
    ('+251911100006', 'Finance by day, football and street photography by night.', 'ፎቶና እግር ኳስ', 'Addis Ababa', '["Fitness","Travel","Film"]',
     '["https://images.unsplash.com/photo-1504257432389-52343af06d0e?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1499996860823-5214fcc65f8f?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0100, 38.7700),
    ('+251911100007', 'Pilot. Soft landings and long dinners in Kazanchis.', 'አብራሪ — እራት', 'Kazanchis', '["Travel","Food","Music"]',
     '["https://images.unsplash.com/photo-1507591064344-4c6ce005b128?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1528892952291-009c663ce843?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0140, 38.7650),
    ('+251911100008', 'University lecturer. Debate clubs and rain-season walks.', 'መምህር', 'Addis Ababa', '["Books","Coffee","Art"]',
     '["https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1552058544-f2b08422138a?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0300, 38.7480),
    ('+251911100009', 'Startup founder. Early gym, late sketching.', 'ስታርትአፕ', 'Bole', '["Fitness","Tech","Design"]',
     '["https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9920, 38.7910),
    ('+251911100010', 'Hotelier. Courtyard coffee and live jazz guests.', 'ሆቴል', 'Piazza', '["Music","Food","Travel"]',
     '["https://images.unsplash.com/photo-1501196354226-91d2556a841c?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0380, 38.7525),
    ('+251911100011', 'Civil engineer. Weekend trail runs above Entoto.', 'ሩጫ', 'Addis Ababa', '["Hiking","Fitness","Coffee"]',
     '["https://images.unsplash.com/photo-1496345875659-59f3d2e4f2d5?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1545167622-3a6ac756afa4?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0480, 38.7400),
    ('+251911100012', 'Documentary editor. Markets, lenses, quiet editing nights.', 'ፊልም', 'Addis Ababa', '["Film","Art","Travel"]',
     '["https://images.unsplash.com/photo-1480455624313-e29b44bbfde1?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1508341591423-641dc9d68e63?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0190, 38.7580),

    ('+251911200001', 'Designer with an eye for beautiful details, slow conversation, and a night that unfolds naturally.', 'ዲዛይነር', 'Addis Ababa', '["Design","Food","Art"]',
     '["https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0285, 38.7525),
    ('+251911200002', 'Amharic poetry, candlelit dinners, and the kind of quiet that makes every glance feel louder.', 'ግጥም', 'Addis Ababa', '["Books","Art","Coffee"]',
     '["https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0180, 38.7410),
    ('+251911200003', 'Bright energy, a runner''s confidence, and a weakness for music that makes a room feel closer.', 'ሩጫ', 'Addis Ababa', '["Fitness","Travel","Music"]',
     '["https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0450, 38.7350),
    ('+251911200004', 'Vinyl, espresso, and an easy smile. I like a little tension before the first song ends.', 'UX', 'Bole', '["Music","Coffee","Tech"]',
     '["https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9945, 38.7870),
    ('+251911200005', 'Sharp mind, warm presence, and a taste for theatre, good wine, and unhurried attention.', 'ጠበቃ', 'Addis Ababa', '["Books","Art","Food"]',
     '["https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0320, 38.7630),
    ('+251911200006', 'Soft playlists, warm conversation, and a calm confidence that makes late nights feel effortless.', 'ሐኪም', 'Addis Ababa', '["Hiking","Music","Faith"]',
     '["https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0080, 38.7550),
    ('+251911200007', 'Photographer with a cinematic eye. I notice the small looks, charged pauses, and the mood in a room.', 'ፎቶ', 'Piazza', '["Film","Travel","Art"]',
     '["https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1506863530036-1efeddceb993?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0375, 38.7520),
    ('+251911200008', 'Ballet teacher: poised, playful, and drawn to strong coffee, soft music, and a little anticipation.', 'ባሌት', 'Addis Ababa', '["Dance","Coffee","Fitness"]',
     '["https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0155, 38.7485),
    ('+251911200009', 'Quick wit, delicious tension, and a love for markets, bookstores, and a slow build.', 'ስታርትአፕ', 'Kazanchis', '["Books","Food","Travel"]',
     '["https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0125, 38.7635),
    ('+251911200010', 'Journalist who loves jazz, kitfo, and the kind of conversation that makes you forget to check the time.', 'ጋዜጠኛ', 'Addis Ababa', '["Music","Food","Books"]',
     '["https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1614283233556-f35b0c801304?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0260, 38.7405),
    ('+251911200011', 'Florist with a soft spot for fragrance, lingering eye contact, and evenings that stay memorable.', 'አበባ', 'Addis Ababa', '["Art","Food","Coffee"]',
     '["https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1524638431109-93d95c968f66?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0210, 38.7510),
    ('+251911200012', 'Architect who appreciates a beautiful setting, a slow build, and someone who knows how to hold a conversation.', 'አርክቴክት', 'Bole', '["Art","Design","Travel"]',
     '["https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9960, 38.7850),
    ('+251911200013', 'Gentle after a long shift, but never dull. Soft playlists, warmth, and a night with real ease.', 'ነርስ', 'Addis Ababa', '["Music","Faith","Coffee"]',
     '["https://images.unsplash.com/photo-1546961329-78bef0414d7e?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0330, 38.7440),
    ('+251911200014', 'Pastry chef with a taste for sweetness, playful banter, and a night that feels like an indulgence.', 'ፓስትሪ', 'Bole', '["Food","Coffee","Art"]',
     '["https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&h=1600&q=85"]', 8.9900, 38.7920),
    ('+251911200015', 'Thoughtful, curious, and quietly magnetic. Long reads, lake weekends, and intimate conversation after dark.', 'ምርምር', 'Addis Ababa', '["Books","Travel","Hiking"]',
     '["https://images.unsplash.com/photo-1506863530036-1efeddceb993?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0410, 38.7360),
    ('+251911200016', 'Yoga instructor with a grounded presence, a teasing smile, and music that slows the whole room down.', 'ዮጋ', 'Addis Ababa', '["Fitness","Faith","Music"]',
     '["https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0460, 38.7380),
    ('+251911200017', 'Radio producer who knows the power of a low voice, a great playlist, and an evening with nowhere else to be.', 'ሬዲዮ', 'Piazza', '["Music","Film","Food"]',
     '["https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0360, 38.7540),
    ('+251911200018', 'Translator with a love for beautiful language, rainy cafés, and the delicious possibility in a first meeting.', 'ተርጓሚ', 'Addis Ababa', '["Books","Coffee","Art"]',
     '["https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=1200&h=1600&q=85","https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=1200&h=1600&q=85"]', 9.0240, 38.7470)
) AS v(phone, bio_en, bio_am, city, interests, photos, lat, lng)
JOIN users u ON u.phone_e164 = v.phone;

INSERT INTO member_preferences (user_id, min_age, max_age, max_distance_km, cities)
SELECT u.id, 21, 42, 45, '["Addis Ababa","Bole","Piazza","Kazanchis"]'::jsonb
FROM users u WHERE u.phone_e164 LIKE '+251911100%';

INSERT INTO member_preferences (user_id, min_age, max_age, max_distance_km, cities)
SELECT u.id, 24, 48, 55, '[]'::jsonb
FROM users u WHERE u.phone_e164 LIKE '+251911200%';

INSERT INTO subscriptions (user_id, plan_id, status, starts_at, ends_at, connections_used)
SELECT u.id, p.id, 'ACTIVE', NOW() - INTERVAL '1 day', NOW() + INTERVAL '120 days', 0
FROM users u
CROSS JOIN subscription_plans p
WHERE (u.phone_e164 LIKE '+251911100%' OR u.phone_e164 LIKE '+251911200%')
  AND p.code = 'ELITE';

-- Inbound likes for women (Likes you queues)
INSERT INTO member_likes (from_user_id, to_user_id, action)
SELECT m.id, w.id, 'LIKE'
FROM (VALUES
  ('+251911100001', '+251911200001'),
  ('+251911100001', '+251911200004'),
  ('+251911100001', '+251911200007'),
  ('+251911100001', '+251911200011'),
  ('+251911100001', '+251911200015'),
  ('+251911100002', '+251911200001'),
  ('+251911100002', '+251911200003'),
  ('+251911100002', '+251911200006'),
  ('+251911100002', '+251911200012'),
  ('+251911100002', '+251911200018'),
  ('+251911100003', '+251911200002'),
  ('+251911100003', '+251911200005'),
  ('+251911100003', '+251911200008'),
  ('+251911100003', '+251911200013'),
  ('+251911100004', '+251911200001'),
  ('+251911100004', '+251911200009'),
  ('+251911100004', '+251911200014'),
  ('+251911100004', '+251911200016'),
  ('+251911100005', '+251911200003'),
  ('+251911100005', '+251911200010'),
  ('+251911100005', '+251911200017'),
  ('+251911100006', '+251911200004'),
  ('+251911100006', '+251911200007'),
  ('+251911100006', '+251911200011'),
  ('+251911100007', '+251911200002'),
  ('+251911100007', '+251911200008'),
  ('+251911100007', '+251911200015'),
  ('+251911100008', '+251911200005'),
  ('+251911100008', '+251911200012'),
  ('+251911100008', '+251911200018'),
  ('+251911100009', '+251911200006'),
  ('+251911100009', '+251911200009'),
  ('+251911100009', '+251911200013'),
  ('+251911100010', '+251911200001'),
  ('+251911100010', '+251911200010'),
  ('+251911100010', '+251911200014'),
  ('+251911100011', '+251911200003'),
  ('+251911100011', '+251911200016'),
  ('+251911100012', '+251911200007'),
  ('+251911100012', '+251911200017')
) AS pairs(from_phone, to_phone)
JOIN users m ON m.phone_e164 = pairs.from_phone
JOIN users w ON w.phone_e164 = pairs.to_phone;

-- Concierge intros (open)
INSERT INTO connections (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at
) VALUES
(
  'cccccccc-cccc-cccc-cccc-cccccccccc01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06',
  'PROPOSED',
  'Both love highland weekends and quiet playlists — coffee at a partner venue.',
  'ሁለቱም ተራራ እና ጸጥ ያለ ሙዚቃ ይወዳሉ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc03',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12',
  'PROPOSED',
  'Two designers with gallery habits — worth an intro.',
  'ሁለት ዲዛይነሮች — መግቢያ ይገባቸዋል።',
  NOW() + INTERVAL '7 days', 'CONCIERGE', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc04',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14',
  'PROPOSED',
  'Travel stories and pastry — a sweet venue meet.',
  'ጉዞ እና ፓስትሪ — ጣፋጭ ስብሰባ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE', NOW()
);

-- Mutual matches for chat/booking tests
INSERT INTO connections (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at, a_responded_at, b_responded_at, updated_at
) VALUES
(
  'cccccccc-cccc-cccc-cccc-cccccccccc02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'MUTUAL',
  'You both said yes — plan a venue meeting when ready.',
  'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc05',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04',
  'MUTUAL',
  'Board games and vinyl — schedule a public venue.',
  'ጨዋታና ቪኒል — ቦታ አቅዱ።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc06',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'MUTUAL',
  'Climbing walls and cameras — a good match.',
  'መውጣትና ካሜራ — ጥሩ ግንኙነት።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
);

-- Marketplace demo: verified performer rates + availability windows
UPDATE member_profiles SET
    session_rate_etb = 3500 + ((ABS(HASHTEXT(user_id::text)) % 8) * 500),
    overnight_rate_etb = 12000 + ((ABS(HASHTEXT(user_id::text)) % 6) * 1500),
    availability_note = 'See calendar for open windows',
    listing_active = TRUE
WHERE user_id IN (SELECT id FROM users WHERE gender = 'FEMALE' AND phone_e164 LIKE '+251911200%');

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '18 hours',
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '23 hours',
       'Evening session'
FROM users u
CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%';

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '20 hours',
       date_trunc('hour', NOW()) + ((d.day + 1) * INTERVAL '1 day') + INTERVAL '8 hours',
       'Overnight'
FROM users u
CROSS JOIN (VALUES (1),(3),(5)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%';

-- ── Extended scenarios: chat, bookings, billing, inbox, history ─────────────

-- One performer awaiting verification review (discover listing inactive until approved)
UPDATE users SET status = 'ACTIVE'
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18';

UPDATE member_profiles SET listing_active = FALSE
WHERE user_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18';

INSERT INTO verification_cases (id, user_id, status, id_document_url, selfie_url, notes, created_at, updated_at)
VALUES (
  '99999999-9999-9999-9999-999999999901',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18',
  'SUBMITTED',
  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=800&q=85',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=85',
  'Demo queue — Yordanos pending ID review',
  NOW() - INTERVAL '6 hours',
  NOW() - INTERVAL '6 hours'
);

INSERT INTO verification_cases (id, user_id, status, id_document_url, selfie_url, reviewed_at, created_at, updated_at)
VALUES (
  '99999999-9999-9999-9999-999999999902',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'APPROVED',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=85',
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=85',
  NOW() - INTERVAL '30 days',
  NOW() - INTERVAL '31 days',
  NOW() - INTERVAL '30 days'
);

INSERT INTO legal_acceptances (user_id, document_set_version, accepted_at, source)
SELECT id, 'v1-2026-08', NOW() - INTERVAL '2 days', 'APP'
FROM users
WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
ON CONFLICT (user_id, document_set_version) DO NOTHING;

-- Closed connections for history screens
INSERT INTO connections (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at, a_responded_at, updated_at
) VALUES
(
  'cccccccc-cccc-cccc-cccc-cccccccccc07',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03',
  'DECLINED',
  'Shared love of running — optional intro.',
  'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc08',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09',
  'EXPIRED',
  'Startup founder meets market explorer.',
  'ስታርትአፕ እና ገበያ።',
  NOW() - INTERVAL '2 days', 'DISCOVERY',
  NOW() - INTERVAL '14 days', NULL, NOW() - INTERVAL '2 days'
);

-- Chat threads for mutual connections
INSERT INTO chat_threads (
  id, connection_id, member_a_id, member_b_id, status,
  a_last_read_at, b_last_read_at, created_at
) VALUES
(
  'dddddddd-dddd-dddd-dddd-dddddddddd01',
  'cccccccc-cccc-cccc-cccc-cccccccccc02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'OPEN',
  NOW() - INTERVAL '20 hours',
  NOW() - INTERVAL '45 minutes',
  NOW() - INTERVAL '2 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd02',
  'cccccccc-cccc-cccc-cccc-cccccccccc05',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04',
  'OPEN',
  NOW() - INTERVAL '3 hours',
  NOW() - INTERVAL '6 hours',
  NOW() - INTERVAL '3 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd03',
  'cccccccc-cccc-cccc-cccc-cccccccccc06',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'OPEN',
  NOW() - INTERVAL '4 days',
  NOW() - INTERVAL '4 days',
  NOW() - INTERVAL '8 days'
);

INSERT INTO messages (id, thread_id, sender_id, body, moderation_status, created_at)
VALUES
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01',
  'dddddddd-dddd-dddd-dddd-dddddddddd01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'Hi Sara — your design portfolio caught my eye.',
  'ALLOWED', NOW() - INTERVAL '2 days'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee02',
  'dddddddd-dddd-dddd-dddd-dddddddddd01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'Thank you Abel! Slow coffee or a gallery walk first?',
  'ALLOWED', NOW() - INTERVAL '36 hours'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee03',
  'dddddddd-dddd-dddd-dddd-dddddddddd01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'Saturday evening works — I will send a booking request.',
  'ALLOWED', NOW() - INTERVAL '20 hours'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee04',
  'dddddddd-dddd-dddd-dddd-dddddddddd01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'Perfect. I have an open window — send it when ready.',
  'ALLOWED', NOW() - INTERVAL '30 minutes'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee05',
  'dddddddd-dddd-dddd-dddd-dddddddddd02',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04',
  'Your board-game suggestion made me smile.',
  'ALLOWED', NOW() - INTERVAL '2 days'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee06',
  'dddddddd-dddd-dddd-dddd-dddddddddd02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  'Let us confirm Tomoca and a late session.',
  'ALLOWED', NOW() - INTERVAL '3 hours'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee07',
  'dddddddd-dddd-dddd-dddd-dddddddddd03',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
  'Thanks again for a great evening in Bole.',
  'ALLOWED', NOW() - INTERVAL '4 days'
),
(
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee08',
  'dddddddd-dddd-dddd-dddd-dddddddddd03',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'Likewise — checkout is complete on my side.',
  'ALLOWED', NOW() - INTERVAL '4 days'
);

-- Bookings across propose → pay → complete
INSERT INTO bookings (
  id, connection_id, venue_id, meetup_place, rate_type, amount_etb, payment_status,
  proposed_by, status, starts_at, notes, confirmed_at, checked_in_at, checked_out_at,
  performer_checked_out_at, client_checked_out_at, created_at, updated_at
) VALUES
(
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
  'cccccccc-cccc-cccc-cccc-cccccccccc02',
  NULL,
  'Kazanchis — private residence (discreet)',
  'SESSION', 4000, 'UNPAID',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'PROPOSED',
  date_trunc('hour', NOW()) + INTERVAL '3 days' + INTERVAL '19 hours',
  'Saturday session — Abel to confirm',
  NULL, NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '18 hours', NOW() - INTERVAL '18 hours'
),
(
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002',
  'cccccccc-cccc-cccc-cccc-cccccccccc05',
  (SELECT id FROM venues WHERE name ILIKE '%Tomoca%' LIMIT 1),
  NULL,
  'SESSION', 5500, 'PENDING',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '20 hours',
  'Tomoca quiet table — Dawit pays on confirm',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'
),
(
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  'cccccccc-cccc-cccc-cccc-cccccccccc06',
  NULL,
  'Bole — discreet suite',
  'SESSION', 6000, 'PAID',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
  'COMPLETED',
  date_trunc('hour', NOW()) - INTERVAL '5 days' + INTERVAL '20 hours',
  'Completed demo session for earnings',
  NOW() - INTERVAL '6 days',
  NOW() - INTERVAL '5 days' + INTERVAL '20 hours',
  NOW() - INTERVAL '5 days' + INTERVAL '23 hours',
  NOW() - INTERVAL '5 days' + INTERVAL '23 hours',
  NOW() - INTERVAL '5 days' + INTERVAL '23 hours',
  NOW() - INTERVAL '7 days', NOW() - INTERVAL '5 days'
);

INSERT INTO payment_intents (
  id, user_id, plan_id, purpose, booking_id, provider, merchant_order_id,
  amount_etb, currency, status, checkout_url, provider_ref, created_at, updated_at, paid_at
) VALUES
(
  'ffffffff-ffff-ffff-ffff-ffffffffff01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  NULL, 'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002',
  'CBE', 'DEMO-BOOK-002',
  5500.00, 'ETB', 'CHECKOUT',
  'https://example.local/cbe/demo-book-002',
  NULL,
  NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NULL
),
(
  'ffffffff-ffff-ffff-ffff-ffffffffff02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
  NULL, 'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  'CBE', 'DEMO-BOOK-003',
  6000.00, 'ETB', 'PAID',
  NULL, 'FT-DEMO-003CBE',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'
);

UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-ffff-ffff-ffffffffff01'
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002';

UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-ffff-ffff-ffffffffff02'
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003';

INSERT INTO ledger_entries (
  id, user_id, payment_intent_id, booking_id, entry_type, amount_etb, currency, description, created_at
) VALUES
(
  'llllllll-llll-llll-llll-llllllllll01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'ffffffff-ffff-ffff-ffff-ffffffffff02',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  'PERFORMER_CREDIT', 5100.00, 'ETB',
  'Booking credit (85% of 6000 ETB)',
  NOW() - INTERVAL '5 days'
),
(
  'llllllll-llll-llll-llll-llllllllll02',
  NULL,
  'ffffffff-ffff-ffff-ffff-ffffffffff02',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  'PLATFORM_FEE', 900.00, 'ETB',
  'Platform fee 15% booking bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  NOW() - INTERVAL '5 days'
);

INSERT INTO payout_requests (id, user_id, amount_etb, status, destination_note, ledger_entry_id, created_at, updated_at)
VALUES (
  'pppppppp-pppp-pppp-pppp-pppppppppp01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  3000.00, 'REQUESTED',
  'CBE •••• 4821 — Helen demo payout',
  'llllllll-llll-llll-llll-llllllllll01',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'
);

INSERT INTO concierge_tasks (id, booking_id, match_id, task_type, due_at, status, notes, created_at, updated_at)
VALUES (
  'tttttttt-tttt-tttt-tttt-tttttttttt01',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002',
  'cccccccc-cccc-cccc-cccc-cccccccccc05',
  'PRE_CALL',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '18 hours',
  'OPEN',
  'Confirm Dawit + Mariam arrival at Tomoca',
  NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'
);

INSERT INTO member_notifications (id, user_id, subject, body, related_type, related_id, read_at, created_at)
VALUES
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'Sara replied',
  'Perfect. I have an open window — send it when ready.',
  'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc02',
  NULL, NOW() - INTERVAL '25 minutes'
),
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'Booking proposed',
  'Your session request with Sara is awaiting confirmation.',
  'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
  NOW() - INTERVAL '12 hours', NOW() - INTERVAL '18 hours'
),
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn03',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01',
  'Session reminder',
  'Your booking with Sara starts in 3 days.',
  'BOOKING_REMINDER', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
  NULL, NOW() - INTERVAL '2 hours'
),
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn04',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
  'Complete payment',
  'Your Tomoca session with Mariam is confirmed — payment is due.',
  'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002',
  NULL, NOW() - INTERVAL '1 day'
),
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn05',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'New booking request',
  'Abel proposed a Saturday session.',
  'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
  NULL, NOW() - INTERVAL '18 hours'
),
(
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn06',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'Earnings credited',
  '5100 ETB from your completed session with Nahom.',
  'BOOKING', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'
);

INSERT INTO member_blocks (id, blocker_id, blocked_id, reason, created_at)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb901',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa0b',
  'Demo block — Robel',
  NOW() - INTERVAL '3 days'
);

INSERT INTO waitlist_applications (id, phone_e164, display_name, city, note, status, invite_code, created_at)
VALUES
(
  'wwwwwwww-wwww-wwww-wwww-wwwwwwwwww01',
  '+251911300001', 'Mimi Tadesse', 'Addis Ababa',
  'Referred by a friend — interested in curated intros.',
  'PENDING', NULL, NOW() - INTERVAL '2 days'
),
(
  'wwwwwwww-wwww-wwww-wwww-wwwwwwwwww02',
  '+251911300002', 'Daniel Kebede', 'Bole',
  'Founder looking for discreet membership.',
  'APPROVED', 'VELVET-DAN01', NOW() - INTERVAL '5 days'
),
(
  'wwwwwwww-wwww-wwww-wwww-wwwwwwwwww03',
  '+251911300003', 'Ruth Haile', 'Piazza',
  'Not a fit for current cohort.',
  'REJECTED', NULL, NOW() - INTERVAL '8 days'
);
