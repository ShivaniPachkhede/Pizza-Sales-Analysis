#Basic
#Ques1 Retrieve the total no. of orders placed
SELECT * FROM orders;
SELECT count(order_id) FROM orders;

#Ques2 Calculate the total revenue generated from pizza sales 
SELECT * FROM pizzas;
SELECT * FROM order_details;
SELECT ROUND(SUM(price * quantity)) as Total_revenue
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id;

#Ques3 Identify the highest price pizza
SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT name, price 
FROM pizzas p JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

#Ques4 Identify the most common pizza size ordered
SELECT * FROM pizzas;
SELECT * FROM order_details;
SELECT size, COUNT(order_details_id) as order_count
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY order_count DESC;

SELECT size, COUNT(order_details_id) as order_count
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;

#Ques5 Find category wise distribution of pizza
SELECT * FROM pizza_types;
SELECT category, count(name) FROM pizza_types
GROUP BY category;



#Intermediate
#Ques6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT * FROM pizza_types;
SELECT * FROM order_details;
SELECT * FROM pizzas;
SELECT category, SUM(quantity) as Total_quantity
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category
ORDER BY Total_quantity DESC;

#Ques7 Determine the distribution of orders by hour of the day
SELECT * FROM orders;
SELECT hour(time) as Hours, count(order_id) as Total_count
FROM orders
GROUP BY Hours
ORDER BY Total_count DESC;

#Ques8 List the top 5 most ordered pizza types along with their quantities
SELECT * FROM order_details;
SELECT * FROM pizza_types;
SELECT name, sum(quantity) as Total_Quantity
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY Total_quantity DESC
LIMIT 5;

#Ques9 Group the orders by date and calculate the average number of pizzas ordered per day
SELECT * FROM orders;
SELECT * FROM order_details;
SELECT Round(avg(Total_quantity),0) as avg_orders_per_day
FROM
(SELECT date, SUM(od.quantity) as Total_quantity
FROM orders o JOIN order_details od ON o.order_id = od.order_id
GROUP BY date) as order_quantity;

#Ques10 Determine the top 3 most ordered pizza based on revenue
SELECT * FROM pizza_types;
SELECT * FROM order_details;
SELECT * FROM pizzas;
SELECT name, round(sum(quantity * price)) as revenue
FROM pizzas p JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;



#Advanced
#Ques11 Calculate the percentage contribution of each pizza type to total revenue
SELECT category,
    round((SUM(quantity * price) / 
        (SELECT ROUND(SUM(quantity * price)) 
         FROM pizza_types pt
         JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
         JOIN order_details od ON od.pizza_id = p.pizza_id
        )
    ) * 100) AS revenue
FROM 
    pizza_types pt
JOIN 
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN 
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY revenue DESC;


#Ques12 Analyze the cumulative revenue geenrated over time
SELECT * FROM order_details;
SELECT * FROM pizzas;
SELECT * FROM orders;

SELECT date, sum(revenue) OVER(ORDER BY date) AS cum_revenue
FROM
	(SELECT date,
	round(SUM(quantity * price)) as revenue
	FROM order_details od JOIN pizzas p
	ON od.pizza_id = p.pizza_id
	JOIN orders o 
	ON o.order_id = od.order_id
	GROUP BY date) AS sales;

#Ques13 Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT * FROM pizza_types;
SELECT * FROM order_details;
SELECT * FROM pizzas;

SELECT name, category, revenue
FROM
	(SELECT name, category, revenue,
	RANK() OVER(partition by category ORDER BY revenue DESC) as rn
	FROM
		(SELECT category, name, round(SUM(quantity * price)) as revenue
		FROM pizza_types pt JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
		JOIN order_details od ON p.pizza_id = od.pizza_id
		GROUP BY category, name) as a) as b
		WHERE rn<=3;