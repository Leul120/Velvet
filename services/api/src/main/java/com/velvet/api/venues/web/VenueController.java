package com.velvet.api.venues.web;

import com.velvet.api.matching.web.dto.MatchDtos;
import com.velvet.api.venues.service.VenueService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/v1/venues")
public class VenueController {

    private final VenueService venueService;

    public VenueController(VenueService venueService) {
        this.venueService = venueService;
    }

    @GetMapping
    public ResponseEntity<List<MatchDtos.VenueResponse>> list() {
        return ResponseEntity.ok(venueService.listActive());
    }
}
