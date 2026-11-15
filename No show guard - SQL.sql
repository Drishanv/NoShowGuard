
-- ============================================================
-- NoShowGuard Project
-- Part 2: SQL Analysis
-- Database: MySQL 8
-- ============================================================


-- ============================================================
-- TASK 2.1: BUILD AND LOAD THE DATABASE
--
-- Objective:
-- Create the NoShowGuard database and define the required
-- clinics and appointments tables.
-- ============================================================


-- ------------------------------------------------------------
-- Step 1: Create the database
-- ------------------------------------------------------------

CREATE DATABASE noshowguard;


-- ------------------------------------------------------------
-- Step 2: Select the database
-- ------------------------------------------------------------

USE noshowguard;


-- ------------------------------------------------------------
-- Step 3: Create the clinics table
--
-- This table stores clinic details, location information,
-- clinic tier and temperature data from the API.
-- ------------------------------------------------------------

CREATE TABLE clinics (
    clinic_id VARCHAR(5) PRIMARY KEY,
    clinic_name VARCHAR(40) NOT NULL,
    city VARCHAR(20) NOT NULL,
    tier VARCHAR(10),
    latitude DECIMAL(8,4),
    longitude DECIMAL(8,4),
    temp_c DECIMAL(5,1)
);


-- ------------------------------------------------------------
-- Step 4: Create the appointments table
--
-- This table stores the cleaned appointment records.
-- appointment_id is the primary key.
-- clinic_id is a foreign key referencing the clinics table.
-- ------------------------------------------------------------

CREATE TABLE appointments (
    appointment_id VARCHAR(8) PRIMARY KEY,
    patient_id VARCHAR(8) NOT NULL,
    clinic_id VARCHAR(5) NOT NULL,
    booked_on DATE,
    appt_date DATE,
    age INT,
    gender VARCHAR(1),
    distance_km DECIMAL(5,1),
    fee_inr INT,
    booking_channel VARCHAR(10),
    visit_type VARCHAR(12),
    reminder_sent VARCHAR(3),
    prior_no_shows INT,
    status VARCHAR(10),
    lead_days INT,
    no_show INT,

    FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id)
);


-- ------------------------------------------------------------
-- Step 5: Verify table creation
--
-- Expected result:
-- Two tables: clinics and appointments.
-- ------------------------------------------------------------

-- Step 6: Loaded sql file into the tables 


-- ============================================================
-- Step 7: Verify the imported data
-- ============================================================

-- Verify all required record counts

SELECT
    (SELECT COUNT(*) FROM clinics) AS total_clinics,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT SUM(no_show) FROM appointments) AS total_no_shows;


-- ============================================================
-- Step 8: Test the appointment primary key constraint
--
-- Objective:
-- Attempt to insert an appointment with an existing ID.
-- The database should reject the duplicate appointment_id.
-- ============================================================

INSERT INTO appointments (
    appointment_id,
    patient_id,
    clinic_id
)
VALUES (
    'A0001',
    'P999',
    'C01'
);


-- ============================================================
-- TASK 2.2: NO-SHOW RATE BY CLINIC
--
-- Objective:
-- Calculate total appointments, no-shows and no-show
-- percentage for each clinic.
--
-- Only clinics with at least 95 appointments are included.
-- Results are sorted by no-show percentage (highest first).
-- ============================================================


-- Step 1: Calculate clinic-wise no-show statistics

SELECT
    c.clinic_name,
    c.city,

    COUNT(a.appointment_id) AS appointments,

    SUM(a.no_show) AS no_shows,

    ROUND(
        100.0 * SUM(a.no_show) / COUNT(*),
        1
    ) AS no_show_pct

FROM appointments AS a

-- Join appointment records with clinic details
INNER JOIN clinics AS c
    ON a.clinic_id = c.clinic_id

-- Group results at the clinic level
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city

-- Include clinics having at least 95 appointments
HAVING COUNT(a.appointment_id) >= 95

-- Sort clinics by no-show percentage in descending order
ORDER BY no_show_pct DESC;

-- Step 2: Analyse all eight clinics
--
-- Objective:
-- Remove the minimum appointment restriction to include
-- every clinic and identify the highest no-show rate.
-- ============================================================

SELECT
    c.clinic_name,
    c.city,

    COUNT(a.appointment_id) AS appointments,

    SUM(a.no_show) AS no_shows,

    ROUND(
        100.0 * SUM(a.no_show) / COUNT(*),
        1
    ) AS no_show_pct

FROM appointments AS a

-- Join appointments with clinic details
INNER JOIN clinics AS c
    ON a.clinic_id = c.clinic_id

-- Group the results by clinic
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city

-- No HAVING condition: include all eight clinics

-- Sort by no-show percentage (highest first)
ORDER BY no_show_pct DESC;


-- ============================================================
-- TASK 2.3: DOES BOOKING FAR AHEAD MATTER?
--
-- Objective:
-- Group appointments into four lead-day bands using CASE WHEN.
-- Calculate appointments, no-shows and no-show percentage
-- for each band.
--
-- Upper limits are inclusive:
-- 1-7, 8-14, 15-30 and 31+
-- ============================================================


-- Step 1: Categorise appointments based on lead_days
-- Step 2: Calculate no-show statistics for each band

SELECT
    CASE
        WHEN lead_days BETWEEN 1 AND 7 THEN '1-7'
        WHEN lead_days BETWEEN 8 AND 14 THEN '8-14'
        WHEN lead_days BETWEEN 15 AND 30 THEN '15-30'
        WHEN lead_days >= 31 THEN '31+'
    END AS lead_day_band,

    COUNT(*) AS appointments,

    SUM(no_show) AS no_shows,

    ROUND(
        100.0 * SUM(no_show) / COUNT(*),
        1
    ) AS no_show_pct

FROM appointments

-- Group appointments by the CASE WHEN category
GROUP BY lead_day_band

-- Sort bands by their minimum lead-day value
ORDER BY MIN(lead_days);


-- ============================================================
-- TASK 2.4: MONTH-BY-MONTH NO-SHOW TREND
--
-- Objective:
-- Calculate monthly appointment counts and no-show rates.
-- Use LAG() to compare each month's rate with the previous
-- month's rate.
-- ============================================================


-- Step 1: Create a CTE containing monthly statistics

WITH monthly AS (
    SELECT
        SUBSTR(appt_date, 1, 7) AS month,

        COUNT(*) AS appointments,

        ROUND(
            100.0 * SUM(no_show) / COUNT(*),
            1
        ) AS no_show_pct

    FROM appointments

    GROUP BY SUBSTR(appt_date, 1, 7)
)


-- Step 2: Compare monthly rates using LAG()

SELECT
    month,
    appointments,
    no_show_pct,

    ROUND(
        no_show_pct - LAG(no_show_pct) OVER (
            ORDER BY month
        ),
        1
    ) AS change_from_previous_month

FROM monthly

ORDER BY month;


-- ============================================================
-- TASK 2.5: RANK CLINICS WITHIN EACH CITY
--
-- Objective:
-- Rank clinics within their respective cities based on
-- no-show percentage.
--
-- Compare each clinic's no-show rate with the overall
-- no-show rate across all appointments.
-- ============================================================


-- Step 1: Calculate clinic-wise no-show percentages

WITH clinic_rates AS (

    SELECT
        c.clinic_name AS clinic,
        c.city,

        ROUND(
            100.0 * SUM(a.no_show) / COUNT(*),
            1
        ) AS no_show_pct

    FROM appointments AS a

    INNER JOIN clinics AS c
        ON a.clinic_id = c.clinic_id

    GROUP BY
        c.clinic_id,
        c.clinic_name,
        c.city
)


-- Step 2: Rank clinics within each city
-- Step 3: Compare clinic rates with the overall no-show rate

SELECT
    clinic,
    city,
    no_show_pct,

    RANK() OVER (
        PARTITION BY city
        ORDER BY no_show_pct DESC
    ) AS rank_in_city,

    CASE
        WHEN no_show_pct > (
            SELECT
                100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'above'

        WHEN no_show_pct < (
            SELECT
                100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'below'

        ELSE 'equal'
    END AS vs_overall

FROM clinic_rates

ORDER BY
    city,
    rank_in_city;
    
-- ============================================================
-- TASK 2.5: FINAL VERIFICATION
-- Check all eight clinic rankings and overall no-show rate
-- ============================================================

SELECT
    clinic,
    city,
    no_show_pct,
    rank_in_city,
    vs_overall
FROM (
    SELECT
        c.clinic_name AS clinic,
        c.city,

        ROUND(
            100.0 * SUM(a.no_show) / COUNT(*),
            1
        ) AS no_show_pct,

        RANK() OVER (
            PARTITION BY c.city
            ORDER BY 100.0 * SUM(a.no_show) / COUNT(*) DESC
        ) AS rank_in_city,

        CASE
            WHEN SUM(a.no_show) * 100.0 / COUNT(*) >
                 (SELECT SUM(no_show) * 100.0 / COUNT(*)
                  FROM appointments)
                THEN 'above'
            WHEN SUM(a.no_show) * 100.0 / COUNT(*) <
                 (SELECT SUM(no_show) * 100.0 / COUNT(*)
                  FROM appointments)
                THEN 'below'
            ELSE 'equal'
        END AS vs_overall

    FROM appointments a
    INNER JOIN clinics c
        ON a.clinic_id = c.clinic_id

    GROUP BY c.clinic_id, c.clinic_name, c.city
) AS clinic_ranking
ORDER BY city, rank_in_city;    

