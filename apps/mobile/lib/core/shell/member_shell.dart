import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_background.dart';
import 'package:velvet_mobile/core/widgets/magnetic_container.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class MemberShell extends ConsumerWidget {
  const MemberShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isPerformer = isPerformerRole(auth.user?.role);
    final l10n = AppLocalizations.of(context);
    final labels = isPerformer
        ? [l10n.navRequests, l10n.navConversations, l10n.navListing, l10n.navProfile]
        : [l10n.navBrowse, l10n.navConversations, l10n.navSessionPayments, l10n.navProfile];

    return Scaffold(
      backgroundColor: VelvetTokens.parchment,
      extendBody: true,
      body: Stack(
        children: [
          EditorialAtmosphere(
            intensity: 0.85,
            variant: EditorialVariant.member,
            child: navigationShell,
          ),
          Positioned(
            left: VelvetTokens.pageInset,
            right: VelvetTokens.pageInset,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
            child: _EditorialPlinth(
              currentIndex: navigationShell.currentIndex,
              isPerformer: isPerformer,
              labels: labels,
              onTap: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialPlinth extends StatelessWidget {
  const _EditorialPlinth({
    required this.currentIndex,
    required this.isPerformer,
    required this.labels,
    required this.onTap,
  });

  final int currentIndex;
  final bool isPerformer;
  final List<String> labels;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PlinthItem(
        icon: isPerformer ? Icons.inbox_outlined : Icons.explore_outlined,
        activeIcon: isPerformer ? Icons.inbox : Icons.explore,
        index: 0,
      ),
      _PlinthItem(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        index: 1,
      ),
      _PlinthItem(
        icon: isPerformer ? Icons.checklist_outlined : Icons.payments_outlined,
        activeIcon: isPerformer ? Icons.checklist : Icons.payments,
        index: 2,
      ),
      _PlinthItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        index: 3,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(VelvetTokens.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: VelvetTokens.blurHeavy,
          sigmaY: VelvetTokens.blurHeavy,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: VelvetTokens.glassFill.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(VelvetTokens.radiusXl),
            border: Border.all(
              color: VelvetTokens.line.withValues(alpha: 0.55),
            ),
            boxShadow: VelvetTokens.depthLift(elevation: 0.8),
          ),
          child: Row(
            children: items.map((item) {
              final active = item.index == currentIndex;
              return Expanded(
                child: _PlinthTab(
                  item: item,
                  label: labels[item.index],
                  active: active,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(item.index);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PlinthTab extends StatelessWidget {
  const _PlinthTab({
    required this.item,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final _PlinthItem item;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: MagneticContainer(
        enabled: true,
        magneticRange: 6,
        pressScale: 0.94,
        onTap: onTap,
        borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
        child: AnimatedContainer(
          duration: VelvetTokens.motionFast,
          curve: VelvetTokens.easeEditorial,
          padding: EdgeInsets.symmetric(
            horizontal: active ? 10 : 6,
            vertical: 8,
          ),
          decoration: active
              ? BoxDecoration(
                  color: VelvetTokens.ember.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
                  border: Border.all(
                    color: VelvetTokens.ember.withValues(alpha: 0.22),
                  ),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                color: active ? VelvetTokens.ember : VelvetTokens.muted,
                size: active ? 24 : 22,
              ),
              if (active) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: VelvetTokens.emberDeep,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate(target: active ? 1 : 0).scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1, 1),
            duration: VelvetTokens.motionFast,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

class _PlinthItem {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  _PlinthItem({required this.icon, required this.activeIcon, required this.index});
}
