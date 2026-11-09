# Data Quality Rules – Online Learning Enrollment Analytics

**Principle:** Bronze preserves raw data, Silver cleans and validates data, and Gold provides trusted reporting.

## 1. Known Issues in Source Data

Source: `course_enrollments_raw.csv` (1,283 rows × 20 columns)

- Leading/trailing whitespace
- Inconsistent email casing
- Missing category, city, ratings and paid price
- Duplicate enrollment IDs
- Invalid progress percentages
- Negative prices

## 2. Rules by Layer

**Bronze – Preserve**
- BRZ-01: Preserve original source values.
- BRZ-02: Maintain source metadata.
- BRZ-03: Validate source record count.

**Silver – Standardize and Validate**

| Rule | Treatment |
|---|---|
| Trim text fields | Fix |
| Normalize learner emails | Lowercase |
| Missing category/city | Replace with `Unknown` |
| Missing paid price | Calculate from list price − discount |
| Missing ratings | Keep NULL |
| Duplicate enrollment IDs | Remove |
| Progress below 0 or above 100 | Reject |
| Negative prices | Reject |

**Gold – Trusted Reporting**
- GLD-01: Aggregate cleaned Silver data.
- GLD-02: Generate five Gold summary tables.
- GLD-03: Track quality results in `gold_data_quality`.

## 3. Flag vs. Reject

- **Retain:** Missing ratings, category and city (handled using the rules above).
- **Reject:** Invalid progress, negative prices and duplicate enrollment IDs.

## 4. Enrollment Status Rules

| Progress | Status |
|---|---|
| 0% | Not Started |
| 1–99% | In Progress |
| 100% | Completed |
| Below 0 or above 100 | Rejected |

## 5. Pipeline Expectations

Lakeflow Spark Declarative Pipelines manages Bronze, Silver and Gold processing.

## 6. Investigating Issues

- Identify invalid records.
- Compare with Bronze data.
- Check enrollment IDs, progress and prices.
- Apply validation rules and track results.

## 7. Issue Summary

| Issue | Count |
|---|---:|
| Duplicate records | 23 |
| Invalid progress | 11 |
| Negative prices | 8 |
| Missing category | 12 |
| Missing city | 10 |
| Missing paid price | 15 |

**Reconciliation:**
- Bronze: 1,283
- Clean: 1,241
- Rejected: 19
- Duplicates: 23

## 8. Assumptions and Decisions

- One row represents one enrollment.
- `enrollment_id` identifies each enrollment.
- One learner can enroll in multiple courses.
- Missing ratings remain NULL.
- Progress between 0 and 100 is valid.
- Missing paid price is calculated using list price minus discount.
