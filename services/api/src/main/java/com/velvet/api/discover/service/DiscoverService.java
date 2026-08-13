package com.velvet.api.discover.service;

import com.velvet.api.billing.service.SubscriptionQuotaService;
import com.velvet.api.chat.service.ChatService;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.discover.domain.MemberLikeEntity;
import com.velvet.api.discover.domain.MemberPreferencesEntity;
import com.velvet.api.discover.repo.MemberLikeRepository;
import com.velvet.api.discover.repo.MemberPreferencesRepository;
import com.velvet.api.discover.web.dto.DiscoverDtos;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.MemberProfileEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.notify.MemberNotifyService;
import com.velvet.api.safety.repo.MemberBlockRepository;
import com.velvet.api.safety.service.BlockService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class DiscoverService {

    private static final List<MatchStatus> OPEN_OR_MUTUAL = List.of(
            MatchStatus.PROPOSED,
            MatchStatus.ACCEPTED_A,
            MatchStatus.ACCEPTED_B,
            MatchStatus.MUTUAL
    );

    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;
    private final MemberPreferencesRepository preferencesRepository;
    private final MemberLikeRepository likeRepository;
    private final ConnectionRepository connectionRepository;
    private final MemberBlockRepository blockRepository;
    private final BlockService blockService;
    private final SubscriptionQuotaService quotaService;
    private final ChatService chatService;
    private final MemberNotifyService memberNotifyService;
    private final SwipeUndoService swipeUndoService;
    private final com.velvet.api.booking.service.TrustService trustService;

    public DiscoverService(
            UserRepository userRepository,
            MemberProfileRepository profileRepository,
            MemberPreferencesRepository preferencesRepository,
            MemberLikeRepository likeRepository,
            ConnectionRepository connectionRepository,
            MemberBlockRepository blockRepository,
            BlockService blockService,
            SubscriptionQuotaService quotaService,
            ChatService chatService,
            MemberNotifyService memberNotifyService,
            SwipeUndoService swipeUndoService,
            com.velvet.api.booking.service.TrustService trustService
    ) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.preferencesRepository = preferencesRepository;
        this.likeRepository = likeRepository;
        this.connectionRepository = connectionRepository;
        this.blockRepository = blockRepository;
        this.blockService = blockService;
        this.quotaService = quotaService;
        this.chatService = chatService;
        this.memberNotifyService = memberNotifyService;
        this.swipeUndoService = swipeUndoService;
        this.trustService = trustService;
    }

    @Transactional(readOnly = true)
    public DiscoverDtos.DiscoverFeedResponse feed(UUID viewerId, int limit) {
        requireActiveSubscription(viewerId);
        requireCompleteProfile(viewerId);
        UserEntity viewer = userRepository.findById(viewerId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));

        // Asymmetric: only clients browse performers. Performers use received-likes instead.
        if (viewer.getRole() == UserRole.PERFORMER) {
            return new DiscoverDtos.DiscoverFeedResponse(List.of(), "RECEIVE_ONLY");
        }

        MemberPreferencesEntity prefs = getOrDefaultPrefs(viewerId);
        MemberProfileEntity viewerProfile = profileRepository.findById(viewerId).orElse(null);

        Set<UUID> exclude = new HashSet<>();
        exclude.add(viewerId);
        exclude.addAll(likeRepository.findTargetIdsByFromUserId(viewerId));
        exclude.addAll(blockedPartnerIds(viewerId));
        connectionRepository.findForUserWithStatuses(viewerId, OPEN_OR_MUTUAL).forEach(m -> {
            exclude.add(m.getMemberAId());
            exclude.add(m.getMemberBId());
        });

        List<UserEntity> candidates = userRepository.findByStatusIn(
                List.of(UserStatus.ACTIVE, UserStatus.VERIFIED)
        );

        List<Scored> scored = new ArrayList<>();
        for (UserEntity u : candidates) {
            if (exclude.contains(u.getId())) {
                continue;
            }
            if (u.getRole() != UserRole.PERFORMER) {
                continue;
            }
            if (prefs.isVerifiedOnly() && u.getStatus() != UserStatus.VERIFIED) {
                continue;
            }
            // Platform rule: only ID-verified performers appear in client browse.
            if (u.getStatus() != UserStatus.VERIFIED) {
                continue;
            }
            Integer age = ageOf(u);
            if (age == null || age < prefs.getMinAge() || age > prefs.getMaxAge()) {
                continue;
            }
            MemberProfileEntity profile = profileRepository.findById(u.getId()).orElse(null);
            if (profile == null || !profile.isListingActive() || !"APPROVED".equals(profile.getPhotoQualityStatus())) {
                continue;
            }
            if (isPhotoQualityBlocked(profile)) {
                continue;
            }
            if (prefs.getCities() != null && !prefs.getCities().isEmpty()) {
                String city = profile.getCity() == null ? "" : profile.getCity().trim().toLowerCase(Locale.ROOT);
                boolean cityOk = prefs.getCities().stream()
                        .filter(c -> c != null && !c.isBlank())
                        .anyMatch(c -> c.trim().toLowerCase(Locale.ROOT).equals(city));
                if (!cityOk) {
                    continue;
                }
            }
            if (!matchesLanguages(prefs.getPreferredLanguages(), profile.getLanguages())) {
                continue;
            }
            if (!matchesIntents(prefs.getIntents(), profile.getLookingFor())) {
                continue;
            }
            Double distance = null;
            if (viewerProfile != null
                    && viewerProfile.getLastLat() != null
                    && viewerProfile.getLastLng() != null
                    && profile.getLastLat() != null
                    && profile.getLastLng() != null) {
                distance = haversineKm(
                        viewerProfile.getLastLat(), viewerProfile.getLastLng(),
                        profile.getLastLat(), profile.getLastLng()
                );
                if (distance > prefs.getMaxDistanceKm()) {
                    continue;
                }
            }
            scored.add(new Scored(u, profile, age, distance));
        }

        scored.sort(Comparator
                .comparing((Scored s) -> s.distanceKm() == null)
                .thenComparing(s -> s.distanceKm() == null ? Double.MAX_VALUE : s.distanceKm())
                .thenComparing(s -> s.user().getCreatedAt(), Comparator.reverseOrder()));

        int cap = Math.min(Math.max(limit, 1), 50);
        List<DiscoverDtos.DiscoverCard> items = scored.stream()
                .limit(cap)
                .map(s -> toCard(s.user(), s.profile(), s.age(), s.distanceKm(), null))
                .toList();
        return new DiscoverDtos.DiscoverFeedResponse(items, "BROWSE_WOMEN");
    }

    @Transactional(readOnly = true)
    public DiscoverDtos.DiscoverFeedResponse receivedLikes(UUID viewerId, int limit) {
        requireCompleteProfile(viewerId);
        // Performers list free — membership is for clients who browse/book.
        UserEntity viewer = userRepository.findById(viewerId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (viewer.getRole() != UserRole.PERFORMER) {
            return new DiscoverDtos.DiscoverFeedResponse(List.of(), "CLIENTS_BROWSE");
        }

        Set<UUID> exclude = blockedPartnerIds(viewerId);
        connectionRepository.findForUserWithStatuses(viewerId, OPEN_OR_MUTUAL).forEach(m -> {
            exclude.add(m.getMemberAId());
            exclude.add(m.getMemberBId());
        });

        MemberProfileEntity viewerProfile = profileRepository.findById(viewerId).orElse(null);

        List<DiscoverDtos.DiscoverCard> items = new ArrayList<>();
        for (MemberLikeEntity like : likeRepository.findReceivedLikes(viewerId)) {
            if (exclude.contains(like.getFromUserId())) {
                continue;
            }
            // Skip if she already responded to him
            if (likeRepository.findByFromUserIdAndToUserId(viewerId, like.getFromUserId()).isPresent()) {
                continue;
            }
            UserEntity from = userRepository.findById(like.getFromUserId()).orElse(null);
            if (from == null || from.getRole() != UserRole.CLIENT) {
                continue;
            }
            if (from.getStatus() != UserStatus.ACTIVE && from.getStatus() != UserStatus.VERIFIED) {
                continue;
            }
            MemberProfileEntity profile = profileRepository.findById(from.getId()).orElse(null);
            if (profile == null) {
                continue;
            }
            items.add(toCard(from, profile, ageOf(from), null, likeContext(like, viewerProfile)));
            if (items.size() >= Math.min(Math.max(limit, 1), 50)) {
                break;
            }
        }
        return new DiscoverDtos.DiscoverFeedResponse(items, "LIKES_YOU");
    }

    @Transactional(readOnly = true)
    public DiscoverDtos.DiscoverFeedResponse recentPasses(UUID viewerId, int limit) {
        requireActiveSubscription(viewerId);
        requireCompleteProfile(viewerId);
        int cap = Math.min(Math.max(limit, 1), 5);
        List<DiscoverDtos.DiscoverCard> items = new ArrayList<>();
        for (MemberLikeEntity like : likeRepository.findRecentPasses(viewerId)) {
            UserEntity target = userRepository.findById(like.getToUserId()).orElse(null);
            if (target == null) {
                continue;
            }
            if (target.getStatus() != UserStatus.ACTIVE && target.getStatus() != UserStatus.VERIFIED) {
                continue;
            }
            MemberProfileEntity profile = profileRepository.findById(target.getId()).orElse(null);
            if (profile == null) {
                continue;
            }
            items.add(toCard(target, profile, ageOf(target), null, null));
            if (items.size() >= cap) {
                break;
            }
        }
        return new DiscoverDtos.DiscoverFeedResponse(items, "RECENT_PASSES");
    }

    @Transactional
    public DiscoverDtos.UndoResponse rewindPass(UUID userId, UUID targetUserId) {
        requireActiveSubscription(userId);
        List<MemberLikeEntity> recent = likeRepository.findRecentPasses(userId);
        MemberLikeEntity pass = recent.stream()
                .limit(5)
                .filter(l -> l.getToUserId().equals(targetUserId))
                .findFirst()
                .orElseThrow(() -> new BusinessException(
                        "PASS_NOT_FOUND",
                        "That pass is not in your last 5. Only recent passes can be rewound."
                ));
        likeRepository.delete(pass);
        swipeUndoService.remember(userId, targetUserId, "PASS");
        return new DiscoverDtos.UndoResponse(targetUserId.toString(), "PASS", swipeUndoService.remainingUndos(userId));
    }

    @Transactional
    public DiscoverDtos.DiscoverActionResponse action(
            UUID fromUserId,
            UUID toUserId,
            DiscoverDtos.DiscoverActionRequest request
    ) {
        String rawAction = request.action();
        if (fromUserId.equals(toUserId)) {
            throw new BusinessException("INVALID_TARGET", "Cannot act on yourself.");
        }
        requireClientSubscription(fromUserId);
        UserEntity from = userRepository.findById(fromUserId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        UserEntity target = userRepository.findById(toUserId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));

        String action = rawAction.trim().toUpperCase(Locale.ROOT);
        if (!"LIKE".equals(action) && !"PASS".equals(action)) {
            throw new BusinessException("INVALID_ACTION", "Action must be LIKE or PASS.");
        }

        // Clients browse Performers only
        if (from.getRole() == UserRole.CLIENT) {
            if (target.getRole() != UserRole.PERFORMER) {
                throw new BusinessException("ROLE_RULE", "Clients can only choose performers.");
            }
            return recordLikeAndMaybeMatch(from, target, action, false, request.likedPhotoIndex(), request.likedPromptKey());
        }

        // Performers only respond to clients who already liked them (not browse)
        if (from.getRole() == UserRole.PERFORMER) {
            if (target.getRole() != UserRole.CLIENT) {
                throw new BusinessException("ROLE_RULE", "Performers only respond to clients who liked them.");
            }
            boolean heLiked = likeRepository.findByFromUserIdAndToUserId(toUserId, fromUserId)
                    .filter(l -> "LIKE".equalsIgnoreCase(l.getAction()))
                    .isPresent();
            if (!heLiked) {
                throw new BusinessException(
                        "DISCOVER_RECEIVE_ONLY",
                        "Performers do not browse. Respond to likes you received."
                );
            }
            return recordLikeAndMaybeMatch(from, target, action, true, request.likedPhotoIndex(), request.likedPromptKey());
        }

        throw new BusinessException("ROLE_REQUIRED", "Your current role lacks discovery permissions.");
    }

    private DiscoverDtos.DiscoverActionResponse recordLikeAndMaybeMatch(
            UserEntity from,
            UserEntity target,
            String action,
            boolean womanResponding,
            Integer likedPhotoIndex,
            String likedPromptKey
    ) {
        UUID fromUserId = from.getId();
        UUID toUserId = target.getId();

        if (target.getStatus() != UserStatus.ACTIVE && target.getStatus() != UserStatus.VERIFIED) {
            throw new BusinessException("MEMBER_UNAVAILABLE", "This member is not available.");
        }
        if (blockService.isBlockedEitherWay(fromUserId, toUserId)) {
            throw new BusinessException("MEMBERS_BLOCKED", "Cannot interact with this member.");
        }

        MemberLikeEntity existing = likeRepository.findByFromUserIdAndToUserId(fromUserId, toUserId).orElse(null);
        if (existing != null) {
            throw new BusinessException("ALREADY_ACTED", "You already responded to this member.");
        }

        Integer photoIdx = null;
        String promptKey = null;
        if ("LIKE".equals(action) && !womanResponding) {
            MemberProfileEntity targetProfile = profileRepository.findById(toUserId).orElse(null);
            int photoCount = targetProfile == null || targetProfile.getPhotoUrls() == null
                    ? 0
                    : targetProfile.getPhotoUrls().size();
            if (likedPhotoIndex != null && likedPhotoIndex >= 0 && likedPhotoIndex < Math.max(photoCount, 1)) {
                photoIdx = likedPhotoIndex;
            } else if (photoCount > 0) {
                photoIdx = 0;
            }
            if (likedPromptKey != null && !likedPromptKey.isBlank()) {
                String key = likedPromptKey.trim().toLowerCase(Locale.ROOT);
                if (key.equals("bio_en") || key.equals("bio_am")) {
                    promptKey = key;
                }
            }
        }

        likeRepository.save(MemberLikeEntity.builder()
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .action(action)
                .likedPhotoIndex(photoIdx)
                .likedPromptKey(promptKey)
                .build());
        swipeUndoService.remember(fromUserId, toUserId, action);

        if ("PASS".equals(action)) {
            return new DiscoverDtos.DiscoverActionResponse(false, null, null, null);
        }

        // Man likes woman: notify her; no mutual until she accepts
        if (!womanResponding) {
            try {
                String name = from.getDisplayName() == null || from.getDisplayName().isBlank()
                        ? "Someone"
                        : from.getDisplayName();
                String why = promptKey != null
                        ? name + " noted your listing prompt"
                        : (photoIdx != null ? name + " noted your listing photo" : name + " requested a booking");
                memberNotifyService.notifyUser(
                        toUserId,
                        why,
                        "Open Requests to accept or decline — " + name + " is waiting.",
                        "DISCOVER_LIKE",
                        fromUserId.toString()
                );
            } catch (Exception e) {
                // Never roll back the like because push/outbox failed.
            }
            return new DiscoverDtos.DiscoverActionResponse(false, null, null, null);
        }

        // Woman accepted a man's like → mutual
        for (ConnectionEntity m : connectionRepository.findForUserWithStatuses(fromUserId, OPEN_OR_MUTUAL)) {
            if (m.getMemberAId().equals(toUserId) || m.getMemberBId().equals(toUserId)) {
                MemberProfileEntity tp = profileRepository.findById(toUserId).orElse(null);
                return new DiscoverDtos.DiscoverActionResponse(
                        m.getStatus() == MatchStatus.MUTUAL,
                        m.getId().toString(),
                        target.getDisplayName(),
                        tp == null || tp.getPhotoUrls() == null ? List.of() : List.copyOf(tp.getPhotoUrls())
                );
            }
        }

        // Quota on the man (member A = man who initiated)
        quotaService.assertAndConsumeMatch(toUserId);
        Instant now = Instant.now();
        ConnectionEntity match = ConnectionEntity.builder()
                .memberAId(toUserId) // man
                .memberBId(fromUserId) // woman
                .status(MatchStatus.MUTUAL)
                .source("DISCOVERY")
                .expiresAt(now.plus(72, ChronoUnit.HOURS))
                .aRespondedAt(now)
                .bRespondedAt(now)
                .introNoteEn("You connected through browse.")
                .introNoteAm("በዝርዝር ተገናኝተዋል።")
                .build();
        match = connectionRepository.save(match);
        chatService.openForMatch(match);
        String womanName = from.getDisplayName() == null || from.getDisplayName().isBlank() ? "Member" : from.getDisplayName();
        String manName = target.getDisplayName() == null || target.getDisplayName().isBlank() ? "Member" : target.getDisplayName();
        memberNotifyService.notifyUser(
                toUserId,
                "Connected with " + womanName,
                "You and " + womanName + " are connected — chat and propose a booking.",
                "MATCH",
                match.getId().toString()
        );
        memberNotifyService.notifyUser(
                fromUserId,
                "Connected with " + manName,
                "You and " + manName + " are connected — chat and propose a booking.",
                "MATCH",
                match.getId().toString()
        );

        MemberProfileEntity tp = profileRepository.findById(toUserId).orElse(null);
        return new DiscoverDtos.DiscoverActionResponse(
                true,
                match.getId().toString(),
                target.getDisplayName(),
                tp == null || tp.getPhotoUrls() == null ? List.of() : List.copyOf(tp.getPhotoUrls())
        );
    }

    @Transactional
    public DiscoverDtos.UndoResponse undo(UUID userId) {
        return swipeUndoService.undo(userId);
    }

    @Transactional(readOnly = true)
    public DiscoverDtos.PreferencesResponse getPreferences(UUID userId) {
        MemberPreferencesEntity p = getOrDefaultPrefs(userId);
        return new DiscoverDtos.PreferencesResponse(
                p.getMinAge(),
                p.getMaxAge(),
                p.getMaxDistanceKm(),
                p.getCities() == null ? List.of() : List.copyOf(p.getCities()),
                p.getPreferredLanguages() == null ? List.of() : List.copyOf(p.getPreferredLanguages()),
                p.getIntents() == null ? List.of() : List.copyOf(p.getIntents()),
                p.isVerifiedOnly()
        );
    }

    @Transactional
    public DiscoverDtos.PreferencesResponse updatePreferences(UUID userId, DiscoverDtos.PreferencesRequest request) {
        userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        MemberPreferencesEntity p = preferencesRepository.findById(userId)
                .orElseGet(() -> MemberPreferencesEntity.builder().userId(userId).build());
        if (request.minAge() != null) {
            p.setMinAge(request.minAge());
        }
        if (request.maxAge() != null) {
            p.setMaxAge(request.maxAge());
        }
        if (request.maxDistanceKm() != null) {
            p.setMaxDistanceKm(request.maxDistanceKm());
        }
        if (request.cities() != null) {
            p.setCities(request.cities().stream()
                    .filter(c -> c != null && !c.isBlank())
                    .map(String::trim)
                    .collect(Collectors.toCollection(ArrayList::new)));
        }
        if (request.preferredLanguages() != null) {
            p.setPreferredLanguages(normalizeList(request.preferredLanguages(), List.of("am", "en")));
        }
        if (request.intents() != null) {
            p.setIntents(normalizeList(request.intents(), List.of("serious", "social")));
        }
        if (request.verifiedOnly() != null) {
            p.setVerifiedOnly(request.verifiedOnly());
        }
        if (p.getMaxAge() < p.getMinAge()) {
            throw new BusinessException("INVALID_PREFS", "maxAge must be >= minAge.");
        }
        preferencesRepository.save(p);
        return getPreferences(userId);
    }

    @Transactional
    public void updateLocation(UUID userId, DiscoverDtos.LocationRequest request) {
        if (request.latitude() < -90 || request.latitude() > 90
                || request.longitude() < -180 || request.longitude() > 180) {
            throw new BusinessException("INVALID_LOCATION", "Invalid coordinates.");
        }
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());
        profile.setLastLat(request.latitude());
        profile.setLastLng(request.longitude());
        profile.setLocationUpdatedAt(Instant.now());
        profileRepository.save(profile);
    }

    private void requireActiveSubscription(UUID userId) {
        quotaService.assertHasActiveSubscription(userId);
    }

    /** Clients must subscribe to browse/book; performers may list and respond free. */
    private void requireClientSubscription(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getRole() == UserRole.PERFORMER) {
            return;
        }
        quotaService.assertHasActiveSubscription(userId);
    }

    private MemberPreferencesEntity getOrDefaultPrefs(UUID userId) {
        return preferencesRepository.findById(userId)
                .orElseGet(() -> MemberPreferencesEntity.builder().userId(userId).build());
    }

    private Set<UUID> blockedPartnerIds(UUID userId) {
        Set<UUID> ids = new HashSet<>();
        ids.addAll(blockRepository.findBlockedIds(userId));
        ids.addAll(blockRepository.findBlockerIds(userId));
        return ids;
    }

    private static Integer ageOf(UserEntity u) {
        if (u.getDateOfBirth() == null) {
            return null;
        }
        return Period.between(u.getDateOfBirth(), LocalDate.now()).getYears();
    }

    private static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double r = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * r * Math.asin(Math.sqrt(a));
    }

    private record Scored(UserEntity user, MemberProfileEntity profile, Integer age, Double distanceKm) {}

    private record LikeContext(Integer likedPhotoIndex, String likedPromptKey, String likedPhotoUrl, String likeReason) {}

    private DiscoverDtos.DiscoverCard toCard(
            UserEntity user,
            MemberProfileEntity profile,
            Integer age,
            Double distanceKm,
            LikeContext like
    ) {
        return new DiscoverDtos.DiscoverCard(
                user.getId().toString(),
                user.getDisplayName(),
                age,
                profile.getCity(),
                profile.getBioEn(),
                profile.getBioAm(),
                profile.getHeightCm(),
                profile.getJobTitle(),
                profile.getEducation(),
                profile.getLanguages(),
                profile.getReligion(),
                profile.getLookingFor(),
                profile.getSessionRateEtb(),
                profile.getOvernightRateEtb(),
                profile.getAvailabilityNote(),
                profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls()),
                distanceKm,
                profile.getInterests() == null ? List.of() : List.copyOf(profile.getInterests()),
                user.getStatus() == UserStatus.VERIFIED,
                like == null ? null : like.likedPhotoIndex(),
                like == null ? null : like.likedPromptKey(),
                like == null ? null : like.likedPhotoUrl(),
                like == null ? null : like.likeReason(),
                trustService.getTrustScore(user.getId())
        );
    }

    private static LikeContext likeContext(MemberLikeEntity like, MemberProfileEntity viewerProfile) {
        Integer idx = like.getLikedPhotoIndex();
        String prompt = like.getLikedPromptKey();
        String likedPhotoUrl = null;
        if (idx != null && viewerProfile != null && viewerProfile.getPhotoUrls() != null
                && idx >= 0 && idx < viewerProfile.getPhotoUrls().size()) {
            likedPhotoUrl = viewerProfile.getPhotoUrls().get(idx);
        }
        String reason;
        if (prompt != null && !prompt.isBlank()) {
            reason = "PROMPT";
        } else if (idx != null) {
            reason = "PHOTO";
        } else {
            reason = "PROFILE";
        }
        return new LikeContext(idx, prompt, likedPhotoUrl, reason);
    }

    private static boolean isPhotoQualityBlocked(MemberProfileEntity profile) {
        String status = profile.getPhotoQualityStatus();
        return status != null && "REJECTED".equalsIgnoreCase(status.trim());
    }

    private static boolean matchesLanguages(List<String> preferred, String profileLanguages) {
        if (preferred == null || preferred.isEmpty()) {
            return true;
        }
        String hay = profileLanguages == null ? "" : profileLanguages.toLowerCase(Locale.ROOT);
        if (hay.isBlank()) {
            return false;
        }
        for (String code : preferred) {
            if (code == null || code.isBlank()) {
                continue;
            }
            String c = code.trim().toLowerCase(Locale.ROOT);
            if (c.equals("am") && (hay.contains("am") || hay.contains("amharic") || hay.contains("አማርኛ"))) {
                return true;
            }
            if (c.equals("en") && (hay.contains("en") || hay.contains("english"))) {
                return true;
            }
        }
        return false;
    }

    private static boolean matchesIntents(List<String> intents, String lookingFor) {
        if (intents == null || intents.isEmpty()) {
            return true;
        }
        String hay = lookingFor == null ? "" : lookingFor.toLowerCase(Locale.ROOT);
        if (hay.isBlank()) {
            return false;
        }
        for (String intent : intents) {
            if (intent == null || intent.isBlank()) {
                continue;
            }
            String i = intent.trim().toLowerCase(Locale.ROOT);
            if (i.equals("serious") && (hay.contains("serious") || hay.contains("relationship") || hay.contains("long"))) {
                return true;
            }
            if (i.equals("social") && (hay.contains("social") || hay.contains("friend") || hay.contains("fun") || hay.contains("casual"))) {
                return true;
            }
            if (hay.contains(i)) {
                return true;
            }
        }
        return false;
    }

    private static List<String> normalizeList(List<String> raw, List<String> allowed) {
        Set<String> allow = allowed.stream().map(s -> s.toLowerCase(Locale.ROOT)).collect(Collectors.toSet());
        return raw.stream()
                .filter(s -> s != null && !s.isBlank())
                .map(s -> s.trim().toLowerCase(Locale.ROOT))
                .filter(allow::contains)
                .distinct()
                .collect(Collectors.toCollection(ArrayList::new));
    }

    private void requireCompleteProfile(UUID userId) {
        MemberProfileEntity profile = profileRepository.findById(userId).orElse(null);
        boolean complete = profile != null
                && profile.getPhotoUrls() != null && profile.getPhotoUrls().size() >= 3
                && profile.getCity() != null && !profile.getCity().isBlank()
                && profile.getBioEn() != null && !profile.getBioEn().isBlank()
                && profile.getBioAm() != null && !profile.getBioAm().isBlank();
        if (!complete) {
            throw new BusinessException("PROFILE_INCOMPLETE", "Complete your profile with 3 photos, city, and prompts before discovery.");
        }
    }
}
