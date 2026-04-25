-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- File: 04_advanced_queries.sql
-- Purpose: Advanced SQL - JOINs, subqueries, aggregations, window functions
-- =====================================================================

USE nonprofit_db;

-- =====================================================================
-- INNER JOIN QUERIES
-- =====================================================================

-- Q5.1 List every donation with full donor and campaign details (INNER JOIN)
SELECT t.transaction_id,
       CONCAT(c.first_name,' ',c.last_name) AS donor,
       c.donor_type,
       cm.name AS campaign,
       cm.type AS campaign_type,
       t.donation_amount,
       t.donation_date
FROM transactions t
INNER JOIN constituents c ON t.constituent_id = c.constituent_id
INNER JOIN campaigns cm   ON t.campaign_id    = cm.campaign_id
ORDER BY t.donation_date DESC;

-- Q5.2 Three-table INNER JOIN: pledges with donor and campaign info
SELECT p.pledge_id,
       CONCAT(c.first_name,' ',c.last_name) AS donor,
       cm.name AS campaign,
       p.pledge_amount,
       p.pledge_status,
       p.due_date
FROM pledges p
INNER JOIN constituents c ON p.constituent_id = c.constituent_id
INNER JOIN campaigns cm   ON p.campaign_id    = cm.campaign_id
ORDER BY p.pledge_amount DESC;

-- =====================================================================
-- LEFT JOIN QUERIES
-- =====================================================================

-- Q6.1 Find donors who have NEVER made a donation (LEFT JOIN with NULL check)
SELECT c.constituent_id,
       CONCAT(c.first_name,' ',c.last_name) AS donor,
       c.email,
       c.donor_type
FROM constituents c
LEFT JOIN transactions t ON c.constituent_id = t.constituent_id
WHERE t.transaction_id IS NULL;

-- Q6.2 Show every campaign and its total raised (campaigns with $0 still show)
SELECT cm.campaign_id,
       cm.name,
       cm.goal_amount,
       IFNULL(SUM(t.donation_amount), 0) AS total_raised,
       cm.goal_amount - IFNULL(SUM(t.donation_amount), 0) AS amount_remaining
FROM campaigns cm
LEFT JOIN transactions t ON cm.campaign_id = t.campaign_id
GROUP BY cm.campaign_id, cm.name, cm.goal_amount
ORDER BY total_raised DESC;

-- Q6.3 List all pledges and show payment progress (pledges with no payments still appear)
SELECT p.pledge_id,
       CONCAT(c.first_name,' ',c.last_name) AS donor,
       p.pledge_amount,
       IFNULL(SUM(pp.payment_amount), 0) AS total_paid,
       p.pledge_amount - IFNULL(SUM(pp.payment_amount), 0) AS balance,
       p.pledge_status
FROM pledges p
JOIN constituents c ON p.constituent_id = c.constituent_id
LEFT JOIN pledge_payments pp ON p.pledge_id = pp.pledge_id
GROUP BY p.pledge_id, c.first_name, c.last_name, p.pledge_amount, p.pledge_status
ORDER BY balance DESC;

-- =====================================================================
-- AGGREGATE FUNCTIONS (SUM, COUNT, AVG, MIN, MAX)
-- =====================================================================

-- Q7.1 Total donations and average gift size by year
SELECT YEAR(donation_date) AS giving_year,
       COUNT(*) AS gift_count,
       SUM(donation_amount) AS total_raised,
       AVG(donation_amount) AS avg_gift,
       MAX(donation_amount) AS largest_gift,
       MIN(donation_amount) AS smallest_gift
FROM transactions
GROUP BY YEAR(donation_date)
ORDER BY giving_year DESC;

-- Q7.2 Donor count and average gift by donor type
SELECT c.donor_type,
       COUNT(DISTINCT c.constituent_id) AS donor_count,
       COUNT(t.transaction_id) AS gift_count,
       SUM(t.donation_amount) AS total_given,
       AVG(t.donation_amount) AS avg_gift
FROM constituents c
LEFT JOIN transactions t ON c.constituent_id = t.constituent_id
GROUP BY c.donor_type
ORDER BY total_given DESC;

-- Q7.3 Campaign performance summary with goal achievement percentage
SELECT cm.name,
       cm.type,
       cm.goal_amount,
       IFNULL(SUM(t.donation_amount), 0) AS raised,
       ROUND(IFNULL(SUM(t.donation_amount), 0) / cm.goal_amount * 100, 2) AS pct_of_goal,
       COUNT(DISTINCT t.constituent_id) AS unique_donors
FROM campaigns cm
LEFT JOIN transactions t ON cm.campaign_id = t.campaign_id
GROUP BY cm.campaign_id, cm.name, cm.type, cm.goal_amount
ORDER BY pct_of_goal DESC;

-- =====================================================================
-- SUBQUERIES
-- =====================================================================

-- Q8.1 Find donors who gave more than the average gift size
SELECT DISTINCT CONCAT(c.first_name,' ',c.last_name) AS donor,
       c.donor_type
FROM constituents c
JOIN transactions t ON c.constituent_id = t.constituent_id
WHERE t.donation_amount > (SELECT AVG(donation_amount) FROM transactions)
ORDER BY donor;

-- Q8.2 Identify the top 5 donors by lifetime giving (correlated subquery)
SELECT CONCAT(c.first_name,' ',c.last_name) AS donor,
       c.donor_type,
       (SELECT SUM(donation_amount)
        FROM transactions
        WHERE constituent_id = c.constituent_id) AS total_given
FROM constituents c
WHERE (SELECT SUM(donation_amount)
       FROM transactions
       WHERE constituent_id = c.constituent_id) IS NOT NULL
ORDER BY total_given DESC
LIMIT 5;

-- Q8.3 Find campaigns that exceeded their goal
SELECT name, goal_amount, total_raised
FROM (
    SELECT cm.name,
           cm.goal_amount,
           IFNULL(SUM(t.donation_amount), 0) AS total_raised
    FROM campaigns cm
    LEFT JOIN transactions t ON cm.campaign_id = t.campaign_id
    GROUP BY cm.campaign_id, cm.name, cm.goal_amount
) AS campaign_totals
WHERE total_raised > goal_amount;

-- Q8.4 Find donors whose lifetime giving exceeds $10,000 (NOT IN / IN subquery)
SELECT first_name, last_name, email
FROM constituents
WHERE constituent_id IN (
    SELECT constituent_id
    FROM donor_metrics
    WHERE lifetime_giving > 10000
);

-- Q8.5 Identify lapsed major donors (gave in 2024 but not 2025)
SELECT CONCAT(c.first_name,' ',c.last_name) AS donor,
       dm.giving_2024,
       dm.giving_2025,
       dm.lifetime_giving
FROM constituents c
JOIN donor_metrics dm ON c.constituent_id = dm.constituent_id
WHERE dm.giving_2024 > 1000
  AND dm.giving_2025 = 0
ORDER BY dm.giving_2024 DESC;

-- =====================================================================
-- COMBINED ADVANCED QUERIES
-- =====================================================================

-- Q9.1 Year-over-year growth analysis with multiple aggregations
SELECT 'Total YoY Comparison' AS metric,
       SUM(giving_2021) AS Y2021,
       SUM(giving_2022) AS Y2022,
       SUM(giving_2023) AS Y2023,
       SUM(giving_2024) AS Y2024,
       SUM(giving_2025) AS Y2025,
       ROUND((SUM(giving_2025) - SUM(giving_2024)) / NULLIF(SUM(giving_2024),0) * 100, 2) AS pct_change_2024_2025
FROM donor_metrics;

-- Q9.2 Top campaigns by both dollars raised AND donor count (combined ranking)
SELECT cm.name,
       cm.type,
       COUNT(DISTINCT t.constituent_id) AS unique_donors,
       SUM(t.donation_amount) AS total_raised,
       AVG(t.donation_amount) AS avg_gift
FROM campaigns cm
JOIN transactions t ON cm.campaign_id = t.campaign_id
GROUP BY cm.campaign_id, cm.name, cm.type
HAVING COUNT(DISTINCT t.constituent_id) >= 2
ORDER BY total_raised DESC, unique_donors DESC;

-- Q9.3 Donor segmentation: count of donors at each level with average gift
SELECT donor_level,
       retention_status,
       COUNT(*) AS donor_count,
       AVG(lifetime_giving) AS avg_lifetime_giving,
       SUM(lifetime_giving) AS segment_total
FROM donor_metrics
GROUP BY donor_level, retention_status
ORDER BY FIELD(donor_level,'Platinum','Gold','Silver','Bronze'),
         retention_status;
