package com.velvet.api.identity.security;

import com.velvet.api.common.config.VelvetProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    private final VelvetProperties properties;
    private final SecretKey key;

    public JwtService(VelvetProperties properties) {
        this.properties = properties;
        byte[] secret = properties.jwt().secret().getBytes(StandardCharsets.UTF_8);
        this.key = Keys.hmacShaKeyFor(secret);
    }

    public String createAccessToken(UUID userId, String role) {
        Instant now = Instant.now();
        Instant exp = now.plusSeconds(properties.jwt().accessTokenMinutes() * 60);
        return Jwts.builder()
                .subject(userId.toString())
                .claim("role", role)
                .claim("typ", "access")
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(key)
                .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public UUID userId(Claims claims) {
        return UUID.fromString(claims.getSubject());
    }
}
