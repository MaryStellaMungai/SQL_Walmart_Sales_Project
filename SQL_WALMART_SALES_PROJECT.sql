#1 SQL_WALMART_SALES_PROJECT
#2 Data Setup
CREATE database WALMART_SALES;
CREATE TABLE SALES(
invoice_id varchar(30) NOT NULL PRIMARY KEY,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10, 2) not null,
quantity int not null,
VAT float(6, 4) not null,
total decimal(12, 4) not null,
Date DATETIME not null,
time TIME not null,
payment_method varchar(15) not null,
cogs decimal(10, 2) not null,
Gross_margin_prct float(11, 9),
Gross_income Decimal (12, 4) not null,
rating float(2, 1)
);

#3. Feature Engineering
 # Time of the day
 select time ,
 (case
	when time between '00:00:00' and '12:00:00' then 'Morning'
    when time between '12:01:00' and '16:00:00' then 'Aternoon'
    else 'evening'
    end
 ) as Time_of_day
 from sales;

USE WALMART_SALES;
Alter Table sales ADD COLUMN time_of_day varchar(20);
DESCRIBE SALES;

UPDATE sales
SET time_of_day = (
case
	when time between '00:00:00' and '12:00:00' then 'Morning'
    when time between '12:01:00' and '16:00:00' then 'Afternoon'
    else 'evening'
    end
    );
    
    # DAY NAME
select date,
DAYNAME(date)
 from sales;
 
 use walmart_sales;
 alter Table Sales add column day_name varchar(10);
 
 update sales
 set day_name = DAYNAME(date);
 
select date,
MONTHNAME(date)
from sales;

use walmart_sales;
alter Table sales add column month_name varchar(10);

update sales
set month_name = MONTHNAME(date);

                         #4. EXPLORATORY DATA ANALYSIS
------------------------------------------# GENERIC---------------------------------------------------------------------------------------------
SELECT * FROM walmart_sales.sales;
#1.	How many unique cities does the data have?
SELECT DISTINCT CITY FROM SALES;
#2.In which city is each branch?
SELECT DISTINCT CITY, branch FROM SALES;
-------------------#PRODUCT------------------------------------
#1.How many unique product lines does the data have?
SELECT count(DISTINCT product_line) from sales;
#2.	What is the most common payment method?
select payment_method, count(payment_method) as cnt
from sales
group by payment_method
order by cnt desc;
#3.	What is the most selling product line?
select product_line, count(product_line) as cnt
from sales
group by product_line
order by cnt desc;
#4.	What is the total revenue by month?
select month_name as month,
sum(total)as Total_Revenue
from sales
group by month_name
order by total_revenue desc
;
#5.	What month had the largest COGS?
select month_name as month , 
sum(cogs) as cost_of_goods
from sales
group by month
order by cost_of_goods desc;
#6.	What product line had the largest revenue?
select product_line,
sum(Total) as total_revenue
from sales
group by product_line
order by total_revenue desc;
#7.	What is the city with the largest revenue?
select city, 
branch,
sum(total) as revenue
from sales
group by city, branch
order by revenue desc;
#8.	What product line had the largest VAT?
SELECT product_line, 
MAX(VAT) AS largest_vat
FROM SALES
GROUP BY product_line
ORDER BY largest_vat DESC;
#10.	Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS total_quantity
FROM SALES
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(total_quantity)
    FROM (
        SELECT SUM(quantity) AS total_quantity
        FROM SALES
        GROUP BY branch
    ) AS branch_totals
);
#11.	What is the most common product line by gender?
select gender, product_line, count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;

SELECT gender, product_line
FROM (
    SELECT gender, product_line, COUNT(*) AS total_cnt
    FROM SALES
    GROUP BY gender, product_line
) AS counts
WHERE (gender, total_cnt) IN (
    SELECT gender, MAX(total_cnt)
    FROM (
        SELECT gender, product_line, COUNT(*) AS total_cnt
        FROM SALES
        GROUP BY gender, product_line
    ) AS sub_counts
    GROUP BY gender
);
#12.	What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating), 2) AS average_rating
FROM SALES
GROUP BY product_line
order by average_rating desc;

#1.	Number of sales made in each time of the day per weekday
SELECT time_of_day,
count(*) as total_sales
from sales
where day_name='monday'
group by time_of_day
order by total_sales desc;
#2.	Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue
from sales
group by customer_type
order by revenue desc
limit 1;
#3.	Which city has the largest tax percent/ VAT (Value Added Tax)?
select city ,
MAX(VAT) as largest_tax
from sales
group by city
order by largest_tax desc
limit 1;

SELECT city, VAT AS largest_tax
FROM sales
ORDER BY VAT DESC
LIMIT 1;

#4.	Which customer type pays the most in VAT?
select customer_type, max(vat)
from sales
group by customer_type
order by max(vat) desc;

#1.	How many unique customer types does the data have?
select distinct customer_type from sales;
#2.	How many unique payment methods does the data have?
select distinct payment_method from sales;
#3.	What is the most common customer type?
select customer_type, count(*) as count
from sales
group by customer_type
order by count desc;
#4.	Which customer type buys the most?
select customer_type, sum(total) as total
from sales
group by customer_type
order by total desc;
#5.	What is the gender of most of the customers?
select gender, count(*) as gdr_count
from sales
group by gender
order by gdr_count desc;
#6.	What is the gender distribution per branch?
select branch, gender, count(*) as gender_dist
from sales
group by branch, gender
order by branch, gender_dist;

#7.	Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(*) AS rating_count
FROM sales
GROUP BY time_of_day
ORDER BY rating_count DESC;
#8.	Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, COUNT(*) AS rating_count
FROM sales
GROUP BY branch, time_of_day
ORDER BY rating_count DESC
limit 3;

#9.	Which day fo the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

#10.	Which day of the week has the best average ratings per branch?
select branch,day_name, avg(rating) as avg_rating
from sales
group by branch, day_name
order by avg_rating desc
limit 3;

WITH RankedRatings AS (
    SELECT branch, day_name, AVG(rating) AS avg_rating,
           ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rn
    FROM sales
    GROUP BY branch, day_name
)
SELECT branch, day_name, avg_rating
FROM RankedRatings
WHERE rn = 1
ORDER BY branch;