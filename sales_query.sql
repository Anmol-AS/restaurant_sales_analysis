-- Retrieve the total number of orders placed. 
SELECT 
    COUNT(order_id)
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS revenue_generated
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
order by p.price desc
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size AS pizza_id, COUNT(od.order_id)
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name AS pizza_name, COUNT(od.order_id) AS count
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY count DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category AS category, COUNT(od.order_id) AS count
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY count DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time), COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(counts)
FROM
    (SELECT 
        DAY(o.date) AS date, SUM(od.quantity) AS counts
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date) AS total_count;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name AS pizza_name, SUM(p.price * od.quantity) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pizza_name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category AS pizza_category, 
    
    (SUM(p.price * od.quantity) / 
    (SELECT 
		ROUND(SUM(od.quantity * p.price), 2) AS revenue_generated
	FROM
		order_details od
			JOIN
		pizzas p ON od.pizza_id = p.pizza_id))*100 
	AS revenue_percentage
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pizza_category;


-- Analyze the cumulative revenue generated over time.
select date, 
sum(revenue) over (order by date) as cum_revenue
from
(
	select o.date, 
	sum(od.quantity * p.price) as revenue
	from orders o 
	join order_details od on o.order_id = od.order_id
	join pizzas p on od.pizza_id = p.pizza_id
	group by o.date
) 
as daily_revenue;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn from
(select pt.category, pt.name,  sum(od.quantity * p.price) as revenue 
from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category, pt.name) as a
) as b
where rn <= 3;