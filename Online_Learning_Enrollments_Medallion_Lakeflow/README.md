# Online Learning Enrollments – Medallion Architecture

## 1. Project Overview

This project is about analyzing online course enrollment data using Databricks.

The main goal is to clean raw enrollment data, organize it into different layers, and prepare it for business analysis.

I used Medallion Architecture, which has three layers:

- **Bronze Layer:** Stores raw data.
- **Silver Layer:** Cleans and transforms data.
- **Gold Layer:** Creates summary tables for analysis.

Finally, I created a Databricks AI/BI Dashboard to understand enrollment trends, course performance, revenue, and data quality.

## 2. Business Problem

Online learning platforms collect information about learners, courses, enrollments, prices, and learning progress.

However, raw data may contain:
- Duplicate records.
- Missing values.
- Incorrect email formats.
- Invalid progress values.
- Negative or missing prices.

These problems can affect reports and business decisions.

**Solution:** I built data pipelines to clean the raw data and create useful summary tables for business analysis.

## 3. Project Workflow

The project follows this workflow:

**CSV File → Bronze Layer → Silver Layer → Gold Layer → AI/BI Dashboard**

Each layer has a different role in preparing the data.

## 4. Technologies Used

| Technology | Purpose |
|---|---|
| Databricks | Data processing and analytics |
| Unity Catalog | Organizing data |
| Lakeflow Spark Declarative Pipelines | Creating data pipelines |
| Spark SQL | Cleaning and transforming data |
| Delta Lake | Storing data in tables |
| Databricks AI/BI | Creating dashboards |
| GitHub | Managing project files |

## 5. Dataset Information

| Description | Details |
|---|---|
| Dataset | Online Learning Enrollments |
| File Name | `course_enrollments_raw.csv` |
| Total Rows | 1,283 |
| Total Columns | 20 |
| Unique Identifier | `enrollment_id` |
| Data Grain | One row represents one enrollment |

A learner can enroll in multiple courses, so the same email address can appear more than once.

## 6. Unity Catalog Structure

I used Unity Catalog to organize the project data.

| Component | Name |
|---|---|
| Catalog | `edtech_catalog` |
| Schema | `learning` |
| Volume | `raw_files` |

**CSV File Location:**

`/Volumes/edtech_catalog/learning/raw_files/course_enrollments_raw.csv`

## 7. Data Pipeline

The project follows three layers:

1. Bronze Layer
2. Silver Layer
3. Gold Layer

The data is processed in this order:

**Bronze → Silver → Gold**

### 7.1 Bronze Layer – Raw Data

**Table Name:** `bronze_course_enrollments`

The Bronze layer reads the original CSV file and stores the raw enrollment data.

Main activities:
- Reads the CSV file.
- Loads the data into the Bronze table.
- Keeps the raw data for further processing.

### 7.2 Silver Layer – Data Cleaning

The Silver layer cleans the raw data and prepares it for analysis.

The following steps are performed:

- Removes extra spaces from text values.
- Converts email addresses to lowercase.
- Replaces missing categories and cities with `Unknown`.
- Calculates missing paid prices using list price minus discount amount.
- Keeps missing ratings as NULL.
- Removes duplicate enrollment IDs.
- Rejects progress values below 0 or above 100.
- Rejects negative prices.
- Creates enrollment status based on progress.

**Enrollment Status:**

| Progress | Status |
|---|---|
| 100% | Completed |
| 1% to 99% | In Progress |
| 0% | Not Started |

### 7.3 Gold Layer – Business Summary Tables

The Gold layer contains five tables for business analysis.

| Table Name | Purpose |
|---|---|
| `gold_monthly_enrollments` | Monthly enrollment and revenue analysis |
| `gold_category_summary` | Category-wise performance |
| `gold_course_summary` | Individual course performance |
| `gold_channel_summary` | Channel-wise enrollment and revenue |
| `gold_data_quality` | Data quality results |

These tables make business analysis easier.

## 8. Data Quality Results

I checked the raw data for common data quality issues.

| Check | Records |
|---|---:|
| Total Bronze Records | 1,283 |
| Duplicate Records | 23 |
| Invalid Progress Records | 11 |
| Negative Price Records | 8 |
| Missing Category Records | 12 |
| Missing City Records | 10 |
| Missing Price Records | 15 |
| Learners Before Email Cleaning | 602 |
| Learners After Email Cleaning | 555 |
| Clean Records | 1,241 |
| Rejected Records | 19 |

**Note:** Some data quality issues may overlap. Individual issue counts should not be added together to calculate rejected records.

## 9. Data Reconciliation

The project tracks the records after data cleaning.

| Description | Records |
|---|---:|
| Original Records | 1,283 |
| Clean Records | 1,241 |
| Rejected Records | 19 |
| Duplicate Records | 23 |

**Reported Record Count:**

1,283 = 1,241 + 19 + 23

This is the reported record-count breakdown from the project.

## 10. Dashboard

I created a Databricks AI/BI Dashboard with three pages.

### Page 1 – Overview

This page shows the overall performance of the online learning platform.

It includes:
- Monthly enrollments.
- Unique learners.
- Revenue.
- Course completions.
- Learning hours.

### Page 2 – Courses & Channels

This page compares course and enrollment channel performance.

It includes:
- Category-wise enrollments.
- Course performance.
- Revenue by channel.
- Completion rates.

### Page 3 – Data Quality

This page shows the quality of the source data.

It includes:
- Duplicate records.
- Invalid progress records.
- Negative prices.
- Missing values.
- Clean and rejected records.

## 11. Key Business Insights

The analysis helped identify four important business insights:

1. **Data Science – Highest Enrollments and Revenue**

   Data Science recorded the highest number of enrollments (385) and the highest revenue (₹1,149,465) among the course categories.

2. **Graphic Design – Highest Completion Rate Among Named Categories**

   Graphic Design had the highest completion rate among named categories at 32.63%.

   The `Unknown` category had a 33.33% completion rate, but it contained only 12 enrollments. Therefore, Graphic Design is the highest-performing named category.

3. **Website – Leading Enrollment Channel**

   Website recorded 504 enrollments and the highest revenue among all channels, with ₹1,102,959.

4. **Social Media – Highest Channel Completion Rate**

   Social Media had the highest completion rate among the enrollment channels at 29.78%.

These insights help understand course performance, learner progress, revenue, and enrollment channel effectiveness.

## 12. How to Run the Project

1. Open your Databricks workspace.
2. Open Unity Catalog.
3. Select the `edtech_catalog` catalog.
4. Open the `learning` schema.
5. Check the CSV file inside the `raw_files` volume.
6. Run the Bronze layer pipeline.
7. After Bronze completes, run the Silver layer pipeline.
8. After Silver completes, run the Gold layer pipeline.
9. Check the five Gold tables.
10. Open the AI/BI Dashboard to view the results.

## 13. Key Learnings

Through this project, I learned:

- How to work with Databricks.
- How to use Unity Catalog.
- How Medallion Architecture works.
- How to create Bronze, Silver, and Gold layers.
- How to clean data using Spark SQL.
- How to create pipelines using Lakeflow Spark Declarative Pipelines.
- How to create summary tables.
- How to build dashboards using Databricks AI/BI.

## 14. Future Improvements

- Add more data quality checks.
- Include more business metrics.
- Improve dashboard interactivity.
- Explore automated pipeline scheduling.




