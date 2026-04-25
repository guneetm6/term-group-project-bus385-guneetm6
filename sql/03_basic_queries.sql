-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- File: 03_basic_queries.sql
-- Purpose: Core CRUD operations - SELECT, INSERT, UPDATE, DELETE
-- =====================================================================

USE nonprofit_db;

-- =====================================================================
-- SELECT QUERIES (Data Retrieval)
-- =====================================================================

-- Q1.1 Retrieve all donors sorted by last name
SELECT constituent_id, first_name, last_name, email, city, state, donor_type
FROM constituents
ORDER BY last_name, first_name;

-- Q1.2 Find donors located in a specific state
SELECT first_name, last_name, email, city, donor_type
FROM constituents
WHERE state = 'NY'
ORDER BY last_name;

-- Q1.3 List all active campaigns within current date range
SELECT campaign_id, name, type, goal_amount, start_date, end_date
FROM campaigns
WHERE CURRENT_DATE BETWEEN start_date AND end_date
ORDER BY end_date;

-- Q1.4 Display recent donations (last 90 days)
SELECT t.transaction_id, t.donation_date, t.donation_amount, t.payment_method,
       CONCAT(c.first_name,' ',c.last_name) AS donor_name,
       cm.name AS campaign_name
FROM transactions t
JOIN constituents c ON t.constituent_id = c.constituent_id
JOIN campaigns cm   ON t.campaign_id    = cm.campaign_id
WHERE t.donation_date >= DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)
ORDER BY t.donation_date DESC;

-- Q1.5 Show all open pledges with outstanding balances
SELECT p.pledge_id,
       CONCAT(c.first_name,' ',c.last_name) AS donor,
       p.pledge_amount,
       p.due_date,
       p.pledge_status,
       cm.name AS campaign
FROM pledges p
JOIN constituents c ON p.constituent_id = c.constituent_id
JOIN campaigns cm   ON p.campaign_id    = cm.campaign_id
WHERE p.pledge_status = 'Open'
ORDER BY p.due_date;

-- =====================================================================
-- INSERT QUERIES (Data Entry)
-- =====================================================================

-- Q2.1 Add a new individual donor
INSERT INTO constituents (first_name, last_name, email, phone, address, city, state, donor_type)
VALUES ('Maria','Sanchez','maria.s@email.com','555-0112','111 Sunset Blvd','Los Angeles','CA','Individual');

-- Q2.2 Record a new donation transaction
INSERT INTO transactions (constituent_id, campaign_id, donation_amount, donation_date, payment_method)
VALUES (LAST_INSERT_ID(), 1, 500.00, CURRENT_DATE, 'Credit Card');

-- Q2.3 Create a new pledge
INSERT INTO pledges (constituent_id, campaign_id, pledge_amount, pledge_date, due_date, pledge_status)
VALUES (1, 2, 5000.00, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 1 YEAR), 'Open');

-- Q2.4 Log a payment against a pledge
INSERT INTO pledge_payments (pledge_id, constituent_id, payment_amount, payment_date, outstanding_balance)
VALUES (1, 4, 25000.00, CURRENT_DATE, 25000.00);

-- Q2.5 Add a new fundraising campaign
INSERT INTO campaigns (name, type, goal_amount, start_date, end_date, description)
VALUES ('Holiday Appeal 2025','Annual Fund', 100000.00, '2025-11-01','2025-12-31','Holiday season giving campaign');

-- =====================================================================
-- UPDATE QUERIES (Data Modification)
-- =====================================================================

-- Q3.1 Update donor contact information
UPDATE constituents
SET email = 'sarah.johnson.new@email.com',
    phone = '555-9999'
WHERE constituent_id = 1;

-- Q3.2 Mark a pledge as Fulfilled when fully paid
UPDATE pledges
SET pledge_status = 'Fulfilled'
WHERE pledge_id IN (
    SELECT pledge_id FROM (
        SELECT p.pledge_id
        FROM pledges p
        LEFT JOIN pledge_payments pp ON p.pledge_id = pp.pledge_id
        GROUP BY p.pledge_id, p.pledge_amount
        HAVING IFNULL(SUM(pp.payment_amount),0) >= MAX(p.pledge_amount)
    ) AS sub
);

-- Q3.3 Flag pledges as Overdue if past due date and still Open
UPDATE pledges
SET pledge_status = 'Overdue'
WHERE due_date < CURRENT_DATE
  AND pledge_status = 'Open';

-- Q3.4 Promote donor level based on lifetime giving thresholds
UPDATE donor_metrics
SET donor_level = CASE
    WHEN lifetime_giving >= 50000 THEN 'Platinum'
    WHEN lifetime_giving >= 10000 THEN 'Gold'
    WHEN lifetime_giving >= 1000  THEN 'Silver'
    ELSE 'Bronze'
END;

-- Q3.5 Update retention_status to Lapsed for donors inactive in 2025
UPDATE donor_metrics
SET retention_status = 'Lapsed'
WHERE giving_2025 = 0
  AND giving_2024 > 0;

-- =====================================================================
-- DELETE QUERIES (Data Removal)
-- =====================================================================

-- Q4.1 Remove duplicate donor records (keeping the lowest ID)
-- (Demonstration - only deletes if duplicates exist)
DELETE c1 FROM constituents c1
INNER JOIN constituents c2
WHERE c1.constituent_id > c2.constituent_id
  AND c1.email = c2.email
  AND c1.email IS NOT NULL;

-- Q4.2 Remove cancelled pledges older than 1 year
DELETE FROM pledges
WHERE pledge_status = 'Cancelled'
  AND pledge_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR);

-- Q4.3 Remove a test transaction (example - inserted for demo cleanup)
DELETE FROM transactions
WHERE donation_amount = 0;

-- Q4.4 Remove campaigns that ended over 5 years ago and have no transactions
DELETE FROM campaigns
WHERE end_date < DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR)
  AND campaign_id NOT IN (SELECT DISTINCT campaign_id FROM transactions);
