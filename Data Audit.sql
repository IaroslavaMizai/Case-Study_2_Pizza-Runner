
-- Set schema context

SET search_path TO pizza_runner; 

-- 1) table customer_orders  
  
/*1. Inspect distinct values*/
SELECT DISTINCT exclusions FROM customer_orders;
SELECT DISTINCT extras FROM customer_orders;

/*2.Count frequency of each value*/

SELECT exclusions, COUNT(*) 
FROM customer_orders
GROUP BY exclusions
ORDER BY COUNT(*) DESC;

SELECT extras, COUNT(*) 
FROM customer_orders
GROUP BY extras
ORDER BY COUNT(*) DESC;

/*3. Check for NULL vs non-NULL inconsistencies*/

SELECT
    SUM(CASE WHEN exclusions IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN exclusions = '' THEN 1 END) AS empty_string,
    SUM(CASE WHEN exclusions ILIKE '%null%' THEN 1 END) AS fake_nulls
FROM customer_orders;

SELECT
    SUM(CASE WHEN extras IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN extras = '' THEN 1 END) AS empty_string,
    SUM(CASE WHEN extras ILIKE '%null%' THEN 1 END) AS fake_nulls
FROM customer_orders;

/*4. Detect non-numeric characters*/

SELECT exclusions
FROM customer_orders
WHERE exclusions !~ '^[0-9,\s]*$'
  AND exclusions IS NOT NULL;

SELECT extras
FROM customer_orders
WHERE extras !~ '^[0-9,\s]*$'
  AND extras IS NOT NULL;

/*5. Detect inconsistent separators and spacing*/

SELECT exclusions
FROM customer_orders
WHERE exclusions LIKE '%, %' 
   OR exclusions LIKE '% ,%'
   OR exclusions LIKE '%  %';

SELECT extras
FROM customer_orders
WHERE extras LIKE '%, %' 
   OR extras LIKE '% ,%'
   OR extras LIKE '%  %';

/* 6. Identify multi-value formats*/

SELECT
    CASE WHEN exclusions LIKE '%,%' THEN 'list' ELSE 'single' END AS format_type,
    COUNT(*)
FROM customer_orders
GROUP BY format_type;

SELECT
    CASE WHEN extras LIKE '%,%' THEN 'list' ELSE 'single' END AS format_type,
    COUNT(*)
FROM customer_orders
GROUP BY format_type;

/*7. Validate numeric ranges*/

--Check exclusions
WITH cleaned_exclusions AS (
    SELECT
        UNNEST(
            STRING_TO_ARRAY(
                REGEXP_REPLACE(exclusions, '\s+', '', 'g'),  -- remove spaces
                ','                                           -- split into array
            )
        ) AS ingredient_text
    FROM customer_orders
    WHERE exclusions IS NOT NULL
)
SELECT DISTINCT ingredient_text::INT AS ingredient
FROM cleaned_exclusions
WHERE ingredient_text <> 'null'     -- ignore text 'null'
  AND ingredient_text <> ''         -- ignore empty text
  AND (ingredient_text::INT < 1 OR ingredient_text::INT > 12)
ORDER BY ingredient;

-- Check extras 
WITH cleaned_extras AS (
    SELECT
        UNNEST(
            STRING_TO_ARRAY(
                REGEXP_REPLACE(extras, '\s+', '', 'g'),  -- remove spaces
                ','
            )
        ) AS ingredient_text
    FROM customer_orders
    WHERE extras IS NOT NULL
)
SELECT DISTINCT ingredient_text::INT AS ingredient
FROM cleaned_extras
WHERE ingredient_text <> 'null'     
  AND ingredient_text <> ''         
  AND (ingredient_text::INT < 1 OR ingredient_text::INT > 12)
ORDER BY ingredient;


-- 2) table runner_orders; 


/* 1. Inspect distinct values Detect unexpected formats and placeholder values*/

SELECT DISTINCT pickup_time FROM runner_orders;
SELECT DISTINCT distance FROM runner_orders;
SELECT DISTINCT duration FROM runner_orders;
SELECT DISTINCT cancellation FROM runner_orders;


/*  2. Frequency analysis. Identify dominant patterns and anomalies*/

SELECT pickup_time, COUNT(*)
FROM runner_orders
GROUP BY pickup_time
ORDER BY COUNT(*) DESC;

SELECT distance, COUNT(*)
FROM runner_orders
GROUP BY distance
ORDER BY COUNT(*) DESC;

SELECT duration, COUNT(*)
FROM runner_orders
GROUP BY duration
ORDER BY COUNT(*) DESC;

SELECT cancellation, COUNT(*)
FROM runner_orders
GROUP BY cancellation
ORDER BY COUNT(*) DESC;


/* 3. Check for NULL vs non-NULL inconsistencies
pickup_time should not mix NULL, empty string, and 'null'*/

SELECT
    SUM(CASE WHEN pickup_time IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN pickup_time = '' THEN 1 END) AS empty_string_count,
    SUM(CASE WHEN pickup_time ILIKE '%null%' THEN 1 END) AS fake_null_count
FROM runner_orders;


/* 4. Detect non-numeric characters
distance and duration should contain numeric values only*/

SELECT distance
FROM runner_orders
WHERE distance !~ '^[0-9.\s]*$'
  AND distance IS NOT NULL;

SELECT duration
FROM runner_orders
WHERE duration !~ '^[0-9.\s]*$'
  AND duration IS NOT NULL;


/* 5. Detect inconsistent spacing and formatting
These patterns must be normalized before casting*/

SELECT distance
FROM runner_orders
WHERE distance LIKE '%  %'
   OR distance LIKE '% km'
   OR distance LIKE 'km %';


SELECT duration
FROM runner_orders
WHERE duration LIKE '%  %'
   OR duration ILIKE '%min%'
   OR duration ILIKE '%minutes%';


/*6. Cancellation field sanity check. Only meaningful cancellation values should exist */

SELECT cancellation
FROM runner_orders
WHERE cancellation IS NOT NULL
  AND cancellation NOT ILIKE '%cancel%';
