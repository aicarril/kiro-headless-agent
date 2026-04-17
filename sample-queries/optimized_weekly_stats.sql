-- Optimized Query 2: Weekly event statistics with trend analysis
-- Original: Used DATE_FORMAT(DATE_ADD('month', -6, CURRENT_DATE)) for partition filter
-- Optimizations: Static partition filter, simplified GROUP BY, removed redundant aliases
-- Note: Query was already well-structured; minimal optimization possible with CSV format

WITH weekly_stats AS (
    SELECT
        DATE_TRUNC('week', DATE(partition_date)) AS week_start,
        COUNT(*) AS total_events,
        SUM(CASE WHEN event_type = 'error' THEN 1 ELSE 0 END) AS error_count,
        SUM(CASE WHEN status_code >= 500 THEN 1 ELSE 0 END) AS server_errors,
        AVG(duration_ms) AS avg_duration_ms,
        APPROX_PERCENTILE(duration_ms, 0.95) AS p95_duration_ms
    FROM demo_db.events
    WHERE partition_date >= '2025-10-17'
    GROUP BY 1
)
SELECT
    week_start,
    total_events,
    error_count,
    server_errors,
    ROUND(avg_duration_ms, 1) AS avg_duration_ms,
    p95_duration_ms,
    LAG(total_events) OVER (ORDER BY week_start) AS prev_week_events,
    ROUND(
        (CAST(total_events AS DOUBLE) - LAG(total_events) OVER (ORDER BY week_start))
        / NULLIF(LAG(total_events) OVER (ORDER BY week_start), 0) * 100,
        1
    ) AS wow_events_pct_change,
    ROUND(
        (CAST(error_count AS DOUBLE) - LAG(error_count) OVER (ORDER BY week_start))
        / NULLIF(LAG(error_count) OVER (ORDER BY week_start), 0) * 100,
        1
    ) AS wow_errors_pct_change
FROM weekly_stats
ORDER BY week_start;
