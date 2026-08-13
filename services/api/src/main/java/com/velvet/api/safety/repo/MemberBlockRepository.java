package com.velvet.api.safety.repo;

import com.velvet.api.safety.domain.MemberBlockEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberBlockRepository extends JpaRepository<MemberBlockEntity, UUID> {
    Optional<MemberBlockEntity> findByBlockerIdAndBlockedId(UUID blockerId, UUID blockedId);

    List<MemberBlockEntity> findByBlockerIdOrderByCreatedAtDesc(UUID blockerId);

    @Query("""
            select case when count(b) > 0 then true else false end from MemberBlockEntity b
            where (b.blockerId = :a and b.blockedId = :b)
               or (b.blockerId = :b and b.blockedId = :a)
            """)
    boolean existsBetween(UUID a, UUID b);

    @Query("select b.blockedId from MemberBlockEntity b where b.blockerId = :userId")
    List<UUID> findBlockedIds(@Param("userId") UUID userId);

    @Query("select b.blockerId from MemberBlockEntity b where b.blockedId = :userId")
    List<UUID> findBlockerIds(@Param("userId") UUID userId);
}
