-- Local demo roster: wipe then reload on every API start (VELVET_SEED_RESET=true).
-- Invite: VELVET-SEED
-- Clients:    +251911100001 … +251911100024
-- Performers: +251911200001 … +251911200060
-- Abel (+251911100001) has packed inbox, intros, bookings, history, passes, browse.
-- Login: invite VELVET-SEED, then OTP from API logs.

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

DELETE FROM meeting_feedback WHERE booking_id IN (
    SELECT id FROM bookings WHERE connection_id IN (
        SELECT id FROM connections
        WHERE member_a_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR member_b_id IN (SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%')
           OR id::text LIKE 'cccccccc-cccc-cccc-cccc-cccccccc%'
    )
);

DELETE FROM trip_shares WHERE user_id IN (
    SELECT id FROM users WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
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

INSERT INTO invites (code, max_uses, use_count, active)
VALUES ('VELVET-SEED', 10000, 0, TRUE)
ON CONFLICT (code) DO UPDATE SET max_uses = 10000, active = TRUE;

INSERT INTO users (id, phone_e164, status, role, display_name, date_of_birth, gender, preferred_locale, legal_accepted_version, legal_accepted_at)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', '+251911100001', 'ACTIVE', 'CLIENT', 'Abel', '1989-04-06', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', '+251911100002', 'ACTIVE', 'CLIENT', 'Dawit', '1990-07-11', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', '+251911100003', 'ACTIVE', 'CLIENT', 'Yonas', '1991-10-16', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', '+251911100004', 'ACTIVE', 'CLIENT', 'Kidus', '1992-01-21', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', '+251911100005', 'ACTIVE', 'CLIENT', 'Nahom', '1993-04-26', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', '+251911100006', 'ACTIVE', 'CLIENT', 'Samson', '1994-07-04', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07', '+251911100007', 'ACTIVE', 'CLIENT', 'Biruk', '1995-10-09', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', '+251911100008', 'ACTIVE', 'CLIENT', 'Elias', '1996-01-14', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', '+251911100009', 'ACTIVE', 'CLIENT', 'Henok', '1997-04-19', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', '+251911100010', 'ACTIVE', 'CLIENT', 'Michael', '1988-07-24', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', '+251911100011', 'ACTIVE', 'CLIENT', 'Robel', '1989-10-02', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', '+251911100012', 'ACTIVE', 'CLIENT', 'Tedros', '1990-01-07', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', '+251911100013', 'ACTIVE', 'CLIENT', 'Aman', '1991-04-12', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa14', '+251911100014', 'ACTIVE', 'CLIENT', 'Fasil', '1992-07-17', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', '+251911100015', 'ACTIVE', 'CLIENT', 'Haile', '1993-10-22', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16', '+251911100016', 'ACTIVE', 'CLIENT', 'Iyasu', '1994-01-27', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17', '+251911100017', 'ACTIVE', 'CLIENT', 'Jemal', '1995-04-05', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18', '+251911100018', 'ACTIVE', 'CLIENT', 'Kaleb', '1996-07-10', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19', '+251911100019', 'ACTIVE', 'CLIENT', 'Lemma', '1997-10-15', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20', '+251911100020', 'ACTIVE', 'CLIENT', 'Mulugeta', '1988-01-20', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21', '+251911100021', 'ACTIVE', 'CLIENT', 'Nati', '1989-04-25', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22', '+251911100022', 'ACTIVE', 'CLIENT', 'Omar', '1990-07-03', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23', '+251911100023', 'ACTIVE', 'CLIENT', 'Paulos', '1991-10-08', 'MALE', 'en', 'v1-2026-08', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24', '+251911100024', 'ACTIVE', 'CLIENT', 'Yared', '1992-01-13', 'MALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', '+251911200001', 'VERIFIED', 'PERFORMER', 'Sara', '1994-03-08', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', '+251911200002', 'VERIFIED', 'PERFORMER', 'Hanna', '1995-05-15', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', '+251911200003', 'VERIFIED', 'PERFORMER', 'Liya', '1996-07-22', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', '+251911200004', 'VERIFIED', 'PERFORMER', 'Mariam', '1997-09-02', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', '+251911200005', 'VERIFIED', 'PERFORMER', 'Betel', '1998-11-09', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', '+251911200006', 'VERIFIED', 'PERFORMER', 'Selam', '1999-01-16', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', '+251911200007', 'VERIFIED', 'PERFORMER', 'Helen', '2000-03-23', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', '+251911200008', 'VERIFIED', 'PERFORMER', 'Rahel', '1993-05-03', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', '+251911200009', 'VERIFIED', 'PERFORMER', 'Nardos', '1994-07-10', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', '+251911200010', 'VERIFIED', 'PERFORMER', 'Tigist', '1995-09-17', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', '+251911200011', 'VERIFIED', 'PERFORMER', 'Meron', '1996-11-24', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', '+251911200012', 'VERIFIED', 'PERFORMER', 'Saron', '1997-01-04', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', '+251911200013', 'VERIFIED', 'PERFORMER', 'Hiwot', '1998-03-11', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', '+251911200014', 'VERIFIED', 'PERFORMER', 'Eden', '1999-05-18', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', '+251911200015', 'VERIFIED', 'PERFORMER', 'Bezawit', '2000-07-25', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', '+251911200016', 'VERIFIED', 'PERFORMER', 'Kidist', '1993-09-05', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', '+251911200017', 'VERIFIED', 'PERFORMER', 'Mekdes', '1994-11-12', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', '+251911200018', 'VERIFIED', 'PERFORMER', 'Yordanos', '1995-01-19', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19', '+251911200019', 'VERIFIED', 'PERFORMER', 'Aster', '1996-03-26', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20', '+251911200020', 'VERIFIED', 'PERFORMER', 'Blen', '1997-05-06', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21', '+251911200021', 'VERIFIED', 'PERFORMER', 'Chaltu', '1998-07-13', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22', '+251911200022', 'VERIFIED', 'PERFORMER', 'Dagmawit', '1999-09-20', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23', '+251911200023', 'VERIFIED', 'PERFORMER', 'Eyerusalem', '2000-11-27', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24', '+251911200024', 'VERIFIED', 'PERFORMER', 'Fikirte', '1993-01-07', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25', '+251911200025', 'VERIFIED', 'PERFORMER', 'Genet', '1994-03-14', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26', '+251911200026', 'VERIFIED', 'PERFORMER', 'Imani', '1995-05-21', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27', '+251911200027', 'VERIFIED', 'PERFORMER', 'Kalkidan', '1996-07-01', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28', '+251911200028', 'VERIFIED', 'PERFORMER', 'Lulit', '1997-09-08', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29', '+251911200029', 'VERIFIED', 'PERFORMER', 'Mahlet', '1998-11-15', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30', '+251911200030', 'VERIFIED', 'PERFORMER', 'Naomi', '1999-01-22', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31', '+251911200031', 'VERIFIED', 'PERFORMER', 'Rediet', '2000-03-02', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32', '+251911200032', 'VERIFIED', 'PERFORMER', 'Semhal', '1993-05-09', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33', '+251911200033', 'VERIFIED', 'PERFORMER', 'Tsion', '1994-07-16', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34', '+251911200034', 'VERIFIED', 'PERFORMER', 'Winta', '1995-09-23', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35', '+251911200035', 'VERIFIED', 'PERFORMER', 'Zewditu', '1996-11-03', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36', '+251911200036', 'VERIFIED', 'PERFORMER', 'Soliyana', '1997-01-10', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37', '+251911200037', 'VERIFIED', 'PERFORMER', 'Elsa', '1998-03-17', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38', '+251911200038', 'VERIFIED', 'PERFORMER', 'Frehiwot', '1999-05-24', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39', '+251911200039', 'VERIFIED', 'PERFORMER', 'Gelila', '2000-07-04', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', '+251911200040', 'VERIFIED', 'PERFORMER', 'Hana', '1993-09-11', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41', '+251911200041', 'VERIFIED', 'PERFORMER', 'Jerusalem', '1994-11-18', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42', '+251911200042', 'VERIFIED', 'PERFORMER', 'Kenna', '1995-01-25', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43', '+251911200043', 'VERIFIED', 'PERFORMER', 'Lensa', '1996-03-05', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44', '+251911200044', 'VERIFIED', 'PERFORMER', 'Marta', '1997-05-12', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', '+251911200045', 'VERIFIED', 'PERFORMER', 'Netsanet', '1998-07-19', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46', '+251911200046', 'VERIFIED', 'PERFORMER', 'Olana', '1999-09-26', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47', '+251911200047', 'VERIFIED', 'PERFORMER', 'Rekik', '2000-11-06', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48', '+251911200048', 'VERIFIED', 'PERFORMER', 'Seble', '1993-01-13', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49', '+251911200049', 'VERIFIED', 'PERFORMER', 'Tsehay', '1994-03-20', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', '+251911200050', 'VERIFIED', 'PERFORMER', 'Wesene', '1995-05-27', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51', '+251911200051', 'VERIFIED', 'PERFORMER', 'Yabsira', '1996-07-07', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52', '+251911200052', 'VERIFIED', 'PERFORMER', 'Zahara', '1997-09-14', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53', '+251911200053', 'VERIFIED', 'PERFORMER', 'Bruktawit', '1998-11-21', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54', '+251911200054', 'VERIFIED', 'PERFORMER', 'Danait', '1999-01-01', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', '+251911200055', 'VERIFIED', 'PERFORMER', 'Eyerus', '2000-03-08', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56', '+251911200056', 'VERIFIED', 'PERFORMER', 'Abyssinia', '1993-05-15', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57', '+251911200057', 'VERIFIED', 'PERFORMER', 'Mimi', '1994-07-22', 'FEMALE', 'am', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', '+251911200058', 'VERIFIED', 'PERFORMER', 'Ruth', '1995-09-02', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59', '+251911200059', 'VERIFIED', 'PERFORMER', 'Senait', '1996-11-09', 'FEMALE', 'en', 'v1-2026-08', NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60', '+251911200060', 'ACTIVE', 'PERFORMER', 'Birtukan', '1997-01-16', 'FEMALE', 'am', 'v1-2026-08', NOW());

INSERT INTO member_profiles (
  user_id, bio_en, bio_am, city, interests, photo_urls, last_lat, last_lng, location_updated_at,
  height_cm, job_title, languages, looking_for, photo_quality_status, photo_quality_notes
)
SELECT u.id, v.bio_en, v.bio_am, v.city, v.interests::jsonb, v.photos::jsonb, v.lat, v.lng, NOW(),
       v.height_cm, v.job_title, v.languages, v.looking_for, v.photo_quality, 'Demo seed approved'
FROM (
  VALUES
    ('+251911100001', 'Addis-based, loves jazz cafés and hiking Entoto.', 'ጃዝና ተራራ', 'Addis Ababa', '["Design","Food","Art"]', '["https://randomuser.me/api/portraits/men/41.jpg","https://randomuser.me/api/portraits/men/48.jpg","https://randomuser.me/api/portraits/men/55.jpg"]', 9.0162, 38.7497, 169, 'Engineer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100002', 'Engineer who hosts board-game nights and specialty coffee.', 'ቡናና ጨዋታ', 'Bole', '["Books","Art","Coffee"]', '["https://randomuser.me/api/portraits/men/42.jpg","https://randomuser.me/api/portraits/men/49.jpg","https://randomuser.me/api/portraits/men/56.jpg"]', 9.0224, 38.7594, 170, 'Architect', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100003', 'Architect. Slow Sundays, galleries, Piazza walks.', 'ጥበብና ጉዞ', 'Piazza', '["Fitness","Travel","Music"]', '["https://randomuser.me/api/portraits/men/43.jpg","https://randomuser.me/api/portraits/men/50.jpg","https://randomuser.me/api/portraits/men/57.jpg"]', 9.0286, 38.7691, 171, 'Chef', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100004', 'Chef experimenting with modern Ethiopian plates.', 'ዘመናዊ ምግብ', 'Kazanchis', '["Music","Coffee","Tech"]', '["https://randomuser.me/api/portraits/men/44.jpg","https://randomuser.me/api/portraits/men/51.jpg","https://randomuser.me/api/portraits/men/58.jpg"]', 9.0348, 38.7788, 172, 'Founder', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100005', 'Product designer. Climbing walls and vinyl weekends.', 'መውጣትና ሙዚቃ', 'Addis Ababa', '["Books","Art","Food"]', '["https://randomuser.me/api/portraits/men/45.jpg","https://randomuser.me/api/portraits/men/52.jpg","https://randomuser.me/api/portraits/men/59.jpg"]', 9.041, 38.7885, 173, 'Pilot', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100006', 'Finance by day, football and street photography by night.', 'ፎቶና እግር ኳስ', 'Bole', '["Hiking","Music","Faith"]', '["https://randomuser.me/api/portraits/men/46.jpg","https://randomuser.me/api/portraits/men/53.jpg","https://randomuser.me/api/portraits/men/60.jpg"]', 9.0472, 38.7502, 174, 'Lecturer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100007', 'Pilot. Soft landings and long dinners in Kazanchis.', 'አብራሪ — እራት', 'Piazza', '["Film","Travel","Art"]', '["https://randomuser.me/api/portraits/men/47.jpg","https://randomuser.me/api/portraits/men/54.jpg","https://randomuser.me/api/portraits/men/61.jpg"]', 9.0534, 38.7599, 175, 'Engineer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100008', 'University lecturer. Debate clubs and rain-season walks.', 'መምህር', 'Kazanchis', '["Dance","Coffee","Fitness"]', '["https://randomuser.me/api/portraits/men/48.jpg","https://randomuser.me/api/portraits/men/55.jpg","https://randomuser.me/api/portraits/men/62.jpg"]', 9.0236, 38.7696, 176, 'Architect', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100009', 'Startup founder. Early gym, late sketching.', 'ስታርትአፕ', 'Addis Ababa', '["Books","Food","Travel"]', '["https://randomuser.me/api/portraits/men/49.jpg","https://randomuser.me/api/portraits/men/56.jpg","https://randomuser.me/api/portraits/men/63.jpg"]', 9.0298, 38.7793, 177, 'Chef', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100010', 'Hotelier. Courtyard coffee and live jazz guests.', 'ሆቴል', 'Bole', '["Music","Food","Books"]', '["https://randomuser.me/api/portraits/men/50.jpg","https://randomuser.me/api/portraits/men/57.jpg","https://randomuser.me/api/portraits/men/64.jpg"]', 9.036, 38.789, 178, 'Founder', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100011', 'Civil engineer. Weekend trail runs above Entoto.', 'ሩጫ', 'Piazza', '["Design","Food","Art"]', '["https://randomuser.me/api/portraits/men/51.jpg","https://randomuser.me/api/portraits/men/58.jpg","https://randomuser.me/api/portraits/men/65.jpg"]', 9.0422, 38.7987, 179, 'Pilot', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100012', 'Documentary editor. Markets, lenses, quiet editing nights.', 'ፊልም', 'Kazanchis', '["Books","Art","Coffee"]', '["https://randomuser.me/api/portraits/men/52.jpg","https://randomuser.me/api/portraits/men/59.jpg","https://randomuser.me/api/portraits/men/66.jpg"]', 9.0484, 38.7604, 180, 'Lecturer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100013', 'Diplomat. Long lunches, short speeches, careful charm.', 'ዲፕሎማት', 'Addis Ababa', '["Fitness","Travel","Music"]', '["https://randomuser.me/api/portraits/men/53.jpg","https://randomuser.me/api/portraits/men/60.jpg","https://randomuser.me/api/portraits/men/67.jpg"]', 9.0546, 38.7701, 181, 'Engineer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100014', 'Sommelier in training. Natural wine and late kitchens.', 'ወይን', 'Bole', '["Music","Coffee","Tech"]', '["https://randomuser.me/api/portraits/men/54.jpg","https://randomuser.me/api/portraits/men/61.jpg","https://randomuser.me/api/portraits/men/68.jpg"]', 9.0608, 38.7798, 182, 'Architect', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100015', 'Surgeon with rare evenings and a love of vinyl.', 'ሐኪም', 'Piazza', '["Books","Art","Food"]', '["https://randomuser.me/api/portraits/men/55.jpg","https://randomuser.me/api/portraits/men/62.jpg","https://randomuser.me/api/portraits/men/69.jpg"]', 9.067, 38.7895, 183, 'Chef', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100016', 'Jazz bassist. After-hours rooms and slow tempos.', 'ሙዚቃ', 'Kazanchis', '["Hiking","Music","Faith"]', '["https://randomuser.me/api/portraits/men/56.jpg","https://randomuser.me/api/portraits/men/63.jpg","https://randomuser.me/api/portraits/men/70.jpg"]', 9.0372, 38.7992, 184, 'Founder', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100017', 'Importer. Travel stamps and discreet hospitality.', 'ንግድ', 'Addis Ababa', '["Film","Travel","Art"]', '["https://randomuser.me/api/portraits/men/57.jpg","https://randomuser.me/api/portraits/men/64.jpg","https://randomuser.me/api/portraits/men/71.jpg"]', 9.0434, 38.8089, 185, 'Pilot', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100018', 'Lawyer who actually reads the footnotes.', 'ሕግ', 'Bole', '["Dance","Coffee","Fitness"]', '["https://randomuser.me/api/portraits/men/58.jpg","https://randomuser.me/api/portraits/men/65.jpg","https://randomuser.me/api/portraits/men/72.jpg"]', 9.0496, 38.7706, 186, 'Lecturer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100019', 'Coffee exporter. Origin trips and quiet cuppings.', 'ቡና', 'Piazza', '["Books","Food","Travel"]', '["https://randomuser.me/api/portraits/men/59.jpg","https://randomuser.me/api/portraits/men/66.jpg","https://randomuser.me/api/portraits/men/73.jpg"]', 9.0558, 38.7803, 187, 'Engineer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100020', 'Property developer. Rooftops with a view of Entoto.', 'ሪል እስቴት', 'Kazanchis', '["Music","Food","Books"]', '["https://randomuser.me/api/portraits/men/60.jpg","https://randomuser.me/api/portraits/men/67.jpg","https://randomuser.me/api/portraits/men/74.jpg"]', 9.062, 38.79, 168, 'Architect', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100021', 'Software lead. Night builds and morning espresso.', 'ቴክ', 'Addis Ababa', '["Design","Food","Art"]', '["https://randomuser.me/api/portraits/men/61.jpg","https://randomuser.me/api/portraits/men/68.jpg","https://randomuser.me/api/portraits/men/75.jpg"]', 9.0682, 38.7997, 169, 'Chef', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100022', 'Historian. Archives by day, live music by night.', 'ታሪክ', 'Bole', '["Books","Art","Coffee"]', '["https://randomuser.me/api/portraits/men/62.jpg","https://randomuser.me/api/portraits/men/69.jpg","https://randomuser.me/api/portraits/men/76.jpg"]', 9.0744, 38.8094, 170, 'Founder', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100023', 'Football coach. Early drills, late dinners.', 'እግር ኳስ', 'Piazza', '["Fitness","Travel","Music"]', '["https://randomuser.me/api/portraits/men/63.jpg","https://randomuser.me/api/portraits/men/70.jpg","https://randomuser.me/api/portraits/men/77.jpg"]', 9.0806, 38.8191, 171, 'Pilot', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911100024', 'Photographer of the city after rain.', 'ፎቶ', 'Kazanchis', '["Music","Coffee","Tech"]', '["https://randomuser.me/api/portraits/men/64.jpg","https://randomuser.me/api/portraits/men/71.jpg","https://randomuser.me/api/portraits/men/78.jpg"]', 9.0508, 38.7808, 172, 'Lecturer', 'English, Amharic', NULL, 'APPROVED'),
    ('+251911200001', 'Designer with an eye for beautiful details and a night that unfolds slowly.', 'ዲዛይነር', 'Addis Ababa', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01/eeeeeeee-eeee-4eee-8eee-eeee00010000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01/eeeeeeee-eeee-4eee-8eee-eeee00010001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01/eeeeeeee-eeee-4eee-8eee-eeee00010002.jpg"]', 9.0166, 38.7501, 159, 'Designer', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200002', 'Amharic poetry, candlelit dinners, and glances that linger.', 'ግጥም', 'Bole', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02/eeeeeeee-eeee-4eee-8eee-eeee00020000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02/eeeeeeee-eeee-4eee-8eee-eeee00020001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02/eeeeeeee-eeee-4eee-8eee-eeee00020002.jpg"]', 9.0228, 38.7598, 160, 'Poet', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200003', 'Bright energy, a runner''s confidence, and music that pulls a room closer.', 'ሩጫ', 'Piazza', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03/eeeeeeee-eeee-4eee-8eee-eeee00030000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03/eeeeeeee-eeee-4eee-8eee-eeee00030001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03/eeeeeeee-eeee-4eee-8eee-eeee00030002.jpg"]', 9.029, 38.7695, 161, 'Athlete', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200004', 'Vinyl, espresso, and an easy smile before the first song ends.', 'UX', 'Kazanchis', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04/eeeeeeee-eeee-4eee-8eee-eeee00040000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04/eeeeeeee-eeee-4eee-8eee-eeee00040001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04/eeeeeeee-eeee-4eee-8eee-eeee00040002.jpg"]', 9.0352, 38.7792, 162, 'Product designer', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200005', 'Sharp mind, warm presence, theatre, and unhurried attention.', 'ጠበቃ', 'Addis Ababa', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05/eeeeeeee-eeee-4eee-8eee-eeee00050000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05/eeeeeeee-eeee-4eee-8eee-eeee00050001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05/eeeeeeee-eeee-4eee-8eee-eeee00050002.jpg"]', 9.0414, 38.7889, 163, 'Lawyer', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200006', 'Soft playlists and a calm confidence that makes late nights effortless.', 'ሐኪም', 'Bole', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06/eeeeeeee-eeee-4eee-8eee-eeee00060000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06/eeeeeeee-eeee-4eee-8eee-eeee00060001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06/eeeeeeee-eeee-4eee-8eee-eeee00060002.jpg"]', 9.0476, 38.7506, 164, 'Doctor', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200007', 'Photographer with a cinematic eye for charged pauses.', 'ፎቶ', 'Piazza', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07/eeeeeeee-eeee-4eee-8eee-eeee00070000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07/eeeeeeee-eeee-4eee-8eee-eeee00070001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07/eeeeeeee-eeee-4eee-8eee-eeee00070002.jpg"]', 9.0538, 38.7603, 165, 'Photographer', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200008', 'Ballet teacher: poised, playful, strong coffee, a little anticipation.', 'ባሌት', 'Kazanchis', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08/eeeeeeee-eeee-4eee-8eee-eeee00080000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08/eeeeeeee-eeee-4eee-8eee-eeee00080001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08/eeeeeeee-eeee-4eee-8eee-eeee00080002.jpg"]', 9.024, 38.77, 166, 'Dance instructor', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200009', 'Quick wit and a slow build — markets, bookstores, tension.', 'ስታርትአፕ', 'Addis Ababa', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09/eeeeeeee-eeee-4eee-8eee-eeee00090000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09/eeeeeeee-eeee-4eee-8eee-eeee00090001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09/eeeeeeee-eeee-4eee-8eee-eeee00090002.jpg"]', 9.0302, 38.7797, 167, 'Founder', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200010', 'Journalist who loves jazz, kitfo, and conversation that forgets the clock.', 'ጋዜጠኛ', 'Bole', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10/eeeeeeee-eeee-4eee-8eee-eeee00100000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10/eeeeeeee-eeee-4eee-8eee-eeee00100001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10/eeeeeeee-eeee-4eee-8eee-eeee00100002.jpg"]', 9.0364, 38.7894, 168, 'Journalist', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200011', 'Florist with a soft spot for fragrance and evenings that stay memorable.', 'አበባ', 'Piazza', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11/eeeeeeee-eeee-4eee-8eee-eeee00110000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11/eeeeeeee-eeee-4eee-8eee-eeee00110001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11/eeeeeeee-eeee-4eee-8eee-eeee00110002.jpg"]', 9.0426, 38.7991, 169, 'Florist', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200012', 'Architect who likes a beautiful setting and someone who can hold a room.', 'አርክቴክት', 'Kazanchis', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12/eeeeeeee-eeee-4eee-8eee-eeee00120000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12/eeeeeeee-eeee-4eee-8eee-eeee00120001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12/eeeeeeee-eeee-4eee-8eee-eeee00120002.jpg"]', 9.0488, 38.7608, 170, 'Architect', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200013', 'Gentle after a long shift. Soft playlists and real ease.', 'ነርስ', 'Addis Ababa', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13/eeeeeeee-eeee-4eee-8eee-eeee00130000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13/eeeeeeee-eeee-4eee-8eee-eeee00130001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13/eeeeeeee-eeee-4eee-8eee-eeee00130002.jpg"]', 9.055, 38.7705, 171, 'Nurse', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200014', 'Pastry chef — sweetness, banter, a night that feels like an indulgence.', 'ፓስትሪ', 'Bole', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14/eeeeeeee-eeee-4eee-8eee-eeee00140000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14/eeeeeeee-eeee-4eee-8eee-eeee00140001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14/eeeeeeee-eeee-4eee-8eee-eeee00140002.jpg"]', 9.0612, 38.7802, 172, 'Pastry chef', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200015', 'Thoughtful, quietly magnetic. Lake weekends and intimate talk after dark.', 'ምርምር', 'Piazza', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15/eeeeeeee-eeee-4eee-8eee-eeee00150000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15/eeeeeeee-eeee-4eee-8eee-eeee00150001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15/eeeeeeee-eeee-4eee-8eee-eeee00150002.jpg"]', 9.0674, 38.7899, 173, 'Researcher', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200016', 'Yoga instructor with a teasing smile and music that slows the room.', 'ዮጋ', 'Kazanchis', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16/eeeeeeee-eeee-4eee-8eee-eeee00160000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16/eeeeeeee-eeee-4eee-8eee-eeee00160001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16/eeeeeeee-eeee-4eee-8eee-eeee00160002.jpg"]', 9.0376, 38.7996, 174, 'Yoga instructor', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200017', 'Radio producer who knows the power of a low voice and a great playlist.', 'ሬዲዮ', 'Addis Ababa', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17/eeeeeeee-eeee-4eee-8eee-eeee00170000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17/eeeeeeee-eeee-4eee-8eee-eeee00170001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17/eeeeeeee-eeee-4eee-8eee-eeee00170002.jpg"]', 9.0438, 38.8093, 175, 'Radio producer', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200018', 'Translator with a love for rainy cafés and the first-meeting spark.', 'ተርጓሚ', 'Bole', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18/eeeeeeee-eeee-4eee-8eee-eeee00180000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18/eeeeeeee-eeee-4eee-8eee-eeee00180001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18/eeeeeeee-eeee-4eee-8eee-eeee00180002.jpg"]', 9.05, 38.771, 158, 'Translator', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200019', 'Stylist. Tailoring, perfume, and a look that does the talking.', 'ስታይል', 'Piazza', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19/eeeeeeee-eeee-4eee-8eee-eeee00190000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19/eeeeeeee-eeee-4eee-8eee-eeee00190001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19/eeeeeeee-eeee-4eee-8eee-eeee00190002.jpg"]', 9.0562, 38.7807, 159, 'Stylist', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200020', 'Sommelier. Natural wine, low light, unhurried courses.', 'ወይን', 'Kazanchis', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20/eeeeeeee-eeee-4eee-8eee-eeee00200000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20/eeeeeeee-eeee-4eee-8eee-eeee00200001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20/eeeeeeee-eeee-4eee-8eee-eeee00200002.jpg"]', 9.0624, 38.7904, 160, 'Sommelier', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200021', 'Painter. Colour, silence, and a studio that stays open late.', 'ሥዕል', 'Addis Ababa', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21/eeeeeeee-eeee-4eee-8eee-eeee00210000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21/eeeeeeee-eeee-4eee-8eee-eeee00210001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21/eeeeeeee-eeee-4eee-8eee-eeee00210002.jpg"]', 9.0686, 38.8001, 161, 'Painter', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200022', 'Cellist. Slow movements and rooms that listen back.', 'ሙዚቃ', 'Bole', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22/eeeeeeee-eeee-4eee-8eee-eeee00220000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22/eeeeeeee-eeee-4eee-8eee-eeee00220001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22/eeeeeeee-eeee-4eee-8eee-eeee00220002.jpg"]', 9.0748, 38.8098, 162, 'Cellist', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200023', 'Host. Discreet tables, good stories, better timing.', 'አስተናጋጅ', 'Piazza', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23/eeeeeeee-eeee-4eee-8eee-eeee00230000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23/eeeeeeee-eeee-4eee-8eee-eeee00230001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23/eeeeeeee-eeee-4eee-8eee-eeee00230002.jpg"]', 9.081, 38.8195, 163, 'Host', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200024', 'Dancer. Heat, precision, and a laugh that disarms.', 'ዳንስ', 'Kazanchis', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24/eeeeeeee-eeee-4eee-8eee-eeee00240000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24/eeeeeeee-eeee-4eee-8eee-eeee00240001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24/eeeeeeee-eeee-4eee-8eee-eeee00240002.jpg"]', 9.0512, 38.7812, 164, 'Dancer', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200025', 'Editor. Sharp lines, softer nights.', 'አርታዒ', 'Addis Ababa', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25/eeeeeeee-eeee-4eee-8eee-eeee00250000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25/eeeeeeee-eeee-4eee-8eee-eeee00250001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25/eeeeeeee-eeee-4eee-8eee-eeee00250002.jpg"]', 9.0574, 38.7909, 165, 'Editor', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200026', 'Perfumer. Skin, memory, and a trail that stays.', 'ሽቶ', 'Bole', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26/eeeeeeee-eeee-4eee-8eee-eeee00260000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26/eeeeeeee-eeee-4eee-8eee-eeee00260001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26/eeeeeeee-eeee-4eee-8eee-eeee00260002.jpg"]', 9.0636, 38.8006, 166, 'Perfumer', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200027', 'Galleries, silk, and a gaze that does not hurry.', 'ጋለሪ', 'Piazza', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27/eeeeeeee-eeee-4eee-8eee-eeee00270000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27/eeeeeeee-eeee-4eee-8eee-eeee00270001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27/eeeeeeee-eeee-4eee-8eee-eeee00270002.jpg"]', 9.0698, 38.8103, 167, 'Galleries', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200028', 'Private chef. Spice, candlelight, no rush.', 'ሼፍ', 'Kazanchis', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28/eeeeeeee-eeee-4eee-8eee-eeee00280000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28/eeeeeeee-eeee-4eee-8eee-eeee00280001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28/eeeeeeee-eeee-4eee-8eee-eeee00280002.jpg"]', 9.076, 38.82, 168, 'Private chef', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200029', 'Voice actor. Warm timbre, warmer company.', 'ድምጽ', 'Addis Ababa', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29/eeeeeeee-eeee-4eee-8eee-eeee00290000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29/eeeeeeee-eeee-4eee-8eee-eeee00290001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29/eeeeeeee-eeee-4eee-8eee-eeee00290002.jpg"]', 9.0822, 38.8297, 169, 'Voice actor', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200030', 'Jewelry designer. Gold, restraint, a little flash.', 'ጌጣጌጥ', 'Bole', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30/eeeeeeee-eeee-4eee-8eee-eeee00300000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30/eeeeeeee-eeee-4eee-8eee-eeee00300001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30/eeeeeeee-eeee-4eee-8eee-eeee00300002.jpg"]', 9.0884, 38.7914, 170, 'Jewelry designer', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200031', 'Pilot on layover energy — curious, composed, gone by morning if needed.', 'አብራሪ', 'Piazza', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31/eeeeeeee-eeee-4eee-8eee-eeee00310000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31/eeeeeeee-eeee-4eee-8eee-eeee00310001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31/eeeeeeee-eeee-4eee-8eee-eeee00310002.jpg"]', 9.0946, 38.8011, 171, 'Pilot', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200032', 'Set designer. Atmosphere first, then conversation.', 'መድረክ', 'Kazanchis', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32/eeeeeeee-eeee-4eee-8eee-eeee00320000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32/eeeeeeee-eeee-4eee-8eee-eeee00320001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32/eeeeeeee-eeee-4eee-8eee-eeee00320002.jpg"]', 9.0648, 38.8108, 172, 'Set designer', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200033', 'Calligrapher. Beautiful letters, slower evenings.', 'ጽሑፍ', 'Addis Ababa', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33/eeeeeeee-eeee-4eee-8eee-eeee00330000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33/eeeeeeee-eeee-4eee-8eee-eeee00330001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33/eeeeeeee-eeee-4eee-8eee-eeee00330002.jpg"]', 9.071, 38.8205, 173, 'Calligrapher', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200034', 'Mixologist. Bitter, sweet, and exactly enough ice.', 'ኮክቴል', 'Bole', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34/eeeeeeee-eeee-4eee-8eee-eeee00340000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34/eeeeeeee-eeee-4eee-8eee-eeee00340001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34/eeeeeeee-eeee-4eee-8eee-eeee00340002.jpg"]', 9.0772, 38.8302, 174, 'Mixologist', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200035', 'Curator. Quiet rooms, loud taste.', 'ኩሬተር', 'Piazza', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35/eeeeeeee-eeee-4eee-8eee-eeee00350000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35/eeeeeeee-eeee-4eee-8eee-eeee00350001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35/eeeeeeee-eeee-4eee-8eee-eeee00350002.jpg"]', 9.0834, 38.8399, 175, 'Curator', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200036', 'Composer. Night motifs and a private encore.', 'ሙዚቃ', 'Kazanchis', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36/eeeeeeee-eeee-4eee-8eee-eeee00360000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36/eeeeeeee-eeee-4eee-8eee-eeee00360001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36/eeeeeeee-eeee-4eee-8eee-eeee00360002.jpg"]', 9.0896, 38.8016, 158, 'Composer', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200037', 'Designer with an eye for beautiful details and a night that unfolds slowly.', 'ዲዛይነር', 'Addis Ababa', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37/eeeeeeee-eeee-4eee-8eee-eeee00370000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37/eeeeeeee-eeee-4eee-8eee-eeee00370001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37/eeeeeeee-eeee-4eee-8eee-eeee00370002.jpg"]', 9.0958, 38.8113, 159, 'Designer', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200038', 'Amharic poetry, candlelit dinners, and glances that linger.', 'ግጥም', 'Bole', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38/eeeeeeee-eeee-4eee-8eee-eeee00380000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38/eeeeeeee-eeee-4eee-8eee-eeee00380001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38/eeeeeeee-eeee-4eee-8eee-eeee00380002.jpg"]', 9.102, 38.821, 160, 'Poet', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200039', 'Bright energy, a runner''s confidence, and music that pulls a room closer.', 'ሩጫ', 'Piazza', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39/eeeeeeee-eeee-4eee-8eee-eeee00390000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39/eeeeeeee-eeee-4eee-8eee-eeee00390001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39/eeeeeeee-eeee-4eee-8eee-eeee00390002.jpg"]', 9.1082, 38.8307, 161, 'Athlete', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200040', 'Vinyl, espresso, and an easy smile before the first song ends.', 'UX', 'Kazanchis', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40/eeeeeeee-eeee-4eee-8eee-eeee00400000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40/eeeeeeee-eeee-4eee-8eee-eeee00400001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40/eeeeeeee-eeee-4eee-8eee-eeee00400002.jpg"]', 9.0784, 38.8404, 162, 'Product designer', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200041', 'Sharp mind, warm presence, theatre, and unhurried attention.', 'ጠበቃ', 'Addis Ababa', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41/eeeeeeee-eeee-4eee-8eee-eeee00410000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41/eeeeeeee-eeee-4eee-8eee-eeee00410001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41/eeeeeeee-eeee-4eee-8eee-eeee00410002.jpg"]', 9.0846, 38.8501, 163, 'Lawyer', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200042', 'Soft playlists and a calm confidence that makes late nights effortless.', 'ሐኪም', 'Bole', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42/eeeeeeee-eeee-4eee-8eee-eeee00420000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42/eeeeeeee-eeee-4eee-8eee-eeee00420001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42/eeeeeeee-eeee-4eee-8eee-eeee00420002.jpg"]', 9.0908, 38.8118, 164, 'Doctor', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200043', 'Photographer with a cinematic eye for charged pauses.', 'ፎቶ', 'Piazza', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43/eeeeeeee-eeee-4eee-8eee-eeee00430000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43/eeeeeeee-eeee-4eee-8eee-eeee00430001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43/eeeeeeee-eeee-4eee-8eee-eeee00430002.jpg"]', 9.097, 38.8215, 165, 'Photographer', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200044', 'Ballet teacher: poised, playful, strong coffee, a little anticipation.', 'ባሌት', 'Kazanchis', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44/eeeeeeee-eeee-4eee-8eee-eeee00440000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44/eeeeeeee-eeee-4eee-8eee-eeee00440001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44/eeeeeeee-eeee-4eee-8eee-eeee00440002.jpg"]', 9.1032, 38.8312, 166, 'Dance instructor', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200045', 'Quick wit and a slow build — markets, bookstores, tension.', 'ስታርትአፕ', 'Addis Ababa', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45/eeeeeeee-eeee-4eee-8eee-eeee00450000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45/eeeeeeee-eeee-4eee-8eee-eeee00450001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45/eeeeeeee-eeee-4eee-8eee-eeee00450002.jpg"]', 9.1094, 38.8409, 167, 'Founder', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200046', 'Journalist who loves jazz, kitfo, and conversation that forgets the clock.', 'ጋዜጠኛ', 'Bole', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46/eeeeeeee-eeee-4eee-8eee-eeee00460000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46/eeeeeeee-eeee-4eee-8eee-eeee00460001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46/eeeeeeee-eeee-4eee-8eee-eeee00460002.jpg"]', 9.1156, 38.8506, 168, 'Journalist', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200047', 'Florist with a soft spot for fragrance and evenings that stay memorable.', 'አበባ', 'Piazza', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47/eeeeeeee-eeee-4eee-8eee-eeee00470000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47/eeeeeeee-eeee-4eee-8eee-eeee00470001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47/eeeeeeee-eeee-4eee-8eee-eeee00470002.jpg"]', 9.1218, 38.8603, 169, 'Florist', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200048', 'Architect who likes a beautiful setting and someone who can hold a room.', 'አርክቴክት', 'Kazanchis', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48/eeeeeeee-eeee-4eee-8eee-eeee00480000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48/eeeeeeee-eeee-4eee-8eee-eeee00480001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48/eeeeeeee-eeee-4eee-8eee-eeee00480002.jpg"]', 9.092, 38.822, 170, 'Architect', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200049', 'Gentle after a long shift. Soft playlists and real ease.', 'ነርስ', 'Addis Ababa', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49/eeeeeeee-eeee-4eee-8eee-eeee00490000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49/eeeeeeee-eeee-4eee-8eee-eeee00490001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49/eeeeeeee-eeee-4eee-8eee-eeee00490002.jpg"]', 9.0982, 38.8317, 171, 'Nurse', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200050', 'Pastry chef — sweetness, banter, a night that feels like an indulgence.', 'ፓስትሪ', 'Bole', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50/eeeeeeee-eeee-4eee-8eee-eeee00500000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50/eeeeeeee-eeee-4eee-8eee-eeee00500001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50/eeeeeeee-eeee-4eee-8eee-eeee00500002.jpg"]', 9.1044, 38.8414, 172, 'Pastry chef', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200051', 'Thoughtful, quietly magnetic. Lake weekends and intimate talk after dark.', 'ምርምር', 'Piazza', '["Design","Food","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51/eeeeeeee-eeee-4eee-8eee-eeee00510000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51/eeeeeeee-eeee-4eee-8eee-eeee00510001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51/eeeeeeee-eeee-4eee-8eee-eeee00510002.jpg"]', 9.1106, 38.8511, 173, 'Researcher', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200052', 'Yoga instructor with a teasing smile and music that slows the room.', 'ዮጋ', 'Kazanchis', '["Books","Art","Coffee"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52/eeeeeeee-eeee-4eee-8eee-eeee00520000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52/eeeeeeee-eeee-4eee-8eee-eeee00520001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52/eeeeeeee-eeee-4eee-8eee-eeee00520002.jpg"]', 9.1168, 38.8608, 174, 'Yoga instructor', 'English, Amharic, French', 'Soft & romantic', 'APPROVED'),
    ('+251911200053', 'Radio producer who knows the power of a low voice and a great playlist.', 'ሬዲዮ', 'Addis Ababa', '["Fitness","Travel","Music"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53/eeeeeeee-eeee-4eee-8eee-eeee00530000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53/eeeeeeee-eeee-4eee-8eee-eeee00530001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53/eeeeeeee-eeee-4eee-8eee-eeee00530002.jpg"]', 9.123, 38.8705, 175, 'Radio producer', 'Amharic, English', 'Confident energy', 'APPROVED'),
    ('+251911200054', 'Translator with a love for rainy cafés and the first-meeting spark.', 'ተርጓሚ', 'Bole', '["Music","Coffee","Tech"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54/eeeeeeee-eeee-4eee-8eee-eeee00540000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54/eeeeeeee-eeee-4eee-8eee-eeee00540001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54/eeeeeeee-eeee-4eee-8eee-eeee00540002.jpg"]', 9.1292, 38.8322, 158, 'Translator', 'English, Amharic, French', 'Late night', 'APPROVED'),
    ('+251911200055', 'Stylist. Tailoring, perfume, and a look that does the talking.', 'ስታይል', 'Piazza', '["Books","Art","Food"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55/eeeeeeee-eeee-4eee-8eee-eeee00550000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55/eeeeeeee-eeee-4eee-8eee-eeee00550001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55/eeeeeeee-eeee-4eee-8eee-eeee00550002.jpg"]', 9.1354, 38.8419, 159, 'Stylist', 'Amharic, English', 'Verified venue first', 'APPROVED'),
    ('+251911200056', 'Sommelier. Natural wine, low light, unhurried courses.', 'ወይን', 'Kazanchis', '["Hiking","Music","Faith"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56/eeeeeeee-eeee-4eee-8eee-eeee00560000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56/eeeeeeee-eeee-4eee-8eee-eeee00560001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56/eeeeeeee-eeee-4eee-8eee-eeee00560002.jpg"]', 9.1056, 38.8516, 160, 'Sommelier', 'English, Amharic, French', 'Unhurried evenings', 'APPROVED'),
    ('+251911200057', 'Painter. Colour, silence, and a studio that stays open late.', 'ሥዕል', 'Addis Ababa', '["Film","Travel","Art"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57/eeeeeeee-eeee-4eee-8eee-eeee00570000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57/eeeeeeee-eeee-4eee-8eee-eeee00570001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57/eeeeeeee-eeee-4eee-8eee-eeee00570002.jpg"]', 9.1118, 38.8613, 161, 'Painter', 'Amharic, English', 'Slow burn', 'APPROVED'),
    ('+251911200058', 'Cellist. Slow movements and rooms that listen back.', 'ሙዚቃ', 'Bole', '["Dance","Coffee","Fitness"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58/eeeeeeee-eeee-4eee-8eee-eeee00580000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58/eeeeeeee-eeee-4eee-8eee-eeee00580001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58/eeeeeeee-eeee-4eee-8eee-eeee00580002.jpg"]', 9.118, 38.871, 162, 'Cellist', 'English, Amharic, French', 'Playful nights', 'APPROVED'),
    ('+251911200059', 'Host. Discreet tables, good stories, better timing.', 'አስተናጋጅ', 'Piazza', '["Books","Food","Travel"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59/eeeeeeee-eeee-4eee-8eee-eeee00590000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59/eeeeeeee-eeee-4eee-8eee-eeee00590001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59/eeeeeeee-eeee-4eee-8eee-eeee00590002.jpg"]', 9.1242, 38.8807, 163, 'Host', 'Amharic, English', 'Discreet company', 'APPROVED'),
    ('+251911200060', 'Dancer. Heat, precision, and a laugh that disarms.', 'ዳንስ', 'Kazanchis', '["Music","Food","Books"]', '["/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60/eeeeeeee-eeee-4eee-8eee-eeee00600000.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60/eeeeeeee-eeee-4eee-8eee-eeee00600001.jpg","/v1/media/profile/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60/eeeeeeee-eeee-4eee-8eee-eeee00600002.jpg"]', 9.1304, 38.8424, 164, 'Dancer', 'English, Amharic, French', 'Soft & romantic', 'NEEDS_REVIEW')
) AS v(phone, bio_en, bio_am, city, interests, photos, lat, lng, height_cm, job_title, languages, looking_for, photo_quality)
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

INSERT INTO member_likes (from_user_id, to_user_id, action)
SELECT m.id, w.id, pairs.action
FROM (VALUES
  ('+251911100003', '+251911200001', 'LIKE'),
  ('+251911100006', '+251911200001', 'LIKE'),
  ('+251911100009', '+251911200001', 'LIKE'),
  ('+251911100012', '+251911200001', 'LIKE'),
  ('+251911100015', '+251911200001', 'LIKE'),
  ('+251911100018', '+251911200001', 'LIKE'),
  ('+251911100021', '+251911200001', 'LIKE'),
  ('+251911100024', '+251911200001', 'LIKE'),
  ('+251911100004', '+251911200002', 'LIKE'),
  ('+251911100007', '+251911200002', 'LIKE'),
  ('+251911100010', '+251911200002', 'LIKE'),
  ('+251911100013', '+251911200002', 'LIKE'),
  ('+251911100016', '+251911200002', 'LIKE'),
  ('+251911100019', '+251911200002', 'LIKE'),
  ('+251911100022', '+251911200002', 'LIKE'),
  ('+251911100002', '+251911200002', 'LIKE'),
  ('+251911100005', '+251911200003', 'LIKE'),
  ('+251911100008', '+251911200003', 'LIKE'),
  ('+251911100011', '+251911200003', 'LIKE'),
  ('+251911100014', '+251911200003', 'LIKE'),
  ('+251911100017', '+251911200003', 'LIKE'),
  ('+251911100020', '+251911200003', 'LIKE'),
  ('+251911100023', '+251911200003', 'LIKE'),
  ('+251911100003', '+251911200003', 'LIKE'),
  ('+251911100006', '+251911200004', 'LIKE'),
  ('+251911100009', '+251911200004', 'LIKE'),
  ('+251911100012', '+251911200004', 'LIKE'),
  ('+251911100015', '+251911200004', 'LIKE'),
  ('+251911100018', '+251911200004', 'LIKE'),
  ('+251911100021', '+251911200004', 'LIKE'),
  ('+251911100024', '+251911200004', 'LIKE'),
  ('+251911100004', '+251911200004', 'LIKE'),
  ('+251911100007', '+251911200005', 'LIKE'),
  ('+251911100010', '+251911200005', 'LIKE'),
  ('+251911100013', '+251911200005', 'LIKE'),
  ('+251911100016', '+251911200005', 'LIKE'),
  ('+251911100019', '+251911200005', 'LIKE'),
  ('+251911100022', '+251911200005', 'LIKE'),
  ('+251911100002', '+251911200005', 'LIKE'),
  ('+251911100005', '+251911200005', 'LIKE'),
  ('+251911100008', '+251911200006', 'LIKE'),
  ('+251911100011', '+251911200006', 'LIKE'),
  ('+251911100014', '+251911200006', 'LIKE'),
  ('+251911100017', '+251911200006', 'LIKE'),
  ('+251911100020', '+251911200006', 'LIKE'),
  ('+251911100023', '+251911200006', 'LIKE'),
  ('+251911100003', '+251911200006', 'LIKE'),
  ('+251911100006', '+251911200006', 'LIKE'),
  ('+251911100009', '+251911200007', 'LIKE'),
  ('+251911100012', '+251911200007', 'LIKE'),
  ('+251911100015', '+251911200007', 'LIKE'),
  ('+251911100018', '+251911200007', 'LIKE'),
  ('+251911100021', '+251911200007', 'LIKE'),
  ('+251911100024', '+251911200007', 'LIKE'),
  ('+251911100004', '+251911200007', 'LIKE'),
  ('+251911100007', '+251911200007', 'LIKE'),
  ('+251911100010', '+251911200008', 'LIKE'),
  ('+251911100013', '+251911200008', 'LIKE'),
  ('+251911100016', '+251911200008', 'LIKE'),
  ('+251911100019', '+251911200008', 'LIKE'),
  ('+251911100022', '+251911200008', 'LIKE'),
  ('+251911100002', '+251911200008', 'LIKE'),
  ('+251911100008', '+251911200008', 'LIKE'),
  ('+251911100011', '+251911200009', 'LIKE'),
  ('+251911100014', '+251911200009', 'LIKE'),
  ('+251911100017', '+251911200009', 'LIKE'),
  ('+251911100020', '+251911200009', 'LIKE'),
  ('+251911100023', '+251911200009', 'LIKE'),
  ('+251911100003', '+251911200009', 'LIKE'),
  ('+251911100006', '+251911200009', 'LIKE'),
  ('+251911100009', '+251911200009', 'LIKE'),
  ('+251911100012', '+251911200010', 'LIKE'),
  ('+251911100015', '+251911200010', 'LIKE'),
  ('+251911100018', '+251911200010', 'LIKE'),
  ('+251911100021', '+251911200010', 'LIKE'),
  ('+251911100024', '+251911200010', 'LIKE'),
  ('+251911100004', '+251911200010', 'LIKE'),
  ('+251911100007', '+251911200010', 'LIKE'),
  ('+251911100010', '+251911200010', 'LIKE'),
  ('+251911100013', '+251911200011', 'LIKE'),
  ('+251911100016', '+251911200011', 'LIKE'),
  ('+251911100019', '+251911200011', 'LIKE'),
  ('+251911100022', '+251911200011', 'LIKE'),
  ('+251911100002', '+251911200011', 'LIKE'),
  ('+251911100005', '+251911200011', 'LIKE'),
  ('+251911100008', '+251911200011', 'LIKE'),
  ('+251911100011', '+251911200011', 'LIKE'),
  ('+251911100014', '+251911200012', 'LIKE'),
  ('+251911100017', '+251911200012', 'LIKE'),
  ('+251911100020', '+251911200012', 'LIKE'),
  ('+251911100023', '+251911200012', 'LIKE'),
  ('+251911100003', '+251911200012', 'LIKE'),
  ('+251911100006', '+251911200012', 'LIKE'),
  ('+251911100009', '+251911200012', 'LIKE'),
  ('+251911100012', '+251911200012', 'LIKE'),
  ('+251911100015', '+251911200013', 'LIKE'),
  ('+251911100018', '+251911200013', 'LIKE'),
  ('+251911100021', '+251911200013', 'LIKE'),
  ('+251911100024', '+251911200013', 'LIKE'),
  ('+251911100004', '+251911200013', 'LIKE'),
  ('+251911100007', '+251911200013', 'LIKE'),
  ('+251911100010', '+251911200013', 'LIKE'),
  ('+251911100013', '+251911200013', 'LIKE'),
  ('+251911100016', '+251911200014', 'LIKE'),
  ('+251911100019', '+251911200014', 'LIKE'),
  ('+251911100022', '+251911200014', 'LIKE'),
  ('+251911100002', '+251911200014', 'LIKE'),
  ('+251911100005', '+251911200014', 'LIKE'),
  ('+251911100008', '+251911200014', 'LIKE'),
  ('+251911100011', '+251911200014', 'LIKE'),
  ('+251911100014', '+251911200014', 'LIKE'),
  ('+251911100017', '+251911200015', 'LIKE'),
  ('+251911100020', '+251911200015', 'LIKE'),
  ('+251911100023', '+251911200015', 'LIKE'),
  ('+251911100003', '+251911200015', 'LIKE'),
  ('+251911100006', '+251911200015', 'LIKE'),
  ('+251911100009', '+251911200015', 'LIKE'),
  ('+251911100012', '+251911200015', 'LIKE'),
  ('+251911100015', '+251911200015', 'LIKE'),
  ('+251911100018', '+251911200016', 'LIKE'),
  ('+251911100021', '+251911200016', 'LIKE'),
  ('+251911100024', '+251911200016', 'LIKE'),
  ('+251911100004', '+251911200016', 'LIKE'),
  ('+251911100007', '+251911200016', 'LIKE'),
  ('+251911100010', '+251911200016', 'LIKE'),
  ('+251911100013', '+251911200016', 'LIKE'),
  ('+251911100016', '+251911200016', 'LIKE'),
  ('+251911100019', '+251911200017', 'LIKE'),
  ('+251911100022', '+251911200017', 'LIKE'),
  ('+251911100002', '+251911200017', 'LIKE'),
  ('+251911100005', '+251911200017', 'LIKE'),
  ('+251911100008', '+251911200017', 'LIKE'),
  ('+251911100011', '+251911200017', 'LIKE'),
  ('+251911100014', '+251911200017', 'LIKE'),
  ('+251911100017', '+251911200017', 'LIKE'),
  ('+251911100020', '+251911200018', 'LIKE'),
  ('+251911100023', '+251911200018', 'LIKE'),
  ('+251911100003', '+251911200018', 'LIKE'),
  ('+251911100006', '+251911200018', 'LIKE'),
  ('+251911100009', '+251911200018', 'LIKE'),
  ('+251911100012', '+251911200018', 'LIKE'),
  ('+251911100015', '+251911200018', 'LIKE'),
  ('+251911100018', '+251911200018', 'LIKE'),
  ('+251911100021', '+251911200019', 'LIKE'),
  ('+251911100024', '+251911200019', 'LIKE'),
  ('+251911100004', '+251911200019', 'LIKE'),
  ('+251911100007', '+251911200019', 'LIKE'),
  ('+251911100010', '+251911200019', 'LIKE'),
  ('+251911100013', '+251911200019', 'LIKE'),
  ('+251911100016', '+251911200019', 'LIKE'),
  ('+251911100019', '+251911200019', 'LIKE'),
  ('+251911100022', '+251911200020', 'LIKE'),
  ('+251911100002', '+251911200020', 'LIKE'),
  ('+251911100005', '+251911200020', 'LIKE'),
  ('+251911100008', '+251911200020', 'LIKE'),
  ('+251911100011', '+251911200020', 'LIKE'),
  ('+251911100014', '+251911200020', 'LIKE'),
  ('+251911100017', '+251911200020', 'LIKE'),
  ('+251911100020', '+251911200020', 'LIKE'),
  ('+251911100023', '+251911200021', 'LIKE'),
  ('+251911100003', '+251911200021', 'LIKE'),
  ('+251911100006', '+251911200021', 'LIKE'),
  ('+251911100009', '+251911200021', 'LIKE'),
  ('+251911100012', '+251911200021', 'LIKE'),
  ('+251911100015', '+251911200021', 'LIKE'),
  ('+251911100018', '+251911200021', 'LIKE'),
  ('+251911100021', '+251911200021', 'LIKE'),
  ('+251911100024', '+251911200022', 'LIKE'),
  ('+251911100004', '+251911200022', 'LIKE'),
  ('+251911100007', '+251911200022', 'LIKE'),
  ('+251911100010', '+251911200022', 'LIKE'),
  ('+251911100013', '+251911200022', 'LIKE'),
  ('+251911100016', '+251911200022', 'LIKE'),
  ('+251911100019', '+251911200022', 'LIKE'),
  ('+251911100022', '+251911200022', 'LIKE'),
  ('+251911100002', '+251911200023', 'LIKE'),
  ('+251911100005', '+251911200023', 'LIKE'),
  ('+251911100008', '+251911200023', 'LIKE'),
  ('+251911100011', '+251911200023', 'LIKE'),
  ('+251911100014', '+251911200023', 'LIKE'),
  ('+251911100017', '+251911200023', 'LIKE'),
  ('+251911100020', '+251911200023', 'LIKE'),
  ('+251911100023', '+251911200023', 'LIKE'),
  ('+251911100003', '+251911200024', 'LIKE'),
  ('+251911100006', '+251911200024', 'LIKE'),
  ('+251911100009', '+251911200024', 'LIKE'),
  ('+251911100012', '+251911200024', 'LIKE'),
  ('+251911100015', '+251911200024', 'LIKE'),
  ('+251911100018', '+251911200024', 'LIKE'),
  ('+251911100021', '+251911200024', 'LIKE'),
  ('+251911100024', '+251911200024', 'LIKE'),
  ('+251911100004', '+251911200025', 'LIKE'),
  ('+251911100007', '+251911200025', 'LIKE'),
  ('+251911100010', '+251911200025', 'LIKE'),
  ('+251911100013', '+251911200025', 'LIKE'),
  ('+251911100016', '+251911200025', 'LIKE'),
  ('+251911100019', '+251911200025', 'LIKE'),
  ('+251911100022', '+251911200025', 'LIKE'),
  ('+251911100002', '+251911200025', 'LIKE'),
  ('+251911100005', '+251911200026', 'LIKE'),
  ('+251911100008', '+251911200026', 'LIKE'),
  ('+251911100011', '+251911200026', 'LIKE'),
  ('+251911100014', '+251911200026', 'LIKE'),
  ('+251911100017', '+251911200026', 'LIKE'),
  ('+251911100020', '+251911200026', 'LIKE'),
  ('+251911100023', '+251911200026', 'LIKE'),
  ('+251911100003', '+251911200026', 'LIKE'),
  ('+251911100006', '+251911200027', 'LIKE'),
  ('+251911100009', '+251911200027', 'LIKE'),
  ('+251911100012', '+251911200027', 'LIKE'),
  ('+251911100015', '+251911200027', 'LIKE'),
  ('+251911100018', '+251911200027', 'LIKE'),
  ('+251911100021', '+251911200027', 'LIKE'),
  ('+251911100024', '+251911200027', 'LIKE'),
  ('+251911100004', '+251911200027', 'LIKE'),
  ('+251911100007', '+251911200028', 'LIKE'),
  ('+251911100010', '+251911200028', 'LIKE'),
  ('+251911100013', '+251911200028', 'LIKE'),
  ('+251911100016', '+251911200028', 'LIKE'),
  ('+251911100019', '+251911200028', 'LIKE'),
  ('+251911100022', '+251911200028', 'LIKE'),
  ('+251911100002', '+251911200028', 'LIKE'),
  ('+251911100005', '+251911200028', 'LIKE'),
  ('+251911100008', '+251911200029', 'LIKE'),
  ('+251911100011', '+251911200029', 'LIKE'),
  ('+251911100014', '+251911200029', 'LIKE'),
  ('+251911100017', '+251911200029', 'LIKE'),
  ('+251911100020', '+251911200029', 'LIKE'),
  ('+251911100023', '+251911200029', 'LIKE'),
  ('+251911100003', '+251911200029', 'LIKE'),
  ('+251911100006', '+251911200029', 'LIKE'),
  ('+251911100009', '+251911200030', 'LIKE'),
  ('+251911100012', '+251911200030', 'LIKE'),
  ('+251911100015', '+251911200030', 'LIKE'),
  ('+251911100018', '+251911200030', 'LIKE'),
  ('+251911100021', '+251911200030', 'LIKE'),
  ('+251911100024', '+251911200030', 'LIKE'),
  ('+251911100004', '+251911200030', 'LIKE'),
  ('+251911100007', '+251911200030', 'LIKE'),
  ('+251911100010', '+251911200031', 'LIKE'),
  ('+251911100013', '+251911200031', 'LIKE'),
  ('+251911100016', '+251911200031', 'LIKE'),
  ('+251911100019', '+251911200031', 'LIKE'),
  ('+251911100022', '+251911200031', 'LIKE'),
  ('+251911100002', '+251911200031', 'LIKE'),
  ('+251911100005', '+251911200031', 'LIKE'),
  ('+251911100008', '+251911200031', 'LIKE'),
  ('+251911100011', '+251911200032', 'LIKE'),
  ('+251911100014', '+251911200032', 'LIKE'),
  ('+251911100017', '+251911200032', 'LIKE'),
  ('+251911100020', '+251911200032', 'LIKE'),
  ('+251911100023', '+251911200032', 'LIKE'),
  ('+251911100003', '+251911200032', 'LIKE'),
  ('+251911100006', '+251911200032', 'LIKE'),
  ('+251911100009', '+251911200032', 'LIKE'),
  ('+251911100012', '+251911200033', 'LIKE'),
  ('+251911100015', '+251911200033', 'LIKE'),
  ('+251911100018', '+251911200033', 'LIKE'),
  ('+251911100021', '+251911200033', 'LIKE'),
  ('+251911100024', '+251911200033', 'LIKE'),
  ('+251911100004', '+251911200033', 'LIKE'),
  ('+251911100007', '+251911200033', 'LIKE'),
  ('+251911100010', '+251911200033', 'LIKE'),
  ('+251911100013', '+251911200034', 'LIKE'),
  ('+251911100016', '+251911200034', 'LIKE'),
  ('+251911100019', '+251911200034', 'LIKE'),
  ('+251911100022', '+251911200034', 'LIKE'),
  ('+251911100002', '+251911200034', 'LIKE'),
  ('+251911100005', '+251911200034', 'LIKE'),
  ('+251911100008', '+251911200034', 'LIKE'),
  ('+251911100011', '+251911200034', 'LIKE'),
  ('+251911100014', '+251911200035', 'LIKE'),
  ('+251911100017', '+251911200035', 'LIKE'),
  ('+251911100020', '+251911200035', 'LIKE'),
  ('+251911100023', '+251911200035', 'LIKE'),
  ('+251911100003', '+251911200035', 'LIKE'),
  ('+251911100006', '+251911200035', 'LIKE'),
  ('+251911100009', '+251911200035', 'LIKE'),
  ('+251911100012', '+251911200035', 'LIKE'),
  ('+251911100015', '+251911200036', 'LIKE'),
  ('+251911100018', '+251911200036', 'LIKE'),
  ('+251911100021', '+251911200036', 'LIKE'),
  ('+251911100024', '+251911200036', 'LIKE'),
  ('+251911100004', '+251911200036', 'LIKE'),
  ('+251911100007', '+251911200036', 'LIKE'),
  ('+251911100010', '+251911200036', 'LIKE'),
  ('+251911100013', '+251911200036', 'LIKE'),
  ('+251911100016', '+251911200037', 'LIKE'),
  ('+251911100019', '+251911200037', 'LIKE'),
  ('+251911100022', '+251911200037', 'LIKE'),
  ('+251911100002', '+251911200037', 'LIKE'),
  ('+251911100005', '+251911200037', 'LIKE'),
  ('+251911100008', '+251911200037', 'LIKE'),
  ('+251911100011', '+251911200037', 'LIKE'),
  ('+251911100014', '+251911200037', 'LIKE'),
  ('+251911100017', '+251911200038', 'LIKE'),
  ('+251911100020', '+251911200038', 'LIKE'),
  ('+251911100023', '+251911200038', 'LIKE'),
  ('+251911100003', '+251911200038', 'LIKE'),
  ('+251911100006', '+251911200038', 'LIKE'),
  ('+251911100009', '+251911200038', 'LIKE'),
  ('+251911100012', '+251911200038', 'LIKE'),
  ('+251911100015', '+251911200038', 'LIKE'),
  ('+251911100018', '+251911200039', 'LIKE'),
  ('+251911100021', '+251911200039', 'LIKE'),
  ('+251911100024', '+251911200039', 'LIKE'),
  ('+251911100004', '+251911200039', 'LIKE'),
  ('+251911100007', '+251911200039', 'LIKE'),
  ('+251911100010', '+251911200039', 'LIKE'),
  ('+251911100013', '+251911200039', 'LIKE'),
  ('+251911100016', '+251911200039', 'LIKE'),
  ('+251911100019', '+251911200040', 'LIKE'),
  ('+251911100022', '+251911200040', 'LIKE'),
  ('+251911100002', '+251911200040', 'LIKE'),
  ('+251911100005', '+251911200040', 'LIKE'),
  ('+251911100008', '+251911200040', 'LIKE'),
  ('+251911100011', '+251911200040', 'LIKE'),
  ('+251911100014', '+251911200040', 'LIKE'),
  ('+251911100017', '+251911200040', 'LIKE'),
  ('+251911100020', '+251911200041', 'LIKE'),
  ('+251911100023', '+251911200041', 'LIKE'),
  ('+251911100003', '+251911200041', 'LIKE'),
  ('+251911100006', '+251911200041', 'LIKE'),
  ('+251911100009', '+251911200041', 'LIKE'),
  ('+251911100012', '+251911200041', 'LIKE'),
  ('+251911100015', '+251911200041', 'LIKE'),
  ('+251911100018', '+251911200041', 'LIKE'),
  ('+251911100021', '+251911200042', 'LIKE'),
  ('+251911100024', '+251911200042', 'LIKE'),
  ('+251911100007', '+251911200042', 'LIKE'),
  ('+251911100010', '+251911200042', 'LIKE'),
  ('+251911100013', '+251911200042', 'LIKE'),
  ('+251911100016', '+251911200042', 'LIKE'),
  ('+251911100019', '+251911200042', 'LIKE'),
  ('+251911100022', '+251911200043', 'LIKE'),
  ('+251911100002', '+251911200043', 'LIKE'),
  ('+251911100005', '+251911200043', 'LIKE'),
  ('+251911100008', '+251911200043', 'LIKE'),
  ('+251911100011', '+251911200043', 'LIKE'),
  ('+251911100014', '+251911200043', 'LIKE'),
  ('+251911100017', '+251911200043', 'LIKE'),
  ('+251911100020', '+251911200043', 'LIKE'),
  ('+251911100023', '+251911200044', 'LIKE'),
  ('+251911100003', '+251911200044', 'LIKE'),
  ('+251911100006', '+251911200044', 'LIKE'),
  ('+251911100009', '+251911200044', 'LIKE'),
  ('+251911100012', '+251911200044', 'LIKE'),
  ('+251911100015', '+251911200044', 'LIKE'),
  ('+251911100018', '+251911200044', 'LIKE'),
  ('+251911100021', '+251911200044', 'LIKE'),
  ('+251911100024', '+251911200045', 'LIKE'),
  ('+251911100004', '+251911200045', 'LIKE'),
  ('+251911100007', '+251911200045', 'LIKE'),
  ('+251911100010', '+251911200045', 'LIKE'),
  ('+251911100013', '+251911200045', 'LIKE'),
  ('+251911100016', '+251911200045', 'LIKE'),
  ('+251911100019', '+251911200045', 'LIKE'),
  ('+251911100022', '+251911200045', 'LIKE'),
  ('+251911100002', '+251911200046', 'LIKE'),
  ('+251911100005', '+251911200046', 'LIKE'),
  ('+251911100008', '+251911200046', 'LIKE'),
  ('+251911100011', '+251911200046', 'LIKE'),
  ('+251911100014', '+251911200046', 'LIKE'),
  ('+251911100017', '+251911200046', 'LIKE'),
  ('+251911100020', '+251911200046', 'LIKE'),
  ('+251911100023', '+251911200046', 'LIKE'),
  ('+251911100003', '+251911200047', 'LIKE'),
  ('+251911100006', '+251911200047', 'LIKE'),
  ('+251911100009', '+251911200047', 'LIKE'),
  ('+251911100012', '+251911200047', 'LIKE'),
  ('+251911100015', '+251911200047', 'LIKE'),
  ('+251911100018', '+251911200047', 'LIKE'),
  ('+251911100021', '+251911200047', 'LIKE'),
  ('+251911100024', '+251911200047', 'LIKE'),
  ('+251911100004', '+251911200048', 'LIKE'),
  ('+251911100007', '+251911200048', 'LIKE'),
  ('+251911100010', '+251911200048', 'LIKE'),
  ('+251911100013', '+251911200048', 'LIKE'),
  ('+251911100016', '+251911200048', 'LIKE'),
  ('+251911100019', '+251911200048', 'LIKE'),
  ('+251911100022', '+251911200048', 'LIKE'),
  ('+251911100002', '+251911200048', 'LIKE'),
  ('+251911100005', '+251911200049', 'LIKE'),
  ('+251911100008', '+251911200049', 'LIKE'),
  ('+251911100011', '+251911200049', 'LIKE'),
  ('+251911100014', '+251911200049', 'LIKE'),
  ('+251911100017', '+251911200049', 'LIKE'),
  ('+251911100020', '+251911200049', 'LIKE'),
  ('+251911100023', '+251911200049', 'LIKE'),
  ('+251911100003', '+251911200049', 'LIKE'),
  ('+251911100006', '+251911200050', 'LIKE'),
  ('+251911100009', '+251911200050', 'LIKE'),
  ('+251911100015', '+251911200050', 'LIKE'),
  ('+251911100018', '+251911200050', 'LIKE'),
  ('+251911100021', '+251911200050', 'LIKE'),
  ('+251911100024', '+251911200050', 'LIKE'),
  ('+251911100004', '+251911200050', 'LIKE'),
  ('+251911100007', '+251911200051', 'LIKE'),
  ('+251911100010', '+251911200051', 'LIKE'),
  ('+251911100013', '+251911200051', 'LIKE'),
  ('+251911100016', '+251911200051', 'LIKE'),
  ('+251911100019', '+251911200051', 'LIKE'),
  ('+251911100022', '+251911200051', 'LIKE'),
  ('+251911100002', '+251911200051', 'LIKE'),
  ('+251911100005', '+251911200051', 'LIKE'),
  ('+251911100008', '+251911200052', 'LIKE'),
  ('+251911100011', '+251911200052', 'LIKE'),
  ('+251911100014', '+251911200052', 'LIKE'),
  ('+251911100017', '+251911200052', 'LIKE'),
  ('+251911100020', '+251911200052', 'LIKE'),
  ('+251911100023', '+251911200052', 'LIKE'),
  ('+251911100003', '+251911200052', 'LIKE'),
  ('+251911100006', '+251911200052', 'LIKE'),
  ('+251911100009', '+251911200053', 'LIKE'),
  ('+251911100012', '+251911200053', 'LIKE'),
  ('+251911100015', '+251911200053', 'LIKE'),
  ('+251911100018', '+251911200053', 'LIKE'),
  ('+251911100021', '+251911200053', 'LIKE'),
  ('+251911100024', '+251911200053', 'LIKE'),
  ('+251911100004', '+251911200053', 'LIKE'),
  ('+251911100007', '+251911200053', 'LIKE'),
  ('+251911100010', '+251911200054', 'LIKE'),
  ('+251911100013', '+251911200054', 'LIKE'),
  ('+251911100016', '+251911200054', 'LIKE'),
  ('+251911100019', '+251911200054', 'LIKE'),
  ('+251911100022', '+251911200054', 'LIKE'),
  ('+251911100002', '+251911200054', 'LIKE'),
  ('+251911100005', '+251911200054', 'LIKE'),
  ('+251911100008', '+251911200054', 'LIKE'),
  ('+251911100011', '+251911200055', 'LIKE'),
  ('+251911100014', '+251911200055', 'LIKE'),
  ('+251911100017', '+251911200055', 'LIKE'),
  ('+251911100020', '+251911200055', 'LIKE'),
  ('+251911100023', '+251911200055', 'LIKE'),
  ('+251911100003', '+251911200055', 'LIKE'),
  ('+251911100006', '+251911200055', 'LIKE'),
  ('+251911100009', '+251911200055', 'LIKE'),
  ('+251911100012', '+251911200056', 'LIKE'),
  ('+251911100015', '+251911200056', 'LIKE'),
  ('+251911100018', '+251911200056', 'LIKE'),
  ('+251911100021', '+251911200056', 'LIKE'),
  ('+251911100024', '+251911200056', 'LIKE'),
  ('+251911100004', '+251911200056', 'LIKE'),
  ('+251911100007', '+251911200056', 'LIKE'),
  ('+251911100010', '+251911200056', 'LIKE'),
  ('+251911100013', '+251911200057', 'LIKE'),
  ('+251911100016', '+251911200057', 'LIKE'),
  ('+251911100019', '+251911200057', 'LIKE'),
  ('+251911100022', '+251911200057', 'LIKE'),
  ('+251911100002', '+251911200057', 'LIKE'),
  ('+251911100005', '+251911200057', 'LIKE'),
  ('+251911100008', '+251911200057', 'LIKE'),
  ('+251911100011', '+251911200057', 'LIKE'),
  ('+251911100014', '+251911200058', 'LIKE'),
  ('+251911100017', '+251911200058', 'LIKE'),
  ('+251911100020', '+251911200058', 'LIKE'),
  ('+251911100023', '+251911200058', 'LIKE'),
  ('+251911100003', '+251911200058', 'LIKE'),
  ('+251911100006', '+251911200058', 'LIKE'),
  ('+251911100009', '+251911200058', 'LIKE'),
  ('+251911100012', '+251911200058', 'LIKE'),
  ('+251911100015', '+251911200059', 'LIKE'),
  ('+251911100018', '+251911200059', 'LIKE'),
  ('+251911100021', '+251911200059', 'LIKE'),
  ('+251911100024', '+251911200059', 'LIKE'),
  ('+251911100004', '+251911200059', 'LIKE'),
  ('+251911100007', '+251911200059', 'LIKE'),
  ('+251911100010', '+251911200059', 'LIKE'),
  ('+251911100013', '+251911200059', 'LIKE'),
  ('+251911100005', '+251911200001', 'LIKE'),
  ('+251911100007', '+251911200001', 'LIKE'),
  ('+251911100011', '+251911200001', 'LIKE'),
  ('+251911100013', '+251911200001', 'LIKE'),
  ('+251911100017', '+251911200001', 'LIKE'),
  ('+251911100019', '+251911200001', 'LIKE'),
  ('+251911100023', '+251911200001', 'LIKE'),
  ('+251911100006', '+251911200002', 'LIKE'),
  ('+251911100008', '+251911200002', 'LIKE'),
  ('+251911100012', '+251911200002', 'LIKE'),
  ('+251911100014', '+251911200002', 'LIKE'),
  ('+251911100018', '+251911200002', 'LIKE'),
  ('+251911100020', '+251911200002', 'LIKE'),
  ('+251911100024', '+251911200002', 'LIKE'),
  ('+251911100007', '+251911200003', 'LIKE'),
  ('+251911100009', '+251911200003', 'LIKE'),
  ('+251911100013', '+251911200003', 'LIKE'),
  ('+251911100015', '+251911200003', 'LIKE'),
  ('+251911100019', '+251911200003', 'LIKE'),
  ('+251911100021', '+251911200003', 'LIKE'),
  ('+251911100002', '+251911200004', 'LIKE'),
  ('+251911100008', '+251911200004', 'LIKE'),
  ('+251911100010', '+251911200004', 'LIKE'),
  ('+251911100014', '+251911200004', 'LIKE'),
  ('+251911100016', '+251911200004', 'LIKE'),
  ('+251911100020', '+251911200004', 'LIKE'),
  ('+251911100022', '+251911200004', 'LIKE'),
  ('+251911100003', '+251911200005', 'LIKE'),
  ('+251911100009', '+251911200005', 'LIKE'),
  ('+251911100011', '+251911200005', 'LIKE'),
  ('+251911100015', '+251911200005', 'LIKE'),
  ('+251911100017', '+251911200005', 'LIKE'),
  ('+251911100021', '+251911200005', 'LIKE'),
  ('+251911100023', '+251911200005', 'LIKE'),
  ('+251911100002', '+251911200006', 'LIKE'),
  ('+251911100004', '+251911200006', 'LIKE'),
  ('+251911100010', '+251911200006', 'LIKE'),
  ('+251911100012', '+251911200006', 'LIKE'),
  ('+251911100016', '+251911200006', 'LIKE'),
  ('+251911100018', '+251911200006', 'LIKE'),
  ('+251911100022', '+251911200006', 'LIKE'),
  ('+251911100024', '+251911200006', 'LIKE'),
  ('+251911100003', '+251911200007', 'LIKE'),
  ('+251911100005', '+251911200007', 'LIKE'),
  ('+251911100011', '+251911200007', 'LIKE'),
  ('+251911100013', '+251911200007', 'LIKE'),
  ('+251911100017', '+251911200007', 'LIKE'),
  ('+251911100019', '+251911200007', 'LIKE'),
  ('+251911100023', '+251911200007', 'LIKE'),
  ('+251911100004', '+251911200008', 'LIKE'),
  ('+251911100006', '+251911200008', 'LIKE'),
  ('+251911100012', '+251911200008', 'LIKE'),
  ('+251911100014', '+251911200008', 'LIKE'),
  ('+251911100018', '+251911200008', 'LIKE'),
  ('+251911100020', '+251911200008', 'LIKE'),
  ('+251911100024', '+251911200008', 'LIKE'),
  ('+251911100005', '+251911200009', 'LIKE'),
  ('+251911100007', '+251911200009', 'LIKE'),
  ('+251911100013', '+251911200009', 'LIKE'),
  ('+251911100015', '+251911200009', 'LIKE'),
  ('+251911100019', '+251911200009', 'LIKE'),
  ('+251911100021', '+251911200009', 'LIKE'),
  ('+251911100002', '+251911200010', 'LIKE'),
  ('+251911100008', '+251911200010', 'LIKE'),
  ('+251911100014', '+251911200010', 'LIKE'),
  ('+251911100016', '+251911200010', 'LIKE'),
  ('+251911100020', '+251911200010', 'LIKE'),
  ('+251911100022', '+251911200010', 'LIKE'),
  ('+251911100003', '+251911200011', 'LIKE'),
  ('+251911100007', '+251911200011', 'LIKE'),
  ('+251911100009', '+251911200011', 'LIKE'),
  ('+251911100015', '+251911200011', 'LIKE'),
  ('+251911100017', '+251911200011', 'LIKE'),
  ('+251911100021', '+251911200011', 'LIKE'),
  ('+251911100023', '+251911200011', 'LIKE'),
  ('+251911100002', '+251911200012', 'LIKE'),
  ('+251911100004', '+251911200012', 'LIKE'),
  ('+251911100010', '+251911200012', 'LIKE'),
  ('+251911100016', '+251911200012', 'LIKE'),
  ('+251911100018', '+251911200012', 'LIKE'),
  ('+251911100022', '+251911200012', 'LIKE'),
  ('+251911100024', '+251911200012', 'LIKE'),
  ('+251911100003', '+251911200013', 'LIKE'),
  ('+251911100005', '+251911200013', 'LIKE'),
  ('+251911100009', '+251911200013', 'LIKE'),
  ('+251911100011', '+251911200013', 'LIKE'),
  ('+251911100017', '+251911200013', 'LIKE'),
  ('+251911100019', '+251911200013', 'LIKE'),
  ('+251911100023', '+251911200013', 'LIKE'),
  ('+251911100004', '+251911200014', 'LIKE'),
  ('+251911100006', '+251911200014', 'LIKE'),
  ('+251911100010', '+251911200014', 'LIKE'),
  ('+251911100012', '+251911200014', 'LIKE'),
  ('+251911100018', '+251911200014', 'LIKE'),
  ('+251911100020', '+251911200014', 'LIKE'),
  ('+251911100024', '+251911200014', 'LIKE'),
  ('+251911100005', '+251911200015', 'LIKE'),
  ('+251911100007', '+251911200015', 'LIKE'),
  ('+251911100011', '+251911200015', 'LIKE'),
  ('+251911100013', '+251911200015', 'LIKE'),
  ('+251911100019', '+251911200015', 'LIKE'),
  ('+251911100021', '+251911200015', 'LIKE'),
  ('+251911100002', '+251911200016', 'LIKE'),
  ('+251911100006', '+251911200016', 'LIKE'),
  ('+251911100008', '+251911200016', 'LIKE'),
  ('+251911100012', '+251911200016', 'LIKE'),
  ('+251911100014', '+251911200016', 'LIKE'),
  ('+251911100020', '+251911200016', 'LIKE'),
  ('+251911100022', '+251911200016', 'LIKE'),
  ('+251911100001', '+251911200025', 'PASS'),
  ('+251911100001', '+251911200026', 'PASS'),
  ('+251911100001', '+251911200027', 'PASS'),
  ('+251911100001', '+251911200028', 'PASS'),
  ('+251911100001', '+251911200029', 'PASS'),
  ('+251911100001', '+251911200030', 'PASS'),
  ('+251911100001', '+251911200031', 'PASS'),
  ('+251911100001', '+251911200032', 'PASS'),
  ('+251911100002', '+251911200019', 'PASS'),
  ('+251911100003', '+251911200020', 'PASS'),
  ('+251911100004', '+251911200021', 'PASS'),
  ('+251911100005', '+251911200022', 'PASS'),
  ('+251911100006', '+251911200023', 'PASS'),
  ('+251911100007', '+251911200024', 'PASS'),
  ('+251911100008', '+251911200025', 'PASS'),
  ('+251911100009', '+251911200017', 'PASS'),
  ('+251911100009', '+251911200026', 'PASS'),
  ('+251911100010', '+251911200018', 'PASS'),
  ('+251911100010', '+251911200027', 'PASS'),
  ('+251911100011', '+251911200019', 'PASS'),
  ('+251911100011', '+251911200028', 'PASS'),
  ('+251911100012', '+251911200020', 'PASS'),
  ('+251911100012', '+251911200029', 'PASS'),
  ('+251911100013', '+251911200021', 'PASS'),
  ('+251911100013', '+251911200030', 'PASS'),
  ('+251911100014', '+251911200022', 'PASS'),
  ('+251911100014', '+251911200031', 'PASS'),
  ('+251911100015', '+251911200023', 'PASS'),
  ('+251911100015', '+251911200032', 'PASS'),
  ('+251911100016', '+251911200024', 'PASS'),
  ('+251911100016', '+251911200033', 'PASS'),
  ('+251911100017', '+251911200025', 'PASS'),
  ('+251911100017', '+251911200034', 'PASS'),
  ('+251911100018', '+251911200026', 'PASS'),
  ('+251911100018', '+251911200035', 'PASS'),
  ('+251911100019', '+251911200027', 'PASS'),
  ('+251911100019', '+251911200036', 'PASS'),
  ('+251911100020', '+251911200028', 'PASS'),
  ('+251911100020', '+251911200037', 'PASS'),
  ('+251911100021', '+251911200029', 'PASS'),
  ('+251911100021', '+251911200038', 'PASS'),
  ('+251911100022', '+251911200030', 'PASS'),
  ('+251911100022', '+251911200039', 'PASS'),
  ('+251911100023', '+251911200031', 'PASS'),
  ('+251911100023', '+251911200040', 'PASS'),
  ('+251911100024', '+251911200032', 'PASS'),
  ('+251911100024', '+251911200041', 'PASS')
) AS pairs(from_phone, to_phone, action)
JOIN users m ON m.phone_e164 = pairs.from_phone
JOIN users w ON w.phone_e164 = pairs.to_phone;

INSERT INTO connections (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at, a_responded_at, b_responded_at, updated_at
) VALUES
(
  'cccccccc-cccc-cccc-cccc-cccccccccc01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc17', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc18', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc19', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc20', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc21', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc22', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc23', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc24', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc25', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc26', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc27', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc28', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58',
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc29', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc30', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc31', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc32', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc33', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc34', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc35', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc36', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc37', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc38', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc39', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc40', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44',
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc41', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33',
  'DECLINED', 'Shared love of running — optional intro.', 'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc42', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34',
  'DECLINED', 'Shared love of running — optional intro.', 'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc43', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35',
  'DECLINED', 'Shared love of running — optional intro.', 'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc44', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46',
  'DECLINED', 'Shared love of running — optional intro.', 'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc45', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36',
  'EXPIRED', 'Startup founder meets market explorer.', 'ስታርትአፕ እና ገበያ።',
  NOW() - INTERVAL '2 days', 'DISCOVERY',
  NOW() - INTERVAL '14 days', NULL, NULL, NOW() - INTERVAL '2 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc46', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37',
  'EXPIRED', 'Startup founder meets market explorer.', 'ስታርትአፕ እና ገበያ።',
  NOW() - INTERVAL '2 days', 'DISCOVERY',
  NOW() - INTERVAL '14 days', NULL, NULL, NOW() - INTERVAL '2 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc47', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47',
  'EXPIRED', 'Startup founder meets market explorer.', 'ስታርትአፕ እና ገበያ።',
  NOW() - INTERVAL '2 days', 'DISCOVERY',
  NOW() - INTERVAL '14 days', NULL, NULL, NOW() - INTERVAL '2 days'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccc48', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38',
  'CANCELLED', 'Evening fell through — kept on file.', 'ተሰርዟል።',
  NOW() - INTERVAL '1 day', 'DISCOVERY',
  NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '3 days'
);

UPDATE member_profiles SET
    session_rate_etb = 3500 + ((ABS(HASHTEXT(user_id::text)) % 8) * 500),
    overnight_rate_etb = 12000 + ((ABS(HASHTEXT(user_id::text)) % 6) * 1500),
    availability_note = 'See calendar for open windows',
    listing_active = TRUE
WHERE user_id IN (SELECT id FROM users WHERE gender = 'FEMALE' AND phone_e164 LIKE '+251911200%');

UPDATE member_profiles p SET availability_note = v.note
FROM (VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53', 'Evenings only · Kazanchis'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54', 'Last-minute nights welcome'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'Tonight · hotel or private suite'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56', 'Weeknights after 8 · Bole'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57', 'Weekends open · discreet venue'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'See calendar for open windows'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59', 'Evenings only · Kazanchis')
) AS v(user_id, note)
WHERE p.user_id = v.user_id::uuid;

UPDATE users SET status = 'ACTIVE' WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60';
UPDATE member_profiles SET listing_active = FALSE
WHERE user_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60';

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '18 hours',
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '23 hours',
       'Evening session'
FROM users u
CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%'
  AND u.id <> 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60';

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '20 hours',
       date_trunc('hour', NOW()) + ((d.day + 1) * INTERVAL '1 day') + INTERVAL '8 hours',
       'Overnight'
FROM users u
CROSS JOIN (VALUES (1),(3),(5)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%'
  AND u.id <> 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60';

INSERT INTO verification_cases (id, user_id, status, id_document_url, selfie_url, notes, reviewed_at, created_at, updated_at)
VALUES
(
  '99999999-9999-4999-8999-999999999901', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb60', 'SUBMITTED',
  'https://randomuser.me/api/portraits/women/90.jpg',
  'https://randomuser.me/api/portraits/women/91.jpg',
  'Demo queue — pending ID review',
  NULL, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'
),
(
  '99999999-9999-4999-8999-999999999902', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'APPROVED',
  'https://randomuser.me/api/portraits/women/1.jpg',
  'https://randomuser.me/api/portraits/women/4.jpg',
  'Demo approved',
  NOW() - INTERVAL '21 days', NOW() - INTERVAL '22 days', NOW() - INTERVAL '21 days'
),
(
  '99999999-9999-4999-8999-999999999903', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'APPROVED',
  'https://randomuser.me/api/portraits/women/2.jpg',
  'https://randomuser.me/api/portraits/women/5.jpg',
  'Demo approved',
  NOW() - INTERVAL '22 days', NOW() - INTERVAL '23 days', NOW() - INTERVAL '22 days'
),
(
  '99999999-9999-4999-8999-999999999904', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'APPROVED',
  'https://randomuser.me/api/portraits/women/3.jpg',
  'https://randomuser.me/api/portraits/women/6.jpg',
  'Demo approved',
  NOW() - INTERVAL '23 days', NOW() - INTERVAL '24 days', NOW() - INTERVAL '23 days'
),
(
  '99999999-9999-4999-8999-999999999905', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'APPROVED',
  'https://randomuser.me/api/portraits/women/4.jpg',
  'https://randomuser.me/api/portraits/women/7.jpg',
  'Demo approved',
  NOW() - INTERVAL '24 days', NOW() - INTERVAL '25 days', NOW() - INTERVAL '24 days'
),
(
  '99999999-9999-4999-8999-999999999906', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'APPROVED',
  'https://randomuser.me/api/portraits/women/5.jpg',
  'https://randomuser.me/api/portraits/women/8.jpg',
  'Demo approved',
  NOW() - INTERVAL '25 days', NOW() - INTERVAL '26 days', NOW() - INTERVAL '25 days'
),
(
  '99999999-9999-4999-8999-999999999907', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'APPROVED',
  'https://randomuser.me/api/portraits/women/6.jpg',
  'https://randomuser.me/api/portraits/women/9.jpg',
  'Demo approved',
  NOW() - INTERVAL '26 days', NOW() - INTERVAL '27 days', NOW() - INTERVAL '26 days'
),
(
  '99999999-9999-4999-8999-999999999908', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'APPROVED',
  'https://randomuser.me/api/portraits/women/7.jpg',
  'https://randomuser.me/api/portraits/women/10.jpg',
  'Demo approved',
  NOW() - INTERVAL '27 days', NOW() - INTERVAL '28 days', NOW() - INTERVAL '27 days'
),
(
  '99999999-9999-4999-8999-999999999909', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'APPROVED',
  'https://randomuser.me/api/portraits/women/8.jpg',
  'https://randomuser.me/api/portraits/women/11.jpg',
  'Demo approved',
  NOW() - INTERVAL '28 days', NOW() - INTERVAL '29 days', NOW() - INTERVAL '28 days'
),
(
  '99999999-9999-4999-8999-999999999910', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'APPROVED',
  'https://randomuser.me/api/portraits/women/9.jpg',
  'https://randomuser.me/api/portraits/women/12.jpg',
  'Demo approved',
  NOW() - INTERVAL '29 days', NOW() - INTERVAL '30 days', NOW() - INTERVAL '29 days'
),
(
  '99999999-9999-4999-8999-999999999911', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'APPROVED',
  'https://randomuser.me/api/portraits/women/10.jpg',
  'https://randomuser.me/api/portraits/women/13.jpg',
  'Demo approved',
  NOW() - INTERVAL '30 days', NOW() - INTERVAL '31 days', NOW() - INTERVAL '30 days'
),
(
  '99999999-9999-4999-8999-999999999912', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'APPROVED',
  'https://randomuser.me/api/portraits/women/11.jpg',
  'https://randomuser.me/api/portraits/women/14.jpg',
  'Demo approved',
  NOW() - INTERVAL '31 days', NOW() - INTERVAL '32 days', NOW() - INTERVAL '31 days'
),
(
  '99999999-9999-4999-8999-999999999913', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'APPROVED',
  'https://randomuser.me/api/portraits/women/12.jpg',
  'https://randomuser.me/api/portraits/women/15.jpg',
  'Demo approved',
  NOW() - INTERVAL '32 days', NOW() - INTERVAL '33 days', NOW() - INTERVAL '32 days'
),
(
  '99999999-9999-4999-8999-999999999914', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'APPROVED',
  'https://randomuser.me/api/portraits/women/13.jpg',
  'https://randomuser.me/api/portraits/women/16.jpg',
  'Demo approved',
  NOW() - INTERVAL '33 days', NOW() - INTERVAL '34 days', NOW() - INTERVAL '33 days'
),
(
  '99999999-9999-4999-8999-999999999915', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'APPROVED',
  'https://randomuser.me/api/portraits/women/14.jpg',
  'https://randomuser.me/api/portraits/women/17.jpg',
  'Demo approved',
  NOW() - INTERVAL '34 days', NOW() - INTERVAL '35 days', NOW() - INTERVAL '34 days'
),
(
  '99999999-9999-4999-8999-999999999916', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'APPROVED',
  'https://randomuser.me/api/portraits/women/15.jpg',
  'https://randomuser.me/api/portraits/women/18.jpg',
  'Demo approved',
  NOW() - INTERVAL '35 days', NOW() - INTERVAL '36 days', NOW() - INTERVAL '35 days'
),
(
  '99999999-9999-4999-8999-999999999917', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'APPROVED',
  'https://randomuser.me/api/portraits/women/16.jpg',
  'https://randomuser.me/api/portraits/women/19.jpg',
  'Demo approved',
  NOW() - INTERVAL '36 days', NOW() - INTERVAL '37 days', NOW() - INTERVAL '36 days'
),
(
  '99999999-9999-4999-8999-999999999918', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', 'APPROVED',
  'https://randomuser.me/api/portraits/women/17.jpg',
  'https://randomuser.me/api/portraits/women/20.jpg',
  'Demo approved',
  NOW() - INTERVAL '37 days', NOW() - INTERVAL '38 days', NOW() - INTERVAL '37 days'
),
(
  '99999999-9999-4999-8999-999999999919', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', 'APPROVED',
  'https://randomuser.me/api/portraits/women/18.jpg',
  'https://randomuser.me/api/portraits/women/21.jpg',
  'Demo approved',
  NOW() - INTERVAL '38 days', NOW() - INTERVAL '39 days', NOW() - INTERVAL '38 days'
),
(
  '99999999-9999-4999-8999-999999999920', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19', 'APPROVED',
  'https://randomuser.me/api/portraits/women/19.jpg',
  'https://randomuser.me/api/portraits/women/22.jpg',
  'Demo approved',
  NOW() - INTERVAL '39 days', NOW() - INTERVAL '40 days', NOW() - INTERVAL '39 days'
),
(
  '99999999-9999-4999-8999-999999999921', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20', 'APPROVED',
  'https://randomuser.me/api/portraits/women/20.jpg',
  'https://randomuser.me/api/portraits/women/23.jpg',
  'Demo approved',
  NOW() - INTERVAL '40 days', NOW() - INTERVAL '41 days', NOW() - INTERVAL '40 days'
),
(
  '99999999-9999-4999-8999-999999999922', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21', 'APPROVED',
  'https://randomuser.me/api/portraits/women/21.jpg',
  'https://randomuser.me/api/portraits/women/24.jpg',
  'Demo approved',
  NOW() - INTERVAL '41 days', NOW() - INTERVAL '42 days', NOW() - INTERVAL '41 days'
),
(
  '99999999-9999-4999-8999-999999999923', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22', 'APPROVED',
  'https://randomuser.me/api/portraits/women/22.jpg',
  'https://randomuser.me/api/portraits/women/25.jpg',
  'Demo approved',
  NOW() - INTERVAL '42 days', NOW() - INTERVAL '43 days', NOW() - INTERVAL '42 days'
),
(
  '99999999-9999-4999-8999-999999999924', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23', 'APPROVED',
  'https://randomuser.me/api/portraits/women/23.jpg',
  'https://randomuser.me/api/portraits/women/26.jpg',
  'Demo approved',
  NOW() - INTERVAL '43 days', NOW() - INTERVAL '44 days', NOW() - INTERVAL '43 days'
),
(
  '99999999-9999-4999-8999-999999999925', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24', 'APPROVED',
  'https://randomuser.me/api/portraits/women/24.jpg',
  'https://randomuser.me/api/portraits/women/27.jpg',
  'Demo approved',
  NOW() - INTERVAL '44 days', NOW() - INTERVAL '45 days', NOW() - INTERVAL '44 days'
),
(
  '99999999-9999-4999-8999-999999999926', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25', 'APPROVED',
  'https://randomuser.me/api/portraits/women/25.jpg',
  'https://randomuser.me/api/portraits/women/28.jpg',
  'Demo approved',
  NOW() - INTERVAL '45 days', NOW() - INTERVAL '46 days', NOW() - INTERVAL '45 days'
),
(
  '99999999-9999-4999-8999-999999999927', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26', 'APPROVED',
  'https://randomuser.me/api/portraits/women/26.jpg',
  'https://randomuser.me/api/portraits/women/29.jpg',
  'Demo approved',
  NOW() - INTERVAL '46 days', NOW() - INTERVAL '47 days', NOW() - INTERVAL '46 days'
),
(
  '99999999-9999-4999-8999-999999999928', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27', 'APPROVED',
  'https://randomuser.me/api/portraits/women/27.jpg',
  'https://randomuser.me/api/portraits/women/30.jpg',
  'Demo approved',
  NOW() - INTERVAL '47 days', NOW() - INTERVAL '48 days', NOW() - INTERVAL '47 days'
),
(
  '99999999-9999-4999-8999-999999999929', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28', 'APPROVED',
  'https://randomuser.me/api/portraits/women/28.jpg',
  'https://randomuser.me/api/portraits/women/31.jpg',
  'Demo approved',
  NOW() - INTERVAL '48 days', NOW() - INTERVAL '49 days', NOW() - INTERVAL '48 days'
),
(
  '99999999-9999-4999-8999-999999999930', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29', 'APPROVED',
  'https://randomuser.me/api/portraits/women/29.jpg',
  'https://randomuser.me/api/portraits/women/32.jpg',
  'Demo approved',
  NOW() - INTERVAL '49 days', NOW() - INTERVAL '50 days', NOW() - INTERVAL '49 days'
),
(
  '99999999-9999-4999-8999-999999999931', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30', 'APPROVED',
  'https://randomuser.me/api/portraits/women/30.jpg',
  'https://randomuser.me/api/portraits/women/33.jpg',
  'Demo approved',
  NOW() - INTERVAL '50 days', NOW() - INTERVAL '51 days', NOW() - INTERVAL '50 days'
),
(
  '99999999-9999-4999-8999-999999999932', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31', 'APPROVED',
  'https://randomuser.me/api/portraits/women/31.jpg',
  'https://randomuser.me/api/portraits/women/34.jpg',
  'Demo approved',
  NOW() - INTERVAL '51 days', NOW() - INTERVAL '52 days', NOW() - INTERVAL '51 days'
),
(
  '99999999-9999-4999-8999-999999999933', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32', 'APPROVED',
  'https://randomuser.me/api/portraits/women/32.jpg',
  'https://randomuser.me/api/portraits/women/35.jpg',
  'Demo approved',
  NOW() - INTERVAL '52 days', NOW() - INTERVAL '53 days', NOW() - INTERVAL '52 days'
),
(
  '99999999-9999-4999-8999-999999999934', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33', 'APPROVED',
  'https://randomuser.me/api/portraits/women/33.jpg',
  'https://randomuser.me/api/portraits/women/36.jpg',
  'Demo approved',
  NOW() - INTERVAL '53 days', NOW() - INTERVAL '54 days', NOW() - INTERVAL '53 days'
),
(
  '99999999-9999-4999-8999-999999999935', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34', 'APPROVED',
  'https://randomuser.me/api/portraits/women/34.jpg',
  'https://randomuser.me/api/portraits/women/37.jpg',
  'Demo approved',
  NOW() - INTERVAL '54 days', NOW() - INTERVAL '55 days', NOW() - INTERVAL '54 days'
),
(
  '99999999-9999-4999-8999-999999999936', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35', 'APPROVED',
  'https://randomuser.me/api/portraits/women/35.jpg',
  'https://randomuser.me/api/portraits/women/38.jpg',
  'Demo approved',
  NOW() - INTERVAL '55 days', NOW() - INTERVAL '56 days', NOW() - INTERVAL '55 days'
),
(
  '99999999-9999-4999-8999-999999999937', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36', 'APPROVED',
  'https://randomuser.me/api/portraits/women/36.jpg',
  'https://randomuser.me/api/portraits/women/39.jpg',
  'Demo approved',
  NOW() - INTERVAL '56 days', NOW() - INTERVAL '57 days', NOW() - INTERVAL '56 days'
),
(
  '99999999-9999-4999-8999-999999999938', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37', 'APPROVED',
  'https://randomuser.me/api/portraits/women/37.jpg',
  'https://randomuser.me/api/portraits/women/40.jpg',
  'Demo approved',
  NOW() - INTERVAL '57 days', NOW() - INTERVAL '58 days', NOW() - INTERVAL '57 days'
),
(
  '99999999-9999-4999-8999-999999999939', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38', 'APPROVED',
  'https://randomuser.me/api/portraits/women/38.jpg',
  'https://randomuser.me/api/portraits/women/41.jpg',
  'Demo approved',
  NOW() - INTERVAL '58 days', NOW() - INTERVAL '59 days', NOW() - INTERVAL '58 days'
),
(
  '99999999-9999-4999-8999-999999999940', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39', 'APPROVED',
  'https://randomuser.me/api/portraits/women/39.jpg',
  'https://randomuser.me/api/portraits/women/42.jpg',
  'Demo approved',
  NOW() - INTERVAL '59 days', NOW() - INTERVAL '60 days', NOW() - INTERVAL '59 days'
),
(
  '99999999-9999-4999-8999-999999999941', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'APPROVED',
  'https://randomuser.me/api/portraits/women/40.jpg',
  'https://randomuser.me/api/portraits/women/43.jpg',
  'Demo approved',
  NOW() - INTERVAL '60 days', NOW() - INTERVAL '61 days', NOW() - INTERVAL '60 days'
),
(
  '99999999-9999-4999-8999-999999999942', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41', 'APPROVED',
  'https://randomuser.me/api/portraits/women/41.jpg',
  'https://randomuser.me/api/portraits/women/44.jpg',
  'Demo approved',
  NOW() - INTERVAL '61 days', NOW() - INTERVAL '62 days', NOW() - INTERVAL '61 days'
),
(
  '99999999-9999-4999-8999-999999999943', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42', 'APPROVED',
  'https://randomuser.me/api/portraits/women/42.jpg',
  'https://randomuser.me/api/portraits/women/45.jpg',
  'Demo approved',
  NOW() - INTERVAL '62 days', NOW() - INTERVAL '63 days', NOW() - INTERVAL '62 days'
),
(
  '99999999-9999-4999-8999-999999999944', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43', 'APPROVED',
  'https://randomuser.me/api/portraits/women/43.jpg',
  'https://randomuser.me/api/portraits/women/46.jpg',
  'Demo approved',
  NOW() - INTERVAL '63 days', NOW() - INTERVAL '64 days', NOW() - INTERVAL '63 days'
),
(
  '99999999-9999-4999-8999-999999999945', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44', 'APPROVED',
  'https://randomuser.me/api/portraits/women/44.jpg',
  'https://randomuser.me/api/portraits/women/47.jpg',
  'Demo approved',
  NOW() - INTERVAL '64 days', NOW() - INTERVAL '65 days', NOW() - INTERVAL '64 days'
),
(
  '99999999-9999-4999-8999-999999999946', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'APPROVED',
  'https://randomuser.me/api/portraits/women/45.jpg',
  'https://randomuser.me/api/portraits/women/48.jpg',
  'Demo approved',
  NOW() - INTERVAL '65 days', NOW() - INTERVAL '66 days', NOW() - INTERVAL '65 days'
),
(
  '99999999-9999-4999-8999-999999999947', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46', 'APPROVED',
  'https://randomuser.me/api/portraits/women/46.jpg',
  'https://randomuser.me/api/portraits/women/49.jpg',
  'Demo approved',
  NOW() - INTERVAL '66 days', NOW() - INTERVAL '67 days', NOW() - INTERVAL '66 days'
),
(
  '99999999-9999-4999-8999-999999999948', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47', 'APPROVED',
  'https://randomuser.me/api/portraits/women/47.jpg',
  'https://randomuser.me/api/portraits/women/50.jpg',
  'Demo approved',
  NOW() - INTERVAL '67 days', NOW() - INTERVAL '68 days', NOW() - INTERVAL '67 days'
),
(
  '99999999-9999-4999-8999-999999999949', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48', 'APPROVED',
  'https://randomuser.me/api/portraits/women/48.jpg',
  'https://randomuser.me/api/portraits/women/51.jpg',
  'Demo approved',
  NOW() - INTERVAL '68 days', NOW() - INTERVAL '69 days', NOW() - INTERVAL '68 days'
),
(
  '99999999-9999-4999-8999-999999999950', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49', 'APPROVED',
  'https://randomuser.me/api/portraits/women/49.jpg',
  'https://randomuser.me/api/portraits/women/52.jpg',
  'Demo approved',
  NOW() - INTERVAL '69 days', NOW() - INTERVAL '70 days', NOW() - INTERVAL '69 days'
),
(
  '99999999-9999-4999-8999-999999999951', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'APPROVED',
  'https://randomuser.me/api/portraits/women/50.jpg',
  'https://randomuser.me/api/portraits/women/53.jpg',
  'Demo approved',
  NOW() - INTERVAL '70 days', NOW() - INTERVAL '71 days', NOW() - INTERVAL '70 days'
),
(
  '99999999-9999-4999-8999-999999999952', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51', 'APPROVED',
  'https://randomuser.me/api/portraits/women/51.jpg',
  'https://randomuser.me/api/portraits/women/54.jpg',
  'Demo approved',
  NOW() - INTERVAL '71 days', NOW() - INTERVAL '72 days', NOW() - INTERVAL '71 days'
),
(
  '99999999-9999-4999-8999-999999999953', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52', 'APPROVED',
  'https://randomuser.me/api/portraits/women/52.jpg',
  'https://randomuser.me/api/portraits/women/55.jpg',
  'Demo approved',
  NOW() - INTERVAL '72 days', NOW() - INTERVAL '73 days', NOW() - INTERVAL '72 days'
),
(
  '99999999-9999-4999-8999-999999999954', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53', 'APPROVED',
  'https://randomuser.me/api/portraits/women/53.jpg',
  'https://randomuser.me/api/portraits/women/56.jpg',
  'Demo approved',
  NOW() - INTERVAL '73 days', NOW() - INTERVAL '74 days', NOW() - INTERVAL '73 days'
),
(
  '99999999-9999-4999-8999-999999999955', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54', 'APPROVED',
  'https://randomuser.me/api/portraits/women/54.jpg',
  'https://randomuser.me/api/portraits/women/57.jpg',
  'Demo approved',
  NOW() - INTERVAL '74 days', NOW() - INTERVAL '75 days', NOW() - INTERVAL '74 days'
),
(
  '99999999-9999-4999-8999-999999999956', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'APPROVED',
  'https://randomuser.me/api/portraits/women/55.jpg',
  'https://randomuser.me/api/portraits/women/58.jpg',
  'Demo approved',
  NOW() - INTERVAL '75 days', NOW() - INTERVAL '76 days', NOW() - INTERVAL '75 days'
),
(
  '99999999-9999-4999-8999-999999999957', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56', 'APPROVED',
  'https://randomuser.me/api/portraits/women/56.jpg',
  'https://randomuser.me/api/portraits/women/59.jpg',
  'Demo approved',
  NOW() - INTERVAL '76 days', NOW() - INTERVAL '77 days', NOW() - INTERVAL '76 days'
),
(
  '99999999-9999-4999-8999-999999999958', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57', 'APPROVED',
  'https://randomuser.me/api/portraits/women/57.jpg',
  'https://randomuser.me/api/portraits/women/60.jpg',
  'Demo approved',
  NOW() - INTERVAL '77 days', NOW() - INTERVAL '78 days', NOW() - INTERVAL '77 days'
),
(
  '99999999-9999-4999-8999-999999999959', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'APPROVED',
  'https://randomuser.me/api/portraits/women/58.jpg',
  'https://randomuser.me/api/portraits/women/61.jpg',
  'Demo approved',
  NOW() - INTERVAL '78 days', NOW() - INTERVAL '79 days', NOW() - INTERVAL '78 days'
),
(
  '99999999-9999-4999-8999-999999999960', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59', 'APPROVED',
  'https://randomuser.me/api/portraits/women/59.jpg',
  'https://randomuser.me/api/portraits/women/62.jpg',
  'Demo approved',
  NOW() - INTERVAL '79 days', NOW() - INTERVAL '80 days', NOW() - INTERVAL '79 days'
);

INSERT INTO legal_acceptances (user_id, document_set_version, accepted_at, source)
SELECT id, 'v1-2026-08', NOW() - INTERVAL '2 days', 'APP'
FROM users
WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
ON CONFLICT (user_id, document_set_version) DO NOTHING;

INSERT INTO chat_threads (
  id, connection_id, member_a_id, member_b_id, status,
  a_last_read_at, b_last_read_at, created_at
) VALUES
(
  'dddddddd-dddd-dddd-dddd-dddddddddd01', 'cccccccc-cccc-cccc-cccc-cccccccccc01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '2 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd02', 'cccccccc-cccc-cccc-cccc-cccccccccc02',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'OPEN',
  NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd03', 'cccccccc-cccc-cccc-cccc-cccccccccc03',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'OPEN',
  NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '12 minutes', NOW() - INTERVAL '4 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd04', 'cccccccc-cccc-cccc-cccc-cccccccccc04',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '5 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd05', 'cccccccc-cccc-cccc-cccc-cccccccccc05',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'OPEN',
  NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '6 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd06', 'cccccccc-cccc-cccc-cccc-cccccccccc06',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'OPEN',
  NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '12 minutes', NOW() - INTERVAL '7 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd07', 'cccccccc-cccc-cccc-cccc-cccccccccc07',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '8 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd08', 'cccccccc-cccc-cccc-cccc-cccccccccc08',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'OPEN',
  NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '9 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd09', 'cccccccc-cccc-cccc-cccc-cccccccccc09',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'OPEN',
  NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '12 minutes', NOW() - INTERVAL '10 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd10', 'cccccccc-cccc-cccc-cccc-cccccccccc10',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '11 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd11', 'cccccccc-cccc-cccc-cccc-cccccccccc11',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'OPEN',
  NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '12 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd12', 'cccccccc-cccc-cccc-cccc-cccccccccc12',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'OPEN',
  NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '12 minutes', NOW() - INTERVAL '13 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd13', 'cccccccc-cccc-cccc-cccc-cccccccccc13',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '14 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd14', 'cccccccc-cccc-cccc-cccc-cccccccccc14',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'OPEN',
  NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '15 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd15', 'cccccccc-cccc-cccc-cccc-cccccccccc15',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'OPEN',
  NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '12 minutes', NOW() - INTERVAL '16 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd16', 'cccccccc-cccc-cccc-cccc-cccccccccc16',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'OPEN',
  NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '17 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd17', 'cccccccc-cccc-cccc-cccc-cccccccccc17',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '18 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd18', 'cccccccc-cccc-cccc-cccc-cccccccccc18',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '19 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd19', 'cccccccc-cccc-cccc-cccc-cccccccccc19',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '20 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd20', 'cccccccc-cccc-cccc-cccc-cccccccccc20',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '21 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd21', 'cccccccc-cccc-cccc-cccc-cccccccccc21',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '22 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd22', 'cccccccc-cccc-cccc-cccc-cccccccccc22',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '23 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd23', 'cccccccc-cccc-cccc-cccc-cccccccccc23',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '24 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd24', 'cccccccc-cccc-cccc-cccc-cccccccccc24',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '25 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd25', 'cccccccc-cccc-cccc-cccc-cccccccccc25',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '26 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd26', 'cccccccc-cccc-cccc-cccc-cccccccccc26',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '27 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd27', 'cccccccc-cccc-cccc-cccc-cccccccccc27',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'OPEN',
  NOW() - INTERVAL '20 hours', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '28 days'
),
(
  'dddddddd-dddd-dddd-dddd-dddddddddd28', 'cccccccc-cccc-cccc-cccc-cccccccccc28',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'OPEN',
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '29 days'
);

INSERT INTO messages (id, thread_id, sender_id, body, moderation_status, created_at)
VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hi Sara — your listing caught my eye.', 'ALLOWED', NOW() - INTERVAL '48 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0002', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Thank you Abel. Slow night or a private suite first?', 'ALLOWED', NOW() - INTERVAL '30 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0003', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0004', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '90 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0005', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0006', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0007', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0008', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0009', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0010', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0011', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0012', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hanna, Saturday evening works on my side.', 'ALLOWED', NOW() - INTERVAL '47 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0013', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Send the booking when you are ready.', 'ALLOWED', NOW() - INTERVAL '29 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0014', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0015', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '91 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0016', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0017', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0018', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0019', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0020', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0021', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0022', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking is in — check your dates.', 'ALLOWED', NOW() - INTERVAL '6 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0023', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Loved the energy in your photos.', 'ALLOWED', NOW() - INTERVAL '46 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0024', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Likewise — let''s keep it discreet.', 'ALLOWED', NOW() - INTERVAL '28 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0025', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0026', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '92 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0027', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0028', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0029', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0030', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0031', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0032', 'dddddddd-dddd-dddd-dddd-dddddddddd03', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0033', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Are you free after 9 this weekend?', 'ALLOWED', NOW() - INTERVAL '45 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0034', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'I have an open window. Book it.', 'ALLOWED', NOW() - INTERVAL '27 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0035', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0036', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '93 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0037', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0038', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0039', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0040', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0041', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0042', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0043', 'dddddddd-dddd-dddd-dddd-dddddddddd04', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0044', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Your Piazza photos made me pause.', 'ALLOWED', NOW() - INTERVAL '44 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0045', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'That room is my favourite. Come see it.', 'ALLOWED', NOW() - INTERVAL '26 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0046', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0047', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '94 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0048', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0049', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0050', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0051', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0052', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0053', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0054', 'dddddddd-dddd-dddd-dddd-dddddddddd05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking is in — check your dates.', 'ALLOWED', NOW() - INTERVAL '6 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0055', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Would you rather a hotel suite or a private table first?', 'ALLOWED', NOW() - INTERVAL '43 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0056', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Suite. Then we can decide about dinner.', 'ALLOWED', NOW() - INTERVAL '25 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0057', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0058', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '95 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0059', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0060', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0061', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0062', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0063', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0064', 'dddddddd-dddd-dddd-dddd-dddddddddd06', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0065', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hi Helen — your listing caught my eye.', 'ALLOWED', NOW() - INTERVAL '42 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0066', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Thank you Abel. Slow night or a private suite first?', 'ALLOWED', NOW() - INTERVAL '24 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0067', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0068', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '96 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0069', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0070', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0071', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0072', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0073', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0074', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0075', 'dddddddd-dddd-dddd-dddd-dddddddddd07', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0076', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Rahel, Saturday evening works on my side.', 'ALLOWED', NOW() - INTERVAL '41 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0077', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Send the booking when you are ready.', 'ALLOWED', NOW() - INTERVAL '23 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0078', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0079', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '97 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0080', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0081', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0082', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0083', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0084', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0085', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0086', 'dddddddd-dddd-dddd-dddd-dddddddddd08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking is in — check your dates.', 'ALLOWED', NOW() - INTERVAL '6 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0087', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Loved the energy in your photos.', 'ALLOWED', NOW() - INTERVAL '40 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0088', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Likewise — let''s keep it discreet.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0089', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0090', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '98 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0091', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0092', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0093', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0094', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0095', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0096', 'dddddddd-dddd-dddd-dddd-dddddddddd09', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0097', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Are you free after 9 this weekend?', 'ALLOWED', NOW() - INTERVAL '39 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0098', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'I have an open window. Book it.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0099', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0100', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '99 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0101', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0102', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0103', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0104', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0105', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0106', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0107', 'dddddddd-dddd-dddd-dddd-dddddddddd10', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0108', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Your Piazza photos made me pause.', 'ALLOWED', NOW() - INTERVAL '38 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0109', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'That room is my favourite. Come see it.', 'ALLOWED', NOW() - INTERVAL '30 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0110', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0111', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '100 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0112', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0113', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0114', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0115', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0116', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0117', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0118', 'dddddddd-dddd-dddd-dddd-dddddddddd11', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking is in — check your dates.', 'ALLOWED', NOW() - INTERVAL '6 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0119', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Would you rather a hotel suite or a private table first?', 'ALLOWED', NOW() - INTERVAL '37 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0120', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Suite. Then we can decide about dinner.', 'ALLOWED', NOW() - INTERVAL '29 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0121', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0122', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '101 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0123', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0124', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0125', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0126', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0127', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0128', 'dddddddd-dddd-dddd-dddd-dddddddddd12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0129', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hi Hiwot — your listing caught my eye.', 'ALLOWED', NOW() - INTERVAL '36 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0130', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Thank you Abel. Slow night or a private suite first?', 'ALLOWED', NOW() - INTERVAL '28 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0131', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0132', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '102 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0133', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0134', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0135', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0136', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0137', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0138', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0139', 'dddddddd-dddd-dddd-dddd-dddddddddd13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0140', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Eden, Saturday evening works on my side.', 'ALLOWED', NOW() - INTERVAL '35 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0141', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Send the booking when you are ready.', 'ALLOWED', NOW() - INTERVAL '27 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0142', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0143', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '103 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0144', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0145', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0146', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0147', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0148', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0149', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0150', 'dddddddd-dddd-dddd-dddd-dddddddddd14', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking is in — check your dates.', 'ALLOWED', NOW() - INTERVAL '6 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0151', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Loved the energy in your photos.', 'ALLOWED', NOW() - INTERVAL '34 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0152', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Likewise — let''s keep it discreet.', 'ALLOWED', NOW() - INTERVAL '26 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0153', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0154', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '104 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0155', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0156', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0157', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0158', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0159', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0160', 'dddddddd-dddd-dddd-dddd-dddddddddd15', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0161', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Are you free after 9 this weekend?', 'ALLOWED', NOW() - INTERVAL '33 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0162', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'I have an open window. Book it.', 'ALLOWED', NOW() - INTERVAL '25 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0163', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0164', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '105 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0165', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I can do after 8 any weeknight this week.', 'ALLOWED', NOW() - INTERVAL '55 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0166', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'Wear something simple. I''ll handle the rest.', 'ALLOWED', NOW() - INTERVAL '47 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0167', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I''ll keep the booking notes short and discreet.', 'ALLOWED', NOW() - INTERVAL '39 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0168', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'If you want overnight, send the higher rate.', 'ALLOWED', NOW() - INTERVAL '31 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0169', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'I liked the jazz mention in your bio.', 'ALLOWED', NOW() - INTERVAL '23 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0170', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'Message me when you''re 10 minutes away.', 'ALLOWED', NOW() - INTERVAL '15 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0171', 'dddddddd-dddd-dddd-dddd-dddddddddd16', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'I''m free tonight if you still want this.', 'ALLOWED', NOW() - INTERVAL '12 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0172', 'dddddddd-dddd-dddd-dddd-dddddddddd17', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'Your Piazza photos made me pause.', 'ALLOWED', NOW() - INTERVAL '32 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0173', 'dddddddd-dddd-dddd-dddd-dddddddddd17', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'That room is my favourite. Come see it.', 'ALLOWED', NOW() - INTERVAL '24 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0174', 'dddddddd-dddd-dddd-dddd-dddddddddd17', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0175', 'dddddddd-dddd-dddd-dddd-dddddddddd17', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '106 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0176', 'dddddddd-dddd-dddd-dddd-dddddddddd17', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '24 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0177', 'dddddddd-dddd-dddd-dddd-dddddddddd18', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'Would you rather a hotel suite or a private table first?', 'ALLOWED', NOW() - INTERVAL '31 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0178', 'dddddddd-dddd-dddd-dddd-dddddddddd18', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Suite. Then we can decide about dinner.', 'ALLOWED', NOW() - INTERVAL '23 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0179', 'dddddddd-dddd-dddd-dddd-dddddddddd18', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0180', 'dddddddd-dddd-dddd-dddd-dddddddddd18', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '107 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0181', 'dddddddd-dddd-dddd-dddd-dddddddddd19', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'Hi Betel — your listing caught my eye.', 'ALLOWED', NOW() - INTERVAL '30 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0182', 'dddddddd-dddd-dddd-dddd-dddddddddd19', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Thank you Kidus. Slow night or a private suite first?', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0183', 'dddddddd-dddd-dddd-dddd-dddddddddd19', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0184', 'dddddddd-dddd-dddd-dddd-dddddddddd19', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '108 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0185', 'dddddddd-dddd-dddd-dddd-dddddddddd19', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '26 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0186', 'dddddddd-dddd-dddd-dddd-dddddddddd20', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'Rahel, Saturday evening works on my side.', 'ALLOWED', NOW() - INTERVAL '29 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0187', 'dddddddd-dddd-dddd-dddd-dddddddddd20', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Send the booking when you are ready.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0188', 'dddddddd-dddd-dddd-dddd-dddddddddd20', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0189', 'dddddddd-dddd-dddd-dddd-dddddddddd20', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '109 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0190', 'dddddddd-dddd-dddd-dddd-dddddddddd21', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'Loved the energy in your photos.', 'ALLOWED', NOW() - INTERVAL '48 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0191', 'dddddddd-dddd-dddd-dddd-dddddddddd21', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Likewise — let''s keep it discreet.', 'ALLOWED', NOW() - INTERVAL '30 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0192', 'dddddddd-dddd-dddd-dddd-dddddddddd21', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0193', 'dddddddd-dddd-dddd-dddd-dddddddddd21', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '110 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0194', 'dddddddd-dddd-dddd-dddd-dddddddddd21', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '28 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0195', 'dddddddd-dddd-dddd-dddd-dddddddddd22', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'Are you free after 9 this weekend?', 'ALLOWED', NOW() - INTERVAL '47 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0196', 'dddddddd-dddd-dddd-dddd-dddddddddd22', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'I have an open window. Book it.', 'ALLOWED', NOW() - INTERVAL '29 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0197', 'dddddddd-dddd-dddd-dddd-dddddddddd22', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0198', 'dddddddd-dddd-dddd-dddd-dddddddddd22', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '111 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0199', 'dddddddd-dddd-dddd-dddd-dddddddddd23', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'Your Piazza photos made me pause.', 'ALLOWED', NOW() - INTERVAL '46 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0200', 'dddddddd-dddd-dddd-dddd-dddddddddd23', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'That room is my favourite. Come see it.', 'ALLOWED', NOW() - INTERVAL '28 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0201', 'dddddddd-dddd-dddd-dddd-dddddddddd23', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0202', 'dddddddd-dddd-dddd-dddd-dddddddddd23', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '112 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0203', 'dddddddd-dddd-dddd-dddd-dddddddddd23', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '30 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0204', 'dddddddd-dddd-dddd-dddd-dddddddddd24', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'Would you rather a hotel suite or a private table first?', 'ALLOWED', NOW() - INTERVAL '45 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0205', 'dddddddd-dddd-dddd-dddd-dddddddddd24', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'Suite. Then we can decide about dinner.', 'ALLOWED', NOW() - INTERVAL '27 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0206', 'dddddddd-dddd-dddd-dddd-dddddddddd24', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '21 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0207', 'dddddddd-dddd-dddd-dddd-dddddddddd24', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '113 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0208', 'dddddddd-dddd-dddd-dddd-dddddddddd25', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'Hi Netsanet — your listing caught my eye.', 'ALLOWED', NOW() - INTERVAL '44 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0209', 'dddddddd-dddd-dddd-dddd-dddddddddd25', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'Thank you Robel. Slow night or a private suite first?', 'ALLOWED', NOW() - INTERVAL '26 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0210', 'dddddddd-dddd-dddd-dddd-dddddddddd25', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '22 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0211', 'dddddddd-dddd-dddd-dddd-dddddddddd25', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '114 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0212', 'dddddddd-dddd-dddd-dddd-dddddddddd25', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '32 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0213', 'dddddddd-dddd-dddd-dddd-dddddddddd26', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'Wesene, Saturday evening works on my side.', 'ALLOWED', NOW() - INTERVAL '43 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0214', 'dddddddd-dddd-dddd-dddd-dddddddddd26', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'Send the booking when you are ready.', 'ALLOWED', NOW() - INTERVAL '25 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0215', 'dddddddd-dddd-dddd-dddd-dddddddddd26', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '18 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0216', 'dddddddd-dddd-dddd-dddd-dddddddddd26', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '115 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0217', 'dddddddd-dddd-dddd-dddd-dddddddddd27', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'Loved the energy in your photos.', 'ALLOWED', NOW() - INTERVAL '42 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0218', 'dddddddd-dddd-dddd-dddd-dddddddddd27', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'Likewise — let''s keep it discreet.', 'ALLOWED', NOW() - INTERVAL '24 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0219', 'dddddddd-dddd-dddd-dddd-dddddddddd27', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '19 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0220', 'dddddddd-dddd-dddd-dddd-dddddddddd27', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '116 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0221', 'dddddddd-dddd-dddd-dddd-dddddddddd27', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'Discreet venue in Bole works.', 'ALLOWED', NOW() - INTERVAL '34 minutes'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0222', 'dddddddd-dddd-dddd-dddd-dddddddddd28', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'Are you free after 9 this weekend?', 'ALLOWED', NOW() - INTERVAL '41 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0223', 'dddddddd-dddd-dddd-dddd-dddddddddd28', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'I have an open window. Book it.', 'ALLOWED', NOW() - INTERVAL '23 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0224', 'dddddddd-dddd-dddd-dddd-dddddddddd28', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'I will send a booking request.', 'ALLOWED', NOW() - INTERVAL '20 hours'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeee0225', 'dddddddd-dddd-dddd-dddd-dddddddddd28', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'Perfect. I have an open window.', 'ALLOWED', NOW() - INTERVAL '117 minutes');

INSERT INTO bookings (
  id, connection_id, venue_id, meetup_place, rate_type, amount_etb, payment_status,
  proposed_by, status, starts_at, notes, confirmed_at, checked_in_at, checked_out_at,
  performer_checked_out_at, client_checked_out_at, created_at, updated_at
) VALUES
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a201', 'cccccccc-cccc-cccc-cccc-cccccccccc01', NULL, 'Kazanchis — private residence (discreet)',
  'SESSION', 4500, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'PROPOSED',
  date_trunc('hour', NOW()) + INTERVAL '3 days' + INTERVAL '19 hours', 'Demo proposed booking',
  NULL, NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a202', 'cccccccc-cccc-cccc-cccc-cccccccccc02', NULL, 'Bole — discreet suite',
  'OVERNIGHT', 14000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'PROPOSED',
  date_trunc('hour', NOW()) + INTERVAL '6 days' + INTERVAL '19 hours', 'Demo proposed booking',
  NULL, NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a203', 'cccccccc-cccc-cccc-cccc-cccccccccc03', (SELECT id FROM venues WHERE name ILIKE '%Tomoca%' LIMIT 1), NULL,
  'SESSION', 5500, 'PENDING', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '6 days', NOW() - INTERVAL '3 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a204', 'cccccccc-cccc-cccc-cccc-cccccccccc04', NULL, 'Piazza — discreet suite',
  'OVERNIGHT', 14000, 'PENDING', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '5 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '7 days', NOW() - INTERVAL '4 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a205', 'cccccccc-cccc-cccc-cccc-cccccccccc05', NULL, 'Bole — hotel suite',
  'SESSION', 6500, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '1 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a206', 'cccccccc-cccc-cccc-cccc-cccccccccc06', NULL, 'Kazanchis — private dining',
  'SESSION', 7000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '4 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '9 days', NOW() - INTERVAL '6 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a207', 'cccccccc-cccc-cccc-cccc-cccccccccc07', NULL, 'Bole — overnight residence',
  'OVERNIGHT', 14000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '7 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '7 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a208', 'cccccccc-cccc-cccc-cccc-cccccccccc08', NULL, 'Piazza — gallery after-hours',
  'SESSION', 8000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '10 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '11 days', NOW() - INTERVAL '8 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209', 'cccccccc-cccc-cccc-cccc-cccccccccc09', NULL, 'Bole — hotel suite',
  'SESSION', 8500, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CHECKED_IN',
  date_trunc('hour', NOW()) + INTERVAL '0 days' + INTERVAL '19 hours', 'Demo checked_in booking',
  NOW() - INTERVAL '1 day', date_trunc('hour', NOW()) + INTERVAL '0 days' + INTERVAL '19 hours', NULL, NULL, NULL,
  NOW() - INTERVAL '12 days', NOW() - INTERVAL '9 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a210', 'cccccccc-cccc-cccc-cccc-cccccccccc10', NULL, 'Bole — discreet suite',
  'SESSION', 9000, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'COMPLETED',
  date_trunc('hour', NOW()) - INTERVAL '4 days' + INTERVAL '20 hours', 'Demo completed booking',
  NOW() - INTERVAL '1 day', date_trunc('hour', NOW()) - INTERVAL '4 days' + INTERVAL '20 hours', (date_trunc('hour', NOW()) - INTERVAL '4 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '4 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '4 days' + INTERVAL '20 hours') + INTERVAL '3 hours',
  NOW() - INTERVAL '13 days', NOW() - INTERVAL '10 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a211', 'cccccccc-cccc-cccc-cccc-cccccccccc11', NULL, 'Kazanchis — private residence',
  'OVERNIGHT', 14000, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'COMPLETED',
  date_trunc('hour', NOW()) - INTERVAL '11 days' + INTERVAL '20 hours', 'Demo completed booking',
  NOW() - INTERVAL '1 day', date_trunc('hour', NOW()) - INTERVAL '11 days' + INTERVAL '20 hours', (date_trunc('hour', NOW()) - INTERVAL '11 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '11 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '11 days' + INTERVAL '20 hours') + INTERVAL '3 hours',
  NOW() - INTERVAL '14 days', NOW() - INTERVAL '11 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a212', 'cccccccc-cccc-cccc-cccc-cccccccccc12', NULL, 'Addis — cancelled demo',
  'SESSION', 10000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CANCELLED',
  date_trunc('hour', NOW()) - INTERVAL '2 days' + INTERVAL '20 hours', 'Demo cancelled booking',
  NULL, NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '15 days', NOW() - INTERVAL '12 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a213', 'cccccccc-cccc-cccc-cccc-cccccccccc13', NULL, 'Piazza — jazz room',
  'SESSION', 10500, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '9 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '16 days', NOW() - INTERVAL '13 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a214', 'cccccccc-cccc-cccc-cccc-cccccccccc14', NULL, 'Bole — weekend suite',
  'OVERNIGHT', 14000, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '14 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '17 days', NOW() - INTERVAL '14 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a215', 'cccccccc-cccc-cccc-cccc-cccccccccc15', NULL, 'Kazanchis — late session',
  'SESSION', 11500, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '11 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '18 days', NOW() - INTERVAL '15 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a216', 'cccccccc-cccc-cccc-cccc-cccccccccc16', NULL, 'Bole — paid reference booking',
  'SESSION', 12000, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '19 days', NOW() - INTERVAL '16 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a217', 'cccccccc-cccc-cccc-cccc-cccccccccc17', NULL, 'Bole — café table',
  'SESSION', 12500, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'CONFIRMED',
  date_trunc('hour', NOW()) + INTERVAL '3 days' + INTERVAL '19 hours', 'Demo confirmed booking',
  NOW() - INTERVAL '1 day', NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '20 days', NOW() - INTERVAL '17 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a218', 'cccccccc-cccc-cccc-cccc-cccccccccc18', NULL, 'Piazza — completed demo',
  'SESSION', 13000, 'PAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'COMPLETED',
  date_trunc('hour', NOW()) - INTERVAL '6 days' + INTERVAL '20 hours', 'Demo completed booking',
  NOW() - INTERVAL '1 day', date_trunc('hour', NOW()) - INTERVAL '6 days' + INTERVAL '20 hours', (date_trunc('hour', NOW()) - INTERVAL '6 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '6 days' + INTERVAL '20 hours') + INTERVAL '3 hours', (date_trunc('hour', NOW()) - INTERVAL '6 days' + INTERVAL '20 hours') + INTERVAL '3 hours',
  NOW() - INTERVAL '21 days', NOW() - INTERVAL '18 days'
),
(
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a219', 'cccccccc-cccc-cccc-cccc-cccccccccc19', NULL, 'Kazanchis — intro dinner',
  'SESSION', 13500, 'UNPAID', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'PROPOSED',
  date_trunc('hour', NOW()) + INTERVAL '4 days' + INTERVAL '19 hours', 'Demo proposed booking',
  NULL, NULL, NULL, NULL, NULL,
  NOW() - INTERVAL '22 days', NOW() - INTERVAL '19 days'
);

INSERT INTO payment_intents (
  id, user_id, plan_id, purpose, booking_id, provider, merchant_order_id,
  amount_etb, currency, status, checkout_url, provider_ref, created_at, updated_at, paid_at
) VALUES
(
  'ffffffff-ffff-4fff-8fff-ffffffffff01', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a203',
  'CBE', 'DEMO-BOOK-003', 5500.00, 'ETB', 'CHECKOUT',
  'https://example.local/cbe/demo-book-003',
  NULL, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NULL
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff02', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a204',
  'CBE', 'DEMO-BOOK-004', 14000.00, 'ETB', 'CHECKOUT',
  'https://example.local/cbe/demo-book-004',
  NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NULL
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff03', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209',
  'CBE', 'DEMO-BOOK-009', 8500.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-009CBE', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '5 days'
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff04', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a210',
  'CBE', 'DEMO-BOOK-010', 9000.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-010CBE', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '5 days'
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff05', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a211',
  'CBE', 'DEMO-BOOK-011', 14000.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-011CBE', NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '5 days'
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff06', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a216',
  'CBE', 'DEMO-BOOK-016', 12000.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-016CBE', NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days', NOW() - INTERVAL '5 days'
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff07', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a217',
  'CBE', 'DEMO-BOOK-017', 12500.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-017CBE', NOW() - INTERVAL '17 days', NOW() - INTERVAL '17 days', NOW() - INTERVAL '5 days'
),
(
  'ffffffff-ffff-4fff-8fff-ffffffffff08', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', NULL, 'BOOKING', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a218',
  'CBE', 'DEMO-BOOK-018', 13000.00, 'ETB', 'PAID',
  NULL,
  'FT-DEMO-018CBE', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days', NOW() - INTERVAL '5 days'
);

UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff01' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a203';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff02' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a204';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff03' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff04' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a210';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff05' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a211';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff06' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a216';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff07' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a217';
UPDATE bookings SET payment_intent_id = 'ffffffff-ffff-4fff-8fff-ffffffffff08' WHERE id = 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a218';

INSERT INTO ledger_entries (id, user_id, payment_intent_id, booking_id, entry_type, amount_etb, currency, description, created_at)
VALUES
('11111111-1111-4111-8111-111111111101', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'ffffffff-ffff-4fff-8fff-ffffffffff03', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209', 'PERFORMER_CREDIT', 7225.00, 'ETB', 'Booking credit (85% of 8500 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111102', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff03', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209', 'PLATFORM_FEE', 1275.00, 'ETB', 'Platform fee 15% booking 9', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111103', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'ffffffff-ffff-4fff-8fff-ffffffffff04', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a210', 'PERFORMER_CREDIT', 7650.00, 'ETB', 'Booking credit (85% of 9000 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111104', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff04', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a210', 'PLATFORM_FEE', 1350.00, 'ETB', 'Platform fee 15% booking 10', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111105', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'ffffffff-ffff-4fff-8fff-ffffffffff05', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a211', 'PERFORMER_CREDIT', 11900.00, 'ETB', 'Booking credit (85% of 14000 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111106', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff05', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a211', 'PLATFORM_FEE', 2100.00, 'ETB', 'Platform fee 15% booking 11', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111107', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'ffffffff-ffff-4fff-8fff-ffffffffff06', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a216', 'PERFORMER_CREDIT', 10200.00, 'ETB', 'Booking credit (85% of 12000 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111108', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff06', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a216', 'PLATFORM_FEE', 1800.00, 'ETB', 'Platform fee 15% booking 16', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111109', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'ffffffff-ffff-4fff-8fff-ffffffffff07', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a217', 'PERFORMER_CREDIT', 10625.00, 'ETB', 'Booking credit (85% of 12500 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111110', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff07', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a217', 'PLATFORM_FEE', 1875.00, 'ETB', 'Platform fee 15% booking 17', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'ffffffff-ffff-4fff-8fff-ffffffffff08', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a218', 'PERFORMER_CREDIT', 11050.00, 'ETB', 'Booking credit (85% of 13000 ETB)', NOW() - INTERVAL '5 days'),
('11111111-1111-4111-8111-111111111112', NULL, 'ffffffff-ffff-4fff-8fff-ffffffffff08', 'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a218', 'PLATFORM_FEE', 1950.00, 'ETB', 'Platform fee 15% booking 18', NOW() - INTERVAL '5 days');

INSERT INTO payout_requests (id, user_id, amount_etb, status, destination_note, ledger_entry_id, created_at, updated_at)
VALUES
('c1c1c1c1-c1c1-41c1-81c1-c1c1c1c1c110', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 3000.00, 'REQUESTED', 'CBE •••• 4810 — demo payout', '11111111-1111-4111-8111-111111111103', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
('c1c1c1c1-c1c1-41c1-81c1-c1c1c1c1c111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 3000.00, 'REQUESTED', 'CBE •••• 4811 — demo payout', '11111111-1111-4111-8111-111111111105', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
('c1c1c1c1-c1c1-41c1-81c1-c1c1c1c1c118', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 3000.00, 'REQUESTED', 'CBE •••• 4818 — demo payout', '11111111-1111-4111-8111-111111111111', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

INSERT INTO concierge_tasks (id, booking_id, match_id, task_type, due_at, status, notes, created_at, updated_at)
VALUES
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e101',
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a203',
  'cccccccc-cccc-cccc-cccc-cccccccccc03',
  'PRE_CALL',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '18 hours',
  'OPEN',
  'Confirm arrival at Tomoca',
  NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'
),
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e102',
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a205',
  'cccccccc-cccc-cccc-cccc-cccccccccc05',
  'PRE_CALL',
  date_trunc('hour', NOW()) + INTERVAL '1 day' + INTERVAL '17 hours',
  'OPEN',
  'Abel tonight — Bole hotel suite',
  NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'
),
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e103',
  'a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a209',
  'cccccccc-cccc-cccc-cccc-cccccccccc09',
  'ARRIVAL_CHECK',
  date_trunc('hour', NOW()) + INTERVAL '1 hour',
  'OPEN',
  'Abel checked in — monitor window',
  NOW() - INTERVAL '90 minutes', NOW() - INTERVAL '90 minutes'
);

INSERT INTO member_notifications (id, user_id, subject, body, related_type, related_id, read_at, created_at)
VALUES
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NULL, NOW() - INTERVAL '1 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a006', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a007', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '4 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a008', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a009', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '5 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a010', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a011', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '6 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a012', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a013', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '7 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a014', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa07', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a015', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '8 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a016', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa08', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a017', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '9 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a018', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa09', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a019', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '10 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a020', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a021', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '11 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a022', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a023', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '12 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a024', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a025', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '13 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a026', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a027', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa14', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '14 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a028', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa14', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a029', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '15 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a030', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a031', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '16 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a032', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a033', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '17 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a034', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a035', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '18 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a036', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a037', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '19 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a038', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a039', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '20 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a040', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a041', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '21 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a042', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a043', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '22 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a044', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a045', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '23 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a046', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a047', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24', 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '24 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a048', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24', 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a049', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '2 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a050', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a051', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '3 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a052', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a053', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '4 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a054', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a055', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '5 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a056', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a057', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '6 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a058', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a059', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '7 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a060', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a061', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '8 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a062', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a063', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '9 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a064', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a065', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '10 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a066', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a067', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '11 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a068', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a069', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '12 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a070', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a071', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '13 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a072', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a073', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '14 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a074', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a075', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '15 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a076', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a077', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '16 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a078', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a079', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '17 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a080', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a081', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '18 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a082', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb17', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a083', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '19 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a084', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb18', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a085', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '20 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a086', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb19', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a087', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '1 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a088', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb20', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a089', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '2 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a090', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb21', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a091', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '3 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a092', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb22', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a093', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '4 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a094', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb23', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a095', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '5 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a096', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb24', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a097', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '6 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a098', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb25', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a099', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '7 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a100', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb26', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a101', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '8 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a102', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb27', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a103', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '9 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a104', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb28', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a105', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '10 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a106', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb29', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a107', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '11 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a108', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb30', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a109', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '12 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a110', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb31', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '13 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb32', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a113', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '14 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a114', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb33', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a115', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '15 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a116', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb34', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a117', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '16 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a118', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb35', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a119', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '17 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a120', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb36', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a121', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '18 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a122', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb37', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a123', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '19 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a124', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb38', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a125', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '20 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a126', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb39', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a127', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '1 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a128', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb40', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a129', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '2 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a130', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb41', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a131', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '3 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a132', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb42', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a133', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '4 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a134', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb43', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a135', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '5 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a136', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb44', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a137', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '6 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a138', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb45', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a139', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '7 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a140', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb46', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a141', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '8 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a142', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb47', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a143', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '9 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a144', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb48', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a145', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '10 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a146', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb49', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a147', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '11 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a148', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb50', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a149', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '12 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a150', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb51', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a151', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '13 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a152', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb52', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a153', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '14 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a154', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb53', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a155', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '15 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a156', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb54', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a157', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '16 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a158', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb55', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a159', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '17 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a160', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb56', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a161', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '18 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a162', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb57', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a163', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '19 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a164', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb58', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a165', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59', 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '20 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a166', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb59', 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a167', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Sara replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc01', NULL, NOW() - INTERVAL '20 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a168', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc01', NULL, NOW() - INTERVAL '15 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a169', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hanna replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc02', NULL, NOW() - INTERVAL '21 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a170', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc02', NULL, NOW() - INTERVAL '16 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a171', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Liya replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc03', NULL, NOW() - INTERVAL '22 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a172', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc03', NULL, NOW() - INTERVAL '17 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a173', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Mariam replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc04', NULL, NOW() - INTERVAL '23 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a174', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc04', NULL, NOW() - INTERVAL '18 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a175', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Betel replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc05', NULL, NOW() - INTERVAL '24 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a176', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc05', NULL, NOW() - INTERVAL '19 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a177', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Selam replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc06', NULL, NOW() - INTERVAL '25 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a178', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc06', NULL, NOW() - INTERVAL '20 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a179', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Helen replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc07', NULL, NOW() - INTERVAL '26 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a180', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc07', NULL, NOW() - INTERVAL '21 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a181', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Rahel replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc08', NULL, NOW() - INTERVAL '27 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a182', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc08', NULL, NOW() - INTERVAL '22 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a183', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Nardos replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc09', NULL, NOW() - INTERVAL '28 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a184', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc09', NULL, NOW() - INTERVAL '23 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a185', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Tigist replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc10', NULL, NOW() - INTERVAL '29 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a186', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc10', NULL, NOW() - INTERVAL '24 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a187', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Meron replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc11', NULL, NOW() - INTERVAL '30 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a188', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc11', NULL, NOW() - INTERVAL '25 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a189', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Saron replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc12', NULL, NOW() - INTERVAL '31 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a190', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc12', NULL, NOW() - INTERVAL '26 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a191', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Hiwot replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc13', NULL, NOW() - INTERVAL '32 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a192', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc13', NULL, NOW() - INTERVAL '27 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a193', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Eden replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc14', NULL, NOW() - INTERVAL '33 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a194', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc14', NULL, NOW() - INTERVAL '28 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a195', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Bezawit replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc15', NULL, NOW() - INTERVAL '34 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a196', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc15', NULL, NOW() - INTERVAL '29 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a197', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Kidist replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc16', NULL, NOW() - INTERVAL '35 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a198', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16', 'Abel messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc16', NULL, NOW() - INTERVAL '30 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a199', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'Sara replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc17', NOW() - INTERVAL '1 day', NOW() - INTERVAL '36 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a200', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Dawit messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc17', NULL, NOW() - INTERVAL '31 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a201', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa03', 'Hanna replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc18', NOW() - INTERVAL '1 day', NOW() - INTERVAL '37 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a202', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Yonas messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc18', NULL, NOW() - INTERVAL '32 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a203', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa04', 'Betel replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc19', NOW() - INTERVAL '1 day', NOW() - INTERVAL '38 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a204', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', 'Kidus messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc19', NULL, NOW() - INTERVAL '33 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a205', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05', 'Rahel replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc20', NOW() - INTERVAL '1 day', NOW() - INTERVAL '39 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a206', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', 'Nahom messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc20', NULL, NOW() - INTERVAL '34 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a207', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa06', 'Tigist replied', 'Open chat to continue the evening.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc21', NOW() - INTERVAL '1 day', NOW() - INTERVAL '40 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a208', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', 'Samson messaged', 'He is waiting on your reply.', 'MATCH', 'cccccccc-cccc-cccc-cccc-cccccccccc21', NULL, NOW() - INTERVAL '35 minutes'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a209', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Awaiting payment', 'Liya is holding Tomoca — complete CBE checkout.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '2 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a210', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Awaiting payment', 'Mariam overnight is confirmed — finish CBE payment.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '3 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a211', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Betel confirmed your Bole suite — tap Pay to start CBE.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '4 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a212', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Selam confirmed Kazanchis dining — payment due before the night.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '5 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a213', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Helen overnight in Bole is confirmed and unpaid.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '6 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a214', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Rahel gallery session is confirmed — pay when ready.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '7 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a215', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Tonight', 'Nardos checked in at the Bole hotel suite.', 'BOOKING_REMINDER', NULL, NULL, NOW() - INTERVAL '8 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a216', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Evening complete', 'Meron marked the night complete. Leave a private note if you like.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '9 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a217', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Booking cancelled', 'The Addis session was cancelled. The chat stays open.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '11 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a218', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Hiwot confirmed the Piazza jazz room — start payment in chat.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '12 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a219', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Eden weekend overnight is locked — pay to secure the hold.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '13 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a220', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Pay for booking', 'Kidist late session confirmed — CBE checkout opens from booking.', 'BOOKING', NULL, NULL, NOW() - INTERVAL '14 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a221', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Concierge intro', 'Mekdes is waiting on your yes for a discreet first meeting.', 'MATCH', NULL, NULL, NOW() - INTERVAL '1 hours'),
('a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Concierge intro', 'Yordanos — concierge thinks this pairing is worth a table.', 'MATCH', NULL, NULL, NOW() - INTERVAL '1 hours');

INSERT INTO member_blocks (id, blocker_id, blocked_id, reason, created_at)
VALUES (
  'f1f1f1f1-f1f1-41f1-81f1-f1f1f1f1f901',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11',
  'Demo block — Robel',
  NOW() - INTERVAL '3 days'
);

INSERT INTO waitlist_applications (id, phone_e164, display_name, city, note, status, invite_code, created_at)
VALUES
('d1d1d1d1-d1d1-41d1-81d1-d1d1d1d1d101', '+251911300001', 'Mimi Tadesse', 'Addis Ababa', 'Referred by a friend.', 'PENDING', NULL, NOW() - INTERVAL '2 days'),
('d1d1d1d1-d1d1-41d1-81d1-d1d1d1d1d102', '+251911300002', 'Daniel Kebede', 'Bole', 'Discreet membership.', 'APPROVED', 'VELVET-DAN01', NOW() - INTERVAL '5 days'),
('d1d1d1d1-d1d1-41d1-81d1-d1d1d1d1d103', '+251911300003', 'Ruth Haile', 'Piazza', 'Not a fit.', 'REJECTED', NULL, NOW() - INTERVAL '8 days'),
('d1d1d1d1-d1d1-41d1-81d1-d1d1d1d1d104', '+251911300004', 'Sami Bekele', 'Kazanchis', 'Waitlist from Instagram.', 'PENDING', NULL, NOW() - INTERVAL '1 day'),
('d1d1d1d1-d1d1-41d1-81d1-d1d1d1d1d105', '+251911300005', 'Lensa Mekonnen', 'Addis Ababa', 'Performer applicant.', 'PENDING', NULL, NOW() - INTERVAL '4 hours');
