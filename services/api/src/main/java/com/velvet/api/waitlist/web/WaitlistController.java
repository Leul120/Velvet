package com.velvet.api.waitlist.web;

import com.velvet.api.waitlist.service.WaitlistService;
import com.velvet.api.waitlist.web.dto.WaitlistDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/waitlist")
public class WaitlistController {

    private final WaitlistService waitlistService;

    public WaitlistController(WaitlistService waitlistService) {
        this.waitlistService = waitlistService;
    }

    @PostMapping
    public ResponseEntity<WaitlistDtos.ApplicationResponse> apply(
            @Valid @RequestBody WaitlistDtos.ApplyRequest request
    ) {
        return ResponseEntity.ok(waitlistService.apply(request));
    }

    @GetMapping("/status")
    public ResponseEntity<WaitlistDtos.StatusResponse> status(@RequestParam String phone) {
        return ResponseEntity.ok(waitlistService.status(phone));
    }
}
