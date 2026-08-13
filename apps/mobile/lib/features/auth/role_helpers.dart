import 'package:velvet_mobile/features/auth/auth_models.dart';

bool isStaffRole(String? role) =>
    role == 'ADMIN' || role == 'CONCIERGE' || role == 'VENUE_PARTNER';

bool isMemberRole(String? role) =>
    role == null ||
    role == 'MEMBER' ||
    role == 'SUBSCRIBER' ||
    role == 'CLIENT' ||
    role == 'PERFORMER';

bool isClientRole(String? role) =>
    role == 'CLIENT' || role == 'SUBSCRIBER' || role == 'MEMBER';

bool isPerformerRole(String? role) => role == 'PERFORMER';

bool isWomanGender(String? gender) => gender == 'FEMALE';

bool isManGender(String? gender) => gender == 'MALE';

String? effectiveGender(UserSummary? user, String? profileGender) {
  final fromProfile = profileGender?.trim();
  if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile.toUpperCase();
  final fromUser = user?.gender?.trim();
  if (fromUser != null && fromUser.isNotEmpty) return fromUser.toUpperCase();
  return null;
}
