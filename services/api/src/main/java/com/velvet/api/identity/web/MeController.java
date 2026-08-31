package com.velvet.api.identity.web;

import com.velvet.api.discover.service.DiscoverService;
import com.velvet.api.discover.web.dto.DiscoverDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.identity.service.ProfileService;
import com.velvet.api.identity.web.dto.ProfileDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/v1/me")
public class MeController {

    private final ProfileService profileService;
    private final DiscoverService discoverService;

    public MeController(ProfileService profileService, DiscoverService discoverService) {
        this.profileService = profileService;
        this.discoverService = discoverService;
    }

    @GetMapping
    public ResponseEntity<ProfileDtos.MeResponse> me(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(profileService.getMe(principal.getUserId()));
    }

    @PatchMapping
    public ResponseEntity<ProfileDtos.MeResponse> updateMe(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.UpdateMeRequest request
    ) {
        return ResponseEntity.ok(profileService.updateMe(principal.getUserId(), request));
    }

    @PostMapping("/photos")
    public ResponseEntity<ProfileDtos.MeResponse> addPhoto(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.AddPhotoRequest request
    ) {
        return ResponseEntity.ok(profileService.addPhoto(principal.getUserId(), request));
    }

    @DeleteMapping("/photos")
    public ResponseEntity<ProfileDtos.MeResponse> removePhoto(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.RemovePhotoRequest request
    ) {
        return ResponseEntity.ok(profileService.removePhoto(principal.getUserId(), request.url()));
    }

    @PutMapping("/photos/order")
    public ResponseEntity<ProfileDtos.MeResponse> reorderPhotos(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.ReorderPhotosRequest request
    ) {
        return ResponseEntity.ok(profileService.reorderPhotos(principal.getUserId(), request));
    }

    @PostMapping("/vault/photos")
    public ResponseEntity<ProfileDtos.MeResponse> addPrivatePhoto(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.AddPhotoRequest request
    ) {
        return ResponseEntity.ok(profileService.addPrivatePhoto(principal.getUserId(), request));
    }

    @PostMapping("/vault/grant")
    public ResponseEntity<Map<String, String>> grantVaultAccess(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.GrantVaultAccessRequest request
    ) {
        profileService.grantVaultAccess(principal.getUserId(), request.memberId(), request.reason());
        return ResponseEntity.ok(Map.of("status", "GRANTED"));
    }

    @PostMapping("/available-tonight")
    public ResponseEntity<ProfileDtos.MeResponse> toggleAvailableTonight(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.ToggleAvailableTonightRequest request
    ) {
        return ResponseEntity.ok(profileService.toggleAvailableTonight(principal.getUserId(), request));
    }

    @PostMapping("/voice-intro")
    public ResponseEntity<ProfileDtos.MeResponse> setVoiceIntro(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody ProfileDtos.UploadVoiceIntroRequest request
    ) {
        return ResponseEntity.ok(profileService.setVoiceIntro(principal.getUserId(), request));
    }



    @PostMapping("/withdraw")
    public ResponseEntity<Map<String, String>> withdraw(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        profileService.withdraw(principal.getUserId());
        return ResponseEntity.ok(Map.of("status", "WITHDRAWN"));
    }

    @GetMapping("/data-export")
    public ResponseEntity<Map<String, Object>> dataExport(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(profileService.exportData(principal.getUserId()));
    }

    @PostMapping("/erasure")
    public ResponseEntity<Map<String, String>> erasure(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        profileService.erasure(principal.getUserId());
        return ResponseEntity.ok(Map.of("status", "ERASED"));
    }

    @GetMapping("/preferences")
    public ResponseEntity<DiscoverDtos.PreferencesResponse> preferences(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(discoverService.getPreferences(principal.getUserId()));
    }

    @PatchMapping("/preferences")
    public ResponseEntity<DiscoverDtos.PreferencesResponse> updatePreferences(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody DiscoverDtos.PreferencesRequest request
    ) {
        return ResponseEntity.ok(discoverService.updatePreferences(principal.getUserId(), request));
    }

    @PostMapping("/location")
    public ResponseEntity<Void> location(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody DiscoverDtos.LocationRequest request
    ) {
        discoverService.updateLocation(principal.getUserId(), request);
        return ResponseEntity.noContent().build();
    }
}
