-- Align liked_photo_index with Hibernate Integer mapping
ALTER TABLE member_likes
    ALTER COLUMN liked_photo_index TYPE INTEGER USING liked_photo_index::integer;
