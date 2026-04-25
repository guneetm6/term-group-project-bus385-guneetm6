# Data Dictionary - Non-Profit Donor & Campaign Management System

This document specifies the complete data type implementation for both Microsoft Access and MySQL Workbench, addressing the professor's initial feedback to "explicitly state the specific data types you plan to implement for these fields."

---

## Table 1: `constituents` (Donor Master Table)

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `constituent_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique donor identifier |
| `first_name` | Short Text (50) | VARCHAR(50) | NOT NULL | Donor first name |
| `last_name` | Short Text (50) | VARCHAR(50) | NOT NULL | Donor last name |
| `email` | Short Text (100) | VARCHAR(100) | nullable | Email address |
| `phone` | Short Text (20) | VARCHAR(20) | nullable | Phone number |
| `address` | Short Text (150) | VARCHAR(150) | nullable | Street address |
| `city` | Short Text (50) | VARCHAR(50) | nullable | City |
| `state` | Short Text (2) | CHAR(2) | nullable | US state abbreviation |
| `donor_type` | Short Text (50) | VARCHAR(50) | DEFAULT 'Individual' | Individual, Organization, Foundation |
| `created_date` | Date/Time | DATE | DEFAULT CURRENT_DATE | Record creation date |

## Table 2: `campaigns`

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `campaign_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique campaign identifier |
| `name` | Short Text (100) | VARCHAR(100) | NOT NULL | Campaign name |
| `type` | Short Text (50) | VARCHAR(50) | nullable | Annual Fund, Capital, Major Gift, Programs |
| `goal_amount` | Currency | DECIMAL(12,2) | NOT NULL, > 0 | Fundraising goal |
| `start_date` | Date/Time | DATE | NOT NULL | Campaign start |
| `end_date` | Date/Time | DATE | NOT NULL, ≥ start_date | Campaign end |
| `description` | Long Text | VARCHAR(255) | nullable | Campaign description |

## Table 3: `transactions` (Donations)

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `transaction_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique transaction ID |
| `constituent_id` | Number (Long Integer) | INT | FK → constituents | Donor reference |
| `campaign_id` | Number (Long Integer) | INT | FK → campaigns | Campaign reference |
| `donation_amount` | Currency | DECIMAL(12,2) | NOT NULL, > 0 | Donation amount |
| `donation_date` | Date/Time | DATE | NOT NULL | Donation date |
| `payment_method` | Short Text (50) | VARCHAR(50) | DEFAULT 'Online' | Cash, Check, Credit Card, Online, Wire Transfer |

## Table 4: `pledges`

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `pledge_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique pledge ID |
| `constituent_id` | Number (Long Integer) | INT | FK → constituents | Donor reference |
| `campaign_id` | Number (Long Integer) | INT | FK → campaigns | Campaign reference |
| `pledge_amount` | Currency | DECIMAL(12,2) | NOT NULL, > 0 | Total pledged amount |
| `pledge_date` | Date/Time | DATE | NOT NULL | Pledge date |
| `due_date` | Date/Time | DATE | NOT NULL | Expected fulfillment date |
| `pledge_status` | Short Text (50) | VARCHAR(50) | CHECK IN ('Open','Fulfilled','Cancelled','Overdue') | Current status |

## Table 5: `pledge_payments`

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `payment_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique payment ID |
| `pledge_id` | Number (Long Integer) | INT | FK → pledges | Pledge reference |
| `constituent_id` | Number (Long Integer) | INT | FK → constituents | Donor reference |
| `payment_amount` | Currency | DECIMAL(12,2) | NOT NULL, > 0 | Payment amount |
| `payment_date` | Date/Time | DATE | NOT NULL | Payment date |
| `outstanding_balance` | Currency | DECIMAL(12,2) | NOT NULL | Remaining balance after payment |

## Table 6: `donor_metrics`

| Field | Access Data Type | MySQL Data Type | Constraints | Description |
|---|---|---|---|---|
| `metric_id` | AutoNumber | INT AUTO_INCREMENT | PRIMARY KEY | Unique metric record ID |
| `constituent_id` | Number (Long Integer) | INT | FK → constituents, UNIQUE | Donor reference (1:1) |
| `lifetime_giving` | Currency | DECIMAL(12,2) | DEFAULT 0 | Total giving across all years |
| `average_gift` | Currency | DECIMAL(12,2) | DEFAULT 0 | Average gift size |
| `largest_gift` | Currency | DECIMAL(12,2) | DEFAULT 0 | Largest single gift |
| `donor_level` | Short Text (50) | VARCHAR(50) | CHECK IN ('Bronze','Silver','Gold','Platinum') | Donor tier |
| `retention_status` | Short Text (50) | VARCHAR(50) | CHECK IN ('Active','Lapsed','Recovered','New') | Retention category |
| `giving_2021` | Currency | DECIMAL(12,2) | DEFAULT 0 | 2021 giving total |
| `giving_2022` | Currency | DECIMAL(12,2) | DEFAULT 0 | 2022 giving total |
| `giving_2023` | Currency | DECIMAL(12,2) | DEFAULT 0 | 2023 giving total |
| `giving_2024` | Currency | DECIMAL(12,2) | DEFAULT 0 | 2024 giving total |
| `giving_2025` | Currency | DECIMAL(12,2) | DEFAULT 0 | 2025 giving total |

---

## Relationship Summary

| Parent Table | Child Table | Relationship | Cardinality |
|---|---|---|---|
| `constituents` | `transactions` | one-to-many | 1 donor → many gifts |
| `constituents` | `pledges` | one-to-many | 1 donor → many pledges |
| `constituents` | `pledge_payments` | one-to-many | 1 donor → many payments |
| `constituents` | `donor_metrics` | one-to-one | 1 donor → 1 metrics row |
| `campaigns` | `transactions` | one-to-many | 1 campaign → many gifts |
| `campaigns` | `pledges` | one-to-many | 1 campaign → many pledges |
| `pledges` | `pledge_payments` | one-to-many | 1 pledge → many payments |

All foreign keys use `ON DELETE CASCADE` to maintain referential integrity.

## Donor Type Domain Values

- **Individual**: Personal donors
- **Organization**: For-profit corporations, businesses
- **Foundation**: Charitable foundations and trusts

## Donor Level Tiers (calculated by lifetime giving)

| Level | Lifetime Giving Range |
|---|---|
| Bronze | $0 – $999 |
| Silver | $1,000 – $9,999 |
| Gold | $10,000 – $49,999 |
| Platinum | $50,000+ |

## Retention Status Values

- **New**: First gift in current fiscal year
- **Active**: Gave in current AND prior year
- **Lapsed**: Gave in prior year but not current year
- **Recovered**: Re-engaged after lapsing
