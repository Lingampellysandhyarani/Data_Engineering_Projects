CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_enrollments AS
SELECT DATE_TRUNC('MONTH', enrollment_date)                     AS enrollment_month,
       COUNT(*)                                                 AS enrollments,
       COUNT(DISTINCT learner_email)                            AS unique_learners,
       ROUND(SUM(price_paid), 2)                                AS revenue,
       SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END) AS completions,
       SUM(hours_watched)                                       AS hours_watched
FROM silver_enrollments_clean
GROUP BY DATE_TRUNC('MONTH', enrollment_date);

CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS
SELECT COUNT(*)                                                   AS bronze_rows,
       COUNT(*) - COUNT(DISTINCT enrollment_id)                   AS duplicate_rows,
       SUM(CASE WHEN progress_pct < 0 OR progress_pct > 100 THEN 1 ELSE 0 END) AS invalid_progress_rows,
       COUNT(DISTINCT learner_email)                              AS learners_before_email_fix,
       COUNT(DISTINCT LOWER(TRIM(learner_email)))                 AS learners_after_email_fix,
       SUM(CASE WHEN price_paid < 0 THEN 1 ELSE 0 END)            AS negative_price_rows,
       SUM(CASE WHEN category IS NULL OR TRIM(category) = '' THEN 1 ELSE 0 END) AS missing_category_rows,
       SUM(CASE WHEN learner_city IS NULL OR TRIM(learner_city) = '' THEN 1 ELSE 0 END) AS missing_city_rows,
       COUNT(*) - COUNT(price_paid)                               AS missing_price_rows,
       (SELECT COUNT(*) FROM silver_enrollments_clean)            AS clean_rows,
       (SELECT COUNT(*) FROM silver_enrollments_rejected)         AS rejected_rows
FROM bronze_course_enrollments;

-- ============================================================================
-- gold_category_summary
-- Category-level analytics from the cleaned Silver layer:
--   - enrollments, revenue, and learner-status breakdown
--     (completed / in-progress / not-started)
--   - completion_rate_pct = completed enrollments / total enrollments * 100
--   - avg_progress_pct    = average learner progress within the category
-- NULL handling: category and learner_status are already coalesced ('Unknown')
-- or derived in Silver, so no extra NULL filtering is needed here.
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW gold_category_summary AS

SELECT
    category,
    COUNT(*) AS enrollments,
    ROUND(SUM(price_paid), 2) AS revenue,

    SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END)
        AS completed_enrollments,

    SUM(CASE WHEN learner_status = 'In Progress' THEN 1 ELSE 0 END)
        AS in_progress_enrollments,

    SUM(CASE WHEN learner_status = 'Not Started' THEN 1 ELSE 0 END)
        AS not_started_enrollments,

    ROUND(
        100.0 * SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS completion_rate_pct,

    ROUND(AVG(progress_pct), 2) AS avg_progress_pct

FROM silver_enrollments_clean
GROUP BY category;

-- ============================================================================
-- gold_course_summary
-- Course-level analytics (one row per category + course + level + instructor):
--   - enrollments, revenue, and completion_rate_pct
--   - avg_rating     = average course_rating across the course's enrollments
--   - hours_watched  = total hours watched for the course
-- NULL handling: category, course_level, and instructor_name are already
-- INITCAP/TRIM-ed in Silver (category falls back to 'Unknown').
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW gold_course_summary AS

SELECT
    category,
    course_name,
    course_level,
    instructor_name,
    COUNT(*) AS enrollments,
    ROUND(SUM(price_paid), 2) AS revenue,

    -- Completion rate = completed enrollments / total enrollments * 100
    ROUND(
        SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS completion_rate_pct,

    ROUND(AVG(course_rating), 2) AS avg_rating,
    SUM(hours_watched) AS hours_watched

FROM silver_enrollments_clean
GROUP BY
    category,
    course_name,
    course_level,
    instructor_name;

-- ============================================================================
-- gold_channel_summary
-- Channel-level analytics: how each enrollment channel performs:
--   - enrollments and revenue per enrollment channel
--   - completed_enrollments and completion_rate_pct per channel
-- NULL handling: enrollment_channel is already coalesced to 'Unknown' in
-- Silver, so every row belongs to a known channel.
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW gold_channel_summary AS
SELECT
    enrollment_channel,
    COUNT(*) AS enrollments,
    ROUND(SUM(price_paid), 2) AS revenue,

    SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END)
        AS completed_enrollments,

    -- Completion rate = completed enrollments / total enrollments * 100
    ROUND(
        100.0 * SUM(CASE WHEN learner_status = 'Completed' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS completion_rate_pct

FROM silver_enrollments_clean
GROUP BY enrollment_channel;
