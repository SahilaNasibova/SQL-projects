# Salary and Overtime Pay Calculation (Oracle SQL/PLSQL)

This project is an Oracle PL/SQL solution designed to calculate net salary and overtime pay based on the work calendar, sector-specific tax rules, and social insurance contribution rates.

## 📁 Project Contents

### 1. Work Calendar
The `work_calendar` table contains data for the year 2026, including:
- Working days and weekends
- Public holidays and non-working days
- Shortened working days (before public holidays)
- Daily working hours for each date

### 2. Net Salary Function — `calculate_net_salary`
Calculates net salary from gross salary based on:
- **Sector** (`ozel` – private / `dovlet` – public)
- Progressive income tax brackets
- Social insurance, unemployment insurance, and mandatory health insurance contributions
- Optional trade union membership fees
- Tax relief deductions

### 3. Overtime Pay Function — `calculate_overtime_salary`
Calculates total monthly pay (net salary + overtime pay):
- Calculates net salary using `calculate_net_salary`
- Retrieves total monthly working hours from `work_calendar`
- Calculates the hourly pay rate and overtime compensation at double the hourly rate (2×)

## 🛠 Technologies
- Oracle SQL / PL/SQL
- Sequences, functions, and `CONNECT BY` for calendar generation

## ▶️ Usage Example

```sql
SELECT calculate_overtime_salary(
    11,        -- Day
    3,         -- Month
    2026,      -- Year
    10000,     -- Gross salary
    5,         -- Overtime hours
    'dovlet',  -- Sector
    0          -- Trade union fee
) AS total_salary
FROM dual;
```

## 📌 Note

Tax and contribution rates are based on the 2026 regulations and the sector-specific logic implemented in the script for private (`ozel`) and public (`dovlet`) sectors.
