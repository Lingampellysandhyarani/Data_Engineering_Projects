# Online Learning Enrollment Analytics Platform
### Medallion Architecture using Lakeflow Spark Declarative Pipelines

An end-to-end data engineering project built using Azure Databricks. This project transforms raw online course enrollment data into clean and useful information using Bronze, Silver, and Gold layers. The final data is used to analyze course performance, enrollments, revenue, and data quality.

## Table of Contents
1. Business Problem
2. Architecture
3. Pipeline Lineage
4. Tech Stack
5. Dataset
6. Repository Structure
7. Layer Details
8. Data Quality Rules
9. Reconciliation
10. How to Run
11. Business Requirements Coverage
12. Key Learnings
13. Future Improvements

## 1. Business Problem

Online learning platforms receive enrollment data from different learners and courses. Raw data may contain missing values, duplicates, extra spaces, and incorrect values.

**Goal:** Build a data pipeline to clean the data, create useful summary tables, and develop a dashboard for business analysis.

## 2. Architecture

CSV File → Bronze → Silver → Gold → AI/BI Dashboard


![Project Architecture](images/architecture.png)

| Layer | Purpose |
|---|---|
| Bronze | Store raw data |
| Silver | Clean and validate data |
| Gold | Create summary tables for analysis |

## 3. Pipeline Lineage

The project uses three Lakeflow Spark Declarative Pipelines.

| Pipeline | Purpose |
|---|---|
| Bronze_pipeline | Loads raw CSV data |
| Silver_layer | Cleans and validates data |
| Gold_layer | Creates summary tables |

**Execution Order:** Bronze → Silver → Gold


![Pipeline Lineage](images/pipeline_lineage.png)

## 4. Tech Stack

- Azure Databricks
- Lakeflow Spark Declarative Pipelines
- Unity Catalog
- Delta Lake
- Spark SQL
- Databricks AI/BI Dashboard
- GitHub

## 5. Dataset

**File:** `course_enrollments_raw.csv`

| Details | Value |
|---|---|
| Total Records | 1,283 |
| Total Columns | 20 |
| Format | CSV |
| Unique Identifier | enrollment_id |

**Unity Catalog Details:**

- Catalog: `edtech_catalog`
- Schema: `learning`
- Volume: `raw_files`

## 6. Repository Structure

```text
Online_Learning_Analytics/
│
├── README.md
├── data/
├── pipeline/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── validation/
├── docs/
└── images/
```

*This is a suggested structure. Keep the files and folders that you actually upload.*

## 7. Layer Details

### Bronze Layer
- Reads the CSV file from the Unity Catalog Volume.
- Stores raw records in `bronze_course_enrollments`.
- Preserves source data.

### Silver Layer
Cleans and validates the data.

- Removes extra spaces.
- Converts emails to lowercase.
- Replaces missing category and city with `Unknown`.
- Calculates missing paid prices.
- Removes duplicate enrollment IDs.
- Rejects invalid progress and negative prices.
- Keeps missing ratings as NULL.

**Enrollment Status:**

| Progress | Status |
|---|---|
| 0 | Not Started |
| 1–99 | In Progress |
| 100 | Completed |

### Gold Layer

Creates five summary tables:

| Table | Purpose |
|---|---|
| gold_monthly_enrollments | Monthly analysis |
| gold_category_summary | Category performance |
| gold_course_summary | Course performance |
| gold_channel_summary | Channel performance |
| gold_data_quality | Data quality results |

## 8. Data Quality Rules

| Issue | Treatment |
|---|---|
| Missing category/city | Replace with Unknown |
| Missing paid price | Calculate using list price minus discount |
| Missing rating | Keep as NULL |
| Duplicate enrollment ID | Remove duplicates |
| Invalid progress | Reject values below 0 or above 100 |
| Negative prices | Reject records |

**Data Quality Results:**

| Metric | Count |
|---|---:|
| Bronze Records | 1,283 |
| Duplicate Records | 23 |
| Invalid Progress | 11 |
| Negative Prices | 8 |
| Clean Records | 1,241 |
| Rejected Records | 19 |

*Individual data quality issue counts can overlap.*

## 9. Reconciliation

Reconciliation checks whether all source records are accounted for.

| Record Type | Count |
|---|---:|
| Source Records | 1,283 |
| Clean Records | 1,241 |
| Rejected Records | 19 |
| Duplicate Records Removed | 23 |

**Check:** `1,283 = 1,241 + 19 + 23`

Additional SQL checks are needed to verify Silver-to-Gold totals.

Validation queries: `validation/`

## 10. How to Run

1. Upload the CSV file to the Unity Catalog Volume.
2. Run the Bronze pipeline.
3. Run the Silver pipeline.
4. Run the Gold pipeline.
5. Validate the Gold tables using SQL.
6. Open the AI/BI Dashboard.

## 11. Business Requirements Coverage

| Requirement | Implementation |
|---|---|
| Monthly enrollment analysis | gold_monthly_enrollments |
| Category analysis | gold_category_summary |
| Course analysis | gold_course_summary |
| Channel analysis | gold_channel_summary |
| Data quality | gold_data_quality |
| Interactive reporting | AI/BI Dashboard |

## 12. Dashboard

The dashboard contains three pages.

### Overview

**[PICTURE REQUIRED: Overview dashboard screenshot.]**

![Dashboard Overview](images/dashboard_overview.png)

### Courses and Channels

**[PICTURE REQUIRED: Courses and Channels dashboard screenshot.]**

![Courses and Channels](images/courses_channels.png)

### Data Quality

**[PICTURE REQUIRED: Data Quality dashboard screenshot.]**

![Data Quality](images/data_quality.png)

## 13. Key Learnings

- Understanding Medallion Architecture.
- Working with Unity Catalog.
- Building data pipelines.
- Cleaning data using Spark SQL.
- Handling duplicates and invalid records.
- Creating summary tables.
- Building interactive dashboards.

## 14. Future Improvements

- Automate daily data ingestion.
- Add more data quality checks.
- Implement incremental processing.
- Add pipeline monitoring and alerts.

---

