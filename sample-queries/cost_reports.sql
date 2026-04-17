-- ============================================================
-- Cost & Usage Report Queries for Athena
-- Database: cost_db | Table: customer_all
-- ============================================================
-- These queries are used by dashboards and reporting tools.
-- The query-review-agent validates them against live Athena
-- on every PR and suggests optimizations.
-- ============================================================


-- ------------------------------------------------------------
-- Q1: Top 10 services by spend (current month)
-- PURPOSE: Executive summary of where money is going
-- ------------------------------------------------------------
SELECT *
FROM cost_db.customer_all
WHERE line_item_line_item_type = 'Usage'
ORDER BY line_item_unblended_cost DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q2: Daily spend trend by service
-- PURPOSE: Spot cost spikes day over day
-- ------------------------------------------------------------
SELECT
  date_format(line_item_usage_start_date, '%Y-%m-%d') as usage_date,
  product_servicecode,
  sum(line_item_unblended_cost) as daily_cost
FROM cost_db.customer_all
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;


-- ------------------------------------------------------------
-- Q3: Cost by region
-- PURPOSE: Understand geographic distribution of spend
-- ------------------------------------------------------------
SELECT product_region_code,
       product_servicecode,
       round(sum(line_item_unblended_cost), 2) as total_cost,
       count(*) as line_items
FROM cost_db.customer_all c, demo_db.events e
WHERE c.line_item_line_item_type = 'Usage'
  AND c.line_item_unblended_cost > 0
  AND e.partition_date = '2026-04-13'
GROUP BY product_region_code, product_servicecode
ORDER BY total_cost DESC
LIMIT 20;


-- ------------------------------------------------------------
-- Q4: EC2 instance type breakdown
-- PURPOSE: Right-sizing analysis — find over-provisioned instances
-- ------------------------------------------------------------
SELECT *
FROM cost_db.customer_all
WHERE product_servicecode = 'AmazonEC2'
  AND product_instance_type != ''
  AND line_item_line_item_type = 'Usage';


-- ------------------------------------------------------------
-- Q5: Month-over-month cost comparison
-- PURPOSE: Compare current month vs previous month by service
-- ------------------------------------------------------------
SELECT
  billing_period,
  product_servicecode,
  round(sum(line_item_unblended_cost), 2) as total_cost,
  round(sum(line_item_usage_amount), 2) as total_usage
FROM cost_db.customer_all
WHERE billing_period IN ('2026-03', '2026-04')
  AND line_item_line_item_type = 'Usage'
GROUP BY billing_period, product_servicecode
ORDER BY product_servicecode, billing_period;


-- ------------------------------------------------------------
-- Q6: Untagged resources (cost governance)
-- PURPOSE: Find resources missing required tags
-- ------------------------------------------------------------
SELECT
  product_servicecode,
  line_item_resource_id,
  round(sum(line_item_unblended_cost), 2) as total_cost
FROM cost_db.customer_all
WHERE billing_period = '2026-04'
  AND line_item_line_item_type = 'Usage'
  AND line_item_resource_id != ''
  AND cardinality(resource_tags) = 0
GROUP BY product_servicecode, line_item_resource_id
ORDER BY total_cost DESC
LIMIT 25;


-- ------------------------------------------------------------
-- Q7: Data transfer costs
-- PURPOSE: Network egress is often a hidden cost driver
-- ------------------------------------------------------------
SELECT
  product_servicecode,
  product_usagetype,
  product_from_region_code,
  product_to_region_code,
  round(sum(line_item_unblended_cost), 2) as transfer_cost,
  round(sum(line_item_usage_amount), 2) as gb_transferred
FROM cost_db.customer_all
WHERE billing_period = '2026-04'
  AND line_item_line_item_type = 'Usage'
  AND product_usagetype LIKE '%DataTransfer%'
GROUP BY 1, 2, 3, 4
ORDER BY transfer_cost DESC
LIMIT 20;


-- ------------------------------------------------------------
-- Q8: EKS cost breakdown (top spender)
-- PURPOSE: EKS is the #1 cost driver — break down by usage type
-- NOTE: Missing partition filter, uses SELECT *
-- ------------------------------------------------------------
SELECT *
FROM cost_db.customer_all
WHERE product_servicecode = 'AmazonEKS'
  AND line_item_line_item_type = 'Usage'
ORDER BY line_item_unblended_cost DESC;
