USE customer_behavior;

SHOW TABLES;
SELECT * FROM customer_data LIMIT 10;
SELECT COUNT(*) FROM customer_data;

-- Total revenue by gender

SELECT
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer_data
GROUP BY gender;

-- Discount users who spent above average
SELECT
    customer_id,
    purchase_amount
FROM customer_data
WHERE discount_applied = 'Yes'
AND purchase_amount > (
    SELECT AVG(purchase_amount)
    FROM customer_data
);

-- Top 5 products by average review rating
SELECT
    item_purchased,
    ROUND(AVG(review_rating), 2) AS average_product_rating
FROM customer_data
GROUP BY item_purchased
ORDER BY average_product_rating DESC
LIMIT 5;

-- Average purchase amount by shipping type
SELECT
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer_data
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Subscribers vs. non-subscribers

SELECT
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_data
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Top 5 products by discount percentage
SELECT
    item_purchased,
    ROUND(
        100.0 * SUM(
            CASE WHEN discount_applied = 'Yes'
            THEN 1 ELSE 0 END
        ) / COUNT(*), 2
    ) AS discount_rate
FROM customer_data
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;
-- Customer segmentation
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_data
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM customer_type
GROUP BY customer_segment;
-- Top 3 products within each category
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS item_rank
    FROM customer_data
    GROUP BY category, item_purchased
)
SELECT
    category,
    item_purchased,
    total_orders,
    item_rank
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;
-- Repeat buyers and subscription status

SELECT
    subscription_status,
    COUNT(*) AS repeat_buyers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM customer_data
         WHERE previous_purchases > 5),
        2
    ) AS percentage
FROM customer_data
WHERE previous_purchases > 5
GROUP BY subscription_status;
-- Revenue contribution by age group
SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount) /
        (SELECT SUM(purchase_amount) FROM customer_data),
        2
    ) AS revenue_percentage
FROM customer_data
GROUP BY age_group
ORDER BY total_revenue DESC;