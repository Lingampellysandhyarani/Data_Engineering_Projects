# Data Reconciliation – Online Learning Enrollment Analytics

Data reconciliation means checking whether all records are correctly processed from Bronze to Silver and Gold layers.

## 1. Reconciliation Objectives

- Check whether all source records are loaded into Bronze.
- Check how many records are cleaned, rejected and removed as duplicates.
- Verify whether Gold table results match Silver data.
- Identify any missing or incorrect records.

## 2. Row Count Reconciliation

| Stage                     | Records |
| ------------------------- | ------: |
| Source CSV                |   1,283 |
| Bronze Records            |   1,283 |
| Clean Records             |   1,241 |
| Rejected Records          |      19 |
| Duplicate Records Removed |      23 |

**Reconciliation Formula:**

`Bronze = Clean + Rejected + Duplicates`

`1,283 = 1,241 + 19 + 23`

This shows that the reported record counts add up to the original Bronze count.

## 3. Data Quality Results

| Issue                    | Count | Action   |
| ------------------------ | ----: | -------- |
| Duplicate enrollment IDs |    23 | Removed  |
| Invalid progress values  |    11 | Rejected |
| Negative prices          |     8 | Rejected |

The rejected record count is 19. Issue counts may overlap, so they should not be added to calculate rejected records.

## 4. Gold Table Validation

The following Gold tables are checked against Silver data:

| Gold Table                 | What to Check                   |
| -------------------------- | ------------------------------- |
| `gold_monthly_enrollments` | Monthly enrollments and revenue |
| `gold_category_summary`    | Category-wise enrollments       |
| `gold_course_summary`      | Course-wise enrollments         |
| `gold_channel_summary`     | Channel-wise enrollments        |
| `gold_data_quality`        | Data-quality counts             |

The expected result is that Gold totals match the corresponding Silver calculations.

## 5. Validation Queries

Save the SQL queries in:

`validation/reconciliation_checks.sql`

**Check Bronze record count:**

```sql
SELECT COUNT(*) AS bronze_count
FROM edtech_catalog.learning.bronze_course_enrollments;
```

**Check monthly Gold records:**

```sql
SELECT *
FROM edtech_catalog.learning.gold_monthly_enrollments
ORDER BY enrollment_month;
```

## 6. Reconciliation Summary

| Comparison                             | Expected Result   |
| -------------------------------------- | ----------------- |
| Source and Bronze                      | Same record count |
| Bronze and cleaned/rejected/duplicates | Counts add up     |
| Silver and Gold enrollments            | Totals match      |
| Silver and Gold revenue                | Totals match      |

## 7. Sign-off Checklist

- [ ] Source and Bronze counts match.
- [ ] Record counts reconcile arithmetically.
- [ ] Data-quality issues are identified.
- [ ] Silver and Gold totals validated.
- [ ] All SQL validation checks completed.

**Run Date:** 09 November 2026
**Pipeline:** Bronze → Silver → Gold
**Result:** Record-count reconciliation matches. Gold total validation is pending.

## 8. Rerun Behavior

After rerunning the pipeline with the same source data and rules, record counts and summary results should remain consistent.
