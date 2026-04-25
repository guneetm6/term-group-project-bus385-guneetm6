-- =====================================================================
-- Non-Profit Donor & Campaign Management System
-- Course: BUS 385 - Business Data Management - Spring 2026
-- Group: Guneet Malhotra, Junior Noel, Donovan Jarvis
-- Instructor: Professor Bruno G. Kamdem, Ph.D.
-- File: 01_schema_mysql.sql
-- Purpose: Create the complete relational database schema in MySQL
-- =====================================================================

-- Drop existing database if it exists (clean rebuild)
DROP DATABASE IF EXISTS nonprofit_db;
CREATE DATABASE nonprofit_db;
USE nonprofit_db;

-- =====================================================================
-- TABLE 1: CONSTITUENTS (Donors)
-- The central table - every transaction, pledge, and metric links here
-- =====================================================================
CREATE TABLE constituents (
    constituent_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    email            VARCHAR(100),
    phone            VARCHAR(20),
    address          VARCHAR(150),
    city             VARCHAR(50),
    state            CHAR(2),
    donor_type       VARCHAR(50)  DEFAULT 'Individual',
    created_date     DATE         DEFAULT (CURRENT_DATE),
    INDEX idx_donor_lastname (last_name),
    INDEX idx_donor_state (state),
    INDEX idx_donor_type (donor_type)
);

-- =====================================================================
-- TABLE 2: CAMPAIGNS
-- Stores fundraising campaign details and goals
-- =====================================================================
CREATE TABLE campaigns (
    campaign_id      INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    type             VARCHAR(50),
    goal_amount      DECIMAL(12,2) NOT NULL,
    start_date       DATE         NOT NULL,
    end_date         DATE         NOT NULL,
    description      VARCHAR(255),
    INDEX idx_campaign_dates (start_date, end_date),
    INDEX idx_campaign_type (type),
    CONSTRAINT chk_campaign_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_goal_positive CHECK (goal_amount > 0)
);

-- =====================================================================
-- TABLE 3: TRANSACTIONS (Donations)
-- Bridge table: each donation links a constituent to a campaign
-- =====================================================================
CREATE TABLE transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    constituent_id   INT NOT NULL,
    campaign_id      INT NOT NULL,
    donation_amount  DECIMAL(12,2) NOT NULL,
    donation_date    DATE NOT NULL,
    payment_method   VARCHAR(50)   DEFAULT 'Online',
    CONSTRAINT fk_trans_constituent FOREIGN KEY (constituent_id)
        REFERENCES constituents(constituent_id) ON DELETE CASCADE,
    CONSTRAINT fk_trans_campaign FOREIGN KEY (campaign_id)
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT chk_donation_positive CHECK (donation_amount > 0),
    INDEX idx_trans_date (donation_date),
    INDEX idx_trans_constituent (constituent_id),
    INDEX idx_trans_campaign (campaign_id)
);

-- =====================================================================
-- TABLE 4: PLEDGES
-- Donor commitments to give in the future (often paid in installments)
-- =====================================================================
CREATE TABLE pledges (
    pledge_id        INT AUTO_INCREMENT PRIMARY KEY,
    constituent_id   INT NOT NULL,
    campaign_id      INT NOT NULL,
    pledge_amount    DECIMAL(12,2) NOT NULL,
    pledge_date      DATE NOT NULL,
    due_date         DATE NOT NULL,
    pledge_status    VARCHAR(50) DEFAULT 'Open',
    CONSTRAINT fk_pledge_constituent FOREIGN KEY (constituent_id)
        REFERENCES constituents(constituent_id) ON DELETE CASCADE,
    CONSTRAINT fk_pledge_campaign FOREIGN KEY (campaign_id)
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT chk_pledge_status CHECK (pledge_status IN ('Open','Fulfilled','Cancelled','Overdue')),
    CONSTRAINT chk_pledge_amount CHECK (pledge_amount > 0),
    INDEX idx_pledge_status (pledge_status),
    INDEX idx_pledge_due (due_date)
);

-- =====================================================================
-- TABLE 5: PLEDGE_PAYMENTS
-- Tracks each individual payment made against a pledge
-- =====================================================================
CREATE TABLE pledge_payments (
    payment_id          INT AUTO_INCREMENT PRIMARY KEY,
    pledge_id           INT NOT NULL,
    constituent_id      INT NOT NULL,
    payment_amount      DECIMAL(12,2) NOT NULL,
    payment_date        DATE NOT NULL,
    outstanding_balance DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_payment_pledge FOREIGN KEY (pledge_id)
        REFERENCES pledges(pledge_id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_constituent FOREIGN KEY (constituent_id)
        REFERENCES constituents(constituent_id) ON DELETE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (payment_amount > 0),
    INDEX idx_payment_date (payment_date)
);

-- =====================================================================
-- TABLE 6: DONOR_METRICS
-- Aggregated donor statistics for analytics and reporting
-- =====================================================================
CREATE TABLE donor_metrics (
    metric_id        INT AUTO_INCREMENT PRIMARY KEY,
    constituent_id   INT NOT NULL UNIQUE,
    lifetime_giving  DECIMAL(12,2) DEFAULT 0.00,
    average_gift     DECIMAL(12,2) DEFAULT 0.00,
    largest_gift     DECIMAL(12,2) DEFAULT 0.00,
    donor_level      VARCHAR(50)   DEFAULT 'Bronze',
    retention_status VARCHAR(50)   DEFAULT 'New',
    giving_2021      DECIMAL(12,2) DEFAULT 0.00,
    giving_2022      DECIMAL(12,2) DEFAULT 0.00,
    giving_2023      DECIMAL(12,2) DEFAULT 0.00,
    giving_2024      DECIMAL(12,2) DEFAULT 0.00,
    giving_2025      DECIMAL(12,2) DEFAULT 0.00,
    last_updated     DATE          DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_metrics_constituent FOREIGN KEY (constituent_id)
        REFERENCES constituents(constituent_id) ON DELETE CASCADE,
    CONSTRAINT chk_donor_level CHECK (donor_level IN ('Bronze','Silver','Gold','Platinum')),
    CONSTRAINT chk_retention CHECK (retention_status IN ('Active','Lapsed','Recovered','New')),
    INDEX idx_donor_level (donor_level),
    INDEX idx_retention (retention_status)
);

-- =====================================================================
-- VERIFY SCHEMA
-- =====================================================================
SHOW TABLES;
-- Expected output: campaigns, constituents, donor_metrics, pledge_payments, pledges, transactions
