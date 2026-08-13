package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.MemberProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;
import java.util.List;

public interface MemberProfileRepository extends JpaRepository<MemberProfileEntity, UUID> {
    List<MemberProfileEntity> findByPhotoQualityStatusOrderByUpdatedAtAsc(String photoQualityStatus);
}
