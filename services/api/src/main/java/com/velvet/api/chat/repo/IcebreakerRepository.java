package com.velvet.api.chat.repo;

import com.velvet.api.chat.domain.IcebreakerEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface IcebreakerRepository extends JpaRepository<IcebreakerEntity, UUID> {
    List<IcebreakerEntity> findByActiveTrue();
}
