package com.velvet.api.db;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Verifies the terminology migration against a real PostgreSQL schema. */
@Testcontainers(disabledWithoutDocker = true)
class ConnectionsMigrationTest {

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("velvet")
            .withUsername("velvet")
            .withPassword("velvet");

    @BeforeAll
    static void migrate() {
        Flyway.configure()
                .dataSource(POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword())
                .locations("classpath:db/migration")
                .load()
                .migrate();
    }

    @Test
    void usesConnectionTerminologyForPersistence() throws Exception {
        try (Connection connection = DriverManager.getConnection(
                POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword())) {
            assertTrue(tableExists(connection, "connections"));
            assertFalse(tableExists(connection, "match_proposals"));
            assertTrue(columnExists(connection, "bookings", "connection_id"));
            assertTrue(columnExists(connection, "chat_threads", "connection_id"));
            assertTrue(columnExists(connection, "subscriptions", "connections_used"));
            assertFalse(columnExists(connection, "bookings", "match_id"));
            assertFalse(columnExists(connection, "subscriptions", "matches_used"));
        }
    }

    private static boolean tableExists(Connection connection, String table) throws Exception {
        try (ResultSet result = connection.getMetaData().getTables(null, "public", table, new String[]{"TABLE"})) {
            return result.next();
        }
    }

    private static boolean columnExists(Connection connection, String table, String column) throws Exception {
        try (ResultSet result = connection.getMetaData().getColumns(null, "public", table, column)) {
            return result.next();
        }
    }
}
