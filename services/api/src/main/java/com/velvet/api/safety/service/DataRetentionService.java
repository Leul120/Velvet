package com.velvet.api.safety.service;

import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.safety.domain.PanicAlertEntity;
import com.velvet.api.safety.repo.PanicAlertRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class DataRetentionService {

    private static final Logger log = LoggerFactory.getLogger(DataRetentionService.class);

    private final PanicAlertRepository panicAlertRepository;
    private final VelvetProperties properties;

    public DataRetentionService(PanicAlertRepository panicAlertRepository, VelvetProperties properties) {
        this.panicAlertRepository = panicAlertRepository;
        this.properties = properties;
    }

    /** Scrub panic GPS older than retention window (default 7 days). */
    @Transactional
    public int scrubExpiredLocation() {
        int days = 7;
        if (properties.retention() != null && properties.retention().locationDays() > 0) {
            days = properties.retention().locationDays();
        }
        Instant cutoff = Instant.now().minus(days, ChronoUnit.DAYS);
        List<PanicAlertEntity> stale = panicAlertRepository.findByCreatedAtBeforeAndLatitudeIsNotNull(cutoff);
        for (PanicAlertEntity alert : stale) {
            alert.setLatitude(null);
            alert.setLongitude(null);
            panicAlertRepository.save(alert);
        }
        if (!stale.isEmpty()) {
            log.info("Scrubbed location from {} panic alerts older than {} days", stale.size(), days);
        }
        return stale.size();
    }
}
