-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- File: 02_data_load.sql
-- Purpose: Load sample data into the database for testing and demo
-- 
-- Note: For production runs against the full Kaggle Mock Nonprofit
-- Fundraising dataset, use LOAD DATA INFILE with the source CSVs:
--   constituents.csv, campaigns.csv, transactions.csv,
--   pledges.csv, pledge_payments.csv, donor_metrics.csv
-- This file provides demo data for manual testing of all queries.
-- =====================================================================

USE nonprofit_db;

-- ---------- CONSTITUENTS ----------
INSERT INTO constituents (first_name, last_name, email, phone, address, city, state, donor_type) VALUES
('Sarah','Johnson','sarah.j@email.com','555-0101','123 Oak St','Boston','MA','Individual'),
('Michael','Chen','m.chen@email.com','555-0102','456 Pine Ave','Seattle','WA','Individual'),
('Emily','Rodriguez','e.rod@email.com','555-0103','789 Elm Rd','Austin','TX','Individual'),
('Greenfield','Foundation','contact@greenfield.org','555-0201','100 Charity Blvd','New York','NY','Foundation'),
('David','Williams','d.will@email.com','555-0104','321 Maple Dr','Chicago','IL','Individual'),
('Acme','Corporation','giving@acme.com','555-0301','555 Corporate Way','Atlanta','GA','Organization'),
('Lisa','Thompson','l.thomp@email.com','555-0105','987 Birch Ln','Denver','CO','Individual'),
('Robert','Anderson','r.and@email.com','555-0106','246 Cedar St','Miami','FL','Individual'),
('Jennifer','Martinez','j.mart@email.com','555-0107','135 Spruce Ave','Phoenix','AZ','Individual'),
('Westfield','Family Trust','trust@westfield.org','555-0202','999 Trust Ct','Boston','MA','Foundation'),
('Christopher','Lee','c.lee@email.com','555-0108','468 Walnut Rd','Portland','OR','Individual'),
('Amanda','Garcia','a.garcia@email.com','555-0109','579 Aspen Way','San Diego','CA','Individual'),
('TechFlow','Industries','community@techflow.com','555-0302','777 Innovation Dr','San Jose','CA','Organization'),
('Patricia','Wilson','p.wilson@email.com','555-0110','864 Magnolia St','Nashville','TN','Individual'),
('James','Brown','j.brown@email.com','555-0111','753 Sycamore Ave','Charlotte','NC','Individual');

-- ---------- CAMPAIGNS ----------
INSERT INTO campaigns (name, type, goal_amount, start_date, end_date, description) VALUES
('Annual Fund 2025','Annual Fund', 250000.00, '2025-01-01','2025-12-31','General operating support'),
('Capital Campaign 2025','Capital', 1000000.00, '2025-03-01','2026-02-28','New community center building'),
('Spring Gala 2025','Major Gift', 150000.00, '2025-04-01','2025-05-31','Annual fundraising gala'),
('Year-End Appeal 2024','Annual Fund', 200000.00, '2024-11-01','2024-12-31','Year-end giving push'),
('Education Initiative','Programs', 75000.00, '2025-06-01','2025-08-31','Scholarship program'),
('Community Outreach 2025','Programs', 50000.00, '2025-02-01','2025-11-30','Local community programs'),
('Giving Tuesday 2024','Annual Fund', 30000.00, '2024-12-03','2024-12-03','Single-day giving event'),
('Annual Fund 2024','Annual Fund', 220000.00, '2024-01-01','2024-12-31','General operating support'),
('Capital Campaign Phase 1','Capital', 500000.00, '2024-01-01','2024-12-31','Initial building phase');

-- ---------- TRANSACTIONS ----------
INSERT INTO transactions (constituent_id, campaign_id, donation_amount, donation_date, payment_method) VALUES
(1, 1, 500.00, '2025-01-15','Credit Card'),
(1, 3, 1000.00, '2025-04-20','Online'),
(2, 1, 250.00, '2025-02-10','Online'),
(2, 5, 500.00, '2025-06-15','Check'),
(3, 6, 100.00, '2025-03-01','Online'),
(4, 2, 50000.00, '2025-03-15','Check'),
(4, 1, 5000.00, '2025-01-20','Check'),
(5, 1, 750.00, '2025-05-12','Credit Card'),
(5, 3, 2500.00, '2025-04-25','Credit Card'),
(6, 2, 25000.00, '2025-04-10','Check'),
(7, 1, 150.00, '2025-07-08','Online'),
(7, 4, 200.00, '2024-12-15','Online'),
(8, 5, 1000.00, '2025-07-20','Credit Card'),
(9, 6, 75.00, '2025-05-30','Online'),
(10, 2, 100000.00, '2025-04-01','Wire Transfer'),
(11, 1, 300.00, '2025-08-14','Online'),
(12, 3, 1500.00, '2025-04-30','Credit Card'),
(13, 2, 15000.00, '2025-05-22','Wire Transfer'),
(14, 7, 500.00, '2024-12-03','Online'),
(15, 8, 250.00, '2024-06-15','Online'),
(1, 8, 400.00, '2024-03-10','Credit Card'),
(2, 8, 200.00, '2024-09-22','Online'),
(4, 9, 35000.00, '2024-08-15','Check');

-- ---------- PLEDGES ----------
INSERT INTO pledges (constituent_id, campaign_id, pledge_amount, pledge_date, due_date, pledge_status) VALUES
(4, 2, 100000.00, '2025-03-01','2026-02-28','Open'),
(6, 2, 50000.00, '2025-04-01','2026-03-31','Open'),
(10, 2, 200000.00, '2025-04-01','2027-03-31','Open'),
(13, 2, 30000.00, '2025-05-01','2026-04-30','Open'),
(1, 3, 5000.00, '2025-04-15','2025-12-31','Fulfilled'),
(5, 1, 3000.00, '2025-01-10','2025-12-31','Open'),
(8, 5, 10000.00, '2025-06-01','2026-05-31','Open'),
(12, 3, 7500.00, '2025-04-20','2025-10-20','Open'),
(2, 1, 2000.00, '2024-06-01','2024-12-31','Overdue');

-- ---------- PLEDGE_PAYMENTS ----------
INSERT INTO pledge_payments (pledge_id, constituent_id, payment_amount, payment_date, outstanding_balance) VALUES
(1, 4, 50000.00, '2025-03-15', 50000.00),
(2, 6, 25000.00, '2025-04-10', 25000.00),
(3, 10, 100000.00, '2025-04-01', 100000.00),
(4, 13, 15000.00, '2025-05-22', 15000.00),
(5, 1, 5000.00, '2025-04-20', 0.00),
(6, 5, 1500.00, '2025-05-12', 1500.00),
(7, 8, 5000.00, '2025-07-15', 5000.00),
(8, 12, 3500.00, '2025-04-30', 4000.00);

-- ---------- DONOR_METRICS ----------
INSERT INTO donor_metrics (constituent_id, lifetime_giving, average_gift, largest_gift, donor_level, retention_status, giving_2021, giving_2022, giving_2023, giving_2024, giving_2025) VALUES
(1, 1900.00, 475.00, 1000.00, 'Silver', 'Active', 200.00, 300.00, 500.00, 400.00, 1500.00),
(2, 950.00, 237.50, 500.00, 'Bronze', 'Active', 100.00, 150.00, 200.00, 200.00, 750.00),
(3, 100.00, 100.00, 100.00, 'Bronze', 'New', 0.00, 0.00, 0.00, 0.00, 100.00),
(4, 90000.00, 30000.00, 50000.00, 'Platinum', 'Active', 5000.00, 10000.00, 15000.00, 35000.00, 55000.00),
(5, 3250.00, 1083.33, 2500.00, 'Silver', 'Active', 250.00, 500.00, 0.00, 750.00, 3250.00),
(6, 25000.00, 25000.00, 25000.00, 'Platinum', 'New', 0.00, 0.00, 0.00, 0.00, 25000.00),
(7, 350.00, 175.00, 200.00, 'Bronze', 'Active', 50.00, 75.00, 100.00, 200.00, 150.00),
(8, 1000.00, 1000.00, 1000.00, 'Silver', 'New', 0.00, 0.00, 0.00, 0.00, 1000.00),
(9, 75.00, 75.00, 75.00, 'Bronze', 'New', 0.00, 0.00, 0.00, 0.00, 75.00),
(10, 100000.00, 100000.00, 100000.00, 'Platinum', 'New', 0.00, 0.00, 0.00, 0.00, 100000.00),
(11, 300.00, 300.00, 300.00, 'Bronze', 'New', 0.00, 0.00, 0.00, 0.00, 300.00),
(12, 1500.00, 1500.00, 1500.00, 'Silver', 'New', 0.00, 0.00, 0.00, 0.00, 1500.00),
(13, 15000.00, 15000.00, 15000.00, 'Gold', 'New', 0.00, 0.00, 0.00, 0.00, 15000.00),
(14, 500.00, 500.00, 500.00, 'Bronze', 'Active', 100.00, 200.00, 300.00, 500.00, 0.00),
(15, 250.00, 250.00, 250.00, 'Bronze', 'Lapsed', 200.00, 300.00, 400.00, 250.00, 0.00);

-- ---------- VERIFY DATA LOAD ----------
SELECT 'constituents' AS table_name, COUNT(*) AS row_count FROM constituents
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'pledges', COUNT(*) FROM pledges
UNION ALL SELECT 'pledge_payments', COUNT(*) FROM pledge_payments
UNION ALL SELECT 'donor_metrics', COUNT(*) FROM donor_metrics;
