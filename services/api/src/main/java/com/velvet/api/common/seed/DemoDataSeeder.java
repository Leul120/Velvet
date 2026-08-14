package com.velvet.api.common.seed;

import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * Local/dev only: wipe demo phones and reload a rich roster on every API boot
 * when {@code velvet.seed.reset-on-startup=true} (docker default).
 */
@Component
@Order(100)
public class DemoDataSeeder implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DemoDataSeeder.class);

    private final DataSource dataSource;
    private final VelvetProperties properties;

    public DemoDataSeeder(DataSource dataSource, VelvetProperties properties) {
        this.dataSource = dataSource;
        this.properties = properties;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!properties.shouldResetDemoSeed()) {
            log.info("Demo seed reset skipped (VELVET_SEED_RESET / production)");
            return;
        }
        log.info("Resetting demo discovery roster…");
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.setContinueOnError(false);
        populator.setSeparator(";");
        populator.addScript(new ClassPathResource("db/seed/demo_roster.sql"));
        populator.execute(dataSource);
        log.info("Demo roster ready — invite VELVET-SEED, clients +251911100001–024, performers +251911200001–060");
    }
}
