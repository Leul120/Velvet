# syntax=docker/dockerfile:1
# Fast path: use a pre-built jar when present (./mvnw -DskipTests package).
# Fallback: full Maven build inside Docker.
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY target/velvet-api-0.1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
