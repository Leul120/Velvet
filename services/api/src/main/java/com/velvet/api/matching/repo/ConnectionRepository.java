package com.velvet.api.matching.repo;

import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface ConnectionRepository extends JpaRepository<ConnectionEntity, UUID> {

    @Query("""
            SELECT m FROM ConnectionEntity m
            WHERE (m.memberAId = :userId OR m.memberBId = :userId)
              AND m.status IN :statuses
            ORDER BY m.createdAt DESC
            """)
    List<ConnectionEntity> findForUserWithStatuses(
            @Param("userId") UUID userId,
            @Param("statuses") List<MatchStatus> statuses
    );

    List<ConnectionEntity> findByStatusInAndExpiresAtBefore(List<MatchStatus> statuses, Instant before);
}
