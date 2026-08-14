#!/usr/bin/env python3
"""Generate db/seed/demo_roster.sql — run from repo or this folder."""

from __future__ import annotations

from pathlib import Path

from demo_photos import woman_photos_json

MEN = 24
WOMEN = 60

MAN_NAMES = [
    "Abel", "Dawit", "Yonas", "Kidus", "Nahom", "Samson", "Biruk", "Elias",
    "Henok", "Michael", "Robel", "Tedros", "Aman", "Fasil", "Haile", "Iyasu",
    "Jemal", "Kaleb", "Lemma", "Mulugeta", "Nati", "Omar", "Paulos", "Yared",
]
WOMAN_NAMES = [
    "Sara", "Hanna", "Liya", "Mariam", "Betel", "Selam", "Helen", "Rahel",
    "Nardos", "Tigist", "Meron", "Saron", "Hiwot", "Eden", "Bezawit", "Kidist",
    "Mekdes", "Yordanos", "Aster", "Blen", "Chaltu", "Dagmawit", "Eyerusalem",
    "Fikirte", "Genet", "Imani", "Kalkidan", "Lulit", "Mahlet", "Naomi",
    "Rediet", "Semhal", "Tsion", "Winta", "Zewditu", "Soliyana",
    "Elsa", "Frehiwot", "Gelila", "Hana", "Jerusalem", "Kenna",
    "Lensa", "Marta", "Netsanet", "Olana", "Rekik", "Seble",
    "Tsehay", "Wesene", "Yabsira", "Zahara", "Bruktawit", "Danait",
    "Eyerus", "Abyssinia", "Mimi", "Ruth", "Senait", "Birtukan",
]

MAN_BIOS = [
    ("Addis-based, loves jazz cafés and hiking Entoto.", "ጃዝና ተራራ"),
    ("Engineer who hosts board-game nights and specialty coffee.", "ቡናና ጨዋታ"),
    ("Architect. Slow Sundays, galleries, Piazza walks.", "ጥበብና ጉዞ"),
    ("Chef experimenting with modern Ethiopian plates.", "ዘመናዊ ምግብ"),
    ("Product designer. Climbing walls and vinyl weekends.", "መውጣትና ሙዚቃ"),
    ("Finance by day, football and street photography by night.", "ፎቶና እግር ኳስ"),
    ("Pilot. Soft landings and long dinners in Kazanchis.", "አብራሪ — እራት"),
    ("University lecturer. Debate clubs and rain-season walks.", "መምህር"),
    ("Startup founder. Early gym, late sketching.", "ስታርትአፕ"),
    ("Hotelier. Courtyard coffee and live jazz guests.", "ሆቴል"),
    ("Civil engineer. Weekend trail runs above Entoto.", "ሩጫ"),
    ("Documentary editor. Markets, lenses, quiet editing nights.", "ፊልም"),
    ("Diplomat. Long lunches, short speeches, careful charm.", "ዲፕሎማት"),
    ("Sommelier in training. Natural wine and late kitchens.", "ወይን"),
    ("Surgeon with rare evenings and a love of vinyl.", "ሐኪም"),
    ("Jazz bassist. After-hours rooms and slow tempos.", "ሙዚቃ"),
    ("Importer. Travel stamps and discreet hospitality.", "ንግድ"),
    ("Lawyer who actually reads the footnotes.", "ሕግ"),
    ("Coffee exporter. Origin trips and quiet cuppings.", "ቡና"),
    ("Property developer. Rooftops with a view of Entoto.", "ሪል እስቴት"),
    ("Software lead. Night builds and morning espresso.", "ቴክ"),
    ("Historian. Archives by day, live music by night.", "ታሪክ"),
    ("Football coach. Early drills, late dinners.", "እግር ኳስ"),
    ("Photographer of the city after rain.", "ፎቶ"),
]

WOMAN_BIOS = [
    ("Designer with an eye for beautiful details and a night that unfolds slowly.", "ዲዛይነር"),
    ("Amharic poetry, candlelit dinners, and glances that linger.", "ግጥም"),
    ("Bright energy, a runner's confidence, and music that pulls a room closer.", "ሩጫ"),
    ("Vinyl, espresso, and an easy smile before the first song ends.", "UX"),
    ("Sharp mind, warm presence, theatre, and unhurried attention.", "ጠበቃ"),
    ("Soft playlists and a calm confidence that makes late nights effortless.", "ሐኪም"),
    ("Photographer with a cinematic eye for charged pauses.", "ፎቶ"),
    ("Ballet teacher: poised, playful, strong coffee, a little anticipation.", "ባሌት"),
    ("Quick wit and a slow build — markets, bookstores, tension.", "ስታርትአፕ"),
    ("Journalist who loves jazz, kitfo, and conversation that forgets the clock.", "ጋዜጠኛ"),
    ("Florist with a soft spot for fragrance and evenings that stay memorable.", "አበባ"),
    ("Architect who likes a beautiful setting and someone who can hold a room.", "አርክቴክት"),
    ("Gentle after a long shift. Soft playlists and real ease.", "ነርስ"),
    ("Pastry chef — sweetness, banter, a night that feels like an indulgence.", "ፓስትሪ"),
    ("Thoughtful, quietly magnetic. Lake weekends and intimate talk after dark.", "ምርምር"),
    ("Yoga instructor with a teasing smile and music that slows the room.", "ዮጋ"),
    ("Radio producer who knows the power of a low voice and a great playlist.", "ሬዲዮ"),
    ("Translator with a love for rainy cafés and the first-meeting spark.", "ተርጓሚ"),
    ("Stylist. Tailoring, perfume, and a look that does the talking.", "ስታይል"),
    ("Sommelier. Natural wine, low light, unhurried courses.", "ወይን"),
    ("Painter. Colour, silence, and a studio that stays open late.", "ሥዕል"),
    ("Cellist. Slow movements and rooms that listen back.", "ሙዚቃ"),
    ("Host. Discreet tables, good stories, better timing.", "አስተናጋጅ"),
    ("Dancer. Heat, precision, and a laugh that disarms.", "ዳንስ"),
    ("Editor. Sharp lines, softer nights.", "አርታዒ"),
    ("Perfumer. Skin, memory, and a trail that stays.", "ሽቶ"),
    ("Galleries, silk, and a gaze that does not hurry.", "ጋለሪ"),
    ("Private chef. Spice, candlelight, no rush.", "ሼፍ"),
    ("Voice actor. Warm timbre, warmer company.", "ድምጽ"),
    ("Jewelry designer. Gold, restraint, a little flash.", "ጌጣጌጥ"),
    ("Pilot on layover energy — curious, composed, gone by morning if needed.", "አብራሪ"),
    ("Set designer. Atmosphere first, then conversation.", "መድረክ"),
    ("Calligrapher. Beautiful letters, slower evenings.", "ጽሑፍ"),
    ("Mixologist. Bitter, sweet, and exactly enough ice.", "ኮክቴል"),
    ("Curator. Quiet rooms, loud taste.", "ኩሬተር"),
    ("Composer. Night motifs and a private encore.", "ሙዚቃ"),
]

JOBS = [
    "Designer", "Poet", "Athlete", "Product designer", "Lawyer", "Doctor",
    "Photographer", "Dance instructor", "Founder", "Journalist", "Florist",
    "Architect", "Nurse", "Pastry chef", "Researcher", "Yoga instructor",
    "Radio producer", "Translator", "Stylist", "Sommelier", "Painter",
    "Cellist", "Host", "Dancer", "Editor", "Perfumer", "Galleries",
    "Private chef", "Voice actor", "Jewelry designer", "Pilot", "Set designer",
    "Calligrapher", "Mixologist", "Curator", "Composer",
]
LOOKING = [
    "Slow burn", "Playful nights", "Discreet company", "Soft & romantic",
    "Confident energy", "Late night", "Verified venue first", "Unhurried evenings",
]
CITIES = ["Addis Ababa", "Bole", "Piazza", "Kazanchis"]
INTERESTS = [
    '["Design","Food","Art"]',
    '["Books","Art","Coffee"]',
    '["Fitness","Travel","Music"]',
    '["Music","Coffee","Tech"]',
    '["Books","Art","Food"]',
    '["Hiking","Music","Faith"]',
    '["Film","Travel","Art"]',
    '["Dance","Coffee","Fitness"]',
    '["Books","Food","Travel"]',
    '["Music","Food","Books"]',
]
NOTES = [
    "Tonight · hotel or private suite",
    "Weeknights after 8 · Bole",
    "Weekends open · discreet venue",
    "See calendar for open windows",
    "Evenings only · Kazanchis",
    "Last-minute nights welcome",
]

# Abel-centric layout (man 1 / +251911100001) so every client screen is packed:
#   Mutuals 1–16  → inbox chats (2 completed meetings drop to history)
#   Intros  17–24 → concierge PROPOSED
#   Passes  25–32 → recent skips
#   History 33–38 → declined / expired / cancelled (still eligible for Browse)
#   Browse  33–59 → ~27 listings (Discover cap 50)
#   60            → pending verification, listing off
MUTUALS = [(1, w) for w in range(1, 17)] + [
    (2, 1), (3, 2), (4, 5), (5, 8), (6, 10), (8, 12),
    (9, 14), (10, 40), (11, 45), (12, 50), (13, 55), (15, 58),
]
CONCIERGE = [(1, w) for w in range(17, 25)] + [(2, 41), (4, 42), (7, 43), (16, 44)]
DECLINED = [(1, 33), (1, 34), (1, 35), (3, 46)]
EXPIRED = [(1, 36), (1, 37), (5, 47)]
CANCELLED_CONNS = [(1, 38)]

# One booking per connection (unique connection_id). Indices into MUTUALS.
# Payment testing: CONFIRMED + UNPAID → tap Pay in chat/booking; CONFIRMED + PENDING → CBE panel resumes.
BOOKING_STATES = [
    # Abel inbox / bookings
    (0, "PROPOSED", "UNPAID", "SESSION", 3, "Kazanchis — private residence (discreet)"),
    (1, "PROPOSED", "UNPAID", "OVERNIGHT", 6, "Bole — discreet suite"),
    (2, "CONFIRMED", "PENDING", "SESSION", 2, None),  # venue Tomoca — payment in progress
    (3, "CONFIRMED", "PENDING", "OVERNIGHT", 5, "Piazza — discreet suite"),
    (4, "CONFIRMED", "UNPAID", "SESSION", 1, "Bole — hotel suite"),
    (5, "CONFIRMED", "UNPAID", "SESSION", 4, "Kazanchis — private dining"),
    (6, "CONFIRMED", "UNPAID", "OVERNIGHT", 7, "Bole — overnight residence"),
    (7, "CONFIRMED", "UNPAID", "SESSION", 10, "Piazza — gallery after-hours"),
    (8, "CHECKED_IN", "PAID", "SESSION", 0, "Bole — hotel suite"),
    (9, "COMPLETED", "PAID", "SESSION", -4, "Bole — discreet suite"),
    (10, "COMPLETED", "PAID", "OVERNIGHT", -11, "Kazanchis — private residence"),
    (11, "CANCELLED", "UNPAID", "SESSION", -2, "Addis — cancelled demo"),
    (12, "CONFIRMED", "UNPAID", "SESSION", 9, "Piazza — jazz room"),
    (13, "CONFIRMED", "UNPAID", "OVERNIGHT", 14, "Bole — weekend suite"),
    (14, "CONFIRMED", "UNPAID", "SESSION", 11, "Kazanchis — late session"),
    (15, "CONFIRMED", "PAID", "SESSION", 2, "Bole — paid reference booking"),
    # Other clients so performer dashboards are busy too
    (16, "CONFIRMED", "PAID", "SESSION", 3, "Bole — café table"),
    (17, "COMPLETED", "PAID", "SESSION", -6, "Piazza — completed demo"),
    (18, "PROPOSED", "UNPAID", "SESSION", 4, "Kazanchis — intro dinner"),
]


def uid(prefix: str, n: int) -> str:
    return f"{prefix}{n:02d}"


def man_id(n: int) -> str:
    return uid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa", n)


def woman_id(n: int) -> str:
    return uid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb", n)


def man_phone(n: int) -> str:
    return f"+25191110{n:04d}"


def woman_phone(n: int) -> str:
    return f"+25191120{n:04d}"


def conn_id(n: int) -> str:
    return uid("cccccccc-cccc-cccc-cccc-cccccccccc", n)


def thread_id(n: int) -> str:
    return uid("dddddddd-dddd-dddd-dddd-dddddddddd", n)


def msg_id(n: int) -> str:
    return f"eeeeeeee-eeee-eeee-eeee-eeeeeeee{n:04d}"


def book_id(n: int) -> str:
    return f"a2a2a2a2-a2a2-42a2-82a2-a2a2a2a2a2{n:02d}"


def pay_id(n: int) -> str:
    return f"ffffffff-ffff-4fff-8fff-ffffffffff{n:02d}"


def led_id(n: int) -> str:
    return f"11111111-1111-4111-8111-1111111111{n:02d}"


def note_id(n: int) -> str:
    return f"a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a{n:03d}"


def ver_id(n: int) -> str:
    return f"99999999-9999-4999-8999-9999999999{n:02d}"


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def photos(kind: str, n: int, count: int = 3) -> str:
    if kind == "women":
        return woman_photos_json(n)
    urls = [
        f"https://randomuser.me/api/portraits/men/{(40 + n + i * 7) % 99}.jpg"
        for i in range(count)
    ]
    inner = ",".join(f'"{u}"' for u in urls)
    return f"'[{inner}]'"


def latlng(n: int, female: bool) -> tuple[float, float]:
    jitter = (n * 0.0017) + (0.0004 if female else 0)
    return round(9.010 + (n % 8) * 0.0045 + jitter, 4), round(38.740 + (n % 6) * 0.008 + jitter, 4)


def wipe_sql() -> str:
    return Path(__file__).with_name("demo_roster_wipe.sql").read_text() if False else WIPE


WIPE = r"""-- Local demo roster: wipe then reload on every API start (VELVET_SEED_RESET=true).
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

"""


def generate() -> str:
    out: list[str] = [WIPE]
    if len(MAN_NAMES) != MEN or len(WOMAN_NAMES) != WOMEN:
        raise SystemExit(f"Name lists must match MEN={MEN} WOMEN={WOMEN}")
    conn_pairs = MUTUALS + CONCIERGE + DECLINED + EXPIRED + CANCELLED_CONNS
    if len(conn_pairs) != len(set(conn_pairs)):
        raise SystemExit("Duplicate connection pairs in seed layout")
    taken = set(conn_pairs)

    # Users
    rows = []
    for i, name in enumerate(MAN_NAMES, 1):
        y = 1988 + (i % 10)
        loc = "am" if i % 4 == 0 else "en"
        rows.append(
            f"  ({sql_str(man_id(i))}, {sql_str(man_phone(i))}, 'ACTIVE', 'CLIENT', "
            f"{sql_str(name)}, '{y}-{((i * 3) % 12) + 1:02d}-{((i * 5) % 27) + 1:02d}', "
            f"'MALE', '{loc}', 'v1-2026-08', NOW())"
        )
    for i, name in enumerate(WOMAN_NAMES, 1):
        y = 1993 + (i % 8)
        loc = "am" if i % 3 == 0 else "en"
        status = "ACTIVE" if i == WOMEN else "VERIFIED"
        rows.append(
            f"  ({sql_str(woman_id(i))}, {sql_str(woman_phone(i))}, '{status}', 'PERFORMER', "
            f"{sql_str(name)}, '{y}-{((i * 2) % 12) + 1:02d}-{((i * 7) % 27) + 1:02d}', "
            f"'FEMALE', '{loc}', 'v1-2026-08', NOW())"
        )
    out.append("INSERT INTO users (id, phone_e164, status, role, display_name, date_of_birth, gender, preferred_locale, legal_accepted_version, legal_accepted_at)\nVALUES\n")
    out.append(",\n".join(rows) + ";\n\n")

    # Profiles
    prof = []
    for i in range(1, MEN + 1):
        bio_en, bio_am = MAN_BIOS[i - 1]
        city = CITIES[(i - 1) % len(CITIES)]
        lat, lng = latlng(i, False)
        job = ["Engineer", "Architect", "Chef", "Founder", "Pilot", "Lecturer"][(i - 1) % 6]
        prof.append(
            f"    ({sql_str(man_phone(i))}, {sql_str(bio_en)}, {sql_str(bio_am)}, {sql_str(city)}, "
            f"'{INTERESTS[(i - 1) % len(INTERESTS)]}', {photos('men', i, 3)}, {lat}, {lng}, "
            f"{168 + (i % 20)}, {sql_str(job)}, 'English, Amharic', NULL, 'APPROVED')"
        )
    for i in range(1, WOMEN + 1):
        bio_en, bio_am = WOMAN_BIOS[(i - 1) % len(WOMAN_BIOS)]
        city = CITIES[(i - 1) % len(CITIES)]
        lat, lng = latlng(i, True)
        job = JOBS[(i - 1) % len(JOBS)]
        looking = LOOKING[(i - 1) % len(LOOKING)]
        langs = "Amharic, English" if i % 2 else "English, Amharic, French"
        quality = "NEEDS_REVIEW" if i == WOMEN else "APPROVED"
        prof.append(
            f"    ({sql_str(woman_phone(i))}, {sql_str(bio_en)}, {sql_str(bio_am)}, {sql_str(city)}, "
            f"'{INTERESTS[(i - 1) % len(INTERESTS)]}', {photos('women', i, 3)}, {lat}, {lng}, "
            f"{158 + (i % 18)}, {sql_str(job)}, {sql_str(langs)}, {sql_str(looking)}, '{quality}')"
        )

    out.append(
        """INSERT INTO member_profiles (
  user_id, bio_en, bio_am, city, interests, photo_urls, last_lat, last_lng, location_updated_at,
  height_cm, job_title, languages, looking_for, photo_quality_status, photo_quality_notes
)
SELECT u.id, v.bio_en, v.bio_am, v.city, v.interests::jsonb, v.photos::jsonb, v.lat, v.lng, NOW(),
       v.height_cm, v.job_title, v.languages, v.looking_for, v.photo_quality, 'Demo seed approved'
FROM (
  VALUES
"""
    )
    out.append(",\n".join(prof))
    out.append(
        """
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

"""
    )

    # Likes — other men fill performer request queues. Abel (man 1) does NOT like
    # the browse pool or he would empty his own Discover feed.
    like_pairs: list[tuple[int, int]] = []
    like_set: set[tuple[int, int]] = set()
    for w in range(1, WOMEN):
        for k in range(8):
            m = ((w + k * 3) % (MEN - 1)) + 2  # men 2–24
            pair = (m, w)
            if pair in taken or pair in like_set:
                continue
            like_set.add(pair)
            like_pairs.append(pair)
    # Extra inbound likes on popular listings (Sara and the first 16)
    for w in range(1, 17):
        for m in range(2, MEN + 1):
            pair = (m, w)
            if pair in taken or pair in like_set:
                continue
            if (m + w) % 2 == 0:
                like_set.add(pair)
                like_pairs.append(pair)

    like_sql = ",\n  ".join(
        f"({sql_str(man_phone(m))}, {sql_str(woman_phone(w))}, 'LIKE')"
        for m, w in like_pairs
    )
    pass_pairs = [(1, w) for w in range(25, 33)]  # Abel recent skips
    for m, w in pass_pairs:
        like_set.add((m, w))
    for m in range(2, MEN + 1):
        for w in (m + 8, m + 17, m + 29):
            ww = ((w - 1) % (WOMEN - 1)) + 1
            pair = (m, ww)
            if pair in taken or pair in like_set:
                continue
            pass_pairs.append(pair)
            like_set.add(pair)
    pass_sql = ",\n  ".join(
        f"({sql_str(man_phone(m))}, {sql_str(woman_phone(w))}, 'PASS')"
        for m, w in pass_pairs
    )
    out.append(
        f"""INSERT INTO member_likes (from_user_id, to_user_id, action)
SELECT m.id, w.id, pairs.action
FROM (VALUES
  {like_sql},
  {pass_sql}
) AS pairs(from_phone, to_phone, action)
JOIN users m ON m.phone_e164 = pairs.from_phone
JOIN users w ON w.phone_e164 = pairs.to_phone;

"""
    )

    # Connections
    conn_rows = []
    cid = 1
    mutual_cids: list[int] = []
    for m, w in MUTUALS:
        days = 1 + (cid % 5)
        conn_rows.append(
            f"""(
  {sql_str(conn_id(cid))}, {sql_str(man_id(m))}, {sql_str(woman_id(w))},
  'MUTUAL', 'You both said yes — plan a private night when ready.', 'ሁለታችሁም ተስማምታችኋል።',
  NOW() + INTERVAL '30 days', 'DISCOVERY',
  NOW() - INTERVAL '{days + 1} days', NOW() - INTERVAL '{days} days', NOW() - INTERVAL '{days} days', NOW()
)"""
        )
        mutual_cids.append(cid)
        cid += 1
    for m, w in CONCIERGE:
        conn_rows.append(
            f"""(
  {sql_str(conn_id(cid))}, {sql_str(man_id(m))}, {sql_str(woman_id(w))},
  'PROPOSED', 'Concierge intro — a discreet first meeting is worth it.', 'የ concierge መግቢያ።',
  NOW() + INTERVAL '7 days', 'CONCIERGE',
  NOW(), NULL, NULL, NOW()
)"""
        )
        cid += 1
    for m, w in DECLINED:
        conn_rows.append(
            f"""(
  {sql_str(conn_id(cid))}, {sql_str(man_id(m))}, {sql_str(woman_id(w))},
  'DECLINED', 'Shared love of running — optional intro.', 'ሩጫ ይወዳሉ።',
  NOW() + INTERVAL '1 day', 'CONCIERGE',
  NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'
)"""
        )
        cid += 1
    for m, w in EXPIRED:
        conn_rows.append(
            f"""(
  {sql_str(conn_id(cid))}, {sql_str(man_id(m))}, {sql_str(woman_id(w))},
  'EXPIRED', 'Startup founder meets market explorer.', 'ስታርትአፕ እና ገበያ።',
  NOW() - INTERVAL '2 days', 'DISCOVERY',
  NOW() - INTERVAL '14 days', NULL, NULL, NOW() - INTERVAL '2 days'
)"""
        )
        cid += 1
    for m, w in CANCELLED_CONNS:
        conn_rows.append(
            f"""(
  {sql_str(conn_id(cid))}, {sql_str(man_id(m))}, {sql_str(woman_id(w))},
  'CANCELLED', 'Evening fell through — kept on file.', 'ተሰርዟል።',
  NOW() - INTERVAL '1 day', 'DISCOVERY',
  NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '3 days'
)"""
        )
        cid += 1

    out.append(
        """INSERT INTO connections (
  id, member_a_id, member_b_id, status, intro_note_en, intro_note_am,
  expires_at, source, created_at, a_responded_at, b_responded_at, updated_at
) VALUES
"""
    )
    out.append(",\n".join(conn_rows) + ";\n\n")

    # Listing rates + availability
    out.append(
        """UPDATE member_profiles SET
    session_rate_etb = 3500 + ((ABS(HASHTEXT(user_id::text)) % 8) * 500),
    overnight_rate_etb = 12000 + ((ABS(HASHTEXT(user_id::text)) % 6) * 1500),
    availability_note = 'See calendar for open windows',
    listing_active = TRUE
WHERE user_id IN (SELECT id FROM users WHERE gender = 'FEMALE' AND phone_e164 LIKE '+251911200%');

UPDATE member_profiles p SET availability_note = v.note
FROM (VALUES
"""
    )
    note_vals = []
    for i in range(1, WOMEN):
        note_vals.append(f"  ({sql_str(woman_id(i))}, {sql_str(NOTES[(i - 1) % len(NOTES)])})")
    out.append(",\n".join(note_vals))
    out.append(
        """
) AS v(user_id, note)
WHERE p.user_id = v.user_id::uuid;

UPDATE users SET status = 'ACTIVE' WHERE id = """
        + sql_str(woman_id(WOMEN))
        + """;
UPDATE member_profiles SET listing_active = FALSE
WHERE user_id = """
        + sql_str(woman_id(WOMEN))
        + """;

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '18 hours',
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '23 hours',
       'Evening session'
FROM users u
CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%'
  AND u.id <> """
        + sql_str(woman_id(WOMEN))
        + """;

INSERT INTO availability_windows (id, user_id, starts_at, ends_at, note)
SELECT gen_random_uuid(), u.id,
       date_trunc('hour', NOW()) + (d.day * INTERVAL '1 day') + INTERVAL '20 hours',
       date_trunc('hour', NOW()) + ((d.day + 1) * INTERVAL '1 day') + INTERVAL '8 hours',
       'Overnight'
FROM users u
CROSS JOIN (VALUES (1),(3),(5)) AS d(day)
WHERE u.gender = 'FEMALE' AND u.phone_e164 LIKE '+251911200%'
  AND u.id <> """
        + sql_str(woman_id(WOMEN))
        + """;

"""
    )

    # Verification
    ver_rows = [
        f"""(
  {sql_str(ver_id(1))}, {sql_str(woman_id(WOMEN))}, 'SUBMITTED',
  'https://randomuser.me/api/portraits/women/90.jpg',
  'https://randomuser.me/api/portraits/women/91.jpg',
  'Demo queue — pending ID review',
  NULL, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'
)"""
    ]
    for i in range(1, WOMEN):
        ver_rows.append(
            f"""(
  {sql_str(ver_id(i + 1))}, {sql_str(woman_id(i))}, 'APPROVED',
  'https://randomuser.me/api/portraits/women/{i % 90}.jpg',
  'https://randomuser.me/api/portraits/women/{(i + 3) % 90}.jpg',
  'Demo approved',
  NOW() - INTERVAL '{20 + i} days', NOW() - INTERVAL '{21 + i} days', NOW() - INTERVAL '{20 + i} days'
)"""
        )
    out.append(
        """INSERT INTO verification_cases (id, user_id, status, id_document_url, selfie_url, notes, reviewed_at, created_at, updated_at)
VALUES
"""
    )
    out.append(",\n".join(ver_rows) + ";\n\n")
    out.append(
        """INSERT INTO legal_acceptances (user_id, document_set_version, accepted_at, source)
SELECT id, 'v1-2026-08', NOW() - INTERVAL '2 days', 'APP'
FROM users
WHERE phone_e164 LIKE '+251911100%' OR phone_e164 LIKE '+251911200%'
ON CONFLICT (user_id, document_set_version) DO NOTHING;

"""
    )

    # Chat for every mutual — Abel's threads are long and mixed unread / your-turn
    thread_rows = []
    msg_rows = []
    mid = 1
    openers = [
        ("Hi {her} — your listing caught my eye.", "Thank you {him}. Slow night or a private suite first?"),
        ("{her}, Saturday evening works on my side.", "Send the booking when you are ready."),
        ("Loved the energy in your photos.", "Likewise — let's keep it discreet."),
        ("Are you free after 9 this weekend?", "I have an open window. Book it."),
        ("Your Piazza photos made me pause.", "That room is my favourite. Come see it."),
        ("Would you rather a hotel suite or a private table first?", "Suite. Then we can decide about dinner."),
    ]
    extra_abel = [
        "I can do after 8 any weeknight this week.",
        "Kazanchis is easier for me if that still works.",
        "I'll keep the booking notes short and discreet.",
        "Tell me if you want overnight instead of a session.",
        "I liked the jazz mention in your bio.",
        "Confirmed — I'll follow the venue instructions.",
    ]
    extra_her = [
        "That window is still open on my calendar.",
        "Wear something simple. I'll handle the rest.",
        "Don't be late — I hate a rushed start.",
        "If you want overnight, send the higher rate.",
        "I already told the desk to expect a guest.",
        "Message me when you're 10 minutes away.",
    ]
    for idx, cid_n in enumerate(mutual_cids):
        m, w = MUTUALS[idx]
        him, her = MAN_NAMES[m - 1], WOMAN_NAMES[w - 1]
        abel_thread = m == 1
        if abel_thread and idx % 3 == 0:
            a_read, b_read = "2 days", "20 minutes"
        elif abel_thread and idx % 3 == 1:
            a_read, b_read = "8 minutes", "3 hours"
        elif abel_thread:
            a_read, b_read = "40 minutes", "12 minutes"
        else:
            a_read = "20 hours" if idx % 2 == 0 else "4 days"
            b_read = "45 minutes" if idx % 3 == 0 else "6 hours"
        thread_rows.append(
            f"""(
  {sql_str(thread_id(idx + 1))}, {sql_str(conn_id(cid_n))},
  {sql_str(man_id(m))}, {sql_str(woman_id(w))}, 'OPEN',
  NOW() - INTERVAL '{a_read}', NOW() - INTERVAL '{b_read}', NOW() - INTERVAL '{2 + idx} days'
)"""
        )
        a, b = openers[idx % len(openers)]
        lines = [
            (man_id(m), a.format(her=her, him=him), f"{48 - (idx % 20)} hours"),
            (woman_id(w), b.format(her=her, him=him), f"{30 - (idx % 10)} hours"),
            (man_id(m), "I will send a booking request.", f"{18 + (idx % 5)} hours"),
            (woman_id(w), "Perfect. I have an open window.", f"{90 + idx} minutes"),
        ]
        if abel_thread:
            for j in range(6):
                ago = f"{55 - j * 8} minutes"
                if j % 2 == 0:
                    lines.append((man_id(m), extra_abel[j], ago))
                else:
                    lines.append((woman_id(w), extra_her[j], ago))
            if idx % 3 == 0:
                lines.append((woman_id(w), "I'm free tonight if you still want this.", "12 minutes"))
            elif idx % 3 == 1:
                lines.append((man_id(m), "Booking is in — check your dates.", "6 minutes"))
        elif idx % 2 == 0:
            lines.append((man_id(m), "Discreet venue in Bole works.", f"{8 + idx} minutes"))
        for sender, body, ago in lines:
            msg_rows.append(
                f"({sql_str(msg_id(mid))}, {sql_str(thread_id(idx + 1))}, {sql_str(sender)}, {sql_str(body)}, 'ALLOWED', NOW() - INTERVAL '{ago}')"
            )
            mid += 1

    out.append(
        """INSERT INTO chat_threads (
  id, connection_id, member_a_id, member_b_id, status,
  a_last_read_at, b_last_read_at, created_at
) VALUES
"""
    )
    out.append(",\n".join(thread_rows) + ";\n\n")
    out.append("INSERT INTO messages (id, thread_id, sender_id, body, moderation_status, created_at)\nVALUES\n")
    out.append(",\n".join(msg_rows) + ";\n\n")

    # Bookings
    book_rows = []
    pay_rows = []
    pay_n = 1
    led_rows = []
    led_n = 1
    payout_rows = []
    for bi, (mi, status, pay, rate, day_off, meetup) in enumerate(BOOKING_STATES, 1):
        cid_n = mutual_cids[mi]
        m, w = MUTUALS[mi]
        amount = 4000 + bi * 500 if rate == "SESSION" else 14000
        venue = "(SELECT id FROM venues WHERE name ILIKE '%Tomoca%' LIMIT 1)" if meetup is None else "NULL"
        place = "NULL" if meetup is None else sql_str(meetup)
        start = (
            f"date_trunc('hour', NOW()) + INTERVAL '{day_off} days' + INTERVAL '19 hours'"
            if day_off >= 0
            else f"date_trunc('hour', NOW()) - INTERVAL '{-day_off} days' + INTERVAL '20 hours'"
        )
        confirmed = "NULL"
        cin = cout = pcout = ccout = "NULL"
        if status in ("CONFIRMED", "CHECKED_IN", "COMPLETED", "CANCELLED"):
            confirmed = "NOW() - INTERVAL '1 day'"
        if status in ("CHECKED_IN", "COMPLETED"):
            cin = start
        if status == "COMPLETED":
            cout = pcout = ccout = f"({start}) + INTERVAL '3 hours'"
        if status == "CANCELLED":
            confirmed = "NULL"
        book_rows.append(
            f"""(
  {sql_str(book_id(bi))}, {sql_str(conn_id(cid_n))}, {venue}, {place},
  '{rate}', {amount}, '{pay}', {sql_str(man_id(m))}, '{status}',
  {start}, {sql_str(f'Demo {status.lower()} booking')},
  {confirmed}, {cin}, {cout}, {pcout}, {ccout},
  NOW() - INTERVAL '{3 + bi} days', NOW() - INTERVAL '{bi} days'
)"""
        )
        if pay in ("PENDING", "PAID"):
            st = "CHECKOUT" if pay == "PENDING" else "PAID"
            paid_at = "NULL" if pay == "PENDING" else "NOW() - INTERVAL '5 days'"
            pref = "NULL" if pay == "PENDING" else sql_str(f"FT-DEMO-{bi:03d}CBE")
            pay_rows.append(
                f"""(
  {sql_str(pay_id(pay_n))}, {sql_str(man_id(m))}, NULL, 'BOOKING', {sql_str(book_id(bi))},
  'CBE', {sql_str(f'DEMO-BOOK-{bi:03d}')}, {amount:.2f}, 'ETB', '{st}',
  {'NULL' if st == 'PAID' else sql_str(f'https://example.local/cbe/demo-book-{bi:03d}')},
  {pref}, NOW() - INTERVAL '{bi} days', NOW() - INTERVAL '{bi} days', {paid_at}
)"""
            )
            if pay == "PAID" and status in ("COMPLETED", "CHECKED_IN", "CONFIRMED"):
                credit = round(amount * 0.85, 2)
                fee = round(amount * 0.15, 2)
                led_rows.append(
                    f"({sql_str(led_id(led_n))}, {sql_str(woman_id(w))}, {sql_str(pay_id(pay_n))}, {sql_str(book_id(bi))}, 'PERFORMER_CREDIT', {credit:.2f}, 'ETB', {sql_str(f'Booking credit (85% of {amount} ETB)')}, NOW() - INTERVAL '5 days')"
                )
                led_n += 1
                led_rows.append(
                    f"({sql_str(led_id(led_n))}, NULL, {sql_str(pay_id(pay_n))}, {sql_str(book_id(bi))}, 'PLATFORM_FEE', {fee:.2f}, 'ETB', {sql_str(f'Platform fee 15% booking {bi}')}, NOW() - INTERVAL '5 days')"
                )
                if status == "COMPLETED":
                    payout_rows.append(
                        f"({sql_str(f'c1c1c1c1-c1c1-41c1-81c1-c1c1c1c1c1{bi:02d}')}, {sql_str(woman_id(w))}, {min(3000, credit):.2f}, 'REQUESTED', {sql_str(f'CBE •••• {4800 + bi} — demo payout')}, {sql_str(led_id(led_n - 1))}, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days')"
                    )
                led_n += 1
            pay_n += 1

    out.append(
        """INSERT INTO bookings (
  id, connection_id, venue_id, meetup_place, rate_type, amount_etb, payment_status,
  proposed_by, status, starts_at, notes, confirmed_at, checked_in_at, checked_out_at,
  performer_checked_out_at, client_checked_out_at, created_at, updated_at
) VALUES
"""
    )
    out.append(",\n".join(book_rows) + ";\n\n")
    out.append(
        """INSERT INTO payment_intents (
  id, user_id, plan_id, purpose, booking_id, provider, merchant_order_id,
  amount_etb, currency, status, checkout_url, provider_ref, created_at, updated_at, paid_at
) VALUES
"""
    )
    out.append(",\n".join(pay_rows) + ";\n\n")
    # Wire payment_intent_id back onto bookings
    for bi, (_, _, pay, _, _, _) in enumerate(BOOKING_STATES, 1):
        if pay in ("PENDING", "PAID"):
            # pay ids increment only for those — reconstruct
            pass
    # Simpler: update by booking merchant mapping using sequential pay ids
    pn = 1
    for bi, (_, _, pay, _, _, _) in enumerate(BOOKING_STATES, 1):
        if pay in ("PENDING", "PAID"):
            out.append(
                f"UPDATE bookings SET payment_intent_id = {sql_str(pay_id(pn))} WHERE id = {sql_str(book_id(bi))};\n"
            )
            pn += 1

    out.append(
        "\nINSERT INTO ledger_entries (id, user_id, payment_intent_id, booking_id, entry_type, amount_etb, currency, description, created_at)\nVALUES\n"
    )
    out.append(",\n".join(led_rows) + ";\n\n")
    if payout_rows:
        out.append(
            "INSERT INTO payout_requests (id, user_id, amount_etb, status, destination_note, ledger_entry_id, created_at, updated_at)\nVALUES\n"
        )
        out.append(",\n".join(payout_rows) + ";\n\n")

    out.append(
        f"""INSERT INTO concierge_tasks (id, booking_id, match_id, task_type, due_at, status, notes, created_at, updated_at)
VALUES
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e101',
  {sql_str(book_id(3))},
  {sql_str(conn_id(mutual_cids[2]))},
  'PRE_CALL',
  date_trunc('hour', NOW()) + INTERVAL '2 days' + INTERVAL '18 hours',
  'OPEN',
  'Confirm arrival at Tomoca',
  NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'
),
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e102',
  {sql_str(book_id(5))},
  {sql_str(conn_id(mutual_cids[4]))},
  'PRE_CALL',
  date_trunc('hour', NOW()) + INTERVAL '1 day' + INTERVAL '17 hours',
  'OPEN',
  'Abel tonight — Bole hotel suite',
  NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'
),
(
  'e1e1e1e1-e1e1-41e1-81e1-e1e1e1e1e103',
  {sql_str(book_id(9))},
  {sql_str(conn_id(mutual_cids[8]))},
  'ARRIVAL_CHECK',
  date_trunc('hour', NOW()) + INTERVAL '1 hour',
  'OPEN',
  'Abel checked in — monitor window',
  NOW() - INTERVAL '90 minutes', NOW() - INTERVAL '90 minutes'
);

"""
    )

    # Notifications — Abel gets a production-sized unread inbox
    notes = []
    nid = 1
    for i in range(1, MEN + 1):
        read_at = "NULL" if i == 1 else "NOW() - INTERVAL '2 days'"
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(man_id(i))}, 'Listings nearby', 'New performer listings match your filters in Addis.', 'DISCOVER', NULL, {read_at}, NOW() - INTERVAL '{i} hours')"
        )
        nid += 1
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(man_id(i))}, 'Membership active', 'Elite access is live — browse and send interest.', 'MEMBERSHIP', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days')"
        )
        nid += 1
    for i in range(1, WOMEN):
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(woman_id(i))}, 'New interest', 'A client sent discreet interest on your listing.', 'MATCH', NULL, NULL, NOW() - INTERVAL '{(i % 20) + 1} hours')"
        )
        nid += 1
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(woman_id(i))}, 'Listing live', 'Your photos are approved and your listing is visible.', 'PROFILE', NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '5 days')"
        )
        nid += 1
    # Unread chat pings on Abel's mutuals + a few others
    for idx, cid_n in enumerate(mutual_cids):
        m, w = MUTUALS[idx]
        if m != 1 and idx > 20:
            continue
        man_read = "NULL" if m == 1 else "NOW() - INTERVAL '1 day'"
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(man_id(m))}, {sql_str(WOMAN_NAMES[w-1] + ' replied')}, 'Open chat to continue the evening.', 'MATCH', {sql_str(conn_id(cid_n))}, {man_read}, NOW() - INTERVAL '{20 + idx} minutes')"
        )
        nid += 1
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(woman_id(w))}, {sql_str(MAN_NAMES[m-1] + ' messaged')}, 'He is waiting on your reply.', 'MATCH', {sql_str(conn_id(cid_n))}, NULL, NOW() - INTERVAL '{15 + idx} minutes')"
        )
        nid += 1
    # Abel booking + reminder stack (unread)
    abel_booking_notes = [
        (2, "BOOKING", "Awaiting payment", "Liya is holding Tomoca — complete CBE checkout."),
        (3, "BOOKING", "Awaiting payment", "Mariam overnight is confirmed — finish CBE payment."),
        (4, "BOOKING", "Pay for booking", "Betel confirmed your Bole suite — tap Pay to start CBE."),
        (5, "BOOKING", "Pay for booking", "Selam confirmed Kazanchis dining — payment due before the night."),
        (6, "BOOKING", "Pay for booking", "Helen overnight in Bole is confirmed and unpaid."),
        (7, "BOOKING", "Pay for booking", "Rahel gallery session is confirmed — pay when ready."),
        (8, "BOOKING_REMINDER", "Tonight", "Nardos checked in at the Bole hotel suite."),
        (9, "BOOKING", "Evening complete", "Meron marked the night complete. Leave a private note if you like."),
        (11, "BOOKING", "Booking cancelled", "The Addis session was cancelled. The chat stays open."),
        (12, "BOOKING", "Pay for booking", "Hiwot confirmed the Piazza jazz room — start payment in chat."),
        (13, "BOOKING", "Pay for booking", "Eden weekend overnight is locked — pay to secure the hold."),
        (14, "BOOKING", "Pay for booking", "Kidist late session confirmed — CBE checkout opens from booking."),
        (1, "MATCH", "Concierge intro", "Mekdes is waiting on your yes for a discreet first meeting."),
        (1, "MATCH", "Concierge intro", "Yordanos — concierge thinks this pairing is worth a table."),
    ]
    for hours, ntype, subject, body in abel_booking_notes:
        notes.append(
            f"({sql_str(note_id(nid))}, {sql_str(man_id(1))}, {sql_str(subject)}, {sql_str(body)}, '{ntype}', NULL, NULL, NOW() - INTERVAL '{hours} hours')"
        )
        nid += 1

    out.append(
        "INSERT INTO member_notifications (id, user_id, subject, body, related_type, related_id, read_at, created_at)\nVALUES\n"
    )
    out.append(",\n".join(notes) + ";\n\n")

    out.append(
        f"""INSERT INTO member_blocks (id, blocker_id, blocked_id, reason, created_at)
VALUES (
  'f1f1f1f1-f1f1-41f1-81f1-f1f1f1f1f901',
  {sql_str(woman_id(1))},
  {sql_str(man_id(11))},
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
"""
    )
    return "".join(out)


def main() -> None:
    dest = Path(__file__).resolve().parents[1] / "src/main/resources/db/seed/demo_roster.sql"
    dest.write_text(generate())
    print(f"Wrote {dest} ({dest.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
