/* =========================================================
   WORK CALENDAR
   ========================================================= */

CREATE TABLE work_calendar (
    calendar_id       NUMBER PRIMARY KEY,
    day_number        NUMBER,
    month_name        VARCHAR2(30),
    year_number       NUMBER,
    day_name          VARCHAR2(30),
    calendar_date     DATE,
    is_weekday        VARCHAR2(30),
    is_weekend        VARCHAR2(30),
    is_workday        VARCHAR2(30),
    daily_work_hours  NUMBER,
    month_number      NUMBER
);

CREATE SEQUENCE work_calendar_seq
START WITH 1
INCREMENT BY 1;


/* =========================================================
   POPULATE 2026 CALENDAR
   ========================================================= */

INSERT INTO work_calendar (
    calendar_id,
    day_number,
    month_name,
    year_number,
    day_name,
    calendar_date
)
SELECT
    work_calendar_seq.NEXTVAL,
    EXTRACT(DAY FROM DATE '2026-01-01' + LEVEL - 1),
    TRIM(TO_CHAR(DATE '2026-01-01' + LEVEL - 1, 'MONTH')),
    EXTRACT(YEAR FROM DATE '2026-01-01' + LEVEL - 1),
    TRIM(TO_CHAR(DATE '2026-01-01' + LEVEL - 1, 'DAY')),
    DATE '2026-01-01' + LEVEL - 1
FROM dual
CONNECT BY LEVEL <= DATE '2026-12-31' - DATE '2026-01-01' + 1;


UPDATE work_calendar
SET month_number = TO_NUMBER(TO_CHAR(calendar_date, 'MM'));


UPDATE work_calendar
SET is_weekday = 'yes'
WHERE LOWER(TRIM(day_name)) IN (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
);


UPDATE work_calendar
SET is_weekday = 'no'
WHERE LOWER(TRIM(day_name)) IN (
    'saturday',
    'sunday'
);


UPDATE work_calendar
SET is_weekend = 'yes'
WHERE LOWER(TRIM(day_name)) IN (
    'saturday',
    'sunday'
);


UPDATE work_calendar
SET is_weekend = 'no'
WHERE LOWER(TRIM(day_name)) IN (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
);


/* =========================================================
   NON-WORKING DAYS
   ========================================================= */

UPDATE work_calendar
SET is_workday = 'no'
WHERE LOWER(TRIM(day_name)) IN ('saturday', 'sunday')
   OR calendar_date IN (
        DATE '2026-01-01',
        DATE '2026-01-02',
        DATE '2026-01-20',
        DATE '2026-03-08',
        DATE '2026-03-09',
        DATE '2026-03-20',
        DATE '2026-03-21',
        DATE '2026-03-22',
        DATE '2026-03-23',
        DATE '2026-03-24',
        DATE '2026-03-25',
        DATE '2026-03-26',
        DATE '2026-03-27',
        DATE '2026-03-30',
        DATE '2026-05-09',
        DATE '2026-05-11',
        DATE '2026-05-27',
        DATE '2026-05-28',
        DATE '2026-05-29',
        DATE '2026-06-15',
        DATE '2026-06-26',
        DATE '2026-11-08',
        DATE '2026-11-09',
        DATE '2026-11-10',
        DATE '2026-12-31'
   );


UPDATE work_calendar
SET is_workday = 'yes'
WHERE LOWER(TRIM(day_name)) IN (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
)
AND calendar_date NOT IN (
    DATE '2026-01-01',
    DATE '2026-01-02',
    DATE '2026-01-20',
    DATE '2026-03-08',
    DATE '2026-03-09',
    DATE '2026-03-20',
    DATE '2026-03-21',
    DATE '2026-03-22',
    DATE '2026-03-23',
    DATE '2026-03-24',
    DATE '2026-03-25',
    DATE '2026-03-26',
    DATE '2026-03-27',
    DATE '2026-03-30',
    DATE '2026-05-09',
    DATE '2026-05-11',
    DATE '2026-05-27',
    DATE '2026-05-28',
    DATE '2026-05-29',
    DATE '2026-06-15',
    DATE '2026-06-26',
    DATE '2026-11-08',
    DATE '2026-11-09',
    DATE '2026-11-10',
    DATE '2026-12-31'
);


/* Standard working day */

UPDATE work_calendar
SET daily_work_hours = 8
WHERE is_workday = 'yes';


UPDATE work_calendar
SET daily_work_hours = 0
WHERE is_workday = 'no';


/* Short working days */

UPDATE work_calendar
SET daily_work_hours = 7
WHERE calendar_date IN (
    DATE '2026-01-19',
    DATE '2026-03-19',
    DATE '2026-05-08',
    DATE '2026-05-26',
    DATE '2026-06-25',
    DATE '2026-12-30'
);

COMMIT;


/* =========================================================
   NET SALARY FUNCTION
   ========================================================= */

CREATE OR REPLACE FUNCTION calculate_net_salary (
    p_gross_salary    NUMBER,
    p_sector          VARCHAR2,
    p_tax_relief      NUMBER,
    p_union_fee_rate  NUMBER
)
RETURN NUMBER
IS
    v_taxable_income         NUMBER := 0;
    v_income_tax             NUMBER := 0;
    v_social_insurance       NUMBER := 0;
    v_unemployment_insurance NUMBER := 0;
    v_health_insurance       NUMBER := 0;
    v_union_fee              NUMBER := 0;
    v_net_salary             NUMBER;
BEGIN

    v_taxable_income := p_gross_salary - p_tax_relief;

    /* Private sector */
    IF p_sector = 'ozel' THEN

        IF v_taxable_income <= 2500 THEN
            v_income_tax := (v_taxable_income - 200) * 3 / 100;

        ELSIF v_taxable_income <= 8000 THEN
            v_income_tax :=
                75 + (v_taxable_income - 2500) * 10 / 100;

        ELSE
            v_income_tax :=
                625 + (v_taxable_income - 8000) * 14 / 100;
        END IF;


        IF p_gross_salary <= 200 THEN
            v_social_insurance :=
                p_gross_salary * 3 / 100;

        ELSIF p_gross_salary < 8000 THEN
            v_social_insurance :=
                6 + (p_gross_salary - 200) * 10 / 100;

        ELSE
            v_social_insurance :=
                786 + (p_gross_salary - 8000) * 10 / 100;
        END IF;


        v_unemployment_insurance :=
            p_gross_salary * 0.5 / 100;


        IF p_gross_salary <= 2500 THEN
            v_health_insurance :=
                p_gross_salary * 2 / 100;

        ELSE
            v_health_insurance :=
                50 + (p_gross_salary - 2500) * 0.5 / 100;
        END IF;


        v_union_fee :=
            p_gross_salary * p_union_fee_rate / 100;


    /* Public sector */
    ELSIF p_sector = 'dovlet' THEN

        IF v_taxable_income <= 2500 THEN
            v_income_tax :=
                (v_taxable_income - 200) * 14 / 100;

        ELSE
            v_income_tax :=
                350 + (v_taxable_income - 2500) * 25 / 100;
        END IF;


        v_social_insurance :=
            p_gross_salary * 3 / 100;


        v_unemployment_insurance :=
            p_gross_salary * 0.5 / 100;


        IF p_gross_salary <= 8000 THEN
            v_health_insurance :=
                p_gross_salary * 2 / 100;

        ELSE
            v_health_insurance :=
                160 + (p_gross_salary - 8000) * 0.5 / 100;
        END IF;


        v_union_fee :=
            p_gross_salary * p_union_fee_rate / 100;

    END IF;


    v_net_salary :=
          p_gross_salary
        - v_income_tax
        - v_social_insurance
        - v_unemployment_insurance
        - v_health_insurance
        - v_union_fee;


    RETURN TRUNC(v_net_salary, 2);

END calculate_net_salary;
/


/* =========================================================
   OVERTIME SALARY FUNCTION
   ========================================================= */

CREATE OR REPLACE FUNCTION calculate_overtime_salary (
    p_day_number       NUMBER,
    p_month_number     NUMBER,
    p_year_number      NUMBER,
    p_gross_salary     NUMBER,
    p_overtime_hours   NUMBER,
    p_sector           VARCHAR2,
    p_union_fee_rate   NUMBER
)
RETURN NUMBER
IS
    v_hourly_rate         NUMBER;
    v_overtime_pay        NUMBER;
    v_total_salary        NUMBER;
    v_monthly_work_hours  NUMBER;
    v_net_salary          NUMBER;
BEGIN

    v_net_salary := calculate_net_salary(
        p_gross_salary,
        p_sector,
        0,
        p_union_fee_rate
    );


    SELECT SUM(daily_work_hours)
    INTO v_monthly_work_hours
    FROM work_calendar
    WHERE month_number = p_month_number
      AND year_number = p_year_number;


    v_hourly_rate :=
        v_net_salary / v_monthly_work_hours;


    v_overtime_pay :=
        p_overtime_hours * v_hourly_rate * 2;


    v_total_salary :=
        v_net_salary + v_overtime_pay;


    RETURN TRUNC(v_total_salary, 2);

END calculate_overtime_salary;
/


/* =========================================================
   EXAMPLES
   ========================================================= */

SELECT calculate_overtime_salary(
    11,
    3,
    2026,
    10000,
    5,
    'dovlet',
    0
) AS total_salary
FROM dual;


SELECT calculate_overtime_salary(
    23,
    10,
    2026,
    10000,
    5,
    'dovlet',
    0
) AS total_salary
FROM dual;