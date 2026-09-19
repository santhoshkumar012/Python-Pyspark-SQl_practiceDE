-- Q01 — Row counts.** Return the number of rows in every table as (table_name, row_count).

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'payments',    COUNT(*) FROM payments
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'returns',     COUNT(*) FROM returns;

-- Q02 — Order status share.** For each order_status give the number of orders and 
-- its percentage share of all orders (2 decimals), largest first.


with 
   cte as 
   (select 
       count(*) as total_count 
	from orders
    )
select 
    order_status, count(*) as order_count, round((count(*)/(select total_count from cte))*100.0,2) as status_share 
from orders
group by order_status 
order by status_share Desc; 

-- optional: (skipping cte)
SELECT order_status,
       COUNT(*) AS order_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS status_share
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Q03 — Priciest active products.** List the 5 most expensive ACTIVE products (name, category, unit_price).

select product_name, category, unit_price from products where is_active = 1 order by unit_price Desc Limit 5;

-- Q04 — Customers by state.** Top 5 states by number of customers, along with how many of those customers are Platinum tier.

select state, count(*) as customer_count, sum(case when loyalty_tier = 'Platinum' then 1 else 0 end
) as Platinum_share from customers group by state order by customer_count Desc limit 5
;
