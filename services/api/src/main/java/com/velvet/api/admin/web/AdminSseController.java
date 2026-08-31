package com.velvet.api.admin.web;

import com.velvet.api.admin.sse.AdminSseRegistry;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequestMapping("/v1/admin/events")
public class AdminSseController {

    private final AdminSseRegistry sseRegistry;

    public AdminSseController(AdminSseRegistry sseRegistry) {
        this.sseRegistry = sseRegistry;
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamEvents() {
        return sseRegistry.subscribe();
    }
}
