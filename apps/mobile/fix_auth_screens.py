import re

prof_path = 'lib/features/auth/profile_setup_screen.dart'
wait_path = 'lib/features/auth/waitlist_screen.dart'

with open(prof_path, 'r') as f:
    prof = f.read()

prof = prof.replace(
'''    return VelvetAuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,''',
'''    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,''')

prof = prof.replace(
'''        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),''',
'''        body: Stack(
          fit: StackFit.expand,
          children: [
            const VelvetAuthBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 48),''')

prof = prof.replace(
'''            VelvetButton(
              label: l10n.profileSetupFinish,
              loading: saving,
              onPressed: saving ? null : finish,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}''',
'''            VelvetButton(
              label: l10n.profileSetupFinish,
              loading: saving,
              onPressed: saving ? null : finish,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}''')

if 'package:google_fonts/google_fonts.dart' not in prof:
    prof = prof.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:google_fonts/google_fonts.dart';")

with open(prof_path, 'w') as f:
    f.write(prof)


with open(wait_path, 'r') as f:
    wait = f.read()

wait = wait.replace(
'''    return VelvetAuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,''',
'''    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,''')

wait = wait.replace(
'''        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 48),''',
'''        body: Stack(
        fit: StackFit.expand,
        children: [
          const VelvetAuthBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 48),''')

wait = wait.replace(
'''                      VelvetButton(
                        label: l10n.waitlistCheckStatus,
                        variant: VelvetButtonVariant.secondary,
                        loading: _loading,
                        onPressed: _loading ? null : _checkStatus,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}''',
'''                      VelvetButton(
                        label: l10n.waitlistCheckStatus,
                        variant: VelvetButtonVariant.secondary,
                        loading: _loading,
                        onPressed: _loading ? null : _checkStatus,
                      ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}''')

with open(wait_path, 'w') as f:
    f.write(wait)

