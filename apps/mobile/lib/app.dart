import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/core/physics/velvet_scroll_physics.dart';
import 'package:velvet_mobile/core/router/app_router.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/features/settings/locale_provider.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class VelvetApp extends ConsumerWidget {
  const VelvetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'VELVET',
      debugShowCheckedModeBanner: false,
      theme: VelvetTheme.light,
      darkTheme: VelvetTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ScrollConfiguration(
        behavior: const _VelvetScrollBehavior(),
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    );
  }
}

class _VelvetScrollBehavior extends MaterialScrollBehavior {
  const _VelvetScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const VelvetSpatialScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
