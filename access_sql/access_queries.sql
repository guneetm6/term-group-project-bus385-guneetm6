-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- File: access_queries.sql
-- Purpose: Microsoft Access SQL versions of key queries
-- 
-- IMPORTANT: Access SQL has key syntax differences from MySQL:
--   * Access requires parentheses around nested JOINs
--   * IIF() instead of IF()
--   * NZ() instead of IFNULL()
--   * & for string concatenation (not CONCAT)
--   * Date#date# format instead of 'date'
--   * No LIMIT - use TOP N
--   * No INTERVAL - use DateAdd()
-- =====================================================================

-- =====================================================================
-- BASIC SELECT (works in both Access and MySQL)
-- =====================================================================

-- AC1: All donors sorted by last name
SELECT constituent_id, first_name, last_name, email, city, state, donor_type
FROM constituents
ORDER BY last_name, first_name;

-- AC2: Donors in NY (works in both)
SELECT first_name, last_name, email, city
FROM constituents
WHERE state = 'NY'
ORDER BY last_name;

-- =====================================================================
-- ACCESS-SPECIFIC: NESTED JOINS REQUIRE PARENTHESES
-- =====================================================================

-- AC3: Three-table join (Access syntax with nested parentheses)
SELECT t.transaction_id,
       (c.first_name & ' ' & c.last_name) AS donor,
       cm.name AS campaign,
       t.donation_amount,
       t.donation_date
FROM (transactions AS t
      INNER JOIN constituents AS c ON t.constituent_id = c.constituent_id)
      INNER JOIN campaigns AS cm ON t.campaign_id = cm.campaign_id
ORDER BY t.donation_date DESC;

-- AC4: Four-table join (Access requires nested parentheses for multiple joins)
SELECT (c.first_name & ' ' & c.last_name) AS donor,
       cm.name AS campaign,
       p.pledge_amount,
       Nz(SUM(pp.payment_amount), 0) AS total_paid
FROM ((pledges AS p
       INNER JOIN constituents AS c ON p.constituent_id = c.constituent_id)
       INNER JOIN campaigns AS cm ON p.campaign_id = cm.campaign_id)
       LEFT JOIN pledge_payments AS pp ON p.pledge_id = pp.pledge_id
GROUP BY c.first_name, c.last_name, cm.name, p.pledge_amount;

-- =====================================================================
-- ACCESS DATE HANDLING
-- =====================================================================

-- AC5: Recent donations (Access uses DateAdd, not INTERVAL)
SELECT t.transaction_id, t.donation_date, t.donation_amount,
       (c.first_name & ' ' & c.last_name) AS donor
FROM transactions AS t
INNER JOIN constituents AS c ON t.constituent_id = c.constituent_id
WHERE t.donation_date >= DateAdd("d", -90, Date())
ORDER BY t.donation_date DESC;

-- AC6: This year's donations (Access syntax)
SELECT (c.first_name & ' ' & c.last_name) AS donor,
       SUM(t.donation_amount) AS total_2025
FROM transactions AS t
INNER JOIN constituents AS c ON t.constituent_id = c.constituent_id
WHERE Year(t.donation_date) = 2025
GROUP BY c.first_name, c.last_name
ORDER BY SUM(t.donation_amount) DESC;

-- =====================================================================
-- ACCESS TOP N (instead of MySQL LIMIT)
-- =====================================================================

-- AC7: Top 5 donors by lifetime giving
SELECT TOP 5
    (c.first_name & ' ' & c.last_name) AS donor,
    dm.lifetime_giving,
    dm.donor_level
FROM constituents AS c
INNER JOIN donor_metrics AS dm ON c.constituent_id = dm.constituent_id
ORDER BY dm.lifetime_giving DESC;

-- =====================================================================
-- ACCESS IIF AND NZ (CASE/IFNULL replacements)
-- =====================================================================

-- AC8: Campaign performance with status flag using IIf
SELECT cm.name,
       cm.goal_amount,
       Nz(SUM(t.donation_amount), 0) AS raised,
       IIf(Nz(SUM(t.donation_amount),0) >= cm.goal_amount, "Goal Met",
       IIf(Nz(SUM(t.donation_amount),0) >= cm.goal_amount * 0.75, "On Track",
       "Needs Attention")) AS status_flag
FROM campaigns AS cm
LEFT JOIN transactions AS t ON cm.campaign_id = t.campaign_id
GROUP BY cm.campaign_id, cm.name, cm.goal_amount;

-- =====================================================================
-- ACCESS UPDATE WITH IIF (CASE replacement)
-- =====================================================================

-- AC9: Update donor levels using IIf
UPDATE donor_metrics
SET donor_level = IIf(lifetime_giving >= 50000, "Platinum",
                  IIf(lifetime_giving >= 10000, "Gold",
                  IIf(lifetime_giving >= 1000, "Silver", "Bronze")));

-- =====================================================================
-- ACCESS-SPECIFIC INSERT
-- =====================================================================

-- AC10: Insert with Access date literal #date#
INSERT INTO constituents (first_name, last_name, email, city, state, donor_type)
VALUES ('Test','Donor','test@example.com','Boston','MA','Individual');

INSERT INTO transactions (constituent_id, campaign_id, donation_amount, donation_date, payment_method)
VALUES (1, 1, 100.00, #2025-04-25#, 'Online');
