SELECT *
FROM accident;


-- To classify reportable/non-reportable case 
-- Case is reportable if MC>4D days and required to report to government enforcement body)
SELECT CASE
	WHEN lost_workday > 3 THEN 'DOSH Reportable'
    WHEN lost_workday < 4 THEN 'Non-Reportable'
ELSE 'Not Applicable'
END case_classification

FROM accident;

ALTER TABLE accident
ADD COLUMN case_classification text;

UPDATE accident
SET case_classification = 
		CASE WHEN lost_workday > 3 THEN 'DOSH Reportable'
			 WHEN lost_workday < 4 THEN 'Non-Reportable'
	ELSE 'Not Applicable'
	END;
    
SET SQL_SAFE_UPDATES = 0;

SELECT case_classification, COUNT(*) AS case_classification_count
FROM accident
GROUP BY case_classification;

-- To calculate Lost Time Injury Frequency Rate (LTIF)
-- To calculate Lost Time Injury Severity Rate (LTISR)
-- LTIR = (number of LTI x 1000,000)/Total hours worked
-- no.of workers/year = 1300 (A)
-- daily hours worker per employee = 8 hrs
-- days work in a week per employee = 5 days
-- total hours/week = (8 hrs x 5 days = 40 hrs) (B)
-- total week/year = 52 weeks (C)
-- (A)x(B)x(C) = 26,00,000
-- Total hours = total employee x working week x employee working hours x working day/week
-- Total hours = 1300 x 52 week x 8 hrs x 5 day
-- Total hours = 2704, 000

-- Number of accident per day
DROP TABLE accident2;

CREATE TEMPORARY TABLE accident2
SELECT *,ROW_NUMBER() OVER (PARTITION BY dateaccident ORDER BY dateaccident) as row_num
FROM accident;

-- LTI rate and LTI severity rate value
DROP TABLE accident3;

CREATE TEMPORARY TABLE accident3;
SELECT ROUND((COUNT(*)*1000000)/2704000,0) AS LTIF, ROUND((SUM(lost_workday)*1000000)/2704000,0) as LTISR
FROM accident;

SELECT *
FROM accident3;

-- number of accident by department
SELECT *
FROM accident2;

SELECT department,COUNT(*)
FROM accident2
GROUP BY department;

-- accident_factor that cause accident
SELECT accident_factor, COUNT(*) as factorcount
FROM accident2
GROUP BY accident_factor;

-- Total reportable accident case
SELECT case_classification,COUNT(case_classification)
FROM accident2
WHERE case_classification = 'DOSH Reportable'
GROUP by case_classification;

-- Total non-reportable accident case
SELECT case_classification,COUNT(case_classification)
FROM accident2
WHERE case_classification = 'Non-Reportable'
GROUP by case_classification;

-- Total accident
SELECT COUNT(case_classification) AS totalaccident
FROM accident2;
