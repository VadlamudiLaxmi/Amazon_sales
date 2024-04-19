-- 	1.Find out the top 5 customers who made the highest profits.
WITH customer_profit AS (
    SELECT 
        customer_id,
        SUM(sale - (price_per_unit * quantity)) AS total_profit
    FROM 
        orders
    GROUP BY 
        customer_id
)
SELECT 
    customer_id,
    total_profit
FROM 
    customer_profit
ORDER BY 
    total_profit DESC
LIMIT 5;


	  

-- 2. Find out the average quantity ordered per category.
SELECT 
      Category,
      AVG(quantity) AS avg_quantity
FROM orders
GROUP BY category;

-- 3. Identify the top 5 products that have generated the highest revenue.

SELECT
      o.product_id,
      p.product_name,
	  SUM(o.sale) AS total_sale
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY  o.product_id,p.product_name
ORDER BY total_sale DESC
LIMIT 5;


-- 4.Determine the top 5 products whose revenue has decreased compared to the previous year.

WITH current_year_revenue AS (
    SELECT
        product_id,
        SUM(sale) AS current_year_sale
    FROM
        orders
    WHERE
        EXTRACT(YEAR FROM order_date) = EXTRACT(YEAR FROM CURRENT_DATE) -1
    GROUP BY
        product_id
),
previous_year_revenue AS (
    SELECT
        product_id,
        SUM(sale) AS previous_year_sale
    FROM
        orders
    WHERE
        EXTRACT(YEAR FROM order_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 2
    GROUP BY
        product_id
)
SELECT
    c.product_id,
    c.current_year_sale,
    p.previous_year_sale,
    c.current_year_sale - p.previous_year_sale AS revenue_difference
FROM
    current_year_revenue c
JOIN
    previous_year_revenue p ON c.product_id = p.product_id
ORDER BY
    revenue_difference ASC
LIMIT 5;

-- 5.Identify the highest profitable sub-category.
WITH subcategory_profit AS (
    SELECT 
        sub_category,
        SUM(sale - (price_per_unit * quantity)) AS total_profit
    FROM 
        orders
    GROUP BY 
        sub_category
)
SELECT 
    sub_category,
    total_profit
FROM 
    subcategory_profit
ORDER BY 
    total_profit DESC
LIMIT 1;



--6. List the products that not been sold yet

SELECT 
    product_id,
    product_name
FROM 
    products
WHERE 
    product_id NOT IN (
        SELECT DISTINCT product_id 
        FROM orders
    );



--7. Determine the month with the highest number of orders.
SELECT 
      EXTRACT(MONTH FROM order_date) AS month,
      COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY total_orders DESC
LIMIT 1;


-- 8. Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT 
    o.order_id,
	p.product_id,
    ((o.sale - (p.price * o.quantity)) / o.sale) * 100 AS profit_margin_percentage
FROM 
    orders o
JOIN 
    products p ON o.product_id = p.product_id
ORDER BY profit_margin_percentage DESC;

 

-- 9. Calculate the percentage contribution of each sub-category.

WITH subcategory_totals AS (
    SELECT 
        sub_category,
        SUM(sale) AS total_sales
    FROM 
        orders
    GROUP BY 
        sub_category
)
SELECT 
    sub_category,
    total_sales,
    (total_sales / SUM(total_sales) OVER ()) * 100 AS percentage_contribution
FROM 
    subcategory_totals;
	  
-- 10. Identify the top 2 categories that have received maximum returns and their return percentage.   

WITH return_totals
AS
(
		SELECT 
			  o.category,
			  COUNT(r.return_id) AS total_returns,
			  COUNT(o.order_id) AS total_orders	  
		FROM orders o
		LEFT JOIN returns r
		ON o.order_id = r.order_id
		GROUP BY o.category
)
SELECT
      category,
	  total_returns,
	  total_orders,
	  (total_returns / total_orders:: FLOAT) * 100 AS return_percentage
FROM return_totals
ORDER BY total_returns DESC
LIMIT 2;

