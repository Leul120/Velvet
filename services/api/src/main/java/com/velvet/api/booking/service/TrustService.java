package com.velvet.api.booking.service;

import com.velvet.api.booking.repo.MeetingFeedbackRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class TrustService {
    private final MeetingFeedbackRepository feedbackRepository;

    public TrustService(MeetingFeedbackRepository feedbackRepository) {
        this.feedbackRepository = feedbackRepository;
    }

    @Transactional(readOnly = true)
    public Integer getTrustScore(UUID userId) {
        long total = feedbackRepository.countFeedbackReceivedByUserId(userId);
        if (total < 1) {
            return null; // No score if no feedback
        }
        long positive = feedbackRepository.countPositiveFeedbackReceivedByUserId(userId);
        return (int) Math.round((positive * 100.0) / total);
    }
}
