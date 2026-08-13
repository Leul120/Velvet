import re

prof_path = 'lib/features/auth/profile_setup_screen.dart'
wait_path = 'lib/features/auth/waitlist_screen.dart'

with open(prof_path, 'r') as f:
    prof = f.read()
# Replace the bad ending
prof = re.sub(
    r'            VelvetButton\(\n              label: l10n\.profileSetupFinish,\n              loading: saving,\n              onPressed: saving \? null : finish,\n            \)\.animate\(\)\.fadeIn\(delay: 200\.ms, duration: 400\.ms\),\n                  \],\n                \),\n              \),\n            \),\n          \),\n        \],\n      \),\n    \);\n  \}\n\}',
    r'''            VelvetButton(
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
}''',
    prof
)
with open(prof_path, 'w') as f:
    f.write(prof)

with open(wait_path, 'r') as f:
    wait = f.read()

wait = re.sub(
    r'                      VelvetButton\(\n                        label: l10n\.waitlistCheckStatus,\n                        variant: VelvetButtonVariant\.secondary,\n                        loading: _loading,\n                        onPressed: _loading \? null : _checkStatus,\n                      \),\n                                \],\n                              \),\n                      \),\n                    \],\n                  \),\n                \),\n              \),\n            \),\n          \),\n        \],\n      \),\n    \);\n  \}\n\}',
    r'''                      VelvetButton(
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
}''',
    wait
)

with open(wait_path, 'w') as f:
    f.write(wait)

