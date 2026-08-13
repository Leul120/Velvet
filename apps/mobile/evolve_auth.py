import re

# PROFILE SETUP
prof_path = 'lib/features/auth/profile_setup_screen.dart'
with open(prof_path, 'r') as f:
    text = f.read()

# Replace Inter with Syne for the title
text = re.sub(
    r'                        style: GoogleFonts\.inter\(\n                          fontSize: 28,\n                          fontWeight: FontWeight\.w800,\n                          letterSpacing: -0\.8,',
    r'''                        style: GoogleFonts.syne(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.5,
                          height: 0.95,''',
    text
)
with open(prof_path, 'w') as f:
    f.write(text)


# WAITLIST
wait_path = 'lib/features/auth/waitlist_screen.dart'
with open(wait_path, 'r') as f:
    text = f.read()

# Replace Inter with Syne for the title
text = re.sub(
    r'                        style: GoogleFonts\.inter\(\n                          fontSize: 28,\n                          fontWeight: FontWeight\.w800,\n                          letterSpacing: -0\.8,',
    r'''                        style: GoogleFonts.syne(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.5,
                          height: 0.95,''',
    text
)
with open(wait_path, 'w') as f:
    f.write(text)

