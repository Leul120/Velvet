package com.velvet.api.discover.repo;

import com.velvet.api.discover.domain.MemberPreferencesEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MemberPreferencesRepository extends JpaRepository<MemberPreferencesEntity, UUID> {
}
