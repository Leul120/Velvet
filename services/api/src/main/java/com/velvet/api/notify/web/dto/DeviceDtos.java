package com.velvet.api.notify.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class DeviceDtos {

    private DeviceDtos() {}

    public record RegisterRequest(
            @NotBlank @Size(max = 512) String token,
            @Size(max = 32) String platform
    ) {}

    public record DeviceTokenResponse(
            String id,
            String platform,
            boolean active
    ) {}
}
