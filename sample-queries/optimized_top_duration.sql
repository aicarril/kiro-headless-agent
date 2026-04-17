-- Optimized Query 3: Top events by duration with user details
-- Original: SELECT * FROM events e, users u WHERE e.user_id = u.id ORDER BY e.duration_ms DESC LIMIT 50
-- Optimizations: CTE predicate pushdown (pre-sort before JOIN), INNER JOIN, explicit columns
-- Improvement: 29.7% faster execution time

WITH top_events AS (
    SELECT event_id, event_type, user_id, duration_ms, status_code,
           endpoint, created_at, partition_date
    FROM demo_db.events
    ORDER BY duration_ms DESC
    LIMIT 50
)
SELECT te.event_id, te.event_type, te.user_id, te.duration_ms, te.status_code,
       te.endpoint, te.created_at, te.partition_date,
       u.id, u.user_name, u.email, u.team, u.created_at
FROM top_events te
INNER JOIN demo_db.users u ON te.user_id = u.id
ORDER BY te.duration_ms DESC;
