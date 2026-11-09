# Project Review Questions and Answers

Answers to the eight review questions for the Online Learning Enrollment Analytics Platform, implemented using Lakeflow Spark Declarative Pipelines on Azure Databricks.

---

## 1. Why do we preserve raw data in Bronze instead of cleaning the source immediately?

Bronze is the system of record for the original enrollment data received from the CSV file. Keeping it unchanged provides:

- **Traceability:** cleaned values in Silver can be compared with the original Bronze records.
- **Reprocessability:** if a cleaning rule changes, we can rebuild Silver and Gold without uploading the source file again.
- **Auditability:** we can identify what data arrived, what transformations were applied and why records were rejected.
- **Safe experimentation:** new cleaning rules can be tested without modifying the original source data.

If we cleaned the source immediately, the original values could be lost, making it difficult to investigate data-quality issues.

---

## 2. What is the difference between a data-quality flag and rejecting a record?

| | **Flag** | **Reject / exclude** |
|---|---|---|
| What happens | The record is retained and identified as having an issue. | The record is excluded from trusted reporting. |
| Use when | The value needs investigation but may be valid. | The record violates a defined validation rule. |
| Example | Missing course rating or category. | Invalid progress percentage or negative price. |
| Risk | Flagged records may affect reports if not handled. | Valid records may be lost if rules are too strict. |
| Reversible | Yes, using Bronze data. | Yes, using Bronze data. |

In this project, missing category and city values are replaced with `Unknown`, missing ratings remain NULL, and missing paid prices are calculated using `list_price - discount_amount`.

Invalid progress values, negative prices and duplicate enrollment IDs are handled according to the project's data-quality rules.

---

## 3. Why is Enrollment ID important when identifying duplicate records?

Each row in this project represents one course enrollment. Therefore, `enrollment_id` identifies an individual enrollment record.

Using `learner_email` alone as a duplicate key would be unsafe because one learner can enroll in multiple courses.

For example, the same learner may enroll in Python, SQL and Power BI courses. These are three valid enrollment records.

Duplicate records are identified using `enrollment_id`, while learner emails are trimmed and converted to lowercase to standardize learner identification.

---

## 4. How would you investigate invalid progress values or negative prices?

1. **Isolate** records with progress below 0, above 100 or negative prices.
2. **Compare** the records with the original Bronze data.
3. **Check related fields:** list price, discount amount, paid price and progress percentage.
4. **Identify patterns:** investigate whether the issue comes from incorrect source data or calculation errors.
5. **Apply validation rules:** retain valid records and reject records that violate the defined rules.
6. **Document the results:** maintain data-quality counts in the Gold summary.

Progress values of 0 and 100 are valid. Learner status is derived as:

- 100% → Completed
- 1–99% → In Progress
- 0% → Not Started

The key principle is to apply clearly defined business rules instead of assuming every unusual value is invalid.

---

## 5. How can you prove that the Gold data is consistent with the cleaned Silver data?

By running reconciliation queries that compare record counts across the Bronze, clean, rejected and duplicate records.

The project results are:

- Bronze records: 1,283
- Clean records: 1,241
- Rejected records: 19
- Duplicate records removed: 23

The reconciliation formula is:

`Bronze = Clean + Rejected + Duplicates Removed`

`1,283 = 1,241 + 19 + 23`

I also validate the Gold summary tables against the cleaned Silver data to check monthly, category, course and channel aggregations.

The `gold_data_quality` table provides visibility into record counts and data-quality results.

---

## 6. What would change if new enrollment files arrived every day?

- **Ingestion:** use Auto Loader (`cloud_files`) to discover new CSV files from the Unity Catalog Volume.
- **Deduplication:** identify duplicate `enrollment_id` values across previously processed and newly arriving files.
- **Idempotency:** ensure reprocessing the same file does not create duplicate enrollment records.
- **Scheduling:** configure pipeline updates to run on a schedule or when new files arrive.
- **Monitoring:** add alerts for pipeline failures and data-quality issues.
- **Schema evolution:** handle new or changed source columns.
- **Gold:** refresh summary tables so reports include the latest enrollment data.

This would allow the platform to process new data incrementally instead of manually rebuilding the entire workflow.

---

## 7. When would you introduce separate learner and course dimension tables?

Separate learner and course dimension tables would be useful when:

- Learner attributes such as location and learner segment need to be maintained separately.
- Course attributes such as course name, category and instructor are repeated across many enrollment records.
- Multiple fact tables, such as enrollment and payment, need shared learner and course information.
- Historical changes to learner or course attributes need to be tracked.
- A star schema is required for more structured reporting.

For the current project, the enrollment dataset and five Gold summary tables are sufficient for the required business analysis. Separate dimension tables are a possible future enhancement.

---

## 8. How could this batch pipeline evolve toward incremental or streaming processing?

1. **Incremental ingestion:** use Auto Loader to process newly arriving enrollment CSV files.
2. **Streaming processing:** use streaming tables to process new enrollment records as they arrive.
3. **Data quality:** continuously validate enrollment IDs, progress percentages, prices and missing values.
4. **Deduplication:** handle duplicate enrollment IDs across incoming files.
5. **Gold updates:** refresh aggregated Gold tables as new records arrive.
6. **Monitoring:** configure alerts for pipeline failures and processing delays.
7. **Operational improvements:** introduce scheduling, CI/CD and pipeline monitoring.

The current project focuses on batch-oriented processing. Incremental ingestion and real-time streaming are future enhancements.

---

> **Note:** The current implementation focuses on Bronze, Silver and Gold processing, data cleaning, aggregation, reconciliation and dashboard reporting. Advanced dimensional modelling and real-time streaming are outside the current project scope.
