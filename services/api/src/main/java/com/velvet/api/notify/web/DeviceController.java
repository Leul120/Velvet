package com.velvet.api.notify.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.notify.service.DeviceTokenService;
import com.velvet.api.notify.web.dto.DeviceDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/devices")
public class DeviceController {

    private final DeviceTokenService deviceTokenService;

    public DeviceController(DeviceTokenService deviceTokenService) {
        this.deviceTokenService = deviceTokenService;
    }

    @PostMapping("/push-token")
    public ResponseEntity<DeviceDtos.DeviceTokenResponse> register(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody DeviceDtos.RegisterRequest request
    ) {
        return ResponseEntity.ok(deviceTokenService.register(principal.getUserId(), request));
    }
}
