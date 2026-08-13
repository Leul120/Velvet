-- Do not treat legacy or client-labelled profile images as approved.
ALTER TABLE member_profiles
    ALTER COLUMN photo_quality_status SET DEFAULT 'NEEDS_REVIEW';

UPDATE member_profiles
SET photo_quality_status = 'NEEDS_REVIEW',
    photo_quality_notes = 'Pending server or concierge photo review.'
WHERE COALESCE(photo_quality_status, 'APPROVED') = 'APPROVED'
  AND jsonb_array_length(COALESCE(photo_urls, '[]'::jsonb)) > 0;
