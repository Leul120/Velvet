package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<UserEntity, UUID> {
    Optional<UserEntity> findByPhoneE164(String phoneE164);

    boolean existsByPhoneE164(String phoneE164);

    List<UserEntity> findByRoleIn(Collection<UserRole> roles);

    List<UserEntity> findByStatusIn(Collection<UserStatus> statuses);
}
