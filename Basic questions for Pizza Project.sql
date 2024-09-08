use pizza

select top 5 * from pizzas;
select top 5 * from order_details;
select top 5 * from pizza_types;
select top 5 * from orders;

-- Total number of pizzas sold--49574
select sum(quantity) as Total_pizzas_sold from order_details;


--Average order Value-- 17
Select round(sum(Revenue)/(count(Orders)),0) as Average_order_Value from 
(Select  p.pizza_id, p.pizza_type_id, p.price, OD.order_details_id as Orders, OD.quantity, (p.price*OD.quantity) as Revenue from pizzas as p
join 
order_details as OD on p.pizza_id= OD.pizza_id) as Table1;


--Average pizzas quantity sold--2
select round(sum(quantity)/count(distinct order_id),0) as Average_qty_sold from order_details;


--Retrieve the total number of orders placed.
select count( distinct order_id) as 'No of orders' from orders; --There are total of 21350 orders.

-- Week day wise pizzas quantity sold
select DATENAME(DW,o.date) as Days, sum(od.quantity) as Sale from orders as o
join
order_details as od on o.order_id=od.order_id
group by DATENAME(DW,date)
order by Sale DESC; 


--Calculate the total revenue generated from pizza sales -- Used Inner Join on pizzas and order_details table and total revenue is 6542880.4 
select ROUND(SUM(p.price*o.quantity),2) as 'Total Reneve' from 
pizzas as p
Join
order_details as o 
on p.pizza_id = o.pizza_id;


-- Identify the highest-priced pizza. -- The Greek Pizza is the highest priced pizza: 35.95 
Select TOP 1 pt.name as Pizza_Name, p.price as Amount from
pizzas as p
Join 
pizza_types as pt on p.pizza_type_id= pt.pizza_type_id
order by p.price DESC; 


--Identify the most common pizza size ordered. -- L size pizza with count of 148208
select p.size, sum(o.quantity) as Quantity from
pizzas as p 
Join
order_details as o on p.pizza_id= o.pizza_id
group by p.size 
order by sum(o.quantity) DESC;


--List the top 5 most ordered pizza types along with their quantities. --The classic Deluxe pizza, barbecue chicken pizza, hawaiian pizza, peopperoni pizza, and thai pizza
select top 5 pt.name as Pizza_Name, sum(o.quantity) as Total_Quantity from 
pizzas as p
inner join 
order_details as o on p.pizza_id = o.pizza_id
inner join
pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by sum(o.quantity) DESC;


--Join the necessary tables to find the total quantity of each pizza category ordered.-- Classic, Supreme, Veggie,Chicken
select pt.category as Category, sum(o.quantity) as Total_Quantity from 
pizzas as p
inner join 
order_details as o on p.pizza_id = o.pizza_id
inner join
pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by sum(o.quantity) DESC;


--Determine the distribution of orders by hour of the day.-- 12,13 are extreme hours for orders received  
select DATEPART(HOUR, time) as Time, count(order_id) as Total_orders from orders
group by DATEPART(HOUR, time)
order by count(order_id) DESC;


--Join relevant tables to find the category-wise distribution of pizzas.--Chicken(6), classic(8), Supreme(9), Veggie(9)
Select category, count(*) as Quantity from pizza_types 
group by category 
order by count(*); 


--Group the orders by date and calculate the average number of orders per day.--59
Select AVG(No_of_orders) as AverageCount from
(Select CONVERT(DATE, date) as Date, count(order_id) as No_of_orders
from orders
Group by Date) as OrderCount;


--Group the orders by date and calculate the average number of pizzas ordered per day.--138
Select Round(AVG(quantity),1) as Average_Pizzas_Count from (Select convert(Date, O.date) as Date,Sum(OD.quantity) as Quantity from
order_details as OD
Inner join 
orders as O on OD.order_id= O.order_id
group by convert(Date, O.date)) as Pizza_per_day;


--Determine the top 3 most ordered pizza types based on revenue.--The Thai chicken, Barbecue chicken, California
Select top 3 pt.name as Pizza_name, sum(p.price*OD.quantity) as Amount 
from pizzas as p
Inner join
order_details as OD 
on p.pizza_id=	OD.pizza_id
join 
pizza_types as pt 
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by Amount DESC;


--Calculate the percentage contribution of each pizza type to total revenue.-- Classic(27),Supreme(25),Veggie(24),Chicken(24),

WITH RenvueTotalCat as(
select pt.category as Name, Round(SUM(p.price*od.quantity),0) as Total_Revenue 
from pizzas as p 
join order_details as od
on p.pizza_id=od.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category
),

Revenue as( 
Select sum(Total_Revenue) as TotalR 
from RenvueTotalCat)

select Name, Round(Total_Revenue/TotalR*100,0) as PercentageContribution  from RenvueTotalCat, Revenue
Order by PercentageContribution DESC ;


--Analyze the cumulative revenue generated over time.
Select Date, sum(amount) over (order by Date) as cumulative_rev 
from 
(select Convert(Date,o.date) as Date, SUM(p.price*quantity) as amount from pizzas as p
join
order_details as od
on p.pizza_id = od.pizza_id
join
orders as o on od.order_id=o.order_id
Group by Convert(Date,o.date)) as RevenueByDate;


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select Name, Revenue from 
(Select Category, Name, Revenue,
rank() over(partition by category order by Revenue DESC) as rank 
from
(Select pt.category as Category, pt.name as Name, Round(SUM(price*od.quantity),0) as Revenue 
from pizzas as p
join 
order_details as od 
on p.pizza_id=od.pizza_id
join 
pizza_types as pt on p.pizza_type_id= pt.pizza_type_id 
Group by pt.category, name) as a) as b where rank <=3;













