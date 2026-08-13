package com.velvet.api.billing.repo;

import com.velvet.api.billing.domain.LedgerEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface LedgerEntryRepository extends JpaRepository<LedgerEntryEntity, UUID> {

    List<LedgerEntryEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);

    boolean existsByBookingIdAndEntryType(UUID bookingId, String entryType);

    java.util.Optional<LedgerEntryEntity> findFirstByBookingIdAndEntryType(UUID bookingId, String entryType);

    @Query("""
            select coalesce(sum(case when e.entryType = 'PERFORMER_CREDIT' then e.amountEtb
                                     when e.entryType = 'PERFORMER_CREDIT_REVERSAL' then -e.amountEtb
                                     when e.entryType = 'PERFORMER_PAYOUT_REVERSAL' then e.amountEtb
                                     when e.entryType = 'PERFORMER_PAYOUT' then -e.amountEtb
                                     else 0 end), 0)
            from LedgerEntryEntity e
            where e.userId = :userId
            """)
    BigDecimal balanceFor(@Param("userId") UUID userId);
}
