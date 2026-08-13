import re

# Fix Inbox
inbox_path = 'lib/features/connections/conversations_inbox_screen.dart'
with open(inbox_path, 'r') as f:
    inbox = f.read()

inbox_new = re.sub(
    r'return VelvetScaffold\(.*?mistIntensity: 0\.9,.*?extendBody: true,.*?body: Column\(.*?(?=crossAxisAlignment)', 
    r'''return VelvetScaffold(
      mistIntensity: 0.7,
      safeArea: true,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: VelvetPageHeader(
                title: l10n.conversationsInboxTitle,
                subtitle: l10n.conversationsInboxHint,
              ),
            ),
          ),
        ],
        body: mutual.when(
          ''', 
    inbox, 
    flags=re.DOTALL
)

# And remove the first two brackets of the old Column from the end of the Inbox builder
inbox_new = re.sub(
    r'                  \),\n                \);\n              },\n            \),\n          \),\n        \],\n      \),\n    \);',
    r'''                  ),
                );
              },
            ),
      ),
    );''',
    inbox_new
)

# Replace the Container with a GlassPanel in Inbox
inbox_new = inbox_new.replace('''                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: yourTurn
                                  ? VelvetTheme.teal.withValues(alpha: 0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: yourTurn
                                    ? VelvetTheme.teal.withValues(alpha: 0.3)
                                    : VelvetTheme.line,
                              ),
                            ),
                            child: Row(''', '''                          child: GlassPanel(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            fill: yourTurn
                                ? VelvetTheme.teal.withValues(alpha: 0.08)
                                : VelvetTheme.glassFill,
                            border: yourTurn
                                ? VelvetTheme.teal.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.25),
                            child: Row(''')

# Add cascade animation to the Material wrapper in Inbox
inbox_new = re.sub(r'(\}\n\s*\}\,\n\s*child\: Container\(\n\s*constraints\: const BoxConstraints\(\n\s*minWidth\: 20\,\n\s*\))', r'\1', inbox_new) # dummy to see if regex syntax is fine

inbox_new = re.sub(
    r'                            \],\n                          \),\n                        \),\n                      \);',
    r'''                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (40 * index).ms, duration: 250.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);''',
    inbox_new
)

with open(inbox_path, 'w') as f:
    f.write(inbox_new)


# Fix Profile
profile_path = 'lib/features/auth/profile_setup_screen.dart'
with open(profile_path, 'r') as f:
    prof = f.read()

prof_new = prof.replace('''    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: VelvetTheme.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            const VelvetWordmark(size: 30),
            const SizedBox(height: 28),
            Text(
              l10n.profileSetupTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.profileSetupBody),''', '''    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: VelvetTheme.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const VelvetAuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
                child: GlassPanel(
                  radius: VelvetTheme.radiusLg,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VelvetWordmark(size: 30),
                      const SizedBox(height: 28),
                      Text(
                        l10n.profileSetupTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: VelvetTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.profileSetupBody,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: VelvetTheme.muted,
                          height: 1.4,
                        ),
                      ),''')

prof_new = prof_new.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:google_fonts/google_fonts.dart';")

prof_new = re.sub(
    r'                  \),\n                \),\n              \),\n            const SizedBox\(height: 28\),\n            VelvetButton\(\n              label: l10n\.profileSetupFinish,\n              loading: saving,\n              onPressed: saving \? null : finish,\n            \)\.animate\(\)\.fadeIn\(delay: 200\.ms, duration: 400\.ms\),\n          \],\n        \),\n      \),\n    \);',
    r'''                  ),
                ),
              ),
            const SizedBox(height: 28),
            VelvetButton(
              label: l10n.profileSetupFinish,
              loading: saving,
              onPressed: saving ? null : finish,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    ),
            ),
          ),
        ],
      ),
    );''',
    prof_new
)

with open(profile_path, 'w') as f:
    f.write(prof_new)

