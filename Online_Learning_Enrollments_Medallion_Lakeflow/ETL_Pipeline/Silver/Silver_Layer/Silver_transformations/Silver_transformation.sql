CREATE OR REFRESH MATERIALIZED VIEW silver_enrollments_clean (
  CONSTRAINT valid_progress EXPECT (progress_pct BETWEEN 0 AND 100) ON VIOLATION DROP ROW,
  CONSTRAINT valid_price    EXPECT (price_paid >= 0)                ON VIOLATION DROP ROW
) AS
WITH cleaned AS (
  SELECT DISTINCT
    enrollment_id,
    learner_id,
    LOWER(TRIM(learner_email))                             AS learner_email,
    COALESCE(INITCAP(TRIM(learner_city)), 'Unknown')       AS learner_city,
    TRIM(age_group)                                        AS age_group,
    course_id,
    TRIM(course_name)                                      AS course_name,
    COALESCE(INITCAP(TRIM(category)), 'Unknown')           AS category,
    INITCAP(TRIM(course_level))                            AS course_level,
    INITCAP(TRIM(instructor_name))                         AS instructor_name,
    enrollment_date,
    COALESCE(INITCAP(TRIM(enrollment_channel)), 'Unknown') AS enrollment_channel,
    list_price,
    discount_amount,
    COALESCE(price_paid, list_price - discount_amount)     AS price_paid,
    INITCAP(TRIM(payment_method))                          AS payment_method,
    progress_pct,
    hours_watched,
    course_rating,
    TRIM(certificate_issued)                               AS certificate_issued,
    _rescued_data,
    source_file,
    loaded_at
  FROM bronze_course_enrollments
)
SELECT
  *,
  CASE
    WHEN progress_pct = 100 THEN 'Completed'
    WHEN progress_pct > 0   THEN 'In Progress'
    ELSE 'Not Started'
  END AS learner_status
FROM cleaned;

CREATE OR REFRESH MATERIALIZED VIEW silver_enrollments_rejected AS
SELECT
  *,
  CASE
    WHEN progress_pct < 0 OR progress_pct > 100 THEN 'Progress is outside 0 to 100'
    ELSE 'Price paid is negative'
  END AS reject_reason
FROM bronze_course_enrollments
WHERE progress_pct < 0 OR progress_pct > 100 OR price_paid < 0;
