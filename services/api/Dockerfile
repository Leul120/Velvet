# syntax=docker/dockerfile:1
# Fast path: use a pre-built jar when present (./mvnw -DskipTests package).
# Fallback: full Maven build (Render / CI, where target/ is not in the build context).
FROM eclipse-temurin:17-jdk AS build
WORKDIR /src
COPY . .
RUN mkdir -p /out \
    && if [ -f target/velvet-api-0.1.0-SNAPSHOT.jar ]; then \
         cp target/velvet-api-0.1.0-SNAPSHOT.jar /out/app.jar; \
       else \
         chmod +x mvnw && ./mvnw -DskipTests package \
         && cp target/velvet-api-0.1.0-SNAPSHOT.jar /out/app.jar; \
       fi

FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY --from=build /out/app.jar app.jar
EXPOSE 8080
# Render sets PORT; local Docker compose leaves it unset (defaults to 8080).
ENTRYPOINT ["sh", "-c", "exec java -jar /app/app.jar --server.port=${PORT:-8080}"]
