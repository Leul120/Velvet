package com.velvet.api.common.api;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.servlet.HandlerMapping;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class GlobalExceptionHandlerTest {

    @Test
    void jsonErrorOverridesImageAcceptPreset() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/v1/media/profile/demo.jpg");
        request.setAttribute(HandlerMapping.PRODUCIBLE_MEDIA_TYPES_ATTRIBUTE, Set.of(MediaType.IMAGE_JPEG));
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.setContentType(MediaType.IMAGE_JPEG_VALUE);

        ResponseEntity<ApiError> entity = GlobalExceptionHandler.jsonError(
                request, response, HttpStatus.NOT_FOUND, "NOT_FOUND", "Media not found.");

        assertEquals(MediaType.APPLICATION_JSON, entity.getHeaders().getContentType());
        assertEquals("NOT_FOUND", entity.getBody().code());
        assertEquals(MediaType.APPLICATION_JSON_VALUE, response.getContentType());
        assertNull(request.getAttribute(HandlerMapping.PRODUCIBLE_MEDIA_TYPES_ATTRIBUTE));
    }

    @Test
    void notFoundBusinessExceptionUses404() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        ResponseEntity<ApiError> entity = handler.handleBusiness(
                new BusinessException("NOT_FOUND", "Media not found."),
                request,
                response
        );

        assertEquals(HttpStatus.NOT_FOUND, entity.getStatusCode());
        assertEquals(MediaType.APPLICATION_JSON, entity.getHeaders().getContentType());
    }
}
