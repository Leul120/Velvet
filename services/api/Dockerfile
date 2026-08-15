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

# Lean defaults for small hosts (Render free = 512MB). Local compose overrides seed.
ENV VELVET_SEED_RESET=false \
    SPRING_LAZY=true \
    DB_POOL_SIZE=3 \
    DB_POOL_IDLE=1 \
    TOMCAT_MAX_THREADS=40 \
    TOMCAT_MIN_SPARE=2 \
    SPRINGDOC_API_DOCS_ENABLED=false \
    SPRINGDOC_SWAGGER_UI_ENABLED=false

# Cap heap vs container RAM; SerialGC uses less native memory than G1 on tiny boxes.
# Render sets PORT; local Docker leaves it unset (defaults to 8080).
ENTRYPOINT ["sh", "-c", "exec java -XX:MaxRAMPercentage=55 -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m -Xss512k -XX:+ExitOnOutOfMemoryError -jar /app/app.jar --server.port=${PORT:-8080}"]
