import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velvet_mobile/core/network/session_bridge.dart';
import 'package:velvet_mobile/core/shell/member_shell.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/gender_setup_screen.dart';
import 'package:velvet_mobile/features/auth/profile_setup_screen.dart';
import 'package:velvet_mobile/features/auth/invite_phone_screen.dart';
import 'package:velvet_mobile/features/auth/legal_accept_screen.dart';
import 'package:velvet_mobile/features/auth/otp_screen.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/auth/waitlist_screen.dart';
import 'package:velvet_mobile/features/billing/earnings_screen.dart';
import 'package:velvet_mobile/features/billing/membership_screen.dart';
import 'package:velvet_mobile/features/billing/session_payments_screen.dart';
import 'package:velvet_mobile/features/discover/discover_screen.dart';
import 'package:velvet_mobile/features/connections/connection_confirmed_screen.dart';
import 'package:velvet_mobile/features/profile/availability_screen.dart';
import 'package:velvet_mobile/features/connections/connection_history_screen.dart';
import 'package:velvet_mobile/features/connections/conversations_inbox_screen.dart';
import 'package:velvet_mobile/features/onboarding/marketplace_welcome_screen.dart';
import 'package:velvet_mobile/features/onboarding/onboarding_prefs.dart';
import 'package:velvet_mobile/features/notifications/notifications_screen.dart';
import 'package:velvet_mobile/features/profile/profile_screen.dart';
import 'package:velvet_mobile/features/safety/blocked_members_screen.dart';
import 'package:velvet_mobile/features/safety/safety_center_screen.dart';
import 'package:velvet_mobile/features/social/booking_screen.dart';
import 'package:velvet_mobile/features/social/chat_screen.dart';
import 'package:velvet_mobile/features/staff/staff_portal_screen.dart';
import 'package:velvet_mobile/features/verification/verification_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Stable listenable — do NOT capture AuthController here (it can be recreated).
  final refresh = ref.read(routerRefreshProvider);

  final router = GoRouter(
    initialLocation: '/auth',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      if (loc.startsWith('/match/') && loc.contains('/celebrate')) {
        final uri = state.uri;
        final segments = uri.pathSegments;
        if (segments.length >= 2 && segments[0] == 'match') {
          final id = segments[1];
          final q = uri.query.isEmpty ? '' : '?${uri.query}';
          return '/connection/$id/confirmed$q';
        }
      }
      if (loc == '/matches') return '/conversations';
      if (loc == '/history') return '/connections/history';
      final onAuth = loc == '/auth' || loc.startsWith('/auth/');
      final onWaitlist = loc == '/waitlist';
      final onLegal = loc == '/legal/accept';
      final onGender = loc == '/onboarding/gender';
      final onProfileSetup = loc == '/onboarding/profile';
      final onWelcome = loc == '/onboarding/welcome';
      final onStaff = loc == '/staff' || loc.startsWith('/staff/');
      final staff = isStaffRole(auth.user?.role);

      if (!auth.bootstrapped) return null;

      if (!loggedIn && !onAuth && !onWaitlist) return '/auth';

      if (loggedIn && auth.needsLegalAccept && !onLegal) return '/legal/accept';

      // Staff skip gender onboarding and never enter the member shell.
      if (loggedIn && staff) {
        if (onAuth || onWaitlist || onLegal || onGender || loc == '/home') {
          return '/staff';
        }
        if (!onStaff &&
            (loc == '/discover' ||
                loc == '/conversations' ||
                loc == '/payments' ||
                loc == '/profile')) {
          return '/staff';
        }
        return null;
      }

      if (loggedIn &&
          !auth.needsLegalAccept &&
          auth.needsGenderSetup &&
          !onGender) {
        return '/onboarding/gender';
      }
      if (loggedIn &&
          !auth.needsLegalAccept &&
          !auth.needsGenderSetup &&
          auth.needsProfileSetup &&
          !onProfileSetup) {
        return '/onboarding/profile';
      }
      if (loggedIn && onStaff) return '/discover';
      if (loggedIn &&
          !auth.needsLegalAccept &&
          !auth.needsGenderSetup &&
          !auth.needsProfileSetup &&
          (onAuth || onWaitlist || onLegal || onGender || onProfileSetup)) {
        final onboarding = ref.read(onboardingPrefsProvider);
        if (onboarding.loaded && !onboarding.welcomeSeen) {
          return '/onboarding/welcome';
        }
        final role = auth.user?.role;
        if (isPerformerRole(role)) {
          return '/payments';
        }
        return '/discover';
      }
      if (loggedIn && onWelcome) {
        final onboarding = ref.read(onboardingPrefsProvider);
        if (onboarding.loaded && onboarding.welcomeSeen) {
          final role = auth.user?.role;
          if (isPerformerRole(role)) {
            return '/payments';
          }
          return '/discover';
        }
      }
      if (loggedIn && loc == '/home') return '/discover';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const InvitePhoneScreen(),
      ),
      GoRoute(
        path: '/waitlist',
        builder: (context, state) => const WaitlistScreen(),
      ),
      GoRoute(
        path: '/legal/accept',
        builder: (context, state) => const LegalAcceptScreen(),
      ),
      GoRoute(
        path: '/onboarding/gender',
        builder: (context, state) => const GenderSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const MarketplaceWelcomeScreen(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) {
          final role = ref.read(authControllerProvider).user?.role ?? 'ADMIN';
          return StaffPortalScreen(role: role);
        },
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final invite = state.uri.queryParameters['invite'] ?? '';
          final devOtp = state.uri.queryParameters['devOtp'];
          final legal = state.uri.queryParameters['legal'];
          return OtpScreen(
            phone: phone,
            inviteCode: invite,
            devOtp: devOtp,
            acceptedLegalVersion: legal,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MemberShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/conversations',
                builder: (context, state) => const ConversationsInboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payments',
                builder: (context, state) => const SessionPaymentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/membership',
        builder: (context, state) => const MembershipScreen(),
      ),
      GoRoute(
        path: '/connections/history',
        builder: (context, state) => const ConnectionHistoryScreen(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: '/blocked',
        builder: (context, state) => const BlockedMembersScreen(),
      ),
      GoRoute(
        path: '/safety',
        builder: (context, state) => const SafetyCenterScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/connection/:connectionId/confirmed',
        builder: (context, state) => ConnectionConfirmedScreen(
          connectionId: state.pathParameters['connectionId']!,
          counterpartName: state.uri.queryParameters['name'],
          counterpartPhoto: state.uri.queryParameters['photo'],
          counterpartUserId: state.uri.queryParameters['other'],
        ),
      ),
      GoRoute(
        path: '/chat/:connectionId',
        builder: (context, state) => ChatScreen(
          connectionId: state.pathParameters['connectionId']!,
          counterpartUserId: state.uri.queryParameters['other'],
          counterpartName: state.uri.queryParameters['name'],
          counterpartVerified: state.uri.queryParameters['verified'] == 'true',
          counterpartTrustScore: int.tryParse(
            state.uri.queryParameters['trustScore'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/booking/:connectionId',
        builder: (context, state) =>
            BookingScreen(connectionId: state.pathParameters['connectionId']!),
      ),
    ],
  );

  refresh.attach(router);
  return router;
});
