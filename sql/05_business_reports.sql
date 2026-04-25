-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- File: 05_business_reports.sql
-- Purpose: Production-ready business analytics queries
-- These are the queries that actually drive nonprofit decisions
-- =====================================================================

USE nonprofit_db;

-- =====================================================================
-- REPORT 1: CAMPAIGN PERFORMANCE DASHBOARD
-- Used by: Development Director, Executive Director, Board
-- =====================================================================
SELECT
    cm.name AS campaign,
    cm.type,
    cm.start_date,
    cm.end_date,
    cm.goal_amount,
    IFNULL(SUM(t.donation_amount), 0) AS raised,
    cm.goal_amount - IFNULL(SUM(t.donation_amount), 0) AS gap_to_goal,
    ROUND(IFNULL(SUM(t.donation_amount), 0) / cm.goal_amount * 100, 1) AS pct_complete,
    COUNT(DISTINCT t.constituent_id) AS unique_donors,
    COUNT(t.transaction_id) AS gift_count,
    ROUND(AVG(t.donation_amount), 2) AS avg_gift,
    CASE
        WHEN IFNULL(SUM(t.donation_amount),0) >= cm.goal_amount THEN 'Goal Met'
        WHEN cm.end_date < CURRENT_DATE THEN 'Closed - Below Goal'
        WHEN IFNULL(SUM(t.donation_amount),0) >= cm.goal_amount * 0.75 THEN 'On Track'
        ELSE 'Needs Attention'
    END AS status_flag
FROM campaigns cm
LEFT JOIN transactions t ON cm.campaign_id = t.campaign_id
GROUP BY cm.campaign_id, cm.name, cm.type, cm.start_date, cm.end_date, cm.goal_amount
ORDER BY pct_complete DESC;

-- =====================================================================
-- REPORT 2: TOP DONOR LEADERBOARD (LIFETIME GIVING)
-- Used by: Major Gifts Officer, Stewardship Team
-- =====================================================================
SELECT
    RANK() OVER (ORDER BY dm.lifetime_giving DESC) AS rank_position,
    CONCAT(c.first_name, ' ', c.last_name) AS donor,
    c.donor_type,
    c.city,
    c.state,
    dm.donor_level,
    dm.retention_status,
    dm.lifetime_giving,
    dm.average_gift,
    dm.largest_gift,
    dm.giving_2025 AS this_year
FROM constituents c
JOIN donor_metrics dm ON c.constituent_id = dm.constituent_id
ORDER BY dm.lifetime_giving DESC
LIMIT 25;

-- =====================================================================
-- REPORT 3: YEAR-OVER-YEAR GIVING TRENDS (2021-2025)
-- Used by: Development Director, Board Reports
-- =====================================================================
SELECT
    'Total Donors Active'   AS metric,
    SUM(CASE WHEN giving_2021 > 0 THEN 1 ELSE 0 END) AS Y2021,
    SUM(CASE WHEN giving_2022 > 0 THEN 1 ELSE 0 END) AS Y2022,
    SUM(CASE WHEN giving_2023 > 0 THEN 1 ELSE 0 END) AS Y2023,
    SUM(CASE WHEN giving_2024 > 0 THEN 1 ELSE 0 END) AS Y2024,
    SUM(CASE WHEN giving_2025 > 0 THEN 1 ELSE 0 END) AS Y2025
FROM donor_metrics
UNION ALL
SELECT 'Total Dollars Raised',
    SUM(giving_2021), SUM(giving_2022), SUM(giving_2023),
    SUM(giving_2024), SUM(giving_2025)
FROM donor_metrics
UNION ALL
SELECT 'Average Gift Per Active Donor',
    ROUND(SUM(giving_2021) / NULLIF(SUM(CASE WHEN giving_2021 > 0 THEN 1 ELSE 0 END),0), 2),
    ROUND(SUM(giving_2022) / NULLIF(SUM(CASE WHEN giving_2022 > 0 THEN 1 ELSE 0 END),0), 2),
    ROUND(SUM(giving_2023) / NULLIF(SUM(CASE WHEN giving_2023 > 0 THEN 1 ELSE 0 END),0), 2),
    ROUND(SUM(giving_2024) / NULLIF(SUM(CASE WHEN giving_2024 > 0 THEN 1 ELSE 0 END),0), 2),
    ROUND(SUM(giving_2025) / NULLIF(SUM(CASE WHEN giving_2025 > 0 THEN 1 ELSE 0 END),0), 2)
FROM donor_metrics;

-- =====================================================================
-- REPORT 4: LAPSED DONOR RECOVERY LIST
-- Used by: Annual Giving Team for re-engagement campaigns
-- =====================================================================
SELECT
    c.constituent_id,
    CONCAT(c.first_name, ' ', c.last_name) AS donor,
    c.email,
    c.phone,
    c.city,
    c.state,
    dm.lifetime_giving,
    dm.giving_2023,
    dm.giving_2024,
    dm.giving_2025,
    dm.retention_status,
    DATEDIFF(CURRENT_DATE, MAX(t.donation_date)) AS days_since_last_gift,
    MAX(t.donation_date) AS last_gift_date
FROM constituents c
JOIN donor_metrics dm ON c.constituent_id = dm.constituent_id
LEFT JOIN transactions t ON c.constituent_id = t.constituent_id
WHERE dm.giving_2024 > 0
  AND dm.giving_2025 = 0
GROUP BY c.constituent_id, c.first_name, c.last_name, c.email, c.phone,
         c.city, c.state, dm.lifetime_giving, dm.giving_2023, dm.giving_2024,
         dm.giving_2025, dm.retention_status
ORDER BY dm.lifetime_giving DESC;

-- =====================================================================
-- REPORT 5: OUTSTANDING PLEDGE BALANCES
-- Used by: Finance, Major Gifts Officer for pledge fulfillment tracking
-- =====================================================================
SELECT
    p.pledge_id,
    CONCAT(c.first_name, ' ', c.last_name) AS donor,
    c.email,
    cm.name AS campaign,
    p.pledge_amount,
    IFNULL(SUM(pp.payment_amount), 0) AS total_paid,
    p.pledge_amount - IFNULL(SUM(pp.payment_amount), 0) AS outstanding_balance,
    ROUND(IFNULL(SUM(pp.payment_amount), 0) / p.pledge_amount * 100, 1) AS pct_paid,
    p.pledge_date,
    p.due_date,
    DATEDIFF(p.due_date, CURRENT_DATE) AS days_until_due,
    CASE
        WHEN p.pledge_status = 'Fulfilled' THEN 'Complete'
        WHEN p.due_date < CURRENT_DATE THEN 'OVERDUE'
        WHEN DATEDIFF(p.due_date, CURRENT_DATE) <= 30 THEN 'Due Soon'
        ELSE 'On Schedule'
    END AS status
FROM pledges p
JOIN constituents c ON p.constituent_id = c.constituent_id
JOIN campaigns cm   ON p.campaign_id    = cm.campaign_id
LEFT JOIN pledge_payments pp ON p.pledge_id = pp.pledge_id
GROUP BY p.pledge_id, c.first_name, c.last_name, c.email, cm.name,
         p.pledge_amount, p.pledge_date, p.due_date, p.pledge_status
HAVING outstanding_balance > 0
ORDER BY p.due_date;

-- =====================================================================
-- REPORT 6: GEOGRAPHIC GIVING ANALYSIS
-- Used by: Marketing, Regional Development
-- =====================================================================
SELECT
    c.state,
    COUNT(DISTINCT c.constituent_id) AS donor_count,
    COUNT(t.transaction_id) AS gift_count,
    SUM(t.donation_amount) AS total_raised,
    ROUND(AVG(t.donation_amount), 2) AS avg_gift,
    MAX(t.donation_amount) AS largest_gift
FROM constituents c
LEFT JOIN transactions t ON c.constituent_id = t.constituent_id
WHERE c.state IS NOT NULL
GROUP BY c.state
ORDER BY total_raised DESC;

-- =====================================================================
-- REPORT 7: DONOR ACQUISITION VS. RETENTION
-- Used by: Strategic Planning
-- =====================================================================
SELECT
    retention_status,
    COUNT(*) AS donor_count,
    SUM(lifetime_giving) AS total_lifetime_value,
    AVG(lifetime_giving) AS avg_lifetime_value,
    SUM(giving_2025) AS current_year_giving
FROM donor_metrics
GROUP BY retention_status
ORDER BY donor_count DESC;

-- =====================================================================
-- REPORT 8: PAYMENT METHOD ANALYSIS
-- Used by: Finance, Operations
-- =====================================================================
SELECT
    payment_method,
    COUNT(*) AS gift_count,
    SUM(donation_amount) AS total_processed,
    ROUND(AVG(donation_amount), 2) AS avg_gift,
    ROUND(SUM(donation_amount) / (SELECT SUM(donation_amount) FROM transactions) * 100, 2) AS pct_of_total
FROM transactions
GROUP BY payment_method
ORDER BY total_processed DESC;
