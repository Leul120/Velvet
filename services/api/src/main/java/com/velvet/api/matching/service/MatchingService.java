package com.velvet.api.matching.service;

import com.velvet.api.billing.service.SubscriptionQuotaService;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.chat.service.ChatService;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.audit.AuditService;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.MemberProfileEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.matching.web.dto.MatchDtos;
import com.velvet.api.notify.MemberNotifyService;
import com.velvet.api.safety.service.BlockService;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class MatchingService {

    private static final List<MatchStatus> OPEN_FOR_MEMBER = List.of(
            MatchStatus.PROPOSED,
            MatchStatus.ACCEPTED_A,
            MatchStatus.ACCEPTED_B,
            MatchStatus.MUTUAL
    );

    private static final List<MatchStatus> HISTORY_STATUSES = List.of(
            MatchStatus.DECLINED,
            MatchStatus.EXPIRED,
            MatchStatus.CANCELLED
    );

    private final ConnectionRepository connectionRepository;
    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;
    private final VenueRepository venueRepository;
    private final BookingRepository bookingRepository;
    private final ChatService chatService;
    private final SubscriptionQuotaService quotaService;
    private final MemberNotifyService memberNotifyService;
    private final BlockService blockService;
    private final AuditService auditService;
    private final com.velvet.api.booking.service.TrustService trustService;

    public MatchingService(
            ConnectionRepository connectionRepository,
            UserRepository userRepository,
            MemberProfileRepository profileRepository,
            VenueRepository venueRepository,
            BookingRepository bookingRepository,
            ChatService chatService,
            SubscriptionQuotaService quotaService,
            MemberNotifyService memberNotifyService,
            BlockService blockService,
            AuditService auditService,
            com.velvet.api.booking.service.TrustService trustService
    ) {
        this.connectionRepository = connectionRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.venueRepository = venueRepository;
        this.bookingRepository = bookingRepository;
        this.chatService = chatService;
        this.quotaService = quotaService;
        this.memberNotifyService = memberNotifyService;
        this.blockService = blockService;
        this.auditService = auditService;
        this.trustService = trustService;
    }

    @Transactional
    public MatchDtos.MatchResponse create(UUID curatorId, MatchDtos.CreateMatchRequest request) {
        if (request.memberAId().equals(request.memberBId())) {
            throw new BusinessException("MATCH_INVALID", "Members must be distinct.");
        }
        UserEntity a = requireMatchable(request.memberAId());
        UserEntity b = requireMatchable(request.memberBId());
        boolean roleValid = (a.getRole() == UserRole.CLIENT && b.getRole() == UserRole.PERFORMER)
                || (a.getRole() == UserRole.PERFORMER && b.getRole() == UserRole.CLIENT);
        if (!roleValid) {
            throw new BusinessException("ROLE_RULE", "Introductions are between clients and performers.");
        }
        if (blockService.isBlockedEitherWay(a.getId(), b.getId())) {
            throw new BusinessException("MEMBERS_BLOCKED", "These members have a block between them.");
        }
        // Client is member A for quota (subscriber who "picks")
        UserEntity quotaMember = a.getRole() == UserRole.CLIENT ? a : b;
        UserEntity other = a.getRole() == UserRole.CLIENT ? b : a;
        quotaService.assertAndConsumeMatch(quotaMember.getId());

        if (request.suggestedVenueId() != null) {
            venueRepository.findById(request.suggestedVenueId())
                    .filter(VenueEntity::isActive)
                    .orElseThrow(() -> new BusinessException("VENUE_NOT_FOUND", "Venue not found or inactive."));
        }

        int hours = request.expiresInHours() == null ? 72 : request.expiresInHours();
        ConnectionEntity match = ConnectionEntity.builder()
                .memberAId(quotaMember.getId())
                .memberBId(other.getId())
                .curatorId(curatorId)
                .introNoteEn(request.introNoteEn())
                .introNoteAm(request.introNoteAm())
                .suggestedVenueId(request.suggestedVenueId())
                .expiresAt(Instant.now().plus(hours, ChronoUnit.HOURS))
                .status(MatchStatus.PROPOSED)
                .source("CONCIERGE")
                .build();
        match = connectionRepository.save(match);
        auditService.log(curatorId, "MATCH_CREATE", "MATCH", match.getId().toString(), Map.of(
                "memberA", quotaMember.getId().toString(),
                "memberB", other.getId().toString()
        ));
        memberNotifyService.notifyUsers(
                List.of(quotaMember.getId(), other.getId()),
                "New introduction waiting",
                "Open Intros to review your curated match — respond before it expires.",
                "MATCH",
                match.getId().toString()
        );
        return toResponse(match, curatorId, true, false);
    }

    @Transactional(readOnly = true)
    public List<MatchDtos.MatchResponse> myMatches(UUID userId) {
        return connectionRepository.findForUserWithStatuses(userId, OPEN_FOR_MEMBER).stream()
                .filter(m -> {
                    UUID other = m.getMemberAId().equals(userId) ? m.getMemberBId() : m.getMemberAId();
                    return !blockService.isBlockedEitherWay(userId, other);
                })
                .map(m -> toResponse(m, userId, false, false))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<MatchDtos.MatchResponse> mutualInbox(UUID userId) {
        return connectionRepository.findForUserWithStatuses(userId, List.of(MatchStatus.MUTUAL)).stream()
                .filter(m -> {
                    UUID other = m.getMemberAId().equals(userId) ? m.getMemberBId() : m.getMemberAId();
                    return !blockService.isBlockedEitherWay(userId, other);
                })
                .filter(m -> !meetingInfo(m.getId()).completed())
                .map(m -> toResponse(m, userId, false, false))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<MatchDtos.MatchResponse> history(UUID userId) {
        List<MatchDtos.MatchResponse> closed = new ArrayList<>(
                connectionRepository.findForUserWithStatuses(userId, HISTORY_STATUSES).stream()
                        .map(m -> toResponse(m, userId, false, false))
                        .toList()
        );
        List<MatchDtos.MatchResponse> completedMeetings = connectionRepository
                .findForUserWithStatuses(userId, List.of(MatchStatus.MUTUAL))
                .stream()
                .map(m -> toResponse(m, userId, false, false))
                .filter(MatchDtos.MatchResponse::meetingCompleted)
                .toList();
        closed.addAll(completedMeetings);
        return closed.stream()
                .sorted(Comparator.comparing(MatchDtos.MatchResponse::expiresAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(50)
                .toList();
    }

    @Transactional
    public MatchDtos.MatchResponse decide(UUID userId, UUID matchId, MatchDtos.DecisionRequest request) {
        ConnectionEntity match = connectionRepository.findById(matchId)
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));

        if (match.getExpiresAt().isBefore(Instant.now())) {
            match.setStatus(MatchStatus.EXPIRED);
            connectionRepository.save(match);
            throw new BusinessException("MATCH_EXPIRED", "This introduction has expired.");
        }

        boolean isA = match.getMemberAId().equals(userId);
        boolean isB = match.getMemberBId().equals(userId);
        if (!isA && !isB) {
            throw new BusinessException("FORBIDDEN", "Not a participant in this match.");
        }

        String action = request.action().trim().toUpperCase();
        if ("DECLINE".equals(action)) {
            match.setStatus(MatchStatus.DECLINED);
            if (isA) {
                match.setARespondedAt(Instant.now());
            } else {
                match.setBRespondedAt(Instant.now());
            }
            connectionRepository.save(match);
            UUID other = isA ? match.getMemberBId() : match.getMemberAId();
            memberNotifyService.notifyUser(
                    other,
                    "Introduction declined",
                    "They passed on this introduction. New ones may still arrive.",
                    "MATCH",
                    match.getId().toString()
            );
            return toResponse(match, userId, false, false);
        }
        if (!"ACCEPT".equals(action)) {
            throw new BusinessException("INVALID_ACTION", "Action must be ACCEPT or DECLINE.");
        }

        Instant now = Instant.now();
        if (isA) {
            if (match.getARespondedAt() != null && EnumSet.of(MatchStatus.ACCEPTED_A, MatchStatus.MUTUAL).contains(match.getStatus())) {
                throw new BusinessException("ALREADY_RESPONDED", "You already responded.");
            }
            match.setARespondedAt(now);
            if (match.getStatus() == MatchStatus.ACCEPTED_B) {
                match.setStatus(MatchStatus.MUTUAL);
            } else if (match.getStatus() == MatchStatus.PROPOSED) {
                match.setStatus(MatchStatus.ACCEPTED_A);
            }
        } else {
            if (match.getBRespondedAt() != null && EnumSet.of(MatchStatus.ACCEPTED_B, MatchStatus.MUTUAL).contains(match.getStatus())) {
                throw new BusinessException("ALREADY_RESPONDED", "You already responded.");
            }
            match.setBRespondedAt(now);
            if (match.getStatus() == MatchStatus.ACCEPTED_A) {
                match.setStatus(MatchStatus.MUTUAL);
            } else if (match.getStatus() == MatchStatus.PROPOSED) {
                match.setStatus(MatchStatus.ACCEPTED_B);
            }
        }
        connectionRepository.save(match);
        boolean becameMutual = match.getStatus() == MatchStatus.MUTUAL;
        if (becameMutual) {
            chatService.openForMatch(match);
            UserEntity a = userRepository.findById(match.getMemberAId()).orElse(null);
            UserEntity b = userRepository.findById(match.getMemberBId()).orElse(null);
            String aName = a == null || a.getDisplayName() == null || a.getDisplayName().isBlank() ? "Member" : a.getDisplayName();
            String bName = b == null || b.getDisplayName() == null || b.getDisplayName().isBlank() ? "Member" : b.getDisplayName();
            memberNotifyService.notifyUser(
                    match.getMemberAId(),
                    "Connected with " + bName,
                    "You and " + bName + " are connected — chat and propose a booking.",
                    "MATCH",
                    match.getId().toString()
            );
            memberNotifyService.notifyUser(
                    match.getMemberBId(),
                    "Connected with " + aName,
                    "You and " + aName + " are connected — chat and propose a booking.",
                    "MATCH",
                    match.getId().toString()
            );
        } else {
            UUID other = isA ? match.getMemberBId() : match.getMemberAId();
            memberNotifyService.notifyUser(
                    other,
                    "They accepted — your turn",
                    "Open Concierge to accept or decline before this introduction expires.",
                    "MATCH",
                    match.getId().toString()
            );
        }
        return toResponse(match, userId, false, becameMutual);
    }

    @Transactional
    public int expireOverdue() {
        List<ConnectionEntity> overdue = connectionRepository.findByStatusInAndExpiresAtBefore(
                List.of(MatchStatus.PROPOSED, MatchStatus.ACCEPTED_A, MatchStatus.ACCEPTED_B),
                Instant.now()
        );
        overdue.forEach(m -> m.setStatus(MatchStatus.EXPIRED));
        connectionRepository.saveAll(overdue);
        return overdue.size();
    }

    private UserEntity requireMatchable(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() != UserStatus.VERIFIED && user.getStatus() != UserStatus.ACTIVE) {
            throw new BusinessException("MEMBER_NOT_VERIFIED", "Both members must be verified.");
        }
        return user;
    }

    private MatchDtos.MatchResponse toResponse(
            ConnectionEntity match,
            UUID viewerId,
            boolean adminView,
            boolean becameMutual
    ) {
        UUID counterpartId = match.getMemberAId().equals(viewerId) ? match.getMemberBId() : match.getMemberAId();
        if (adminView) {
            counterpartId = match.getMemberBId();
        }
        UserEntity counterpart = userRepository.findById(counterpartId).orElse(null);
        MemberProfileEntity profile = profileRepository.findById(counterpartId).orElse(null);
        MatchDtos.VenueSummary venue = null;
        if (match.getSuggestedVenueId() != null) {
            venue = venueRepository.findById(match.getSuggestedVenueId())
                    .map(this::toVenueSummary)
                    .orElse(null);
        }

        boolean awaiting = false;
        if (!adminView) {
            boolean isA = match.getMemberAId().equals(viewerId);
            awaiting = switch (match.getStatus()) {
                case PROPOSED -> true;
                case ACCEPTED_A -> !isA;
                case ACCEPTED_B -> isA;
                default -> false;
            };
        }

        MeetingInfo meeting = meetingInfo(match.getId());
        boolean meetingCompleted = meeting.completed();
        String meetingVenueName = meeting.venueName();
        if (meetingVenueName == null && venue != null) {
            meetingVenueName = venue.name();
        }

        Integer age = null;
        if (counterpart != null && counterpart.getDateOfBirth() != null) {
            age = Period.between(counterpart.getDateOfBirth(), LocalDate.now()).getYears();
        }

        ChatService.InboxMeta inbox = match.getStatus() == MatchStatus.MUTUAL
                ? chatService.inboxMeta(match.getId(), viewerId)
                : ChatService.InboxMeta.empty();

        return new MatchDtos.MatchResponse(
                match.getId().toString(),
                match.getStatus().name(),
                counterpart != null ? counterpart.getDisplayName() : null,
                counterpartId.toString(),
                match.getIntroNoteEn(),
                match.getIntroNoteAm(),
                venue,
                match.getExpiresAt(),
                awaiting,
                match.getStatus() == MatchStatus.MUTUAL,
                meetingCompleted,
                meetingVenueName,
                profile == null || profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls()),
                age,
                profile == null ? null : profile.getCity(),
                profile == null ? null : profile.getBioEn(),
                profile == null ? null : profile.getBioAm(),
                profile == null || profile.getInterests() == null ? List.of() : List.copyOf(profile.getInterests()),
                match.getSource() == null ? "CONCIERGE" : match.getSource(),
                becameMutual,
                inbox.lastMessagePreview(),
                inbox.lastMessageAt(),
                inbox.lastMessageFromMe(),
                inbox.unreadCount(),
                inbox.turn(),
                counterpart != null && counterpart.getStatus() == UserStatus.VERIFIED,
                trustService.getTrustScore(counterpartId)
        );
    }

    private MeetingInfo meetingInfo(UUID matchId) {
        return bookingRepository.findByConnectionId(matchId)
                .filter(b -> b.getStatus() == BookingStatus.COMPLETED)
                .map(b -> {
                    String name = b.getVenueId() == null
                            ? null
                            : venueRepository.findById(b.getVenueId()).map(VenueEntity::getName).orElse(null);
                    return new MeetingInfo(true, name);
                })
                .orElse(new MeetingInfo(false, null));
    }

    private record MeetingInfo(boolean completed, String venueName) {}

    private MatchDtos.VenueSummary toVenueSummary(VenueEntity v) {
        return new MatchDtos.VenueSummary(
                v.getId().toString(),
                v.getName(),
                v.getNameAm(),
                v.getCity(),
                v.getCategory(),
                v.getAddressLine(),
                v.getPrivacyLevel(),
                v.getLatitude(),
                v.getLongitude(),
                v.getGeofenceMeters(),
                v.getArea(),
                v.getPriceBand(),
                v.getVibe(),
                v.getPhotoUrls() == null ? List.of() : List.copyOf(v.getPhotoUrls()),
                v.isVerified()
        );
    }
}
