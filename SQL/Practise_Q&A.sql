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

-- Q05 — Orders per channel per year (pivot).** One row per order year, one column per channel (Web, Mobile App, Marketplace, Store) 
-- containing the number of orders. Do it with conditional aggregation.


select year(order_date) as 'Year', sum(case when channel = "Mobile App" then 1 else 0 end) as 'Mobile App', 
sum(case when channel = "Web" then 1 else 0 end) as 'Web',
sum(case when channel = "Marketplace" then 1 else 0 end) as 'Marketplace',
sum(case when channel = "Store" then 1 else 0 end) as 'Store' from orders
group by year(order_date) order by year(order_date);

-- Q06 — Missing contact details.** How many customers have a missing email, a missing phone, and both missing? (one row, three columns)

select sum(case when phone is null and email is null then 1 else 0 end) as 'Both',
sum(case when phone is null then 1 else 0 end) as "Phone",
sum(case when email is null then 1 else 0 end) as "Email" from customers;

-- Q07 — Revenue by category.** Net revenue per product category for DELIVERED orders, 
-- plus each category's % of total revenue. (net = quantity x unit_price x (1 - discount_pct/100); ignore shipping.)

select * from products order by product_name;
select * from order_items;
select * from orders;

with cte as (select i.product_id,i.quantity,i.unit_price,i.discount_pct, o.*  from order_items i join orders o on i.order_id = o.order_id where order_status = "Delivered")

select P.category, sum(e.quantity * e.unit_price * (1-e.discount_pct/100)),
100* sum(e.quantity * e.unit_price * (1-e.discount_pct/100))/sum(sum(e.quantity * e.unit_price * (1-e.discount_pct/100))) over() from products p join cte e 
on p.product_id = e.product_id group by p.category

-- better one:
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue,
       ROUND(100.0 * SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
             / SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))) OVER (), 2) AS pct_of_total
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY net_revenue DESC;