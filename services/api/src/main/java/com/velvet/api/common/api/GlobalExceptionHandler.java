package com.velvet.api.common.api;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.HandlerMapping;

import java.util.Set;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private static final Set<String> NOT_FOUND_CODES = Set.of("NOT_FOUND");
    private static final Set<String> FORBIDDEN_CODES = Set.of("FORBIDDEN");

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiError> handleBusiness(
            BusinessException ex,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        HttpStatus status = statusFor(ex.getCode());
        return jsonError(request, response, status, ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("; "));
        return jsonError(request, response, HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", message);
    }

    @ExceptionHandler({BadCredentialsException.class})
    public ResponseEntity<ApiError> handleBadCredentials(
            RuntimeException ex,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        return jsonError(request, response, HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", ex.getMessage());
    }

    @ExceptionHandler({AccessDeniedException.class, AuthorizationDeniedException.class})
    public ResponseEntity<ApiError> handleAccessDenied(
            AccessDeniedException ex,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        return jsonError(request, response, HttpStatus.FORBIDDEN, "FORBIDDEN", "Access denied");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleGeneric(
            Exception ex,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        log.error("Unhandled error on {}", request.getRequestURI(), ex);
        return jsonError(
                request,
                response,
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_ERROR",
                "An unexpected error occurred"
        );
    }

    private static HttpStatus statusFor(String code) {
        if (code != null && (NOT_FOUND_CODES.contains(code) || code.endsWith("_NOT_FOUND"))) {
            return HttpStatus.NOT_FOUND;
        }
        if (code != null && FORBIDDEN_CODES.contains(code)) {
            return HttpStatus.FORBIDDEN;
        }
        return HttpStatus.BAD_REQUEST;
    }

    /**
     * Image clients (Flutter {@code Image.network}) send {@code Accept: image/jpeg} on
     * {@code /v1/media/**.jpg}. Spring then treats that as the producible type, so a JSON
     * {@link ApiError} cannot be written unless we clear it and force JSON.
     */
    static ResponseEntity<ApiError> jsonError(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpStatus status,
            String code,
            String message
    ) {
        request.removeAttribute(HandlerMapping.PRODUCIBLE_MEDIA_TYPES_ATTRIBUTE);
        if (response.isCommitted()) {
            log.warn("Could not write {} error; response already committed for {}", code, request.getRequestURI());
            return null;
        }
        response.resetBuffer();
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        return ResponseEntity.status(status)
                .contentType(MediaType.APPLICATION_JSON)
                .body(ApiError.of(code, message));
    }
}
