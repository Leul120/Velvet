package com.velvet.api.discover.repo;

import com.velvet.api.discover.domain.MemberLikeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberLikeRepository extends JpaRepository<MemberLikeEntity, UUID> {

    Optional<MemberLikeEntity> findByFromUserIdAndToUserId(UUID fromUserId, UUID toUserId);

    @Query("SELECT l.toUserId FROM MemberLikeEntity l WHERE l.fromUserId = :fromUserId")
    List<UUID> findTargetIdsByFromUserId(@Param("fromUserId") UUID fromUserId);

    @Query("""
            SELECT l FROM MemberLikeEntity l
            WHERE l.toUserId = :toUserId AND l.action = 'LIKE'
            ORDER BY l.createdAt DESC
            """)
    List<MemberLikeEntity> findReceivedLikes(@Param("toUserId") UUID toUserId);

    @Query("""
            SELECT l FROM MemberLikeEntity l
            WHERE l.fromUserId = :fromUserId AND l.action = 'PASS'
            ORDER BY l.createdAt DESC
            """)
    List<MemberLikeEntity> findRecentPasses(@Param("fromUserId") UUID fromUserId);
}
