package com.velvet.api.notify.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.notify.domain.DeviceTokenEntity;
import com.velvet.api.notify.repo.DeviceTokenRepository;
import com.velvet.api.notify.web.dto.DeviceDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class DeviceTokenService {

    private final DeviceTokenRepository repository;

    public DeviceTokenService(DeviceTokenRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public DeviceDtos.DeviceTokenResponse register(UUID userId, DeviceDtos.RegisterRequest request) {
        String token = request.token().trim();
        if (token.isEmpty()) {
            throw new BusinessException("TOKEN_REQUIRED", "Push token is required.");
        }
        String platform = request.platform() == null || request.platform().isBlank()
                ? "android"
                : request.platform().trim().toLowerCase();

        DeviceTokenEntity entity = repository.findByToken(token).orElseGet(() ->
                DeviceTokenEntity.builder().token(token).build());
        entity.setUserId(userId);
        entity.setPlatform(platform);
        entity.setActive(true);
        entity = repository.save(entity);
        return new DeviceDtos.DeviceTokenResponse(entity.getId().toString(), entity.getPlatform(), entity.isActive());
    }
}
