package com.velvet.api.identity.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.velvet.api.common.api.ApiError;
import com.velvet.api.common.config.VelvetProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final VelvetProperties properties;
    private final ObjectMapper objectMapper;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter,
            VelvetProperties properties,
            ObjectMapper objectMapper
    ) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((request, response, authException) -> {
                            response.setStatus(401);
                            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            objectMapper.writeValue(
                                    response.getOutputStream(),
                                    ApiError.of("UNAUTHORIZED", "Sign in required.")
                            );
                        })
                        .accessDeniedHandler((request, response, accessDeniedException) -> {
                            response.setStatus(403);
                            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            objectMapper.writeValue(
                                    response.getOutputStream(),
                                    ApiError.of("FORBIDDEN", "You do not have access to this resource.")
                            );
                        })
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/actuator/health",
                                "/actuator/info",
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/admin",
                                "/admin/**",
                                "/partner",
                                "/partner/**",
                                "/waitlist",
                                "/waitlist/**",
                                "/legal",
                                "/legal/**"
                        ).permitAll()
                        .requestMatchers(HttpMethod.POST,
                                "/v1/auth/otp/request",
                                "/v1/auth/otp/verify",
                                "/v1/auth/refresh",
                                "/v1/billing/telebirr/notify",
                                "/v1/waitlist",
                                // These local adapters enforce their own bearer service key.
                                "/v1/internal/moderation/score",
                                "/v1/internal/push/deliver"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET,
                                "/v1/legal/current",
                                // Listing photos are intentionally public. All other media,
                                // including identity, receipts, and chat, requires authorization.
                                "/v1/media/profile/**",
                                "/v1/waitlist/status"
                        ).permitAll()
                        .requestMatchers("/v1/admin/**").hasAnyRole("ADMIN", "CONCIERGE")
                        .requestMatchers("/v1/partner/**").hasRole("VENUE_PARTNER")
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        String origins = properties.cors().allowedOrigins();
        if ("*".equals(origins)) {
            config.setAllowedOriginPatterns(List.of("*"));
        } else {
            config.setAllowedOrigins(Arrays.asList(origins.split(",")));
        }
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
