# BUS385-GRP#_FirstName_LastName

> **Repository naming reminder**: When the group representative creates the repo via the Classroom link, name it using the convention **`BUS385-GRP#_FirstName_LastName`** (e.g., `BUS385-GRP7_Guneet_Malhotra`). This README sits inside that repo.

---

# Non-Profit Donor & Campaign Management System

**Course:** BUS 385 – Business Data Management (Spring 2026)
**Instructor:** Bruno G. Kamdem, Ph.D.
**Institution:** Farmingdale State College – School of Business
**Group Members:** Guneet Malhotra · Junior Noel · Donovan Jarvis
**Submission Date:** April 26, 2026

---

## 1. Project Overview

This project implements a fully functional relational database system for nonprofit donor and campaign management. The system centralizes donor profiles, fundraising campaigns, donation transactions, pledge commitments, pledge payments, and donor performance metrics into one integrated platform.

The database is implemented in **two complementary tools**:

| Tool | Purpose |
|---|---|
| **Microsoft Access** | Database design, table relationships, forms, reports, ER diagram visualization |
| **MySQL Workbench** | Production-grade SQL query development, advanced JOINs, subqueries, aggregations |

## 2. Repository Structure

```
BUS385-GRP#_FirstName_LastName/
├── README.md                       <- This file
├── /sql/                           <- MySQL Workbench scripts
│   ├── 01_schema_mysql.sql         <- CREATE DATABASE + 6 tables + constraints
│   ├── 02_data_load.sql            <- Sample data inserts
│   ├── 03_basic_queries.sql        <- SELECT / INSERT / UPDATE / DELETE
│   ├── 04_advanced_queries.sql     <- JOINs, subqueries, aggregations
│   └── 05_business_reports.sql     <- 8 production-ready analytics reports
├── /access_sql/                    <- Microsoft Access SQL versions
│   └── access_queries.sql          <- Access-compatible syntax (IIf, NZ, nested parens)
├── /data/                          <- Source CSV files from Kaggle
│   └── README.md                   <- Dataset attribution and load instructions
├── /docs/                          <- Documentation
│   ├── ERD.png                     <- Entity Relationship Diagram
│   ├── access_relationships.png    <- Screenshot of Access "Relationships" view
│   └── data_dictionary.md          <- Complete data type reference
└── /screenshots/                   <- Query result screenshots for the report
```

## 3. How to Run This Project

### 3.1 MySQL Workbench Setup

```bash
# 1. Open MySQL Workbench, connect to your local MySQL server
# 2. Open and execute scripts in this order:

mysql -u root -p < sql/01_schema_mysql.sql
mysql -u root -p < sql/02_data_load.sql
mysql -u root -p < sql/03_basic_queries.sql
mysql -u root -p < sql/04_advanced_queries.sql
mysql -u root -p < sql/05_business_reports.sql
```

Or in MySQL Workbench: **File → Open SQL Script → execute each file in order (Ctrl+Shift+Enter)**.

### 3.2 Microsoft Access Setup

1. Open `nonprofit_db.accdb` (download from `/data/` folder or build using the schema in `/sql/01_schema_mysql.sql` adapted to Access).
2. Import the six core CSVs from the Kaggle dataset:
   - `constituents.csv`
   - `campaigns.csv`
   - `transactions.csv`
   - `pledges.csv`
   - `pledge_payments.csv`
   - `donor_metrics.csv`
3. Define table relationships in **Database Tools → Relationships**.
4. Run Access-compatible queries from `/access_sql/access_queries.sql`.

## 4. Database Schema (6 Core Tables)

| Table | Primary Key | Foreign Keys | Records |
|---|---|---|---|
| `constituents` | `constituent_id` | — | Donor profiles |
| `campaigns` | `campaign_id` | — | Fundraising campaigns |
| `transactions` | `transaction_id` | `constituent_id`, `campaign_id` | Individual donations |
| `pledges` | `pledge_id` | `constituent_id`, `campaign_id` | Future giving commitments |
| `pledge_payments` | `payment_id` | `pledge_id`, `constituent_id` | Pledge installments |
| `donor_metrics` | `metric_id` | `constituent_id` | Aggregated donor analytics |

Four supplementary reference tables from the Kaggle dataset (`appeals`, `funds`, `households`, `relationships`) are available for extended analysis but are not required for core functionality.

## 5. Key Business Reports

The system answers eight high-value questions for nonprofit decision-makers:

1. **Campaign Performance Dashboard** – goal vs. raised, % complete, status flag
2. **Top Donor Leaderboard** – ranked by lifetime giving with donor level
3. **Year-over-Year Giving Trends** – 2021–2025 dollars, donor count, avg gift
4. **Lapsed Donor Recovery List** – donors who gave in 2024 but not 2025
5. **Outstanding Pledge Balances** – pledge fulfillment status with overdue flags
6. **Geographic Giving Analysis** – performance by state
7. **Donor Acquisition vs. Retention** – breakdown by retention status
8. **Payment Method Analysis** – gift volume by payment channel

## 6. Data Source

**Mock Nonprofit Fundraising Data** (Kaggle):
[https://www.kaggle.com/datasets/grantstancliff/mock-nonprofit-fundraising-data](https://www.kaggle.com/datasets/grantstancliff/mock-nonprofit-fundraising-data)

This is a synthetic dataset with no real personal or financial information, making it appropriate for academic use.

## 7. Roles & Responsibilities (All Members Cross-Functional)

Per course requirements, **every group member contributes to database design, SQL coding, and Access work**. Specialized leadership areas:

| Member | Database Design (Access) | SQL Development (MySQL) | Documentation |
|---|---|---|---|
| **Guneet Malhotra** | Lead: campaigns, pledges, donor_metrics tables; ERD documentation | Co-author: campaign reporting, pledge tracking SQL | Co-author: data dictionary, written report |
| **Junior Noel** | Lead: constituents, transactions, pledge_payments tables; Access forms | Co-author: donor retention, YoY giving SQL; database testing | Co-author: ERD, screenshots |
| **Donovan Jarvis** | Co-author: pledges, pledge_payments tables; Access reports | Co-author: campaign performance, pledge fulfillment SQL; relationship testing | Lead: final written report, presentation slides |

All three members contributed to writing INSERT/UPDATE/DELETE statements, building the ERD, and validating relationships.

## 8. Important Notes on Access vs MySQL Syntax

Per Professor Kamdem's feedback, we maintained two parallel SQL files because of the following key syntactic differences:

| Concept | MySQL | Microsoft Access |
|---|---|---|
| String concatenation | `CONCAT(a, ' ', b)` | `a & ' ' & b` |
| Null coalescing | `IFNULL(x, 0)` | `Nz(x, 0)` |
| Conditional logic | `CASE WHEN ... THEN ... END` | `IIf(condition, true, false)` |
| Date literal | `'2025-04-25'` | `#2025-04-25#` |
| Date arithmetic | `DATE_SUB(d, INTERVAL 90 DAY)` | `DateAdd("d", -90, d)` |
| Row limiting | `LIMIT 5` | `TOP 5` |
| Multi-table JOIN | Flat syntax | Requires nested parentheses |

All MySQL queries in `/sql/` have a tested Access equivalent in `/access_sql/access_queries.sql`.

## 9. Academic Integrity Statement

This project is original work conceived, developed, and executed entirely by Guneet Malhotra, Junior Noel, and Donovan Jarvis for BUS 385, Spring 2026. The dataset is publicly available synthetic data from Kaggle and contains no real personal or financial information.

## 10. License

Academic project — for educational use only.
