# ADR 0001 — Stack choice

## Status
Accepted

## Context
VELVET Ethiopia needs a mobile-first client and a compliance-heavy backend (verification, moderation, ledger).

## Decision
- Mobile: Flutter (Android-first, shared Amharic/English UI)
- API: Spring Boot modular monolith (Java 21)
- DB: PostgreSQL + Flyway
- Cache/OTP: Redis
- Objects: S3-compatible (MinIO locally)

## Consequences
One mobile team ships Android+iOS. Backend stays one deployable until team size forces split.
