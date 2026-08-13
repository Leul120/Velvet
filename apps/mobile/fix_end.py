import re

with open('lib/features/auth/waitlist_screen.dart', 'r') as f:
    r = f.read()
    r = re.sub(
        r'            \),\n          \),\n        \),\n        \],\n      \),\n    \);\n  \}\n\}',
        r'''            ),
          ),
        ),
      ),
      ],
      ),
    );
  }
}''', r)
with open('lib/features/auth/waitlist_screen.dart', 'w') as f:
    f.write(r)

with open('lib/features/auth/profile_setup_screen.dart', 'r') as f:
    r = f.read()
    r = re.sub(
        r'            \),\n          \),\n        \),\n        \],\n      \),\n    \);\n  \}\n\}',
        r'''            ),
          ),
        ),
      ),
      ],
      ),
    );
  }
}''', r)
with open('lib/features/auth/profile_setup_screen.dart', 'w') as f:
    f.write(r)
