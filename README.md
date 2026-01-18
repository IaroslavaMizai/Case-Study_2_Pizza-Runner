# 🍕Case Study #2 : Pizza Runner

This project is part of [the 8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-2/) and focuses on analysing operational, customer, and financial data for Pizza Runner, a fictional pizza delivery startup.
The case study focuses on exploring, cleaning, and transforming delivery and order data to answer real-world business questions. Key goals include understanding pizza metrics, runner performance, customer experience, ingredient usage, and revenue optimization.

## 📝Table of Contents
1. [Business Task](#point-1)
2. [Tools Used](#point-2)
3. [Entity Relationship Diagram](#point-3)
4. [Database Setup](#point-4)
5. [Data Quality Checks](#point-5)
6. [Data Cleaning and Transformation](#point-6)
7. [Solution](#point-7)
   * [A. Pizza Metrics](#group-1)
   * [B. Runner and Customer Experience](#group-2)
   * [C. Ingredient Optimisation](#group-3)
   * [D. Pricing and Ratings](#group-4)
8. [Conclusions](#point-8)
 -------------------------------------------------------- 
## 🎯 1. Business Task <a id="point-1"></a>
The Pizza Runner project simulates a real-world pizza delivery service. The main business objective is to analyze order, delivery, and ingredient data to help optimize operations, improve runner efficiency, track customer satisfaction, and maximize revenue. 

Key tasks include:
* Calculate pizza sales metrics and revenue.
* Evaluate runner performance and customer experience.
* Analyze ingredient usage to optimize pizza recipes.
* Implement a rating system for deliveries.
* Assess the financial impact of extras and delivery costs.

This case study provides hands-on experience in data cleaning, SQL querying, aggregation, and business analytics.

## 🛠️ 2. Tools Used <a id="point-2"></a>

* PostgreSQL – Used for storing, querying, and aggregating pizza orders, runners, and ingredients data. Provides SQL engine for performing complex joins, aggregations, and data transformations.
* Visual Studio Code – SQL editor and workspace for writing and testing queries, organizing scripts, and managing the project files.
* DBDiagram.io – Tool for visualizing the database schema and relationships between tables, helping to understand data structure and plan queries.


## 🗺️ 3. Entity Relationship Diagram (ERD) <a id="point-3"></a>

<p align="left">
  <img src="images\ERD_Pizza _Runner.png" width="600">
</p>

## 🧱 4. Database Setup <a id="point-4"></a>

``` sql
CREATE DATABASE pizza_runner
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    TEMPLATE template0;


CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
```


## 🔍 5.Data Quality Checks <a id="point-5"></a>

### A. Inspect *exclusions* and *extras* columns of customer_orders table

Algorithm: 
1. Inspect distinct values
2. Count frequency of each value
3. Check for NULL vs non-NULL inconsistencies
4. Detect non-numeric characters
5. Detect inconsistent separators and spacing
6. Identify multi-value formats
7. Validate numeric ranges

### 1. Inspect distinct values

Goal: detect unexpected patterns, inconsistent formats, typos, or "fake" values.

``` sql
SELECT DISTINCT exclusions FROM customer_orders;
```

| exclusions |
|------------|
| 2, 6       |
| 4          |
| null       |

``` sql
SELECT DISTINCT extras FROM customer_orders;
```

| extras |
|--------|
| NULL   |
| null   |
| 1, 5   |
| 1, 4   |
|        |
| 1      |



### 2. Count frequency of each value
Understanding how often each anomaly appears helps prioritize cleanup.

Goal: 
``` sql
SELECT exclusions, COUNT(*) 
FROM customer_orders
GROUP BY exclusions
ORDER BY COUNT(*) DESC;
```
| exclusions | count |
|------------|-------|
| null       | 5     |
| 4          | 4     |
|            | 4     |
| 2, 6       | 1     |


``` sql
SELECT extras, COUNT(*) 
FROM customer_orders
GROUP BY extras
ORDER BY COUNT(*) DESC;
```
| extras | count |
|--------|-------|
|        | 6     |
| null   | 3     |
| 1      | 2     |
| NULL   | 1     |
| 1, 5   | 1     |
| 1, 4   | 1     |


### 3. Check for NULL vs non-NULL inconsistencies
Why?
Because text datasets often include:
actual SQL NULL
empty strings
the literal string 'null'
variations like 'NULL', 'Null', 'n u l l'

```sql
SELECT
    SUM(CASE WHEN exclusions IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN exclusions = '' THEN 1 END) AS empty_string,
    SUM(CASE WHEN exclusions ILIKE '%null%' THEN 1 END) AS fake_nulls
FROM customer_orders;
```
| null_count | empty_string | fake_nulls |
|------------|--------------|------------|
| NULL       | 4            | 5          |

!It means, there are no real NULLs in in exclusions column, empty values are string '', but there are fake nulls (strings)!

```sql
SELECT
    SUM(CASE WHEN extras IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN extras = '' THEN 1 END) AS empty_string,
    SUM(CASE WHEN extras ILIKE '%null%' THEN 1 END) AS fake_nulls
FROM customer_orders;
```
| null_count | empty_string | fake_nulls |
|------------|--------------|------------|
| 1          | 6            | 3          |

!There is 1 real NULL in in extras column, empty values are string '', but there are fake nulls (strings)!

### 4. Detect non-numeric characters
Why?
Because text datasets often include:
alphabetic characters
unexpected symbols
invalid separators
emojis (yes, it happens)
broken CSV formats

These columns should contain ingredient IDs — numeric lists.
So check if the dataset contains anything else:

```sql
SELECT exclusions
FROM customer_orders
WHERE exclusions !~ '^[0-9,\s]*$'
  AND exclusions IS NOT NULL;
```
| exclusions |
|------------|
| null       |
| null       |
| null       |
| null       |
| null       |

There are only strings 'null'-s (fake nulls) in exclusions column 

```sql
SELECT extras
FROM customer_orders
WHERE extras !~ '^[0-9,\s]*$'
  AND extras IS NOT NULL;
```
| extras|
|-------|
| null  |
| null  |
| null  |

There are only strings 'null'-s (fake nulls) in extras column 

### 5. Detect inconsistent separators and spacing

These patterns indicate formatting that must be normalized before parsing.
```sql
SELECT exclusions
FROM customer_orders
WHERE exclusions LIKE '%, %' 
   OR exclusions LIKE '% ,%'
   OR exclusions LIKE '%  %';
```

| exclusions |
| ---------- |
| 2, 6       |

```sql
SELECT extras
FROM customer_orders
WHERE extras LIKE '%, %' 
   OR extras LIKE '% ,%'
   OR extras LIKE '%  %';
```

| extras |
| ------ |
| 1, 5   |
| 1, 4   |

### 6. Identify multi-value formats

Check how many rows contain lists vs single values.

This helps determine need to:
    explode arrays
    normalize commas
    trim spaces
    handle one-to-many relationships

```sql
SELECT
    CASE WHEN exclusions LIKE '%,%' THEN 'list' ELSE 'single' END AS format_type,
    COUNT(*)
FROM customer_orders
GROUP BY format_type;
```

| format_type | count |
| ----------- | ----- |
| single      | 13    |
| list        | 1     |


```sql
SELECT
    CASE WHEN extras LIKE '%,%' THEN 'list' ELSE 'single' END AS format_type,
    COUNT(*)
FROM customer_orders
GROUP BY format_type;
```
| format_type | count |
| ----------- | ----- |
| single      | 12    |
| list        | 2     |


### 7. Validate numeric ranges


```sql
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
```
After cleaning and parsing the values in the exclusions column, all numeric ingredients fall within the valid range of 1 to 12. There are no invalid or out-of-range numeric values in the exclusions data, meaning this column contains consistent and valid ingredient IDs or acceptable null/empty values.

```sql
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
```
Similarly, after applying the same cleaning and validation process to the extras column, all numeric values are also within the valid range of 1 to 12.
No anomalies or invalid ingredient IDs were detected in the extras column.

### B. Inspect runner_orders table

Algorithm: 
1. Inspect distinct values Detect unexpected formats and placeholder values
2. Frequency analysis. Identify dominant patterns and anomalies
3. Check for NULL vs non-NULL inconsistencies pickup_time should not mix NULL, empty string, and 'null'
4. Detect non-numeric charactersdistance and duration should contain numeric values only
5. Detect inconsistent spacing and formatting. These patterns must be normalized before casting
6. Cancellation field sanity check. Only meaningful cancellation values should exist 

#### 1. Inspect distinct values Detect unexpected formats and placeholder values

``` sql
SELECT DISTINCT pickup_time FROM runner_orders;
```
| pickup_time         |
| ------------------- |
| 2020-01-08 21:10:57 |
| 2020-01-11 18:50:20 |
| null                |
| 2020-01-10 00:15:02 |
| 2020-01-01 19:10:54 |
| 2020-01-08 21:30:45 |
| 2020-01-01 18:15:34 |
| 2020-01-03 00:12:37 |
| 2020-01-04 13:53:03 |

There are valid timestamp values in pickup_time, but also some NULLs. This indicates that some deliveries may not have been picked up or the data was not recorded. Further cleaning may be needed to handle missing timestamps before calculating delivery metrics.

```sql
SELECT DISTINCT distance FROM runner_orders;
```
| distance |
| -------- |
| 23.4 km  |
| 25km     |
| 13.4km   |
| 23.4     |
| 20km     |
| 10km     |
| null     |

Distance values are inconsistent in format (some have units “km”, others are numeric only). Null values indicate missing records. Standardization is needed to convert all distances to a numeric type (e.g., FLOAT) in kilometers for accurate analysis.

```sql
SELECT DISTINCT duration FROM runner_orders;
```
| duration   |
| ---------- |
| 15 minute  |
| 20 mins    |
| 27 minutes |
| null       |
| 15         |
| 40         |
| 10minutes  |
| 32 minutes |
| 25mins     |

The duration column has inconsistent formatting (text like “minutes”, “mins”, concatenated numbers, and numeric-only values). Some entries are null. A normalization step is required to convert all durations into a consistent numeric value representing minutes.

```sql
SELECT DISTINCT cancellation FROM runner_orders;
```
| cancellation            |
| ----------------------- |
| NULL                    |
| null                    |
| Customer Cancellation   |
| Restaurant Cancellation |

Cancellation values are partially inconsistent in case and NULL representation. Two types of cancellations exist: customer-initiated and restaurant-initiated. Cleaning should standardize NULLs and categorical values for proper analysis.

#### 2. Frequency analysis. Identify dominant patterns and anomalies

``` sql
SELECT pickup_time, COUNT(*)
FROM runner_orders
GROUP BY pickup_time
ORDER BY COUNT(*) DESC;
```
| pickup_time         | count |
| ------------------- | ----- |
| null                | 2     |
| 2020-01-11 18:50:20 | 1     |
| 2020-01-10 00:15:02 | 1     |
| 2020-01-01 19:10:54 | 1     |
| 2020-01-08 21:30:45 | 1     |
| 2020-01-01 18:15:34 | 1     |
| 2020-01-03 00:12:37 | 1     |
| 2020-01-08 21:10:57 | 1     |
| 2020-01-04 13:53:03 | 1     |

Pickup_time contains a small number of missing values (null). Most orders have unique pickup times, indicating no repeated duplicates. Data may require imputation or handling of nulls for time-based metrics.

```sql
SELECT distance, COUNT(*)
FROM runner_orders
GROUP BY distance
ORDER BY COUNT(*) DESC;
```
| distance | count |
| -------- | ----- |
| 20km     | 2     |
| null     | 2     |
| 10       | 1     |
| 13.4km   | 1     |
| 23.4     | 1     |
| 23.4 km  | 1     |
| 10km     | 1     |
| 25km     | 1     |

Distance values show inconsistent formatting (with/without "km") and some missing values. Normalization is required to convert all values to numeric kilometers for accurate calculations.

```sql
SELECT duration, COUNT(*)
FROM runner_orders
GROUP BY duration
ORDER BY COUNT(*) DESC;
```
| duration   | count |
| ---------- | ----- |
| null       | 2     |
| 20 mins    | 1     |
| 27 minutes | 1     |
| 15         | 1     |
| 40         | 1     |
| 10minutes  | 1     |
| 32 minutes | 1     |
| 15 minute  | 1     |
| 25mins     | 1     |

Duration has mixed formats and null values. Standardizing all entries to numeric minutes is necessary for consistent delivery time analysis.

```sql
SELECT cancellation, COUNT(*)
FROM runner_orders
GROUP BY cancellation
ORDER BY COUNT(*) DESC;
```
| cancellation            | count |
| ----------------------- | ----- |
| NULL                    | 3     |
| null                    | 3     |
|                         | 2     |
| Customer Cancellation   | 1     |
| Restaurant Cancellation | 1     |

Cancellation column contains multiple representations of nulls (NULL, null, empty strings) and few labeled cancellations. Data cleaning is required to unify nulls and categorize cancellations consistently.

#### 3. Check for NULL vs non-NULL inconsistencies pickup_time should not mix NULL, empty string, and 'null'

```sql
SELECT
    SUM(CASE WHEN pickup_time IS NULL THEN 1 END) AS null_count,
    SUM(CASE WHEN pickup_time = '' THEN 1 END) AS empty_string_count,
    SUM(CASE WHEN pickup_time ILIKE '%null%' THEN 1 END) AS fake_null_count
FROM runner_orders;
```
| null_count | empty_string_count | fake_null_count |
|------------|------------------|----------------|
| 0          | 0                | 2              |

There are no real SQL NULLs or empty strings in the pickup_time column. However, there are 2 entries containing the string 'null', which are inconsistent and should be cleaned before further processing.

#### 4. Detect non-numeric characters distance and duration should contain numeric values only

```sql
SELECT distance
FROM runner_orders
WHERE distance !~ '^[0-9.\s]*$'
  AND distance IS NOT NULL;
```
| distance   |
|------------|
| 20km       |
| 20km       |
| 13.4km     |
| 25km       |
| 23.4 km    |
| 10km       |

The distance column contains several non-numeric characters (km, spaces). These values should be cleaned and converted to pure numeric format (e.g., 20, 13.4) for calculations.

```sql
SELECT duration
FROM runner_orders
WHERE duration !~ '^[0-9.\s]*$'
  AND duration IS NOT NULL;
```
| duration     |
|--------------|
| 32 minutes   |
| 27 minutes   |
| 20 mins      |
| 25mins       |
| 15 minute    |
| 10minutes    |

The duration column contains text labels (minutes, mins, etc.). These need to be cleaned and converted to numeric values representing minutes for proper analysis.

#### 5. Detect inconsistent spacing and formatting. These patterns must be normalized before casting

```sql
SELECT distance
FROM runner_orders
WHERE distance LIKE '%  %'
   OR distance LIKE '% km'
   OR distance LIKE 'km %';
```
| distance   |
|------------|
| 23.4 km    |
  
The distance column has inconsistent spacing and unit formatting. All distances should be standardized to numeric values (e.g., 23.4) for reliable calculations.

```sql
SELECT duration
FROM runner_orders
WHERE duration LIKE '%  %'
   OR duration ILIKE '%min%'
   OR duration ILIKE '%minutes%';
```

| duration     |
|--------------|
| 32 minutes   |
| 27 minutes   |
| 20 mins      |
| 25mins       |
| 15 minute    |
| 10minutes    |

The duration column contains inconsistent text formats. All durations should be cleaned and converted to numeric minutes to enable proper computation and aggregation.

#### 6. Cancellation field sanity check. Only meaningful cancellation values should exist 
```sql
SELECT cancellation
FROM runner_orders
WHERE cancellation IS NOT NULL
  AND cancellation NOT ILIKE '%cancel%';
```

| cancellation |
|--------------|
|              |
|              |
| null         |
| null         |
| null         |

The cancellation column contains only empty strings and string 'null'. There are no valid cancellation entries.  
For further analysis, standardize this column: convert empty strings and 'null' strings to actual SQL NULL to maintain consistency.


## 🧼 6. Data Cleaning and Transformation <a id="point-6"></a>

The  *customer_orders* , *runner_orders* and *pizza_names* tables require data cleaning before being used in subsequent queries. 

```sql

-- Set schema context

SET search_path TO pizza_runner; 

-- 1 customer_orders

CREATE OR REPLACE VIEW cleaned_customer_orders AS
WITH temp_customer_orders AS (
    SELECT 
        order_id, 
        customer_id, 
        pizza_id, 
        CASE 
            WHEN exclusions IN ('', 'null', 'Null') THEN NULL
            ELSE TRIM(REPLACE(exclusions, ' ', ''))
        END AS excluded_topping_ids,
        CASE 
            WHEN extras IN ('', 'null', 'Null') THEN NULL
            ELSE TRIM(REPLACE(extras, ' ', ''))
        END AS extra_topping_ids,
        order_time
    FROM customer_orders
)
SELECT * FROM temp_customer_orders;

-- 2 runner_orders  

CREATE OR REPLACE VIEW cleaned_runner_orders AS
WITH temp_runner_orders AS (
    SELECT 
        order_id, 
        runner_id,

        -- cancellation flag
        CASE
            WHEN cancellation IS NULL
                 OR cancellation ILIKE '%null%'
                 OR TRIM(cancellation) = ''
            THEN NULL
            ELSE TRIM(cancellation)
        END AS cancellation,

        -- pickup timestamp
        CASE 
            WHEN pickup_time IS NULL
                 OR pickup_time ILIKE 'null'
                 OR TRIM(pickup_time) = ''
            THEN NULL
            ELSE pickup_time::timestamp
        END AS pickup_time,

        -- delivery distance in km
        CASE 
            WHEN distance IS NULL
                 OR distance ILIKE '%null%'
                 OR TRIM(distance) = ''
            THEN NULL
            ELSE REGEXP_REPLACE(distance, '[^0-9\.]', '', 'g')::FLOAT
        END AS distance_km,

        -- delivery duration in minutes
        CASE
            WHEN duration IS NULL
                 OR duration ILIKE '%null%'
                 OR TRIM(duration) = ''
                 OR duration ~ '^\s+$'
            THEN NULL
            ELSE REGEXP_REPLACE(duration, '[^0-9]', '', 'g')::INT
        END AS duration_min

    FROM runner_orders
)
SELECT * FROM temp_runner_orders;

-- 3 pizza_names 

CREATE OR REPLACE VIEW pizza_names_cleaned AS
WITH temp_pizza_names AS (
    SELECT 
        pizza_id,
        CASE
            WHEN LOWER(pizza_name) = 'meatlovers' THEN 'Meat Lovers'
            ELSE pizza_name
        END AS pizza_name
    FROM pizza_names
)
SELECT *
FROM temp_pizza_names;
```

## 💡 7. Solutions <a id="point-7"></a>

   * [A. Pizza Metrics](#group-1)
   * [B. Runner and Customer Experience](#group-2)
   * [C. Ingredient Optimisation](#group-3)
   * [D. Pricing and Ratings](#group-4)
   * [E. Bonus DML Challenges (DML = Data Manipulation Language)](#group-5)
   

### A. Pizza Metrics <a id="group-1"></a>

#### 1️⃣ How many pizzas were ordered?

```sql
SELECT COUNT(*) AS pizza_counted
FROM cleaned_customer_orders;
```
| pizza_counted |
|---------------|
| 14            |

#### 2️⃣ How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT(order_id)) AS unique_orders
FROM cleaned_customer_orders;
```
| unique_orders |
|---------------|
| 10            |

#### 3️⃣ How many successful orders were delivered by each runner?
```sql
SELECT 
    runner_id,
    COUNT(*) AS successful_deliveries
FROM cleaned_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;
```
| runner_id | successful_deliveries |
|-----------|----------------------|
| 1         | 4                    |
| 2         | 3                    |
| 3         | 1                    |

#### 4️⃣ How many of each type of pizza was delivered?

```sql
SELECT 
    n.pizza_name,
    COUNT(*) AS delivered_count
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r ON o.order_id = r.order_id
LEFT JOIN pizza_names_cleaned AS n ON o.pizza_id = n.pizza_id
WHERE r.cancellation IS NULL
GROUP BY n.pizza_name
ORDER BY delivered_count DESC;
```
| pizza_name  | delivered_count|
|-------------|----------------|
| Meat Lovers | 9              |
| Vegetarian  | 3              |

#### 5️⃣ How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT  
    o.customer_id,
    n.pizza_name,
    COUNT(*) AS pizza_count
FROM cleaned_customer_orders AS o 
LEFT JOIN pizza_names_cleaned AS n ON o.pizza_id = n.pizza_id
GROUP BY o.customer_id, n.pizza_name
ORDER BY o.customer_id, n.pizza_name;
```
| customer_id | pizza_name   | pizza_count |
|-------------|--------------|-------------|
| 101         | Meat Lovers  | 2           |
| 101         | Vegetarian   | 1           |
| 102         | Meat Lovers  | 2           |
| 102         | Vegetarian   | 1           |
| 103         | Meat Lovers  | 3           |
| 103         | Vegetarian   | 1           |
| 104         | Meat Lovers  | 3           |
| 105         | Vegetarian   | 1           |


#### 6️⃣ What was the maximum number of pizzas delivered in a single order?

```sql
SELECT 
    o.order_id,
    COUNT(*) AS delivered_count
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r
    ON o.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY o.order_id
ORDER BY delivered_count DESC
LIMIT 1 ;
```
| order_id | delivered_count|
|----------|----------------|
| 4        | 3              |


#### 7️⃣ For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT 
    o.customer_id, 
    SUM(CASE 
        WHEN o.excluded_topping_ids IS NOT NULL OR o.extra_topping_ids IS NOT NULL
        THEN 1 ELSE 0 
    END) AS with_changes,
    SUM(CASE 
        WHEN o.excluded_topping_ids IS NULL AND o.extra_topping_ids IS NULL
        THEN 1 ELSE 0 
    END) AS without_changes
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r 
    ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY o.customer_id;
```
| customer_id | with_changes | without_changes |
|-------------|--------------|----------------|
| 101         | 0            | 2              |
| 102         | 0            | 3              |
| 103         | 3            | 0              |
| 104         | 2            | 1              |
| 105         | 1            | 0              |

#### 8️⃣ How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT 
    SUM(
        CASE 
            WHEN o.excluded_topping_ids IS NOT NULL 
                 AND o.extra_topping_ids IS NOT NULL
            THEN 1 
            ELSE 0 
        END
    ) AS exclusions_extras_changes
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r 
    ON o.order_id = r.order_id
WHERE r.cancellation IS NULL;
```
| exclusions_extras_changes |
|---------------------------|
| 1                         |

#### 9️⃣ What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT EXTRACT(HOUR FROM o.order_time) AS order_hour, count (*) AS total_pizza
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r
    ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY EXTRACT(HOUR FROM o.order_time)
ORDER BY order_hour
```
| order_hour | total_pizza |
|------------|-------------|
| 13         | 3           |
| 18         | 3           |
| 19         | 1           |
| 21         | 2           |
| 23         | 3           |

#### 🔟 What was the volume of orders for each day of the week?

```sql

SELECT 
    TRIM(TO_CHAR(o.order_time, 'Day')) AS order_day, 
    COUNT(*) AS total_pizza,
    EXTRACT(ISODOW FROM o.order_time) AS day_number -- order of days without mistakes
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r
    ON o.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY order_day, day_number
ORDER BY day_number;
```
| order_day  | day_number | total_pizza |
|------------|------------|-------------|
| Wednesday  | 3          | 4           |
| Thursday   | 4          | 3           |
| Saturday   | 6          | 5           |


### B. Runner and Customer Experience <a id="group-2"></a>
 
#### 1️⃣ How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
    DATE '2021-01-01'
      + ((registration_date - DATE '2021-01-01') / 7) * 7 AS week_start,
      -- interval/ integer returns interval ex. interval 10 days. 10/7 = interval 1 day 
      COUNT(*) AS runners_count
FROM runners
GROUP BY week_start
ORDER BY week_start;

```
| week_start | runners_count |
|------------|---------------|
| 2021-01-01 | 2             |
| 2021-01-08 | 1             |
| 2021-01-15 | 1             |

#### 2️⃣ What was the average time in minutes it took  for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
SELECT 
    r.runner_id,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (r.pickup_time - o.order_time)) / 60),
        2
    ) AS avg_minutes_to_pickup
FROM cleaned_customer_orders AS o
JOIN cleaned_runner_orders AS r
    ON r.order_id = o.order_id
WHERE r.cancellation IS NULL
GROUP BY r.runner_id
ORDER BY r.runner_id;
```
runner_id | avg_minutes_to_pickup
--------- | ---------------------
1         | 15.68
2         | 23.72
3         | 10.47


#### 3️⃣ Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH pizza_number_time AS (
    SELECT 
        COUNT(o.pizza_id) AS pizza_number, 
        ROUND(AVG(EXTRACT(EPOCH FROM (r.pickup_time - o.order_time))/60),2) AS time_diff
    FROM cleaned_customer_orders AS o 
    LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
    WHERE r.cancellation IS NULL
    GROUP BY o.order_id
)
SELECT 
    CORR(pizza_number, time_diff)
FROM pizza_number_time;
```
|corr              |
-------------------
|0.8357796486469596|

#### 4️⃣ What was the average distance travelled for each customer?

```sql
SELECT 
    o.customer_id, 
    ROUND(AVG(r.distance_km)::numeric, 2) AS avg_distance_km
FROM cleaned_customer_orders AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id = o.order_id
WHERE r.cancellation IS NULL
GROUP BY o.customer_id
ORDER BY avg_distance;
```
| customer_id | avg_distance_km |
|-------------|-----------------|
| 104         | 10.00           |
| 102         | 16.73           |
| 101         | 20.00           |
| 103         | 23.40           |
| 105         | 25.00           |

#### 5️⃣ What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT 
    MAX(r.duration_min) - MIN(r.duration_min) AS diff_minutes
FROM cleaned_customer_orders AS o 
LEFT JOIN cleaned_runner_orders AS r 
    ON r.order_id = o.order_id
WHERE r.cancellation IS NULL;
```
|diff_minutes|
--------------
|30          |

#### 6️⃣ What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT
    r.runner_id, 
    o.order_id, 
    r.distance_km,
    r.duration_min, 
    ROUND(AVG(r.distance_km/r.duration_min*60)::numeric, 1) AS avg_speed_km_per_hour
FROM cleaned_customer_orders  AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
WHERE r.cancellation IS NULL
GROUP BY r.runner_id, o.order_id, r.distance_km, r.duration_min; 
```
| runner_id | order_id | distance_km | duration_min | avg_speed_km_per_hour |
|-----------|----------|-------------|--------------|-----------------------|
| 1 | 1  | 20.0 | 32 | 37.5 |
| 1 | 2  | 20.0 | 27 | 44.4 |
| 1 | 3  | 13.4 | 20 | 40.2 |
| 1 | 10 | 10.0 | 10 | 60.0 |
| 2 | 4  | 23.4 | 40 | 35.1 |
| 2 | 7  | 25.0 | 25 | 60.0 |
| 2 | 8  | 23.4 | 15 | 93.6 |
| 3 | 5  | 10.0 | 15 | 40.0 |

#### 7️⃣ 7 What is the successful delivery percentage for each runner?

```sql
-- Way 1
SELECT 
    r.runner_id, 
    ROUND(COUNT(*) FILTER (WHERE r.cancellation IS NULL)::numeric / COUNT(*) * 100, 1) AS successful_delivery_percentage   --- for PostgreSQL 9.4+
FROM cleaned_customer_orders  AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
GROUP BY r.runner_id;

-- Way 2
SELECT 
    r.runner_id, 
    ROUND(COUNT(CASE WHEN r.cancellation IS NULL THEN 1 END)::numeric / COUNT(*) * 100, 1) AS successful_delivery_percentage
FROM cleaned_customer_orders  AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
GROUP BY r.runner_id;
```
| runner_id | successful_delivery_percentage |
|----------:|-------------------------------:|
| 3 | 50.0 |
| 2 | 83.3 |
| 1 | 100.0 |


<a id="group-3"></a>

### C. Ingredient Optimisation


#### 1️⃣ What are the standard ingredients for each pizza?

```sql
SELECT 
    rp.pizza_id,
    p.pizza_name,
    STRING_AGG(i.topping_name, ', ' ORDER BY i.topping_name) AS standard_ingredients
FROM pizza_recipes AS rp
LEFT JOIN pizza_names_cleaned AS p 
    ON rp.pizza_id = p.pizza_id
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(rp.toppings, ',')) AS ingredient_id  
) AS t 
    ON TRUE
LEFT JOIN pizza_toppings AS i
    ON i.topping_id = t.ingredient_id::INT
GROUP BY rp.pizza_id, p.pizza_name
ORDER BY rp.pizza_id;

```
| pizza_id | pizza_name   | standard_ingredients |
|---------:|--------------|----------------------|
| 1 | Meat Lovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2 | Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |


#### 2️⃣What was the most commonly added extra?

```sql
SELECT 
    pt.topping_name AS extra_topping,
    COUNT(*) AS extra_count
FROM cleaned_customer_orders AS o
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(o.extra_topping_ids, ',')) AS extra_id
) AS t
    ON TRUE
LEFT JOIN pizza_toppings AS pt
    ON t.extra_id::INT = pt.topping_id
WHERE o.extra_topping_ids IS NOT NULL
GROUP BY pt.topping_name
ORDER BY extra_count DESC
LIMIT 1;

```
| extra_topping | extra_count |
|---------------|-------------|
| Bacon         | 4           |


#### 3️⃣ What was the most common exclusion?

```sql
SELECT 
    pt.topping_name AS exclude_topping,
    COUNT(*) AS exclusion_count
FROM cleaned_customer_orders AS o
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(o.excluded_topping_ids, ',')) AS exclusion_id
) AS t
    ON TRUE
LEFT JOIN pizza_toppings AS pt
    ON t.exclusion_id::INT = pt.topping_id
WHERE o.excluded_topping_ids IS NOT NULL
GROUP BY pt.topping_name
ORDER BY exclusion_count DESC
LIMIT 1;

```
| exclude_topping | exclusion_count |
|-----------------|-----------------|
| Cheese          | 4               |


#### 4️⃣ Generate an order item for each record in the customers_orders table <p>in the format of one of   the following:</p>
  * Meat Lovers
  * Meat Lovers - Exclude Beef
  * Meat Lovers - Extra Bacon
  * Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers 

```sql

SELECT 
    n.pizza_name  
    ||
    CASE 
        WHEN o.excluded_topping_ids IS NULL 
         AND o.extra_topping_ids IS NULL THEN ''

        WHEN o.excluded_topping_ids IS NULL 
        THEN ' - Extra ' || include_list

        WHEN o.extra_topping_ids IS NULL 
        THEN ' - Exclude ' || exclude_list

        ELSE ' - Exclude ' || exclude_list || ' - Extra ' || include_list 
    END AS pizza_ingredients
FROM cleaned_customer_orders AS o
LEFT JOIN pizza_names_cleaned AS n
    ON o.pizza_id = n.pizza_id 

-- exclude ingredients
LEFT JOIN LATERAL (
    SELECT STRING_AGG(pt.topping_name, ', ') AS exclude_list
    FROM UNNEST(STRING_TO_ARRAY(o.excluded_topping_ids, ',')) 
         AS t(exclude_topping_id)
    LEFT JOIN pizza_toppings AS pt
        ON t.exclude_topping_id::INT = pt.topping_id
) AS et
    ON TRUE

-- include ingredients
LEFT JOIN LATERAL (
    SELECT STRING_AGG(pt.topping_name, ', ') AS include_list
    FROM UNNEST(STRING_TO_ARRAY(o.extra_topping_ids, ',')) 
         AS t2(extras_topping_id)
    LEFT JOIN pizza_toppings AS pt
        ON t2.extras_topping_id::INT = pt.topping_id
) AS et2
    ON TRUE;
```
| pizza_ingredients                               |
|------------------------------------------------|
| Meat Lovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
| Meat Lovers                                     |
| Meat Lovers                                     |
| Meat Lovers                                     |
| Meat Lovers - Exclude Cheese - Extra Bacon, Chicken |
| Meat Lovers                                     |
| Meat Lovers                                     |
| Meat Lovers - Exclude Cheese                    |
| Meat Lovers - Exclude Cheese                    |
| Meat Lovers - Extra Bacon                       |
| Vegetarian                                     |
| Vegetarian - Extra Bacon                        |
| Vegetarian                                     |
| Vegetarian - Exclude Cheese                     |


#### 5️⃣ Generate an alphabetically ordered comma separated ingredient list <p>for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
```sql
SELECT 
    pr.pizza_id, 
    pt.topping_name
FROM pizza_recipes AS pr   
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(pr.toppings, ',')) AS toppings_list
) AS t ON TRUE
LEFT JOIN pizza_toppings AS pt 
    ON pt.topping_id = t.toppings_list::INT;
```

| pizza_id | topping_name |
|----------|--------------|
| 1        | Bacon        |
| 1        | BBQ Sauce    |
| 1        | Beef         |
| 2        | Cheese       |
| 1        | Cheese       |
| 1        | Chicken      |
| 1        | Mushrooms    |
| 2        | Mushrooms    |
| 2        | Onions       |
| 1        | Pepperoni    |
| 2        | Peppers      |
| 1        | Salami       |
| 2        | Tomatoes     |
| 2        | Tomato Sauce |

```sql
SELECT
    o.order_id,
    n.pizza_name || ': ' ||
    STRING_AGG(
        CASE 
            WHEN ingr.topping_id = ANY(extra_ids) THEN '2x' || ingr.topping_name
            ELSE ingr.topping_name
        END,
        ', ' ORDER BY ingr.topping_name
    ) AS ingredient_list
FROM cleaned_customer_orders AS o
JOIN pizza_names_cleaned AS n
    ON o.pizza_id = n.pizza_id

-- base toppings defined by the pizza recipe
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(pr.toppings, ','))::INT AS topping_id
    FROM pizza_recipes pr
    WHERE pr.pizza_id = o.pizza_id
) AS base ON TRUE

-- toppings explicitly excluded in the order (per-order exclusions)
LEFT JOIN LATERAL (
    SELECT COALESCE(ARRAY(
        SELECT UNNEST(STRING_TO_ARRAY(o.excluded_topping_ids, ','))::INT
    ), ARRAY[]::INT[]) AS exclude_ids
) AS ex ON TRUE

-- extra toppings explicitly added in the order
LEFT JOIN LATERAL (
    SELECT COALESCE(ARRAY(
        SELECT UNNEST(STRING_TO_ARRAY(o.extra_topping_ids, ','))::INT
    ), ARRAY[]::INT[]) AS extra_ids
) AS ext ON TRUE

-- final list of toppings per pizza:
--   base recipe toppings minus exclusions
--   plus extra toppings
LEFT JOIN LATERAL (
    SELECT topping_id FROM (
        -- base toppings excluding removed ingredients
        SELECT base.topping_id
        WHERE base.topping_id <> ALL(ex.exclude_ids)

        UNION ALL

        -- append extra toppings
        SELECT UNNEST(ext.extra_ids)
    ) AS all_ids
) AS final ON TRUE

LEFT JOIN pizza_toppings ingr
    ON ingr.topping_id = final.topping_id

GROUP BY o.order_id, n.pizza_name
ORDER BY o.order_id;
```
| order_id | ingredient_list |
|----------|----------------|
| 1        | Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2        | Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 3        | Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |
| 4        | Meat Lovers: Bacon, Bacon, BBQ Sauce, BBQ Sauce, Beef, Beef, Chicken, Chicken, Mushrooms, Mushrooms, Pepperoni, Pepperoni, Salami, Salami |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |
| 5        | Meat Lovers: 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |
| 7        | Vegetarian: 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |
| 8        | Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 9        | Meat Lovers: 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, BBQ Sauce, Beef, 2xChicken, 2xChicken, 2xChicken, 2xChicken, 2xChicken, 2xChicken, 2xChicken, 2xChicken, 2xChicken, Mushrooms, Pepperoni, Salami |
| 10       | Meat Lovers: 2xBacon, Bacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, 2xBacon, BBQ Sauce, Beef, Beef, 2xCheese, 2xCheese, 2xCheese, 2xCheese, 2xCheese, 2xCheese, 2xCheese, 2xCheese, Cheese, 2xCheese, Chicken, Chicken, Mushrooms, Pepperoni, Pepperoni, Salami, Salami |


#### 6️⃣ What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH all_toppings AS (
    SELECT
        UNNEST(
            ARRAY(
                SELECT elem
                FROM UNNEST(
                    STRING_TO_ARRAY(pr.toppings, ',') || 
                    COALESCE(STRING_TO_ARRAY(o.extra_topping_ids, ','), ARRAY[]::text[])
                ) AS elem
                WHERE o.excluded_topping_ids IS NULL 
                      OR elem NOT IN (SELECT UNNEST(STRING_TO_ARRAY(o.excluded_topping_ids, ',')))
            )
        ) AS topping_id
    FROM cleaned_customer_orders AS o
    JOIN cleaned_runner_orders AS r 
        ON o.order_id = r.order_id
    JOIN pizza_recipes AS pr 
        ON o.pizza_id = pr.pizza_id
    WHERE r.cancellation IS NULL
)

SELECT pt.topping_name, COUNT(*) AS frequency
FROM all_toppings AS tt
LEFT JOIN pizza_toppings AS pt 
    ON tt.topping_id::INT = pt.topping_id
GROUP BY pt.topping_name
ORDER BY frequency DESC;
```
| topping_name   | frequency |
|----------------|-----------|
| Mushrooms      | 12        |
| Cheese         | 12        |
| Bacon          | 12        |
| BBQ Sauce      | 9         |
| Beef           | 9         |
| Pepperoni      | 9         |
| Chicken        | 9         |
| Salami         | 9         |
| Tomato Sauce   | 3         |
| Onions         | 3         |
| Tomatoes       | 3         |
| Peppers        | 3         |


<a id="group-4"></a>

### D. Pricing and Ratings

#### 1️⃣ If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes<p> - how much money has Pizza Runner made so far if there are no delivery fees? </p>
```sql
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.pizza_id,
        n.pizza_name
    FROM cleaned_customer_orders AS o
    JOIN cleaned_runner_orders AS r
        ON o.order_id = r.order_id
    JOIN pizza_names_cleaned AS n
        ON o.pizza_id = n.pizza_id
    WHERE r.cancellation IS NULL
)

SELECT SUM(
    CASE
        WHEN pizza_name='Meat Lovers' THEN 12
        ELSE 10 END 
) AS total_revenue_USD
FROM delivered_orders;
```
| total_revenue_usd |
|------------------|
| 138              |


#### 2️⃣hat if there was an additional $1 charge for any pizza extras? (Add cheese is $1 extra)
```sql
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.pizza_id,
        o.extra_topping_ids,
        n.pizza_name
    FROM cleaned_customer_orders AS o
    JOIN cleaned_runner_orders AS r
        ON o.order_id = r.order_id
    JOIN pizza_names_cleaned AS n
        ON o.pizza_id = n.pizza_id
    WHERE r.cancellation IS NULL
),

order_prices AS (
    SELECT
        order_id,
        pizza_id,

        -- базова ціна піци
        CASE
            WHEN pizza_name = 'Meat Lovers' THEN 12
            ELSE 10
        END AS base_price,

        -- кількість extras
        COALESCE(
            CARDINALITY(STRING_TO_ARRAY(extra_topping_ids, ',')),  -- рахує кількість додаткових топінгів
            0
        ) AS extras_count
    FROM delivered_orders
)

SELECT
    SUM(base_price + extras_count) AS total_revenue_usd
FROM order_prices;
```
| total_revenue_usd |
|------------------|
| 142              |


#### 3️⃣ The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design <p> an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. 

```sql
CREATE TABLE runner_ratings (
    order_id INTEGER PRIMARY KEY,
    runner_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

INSERT INTO runner_ratings (order_id, runner_id, rating)
SELECT
    order_id,
    runner_id,
    FLOOR(1 + RANDOM() * 5)::INT
FROM cleaned_runner_orders
WHERE cancellation IS NULL;
```

#### 4️⃣ Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
```sql

WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.pizza_id,
        o.order_time,
        r.runner_id,
        r.pickup_time,
        r.duration_min,
        r.distance_km
    FROM cleaned_customer_orders AS o
    JOIN cleaned_runner_orders AS r
        ON o.order_id = r.order_id
    WHERE r.cancellation IS NULL
),

order_level_metrics AS (
    SELECT
        order_id,
        customer_id,
        runner_id,
        order_time,
        pickup_time,
        pickup_time - order_time AS time_between_order_and_pickup,
        duration_min,
        ROUND((distance_km / duration_min * 60)::numeric, 1) AS avg_speed_km_per_hour,
        COUNT(pizza_id) AS total_number_of_pizzas
    FROM delivered_orders
    GROUP BY
        order_id,
        customer_id,
        runner_id,
        order_time,
        pickup_time,
        duration_min,
        distance_km
)

SELECT
    olm.customer_id,
    olm.order_id,
    olm.runner_id,
    rr.rating,
    olm.order_time,
    olm.pickup_time,
    olm.time_between_order_and_pickup,
    olm.duration_min AS delivery_duration,
    olm.avg_speed_km_per_hour,
    olm.total_number_of_pizzas
FROM order_level_metrics AS olm
LEFT JOIN runner_ratings AS rr
    ON olm.order_id = rr.order_id
   AND olm.runner_id = rr.runner_id
ORDER BY olm.order_id;
```
| customer_id | order_id | runner_id | rating | order_time           | pickup_time          | time_between_order_and_pickup | delivery_duration | avg_speed_km_per_hour | total_number_of_pizzas |
|-------------|----------|-----------|--------|--------------------|--------------------|-------------------------------|-----------------|----------------------|-----------------------|
| 101         | 1        | 1         | 3      | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 00:10:32                      | 32              | 37.5                 | 1                     |
| 101         | 2        | 1         | 5      | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 | 00:10:02                      | 27              | 44.4                 | 1                     |
| 102         | 3        | 1         | 4      | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 | 00:21:14                      | 20              | 40.2                 | 2                     |
| 103         | 4        | 2         | 2      | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 | 00:29:17                      | 40              | 35.1                 | 3                     |
| 104         | 5        | 3         | 3      | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 | 00:10:28                      | 15              | 40.0                 | 1                     |
| 105         | 7        | 2         | 5      | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 | 00:10:16                      | 25              | 60.0                 | 1                     |
| 102         | 8        | 2         | 1      | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 | 00:20:29                      | 15              | 93.6                 | 1                     |
| 104         | 10       | 1         | 1      | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 | 00:15:31                      | 10              | 60.0                 | 2                     |

#### 5️⃣ If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

``` sql
 WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.pizza_id,
        n.pizza_name,
        r.distance_km
    FROM cleaned_customer_orders AS o
    JOIN cleaned_runner_orders AS r
        ON o.order_id = r.order_id
    JOIN pizza_names_cleaned AS n
        ON o.pizza_id = n.pizza_id
    WHERE r.cancellation IS NULL
),

revenue AS (
    SELECT
        SUM(
            CASE 
                WHEN pizza_name = 'Meat Lovers' THEN 12
                ELSE 10
            END
        ) AS total_revenue
    FROM delivered_orders
),

runner_cost AS (
    SELECT
        SUM(distance_km) * 0.3 AS total_runner_cost
    FROM (
        SELECT DISTINCT order_id, distance_km
        FROM delivered_orders
    ) t
)

SELECT
    r.total_revenue - c.total_runner_cost AS money_left_over
FROM revenue r
CROSS JOIN runner_cost c;
```
| money_left_over |
|----------------|
| 94.44          |


##  🏁 8. Conclusions <a id="point-8"></a>

### 🍕 A. Pizza Metrics 
| Metric | Value | Insight |
|--------|-------|--------|
| Total pizzas delivered | 14 | Moderate sales volume. |
| Unique customer orders | 10 | Customers place multiple pizzas per order. |
| Most popular pizza | Meat Lovers (9 deliveries) | Key revenue driver; focus marketing here. |
| Orders with modifications | 7 | 50% of orders include extras or exclusions. |
| Orders with both exclusions & extras | 1 | Rare; shows complex customization. |
| Maximum pizzas per order | 3 | Occasional bulk orders affect prep time. |

**Insight:** Customers mostly stick to standard recipes, but a significant segment customizes pizzas → opportunity for upselling.

---

### 🚴 B. Runner & Customer Experience 
| Runner | Avg. Pickup Time (min) | Successful Deliveries (%) | Avg. Speed (km/h) |
|--------|----------------------|--------------------------|-----------------|
| 1      | 15.68                | 100                      | 37.5–60         |
| 2      | 23.72                | 83.3                     | 35–93.6         |
| 3      | 10.47                | 50                       | 40              |

- **Correlation (Order size vs prep time):** 0.836 → more pizzas → longer prep.  
- **Avg. distance per customer:** 10–25 km.  
- **Longest-shortest delivery difference:** 30 min.

**Insight:** Runner performance varies significantly → training, route optimization, and scheduling can improve service.

---

### 🥗 C. Ingredient Optimisation 
| Pizza | Standard Ingredients | Most Added Extra | Most Excluded Ingredient |
|-------|--------------------|-----------------|-------------------------|
| Meat Lovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami | Bacon (4x) | Cheese (4x) |
| Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes | Bacon (4x) | Cheese (4x) |

**Insight:** Extras (Bacon) → upselling opportunity. Cheese often excluded → recipe flexibility improves satisfaction.

**Total ingredient usage frequency (all delivered pizzas):**  
1. Mushrooms – 12  
2. Cheese – 12  
3. Bacon – 12  
4. BBQ Sauce – 9  
5. Beef – 9  
6. Pepperoni – 9  
7. Chicken – 9  
8. Salami – 9  
9. Tomato Sauce – 3  
10. Onions – 3  
11. Tomatoes – 3  
12. Peppers – 3  

---

###  💰 D. Pricing & Revenue 
| Metric | Value (USD) | Insight |
|--------|------------|--------|
| Revenue (base pizza) | 138 | Meat Lovers drives majority of revenue. |
| Revenue with extras ($1 each) | 142 | Extras add modest profit. |
| Profit margin after delivery cost (example) | 94.44 | Positive margin; can be optimized further. |

**Insight:** Business is profitable; margins can be improved via delivery efficiency and ingredient upselling.

---

### ⏰ E. Time & Volume Patterns 
| Metric | Observation |
|--------|------------|
| Peak order hours | 13:00, 18:00, 21:00, 23:00 |
| Peak order days | Wednesday, Thursday, Saturday |

**Insight:** Plan staffing, kitchen prep, and marketing campaigns according to peak periods.

---

### ✅ F. Key Takeaways
1. **Meat Lovers** → main revenue driver, focus marketing campaigns.  
2. **Bacon** is the most popular extra; **Cheese** is most excluded → support recipe customization.  
3. Larger orders increase prep time significantly (correlation 0.836).  
4. Runner performance is uneven → train runners, optimize routes.  
5. Peak hours and days identified → allocate resources efficiently.  
6. Profit margin positive (~94 USD after delivery costs) → room for improvement.

---

**Overall:**  
Pizza Runner operations are **profitable and functional**, with key insights around **runner performance**, **ingredient upselling**, and **peak-time optimization**.  

