USE dannys_diner;
SELECT
s.customer_id,
SUM(m.price) AS total_spend
FROM sales As s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

SELECT 
customer_id,
COUNT(DISTINCT order_date) AS visit_count
FROM sales
GROUP BY customer_id;

SELECT
s.customer_id,
s.order_date,
m.product_name
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE s.order_date = (
SELECT MIN(s2.order_date)
FROM sales AS s2
WHERE s2.customer_id = s.customer_id
)
ORDER BY s.customer_id;

SELECT
m.product_name,
COUNT(*) AS times_purchased
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC;

WITH item_counts AS (
SELECT
s.customer_id,
m.product_name,
COUNT(*) AS purchase_count
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
),
ranked_items AS (
SELECT
customer_id,
product_name,
purchase_count,
DENSE_RANK() OVER (
PARTITION BY customer_id
ORDER BY purchase_count DESC
) AS item_rank
FROM item_counts
)
SELECT
customer_id,
product_name,
purchase_count
FROM ranked_items
WHERE item_rank = 1
ORDER BY customer_id; 

USE dannys_diner;
SELECT
s.customer_id,
s.order_date,
m.product_name
FROM sales AS  s
JOIN members AS mem
ON s.customer_id = mem.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE s.order_date > mem.join_date
AND s.order_date = (
SELECT MIN(s2.order_date)
FROM sales AS s2
WHERE s2.customer_id = s.customer_id
AND s2.order_date > mem.join_date
)
ORDER BY s.customer_id;

SELECT 
s.customer_id,
s.order_date,
m.product_name
FROM sales AS s
JOIN members AS mem
ON s.customer_id = mem.customer_id
JOIN menu As m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
AND s.order_date = (
SELECT MAX(s2.order_date)
FROM sales AS s2
WHERE s2.customer_id = s.customer_id
AND s2.order_date < mem.join_date
)
ORDER BY s.customer_id;

SELECT
s.customer_id,
COUNT(*) AS total_items,
SUM(m.price) AS amount_spent
FROM sales AS s
JOIN members AS mem
ON s.customer_id = mem.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

SELECT
s.customer_id,
SUM(
CASE
WHEN m.product_name = 'sushi'
THEN m.price * 20
ELSE m.price * 10
END
) AS total_points
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id;                                              

SELECT
s.customer_id,
SUM(
CASE
WHEN s.order_date BETWEEN
mem.join_date
AND DATE_ADD(mem.join_date,
INTERVAL 6 DAY)
THEN m.price * 20
WHEN m.product_name = 'sushi'
THEN m.price * 20
ELSE m.price * 10
END
) AS january_points
FROM sales AS s
JOIN members AS mem
ON s.customer_id = mem.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE s.order_date >= '2021-01-01'
AND s.order_date < '2021-02-01'
GROUP BY s.customer_id
ORDER BY s.customer_id;