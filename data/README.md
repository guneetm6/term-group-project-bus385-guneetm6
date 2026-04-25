# Data Source

## Mock Nonprofit Fundraising Data

**Source:** [Kaggle - Mock Nonprofit Fundraising Data](https://www.kaggle.com/datasets/grantstancliff/mock-nonprofit-fundraising-data)
**Author:** Grant Stancliff
**License:** Public synthetic data (no real personal or financial information)

## Files Used

### Six core CSVs (mapped to our six tables):

1. **`constituents.csv`** → `constituents` table
2. **`campaigns.csv`** → `campaigns` table
3. **`transactions.csv`** → `transactions` table
4. **`pledges.csv`** → `pledges` table
5. **`pledge_payments.csv`** → `pledge_payments` table
6. **`donor_metrics.csv`** → `donor_metrics` table

### Four supplementary reference CSVs:

7. **`appeals.csv`** – Campaign appeal codes
8. **`funds.csv`** – Designated fund tracking
9. **`households.csv`** – Donor household groupings
10. **`relationships.csv`** – Donor relationships (spouse, family, etc.)

## How to Load Data

### Option 1: MySQL Workbench

```sql
USE nonprofit_db;

LOAD DATA LOCAL INFILE '/path/to/constituents.csv'
INTO TABLE constituents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Repeat for each CSV file. **Run in this order to satisfy foreign key constraints:**

1. `constituents.csv`
2. `campaigns.csv`
3. `transactions.csv`
4. `pledges.csv`
5. `pledge_payments.csv`
6. `donor_metrics.csv`

### Option 2: Microsoft Access

1. Open the Access database file
2. **External Data → New Data Source → From File → Text File**
3. Browse to each CSV file
4. Choose "Append a copy of records to the table" and select the matching destination table
5. Confirm field mappings (Access usually auto-detects them correctly)
6. Repeat for each CSV in the order listed above

## Note

The sample data in `/sql/02_data_load.sql` provides 15 constituents, 9 campaigns, and ~25 transactions for quick testing without downloading the full Kaggle CSVs. For full-scale demonstrations and the final report screenshots, use the complete Kaggle dataset.
