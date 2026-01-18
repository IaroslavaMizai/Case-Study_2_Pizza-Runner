--- DATA CLEANINING ---

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

DROP VIEW IF EXISTS cleaned_runner_orders;


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

-- A. Pizza Metrics

-- 1 How many pizzas were ordered?

SELECT COUNT(*) AS pizza_counted
FROM cleaned_customer_orders;

-- 2 How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) AS unique_orders
FROM cleaned_customer_orders;

-- 3 How many successful orders were delivered by each runner?

SELECT 
    runner_id,
    COUNT(*) AS successful_deliveries
FROM cleaned_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT 
    n.pizza_name,
    COUNT(*) AS delivered_count
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r ON o.order_id = r.order_id
LEFT JOIN pizza_names_cleaned AS n ON o.pizza_id = n.pizza_id
WHERE r.cancellation IS NULL
GROUP BY n.pizza_name
ORDER BY delivered_count DESC;

-- 5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT  
    o.customer_id,
    n.pizza_name,
    COUNT(*) AS pizza_count
FROM cleaned_customer_orders AS o 
LEFT JOIN pizza_names_cleaned AS n ON o.pizza_id = n.pizza_id
GROUP BY o.customer_id, n.pizza_name
ORDER BY o.customer_id, n.pizza_name;

-- 6 What was the maximum number of pizzas delivered in a single order?

SELECT 
    o.order_id,
    COUNT(*) AS delivered_count
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r ON o.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY o.order_id
ORDER BY delivered_count DESC
LIMIT 1 ;

-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

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


-- 8  How many pizzas were delivered that had both exclusions and extras?

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


-- 9 What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOUR FROM o.order_time) AS order_hour, count (*) AS total_pizza
FROM cleaned_customer_orders AS o
LEFT JOIN cleaned_runner_orders AS r ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY EXTRACT(HOUR FROM o.order_time)
ORDER BY order_hour

--10 What was the volume of orders for each day of the week?

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

     
-- B. Runner and Customer Experience

--1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
    DATE '2021-01-01'
      + ((registration_date - DATE '2021-01-01') / 7) * 7 AS week_start,
      -- interval/ integer returns interval ex. interval 10 days. 10/7 = interval 1 day 
      COUNT(*) AS runners_count
FROM runners
GROUP BY week_start
ORDER BY week_start;


/*2 What was the average time in minutes it took 
for each runner to arrive at the Pizza Runner HQ to pickup the order?*/

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


--3 Is there any relationship between the number of pizzas and how long the order takes to prepare?

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


--4 What was the average distance travelled for each customer?

SELECT 
    o.customer_id, 
    ROUND(AVG(r.distance_km)::numeric, 2) AS avg_distance_km
FROM cleaned_customer_orders AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id = o.order_id
WHERE r.cancellation IS NULL
GROUP BY o.customer_id
ORDER BY avg_distance_km;

--5 What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(r.duration_min) - MIN(r.duration_min) AS diff_minutes
FROM cleaned_customer_orders AS o 
LEFT JOIN cleaned_runner_orders AS r 
    ON r.order_id = o.order_id
WHERE r.cancellation IS NULL;

--6 What was the average speed for each runner for each delivery and do you notice any trend for these values?

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


--7 What is the successful delivery percentage for each runner?

-- Way1
SELECT 
    r.runner_id, 
    ROUND(COUNT(*) FILTER (WHERE r.cancellation IS NULL)::numeric / COUNT(*) * 100, 1) AS successful_delivery_percentage   --- for PostgreSQL 9.4+
FROM cleaned_customer_orders  AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
GROUP BY r.runner_id;

-- Way2
SELECT 
    r.runner_id, 
    ROUND(COUNT(CASE WHEN r.cancellation IS NULL THEN 1 END)::numeric / COUNT(*) * 100, 1) AS successful_delivery_percentage
FROM cleaned_customer_orders  AS o 
LEFT JOIN cleaned_runner_orders AS r ON r.order_id=o.order_id
GROUP BY r.runner_id;

-- C. Ingredient Optimisation

--1 What are the standard ingredients for each pizza?

SELECT 
rp.pizza_id,
p.pizza_name,
STRING_AGG(i.topping_name, ', ' ORDER BY i.topping_name) AS standard_ingredients
FROM pizza_recipes AS rp
LEFT JOIN pizza_names_cleaned AS p ON rp.pizza_id=p.pizza_id
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(rp.toppings,',')) AS ingredient_id  -- REGEXP_SPLIT_TO_ARRAY(rp.toppings,'\s*,\s*')
) AS t 
    ON TRUE
LEFT JOIN pizza_toppings AS i
    ON i.topping_id = t.ingredient_id::INT
GROUP BY rp.pizza_id, p.pizza_name
ORDER BY rp.pizza_id;

--2 What was the most commonly added extra?

SELECT 
    pt.topping_name AS extra_topping,
    COUNT(*) AS extra_count
FROM cleaned_customer_orders AS o
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(o.extra_topping_ids,',')) AS extra_id
    ) AS t
ON TRUE
LEFT JOIN pizza_toppings AS pt
ON t.extra_id::INT=pt.topping_id
WHERE o.extra_topping_ids IS NOT NULL
GROUP BY  extra_topping
ORDER BY extra_count DESC
LIMIT 1;

--3 What was the most common exclusion?

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

/*4 Generate an order item for each record in the customers_orders table 
in the format of one of the following:
    -- Meat Lovers
    -- Meat Lovers - Exclude Beef
    -- Meat Lovers - Extra Bacon
    -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

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


/*5 Generate an alphabetically ordered comma separated ingredient list for each pizza order 
from the customer_orders table 
and add a 2x in front of any relevant ingredients . For example:
 "Meat Lovers: 2xBacon, Beef, ... , Salami" */
-- 1. Pizza recipes expanded
SELECT 
    pr.pizza_id, 
    pt.topping_name
FROM pizza_recipes AS pr   
LEFT JOIN LATERAL (
    SELECT UNNEST(STRING_TO_ARRAY(pr.toppings, ',')) AS toppings_list
) AS t ON TRUE
LEFT JOIN pizza_toppings AS pt 
    ON pt.topping_id = t.toppings_list::INT;


-- 2. Final ingredient list per order
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



--6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

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


--D. Pricing and Ratings

/*1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 
and there were no charges for changes -
how much money has Pizza Runner made so far if there are no delivery fees?*/
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
        WHEN pizza_name = 'Meat Lovers' THEN 12
        ELSE 10
    END
) AS total_revenue_USD
FROM delivered_orders;

---2 What if there was an additional $1 charge for any pizza extras?
    ---Add cheese is $1 extra

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


/* 3 The Pizza Runner team now wants to add an additional ratings system 
that allows customers to rate their runner, how would you design an additional
table for this new dataset - generate a schema for this new table and insert 
your own data for ratings for each successful customer order between 1 to 5.*/

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

/*4 Using your newly generated table - can you join all of the information 
together to form a table which has the following information for successful deliveries?
        customer_id
        order_id
        runner_id
        rating
        order_time
        pickup_time
        Time between order and pickup
        Delivery duration
        Average speed
        Total number of pizzas*/
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


/*5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost 
for extras and each runner is paid $0.30 per kilometre traveled - how much money
 does Pizza Runner have left over after these deliveries?*/

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
