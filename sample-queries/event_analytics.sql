-- ============================================================
-- Event Analytics Queries for Athena
-- Database: demo_db | Tables: events, users
-- ============================================================
-- These queries power operational dashboards.
-- The query-review-agent validates them against live Athena
-- on every PR and suggests optimizations.
-- ============================================================


-- ------------------------------------------------------------
-- Q1: Slowest endpoints (P99 latency)
-- PURPOSE: Identify endpoints that need performance work
-- ------------------------------------------------------------
SELECT *
FROM demo_db.events e, demo_db.users u
WHERE e.user_id = u.id
ORDER BY e.duration_ms DESC
LIMIT 50;


-- ------------------------------------------------------------
-- Q2: Error rate by endpoint
-- PURPOSE: SLA monitoring — which endpoints are failing
-- ------------------------------------------------------------
SELECT
  endpoint,
  count(*) as total_requests,
  sum(CASE WHEN status_code >= 500 THEN 1 ELSE 0 END) as errors,
  round(100.0 * sum(CASE WHEN status_code >= 500 THEN 1 ELSE 0 END) / count(*), 2) as error_rate_pct
FROM demo_db.events
WHERE partition_date = '2026-04-13'
GROUP BY endpoint
ORDER BY error_rate_pct DESC;


-- ------------------------------------------------------------
-- Q3: Team activity summary
-- PURPOSE: Usage patterns across teams
-- ------------------------------------------------------------
SELECT
  u.team,
  count(*) as total_events,
  round(avg(e.duration_ms), 2) as avg_latency_ms,
  sum(CASE WHEN e.status_code >= 500 THEN 1 ELSE 0 END) as errors
FROM demo_db.events e
INNER JOIN demo_db.users u ON e.user_id = u.id
WHERE e.partition_date = '2026-04-13'
GROUP BY u.team
ORDER BY total_events DESC;


-- ------------------------------------------------------------
-- Q4: Hourly traffic pattern
-- PURPOSE: Capacity planning — when are peak hours
-- ------------------------------------------------------------
SELECT
  substr(created_at, 1, 13) as hour,
  event_type,
  count(*) as event_count,
  round(avg(duration_ms), 2) as avg_duration
FROM demo_db.events
WHERE partition_date = '2026-04-13'
GROUP BY substr(created_at, 1, 13), event_type
ORDER BY hour, event_count DESC;


-- ------------------------------------------------------------
-- Q5: Full cross-join report (intentionally bad)
-- PURPOSE: "Quick" dump for ad-hoc analysis
-- NOTE: This is a terrible query — no partition filter,
--       SELECT *, comma join. Perfect agent bait.
-- ------------------------------------------------------------
SELECT *
FROM demo_db.events, demo_db.users
ORDER BY events.created_at DESC
LIMIT 200;
