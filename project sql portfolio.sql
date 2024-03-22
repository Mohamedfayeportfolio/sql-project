SELECT TOP (1000) [Invoice_ID]
      ,[Branch]
      ,[City]
      ,[Customer_type]
      ,[Gender]
      ,[Product_line]
      ,[Unit_price]
      ,[Quantity]
      ,[Tax_5]
      ,[Total]
      ,[Date]
      ,[Time]
      ,[Payment]
      ,[cogs]
      ,[gross_margin_percentage]
      ,[gross_income]
      ,[Rating]
      ,[time_of_day]
      ,[time_of_date]
      ,[day_name]
      ,[monthname]
  FROM [sales portfolio project].[dbo].[sales data]



  
--  -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------- Feature Engeneering ---------------------------------------------------------------------------------------------

-- time of date
SELECT time,
  (CASE 
    WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
	end
  ) AS time_of_date
FROM [sales data]

ALTER TABLE [sales data]
ADD time_of_date VARCHAR(20);

update [sales data]
set time_of_date = (
CASE 
    WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
	end
);

--- day_Name
select Date,
 DATENAME(dw, Date)as day_name
from [sales data]

ALTER TABLE [sales data]
ADD day_name VARCHAR(10);

update [sales data]
set day_name = DATENAME(dw, Date);

--- month name
SELECT Date,
       DATENAME(month, Date) AS MonthName
FROM [sales data];

ALTER TABLE [sales data]
ADD monthname VARCHAR(10);

update [sales data]
set monthname = DATENAME(month, Date)

------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------Generic------------------------------------------------------------------------------------------------------

------how many unique cities does the data have?

select 
    distinct City
	from [sales data]

----in which city is each branch

	select 
    distinct Branch
	from [sales data]

	
	select 
    distinct City, Branch
	from [sales data]


-----------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------product-------------------------------------------------------------------------------------------------------------

----- how many unique product line doeas the data have ?
 select 
     count(distinct Product_line)
 from [sales data]


 -- DECIMAL, according to your needs
ALTER TABLE [sales data]
ALTER COLUMN quantity INT;

 -- What is the most selling product line
SELECT
	SUM(quantity) as qty,
    product_line
FROM [sales data]
GROUP BY product_line
ORDER BY qty DESC;

-- Ajustez la précision et l'échelle selon vos besoins
ALTER TABLE [sales data]
ALTER COLUMN total DECIMAL(10, 2); 

-- What is the total revenue by month
SELECT
	monthname AS month,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY monthname 
ORDER BY total_revenue;

-- Ajustez la précision et l'échelle selon vos besoins

ALTER TABLE [sales data]
ALTER COLUMN cogs DECIMAL(10, 2); 

-- What month had the largest COGS?
SELECT
	monthname AS month,
	SUM(cogs) AS cogs
FROM [sales data]
GROUP BY monthname 
ORDER BY cogs;

-- What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM [sales data]
GROUP BY product_line
ORDER BY total_revenue DESC;


-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY city, branch 
ORDER BY total_revenue;

-- Ajustez la précision et l'échelle selon vos besoins
ALTER TABLE [sales data]
ALTER COLUMN Tax_5 DECIMAL(10, 2); 

-- What product line had the largest TAX?
SELECT
	product_line,
	AVG(Tax_5) as avg_tax
FROM [sales data]
GROUP BY product_line
ORDER BY avg_tax DESC;

-- which branch sold more products than average product sold
-- Quelle succursale a vendu plus de produits que la moyenne des produits vendus ?
SELECT 
    Branch,
    SUM(quantity) AS qty
FROM [sales data]
GROUP BY Branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM [sales data] AS subquery);


-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM [sales data]
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM [sales data]

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM [sales data];


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM [sales data]
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM [sales data]
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM [sales data]
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM [sales data]
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.


-- Which time of the day do customers give most ratings?

-- Ajustez la précision et l'échelle selon vos besoins

ALTER TABLE [sales data]
ALTER COLUMN rating DECIMAL (2) ; 

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM [sales data]
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM [sales data]
WHERE branch = 'a'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM [sales data]
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM [sales data]
WHERE branch = 'C'
GROUP BY day_name
ORDER BY total_sales DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM [sales data]
WHERE day_name = 'Sunday'
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(Tax_5), 2) AS avg_tax_pct
FROM [sales data]
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_5) AS total_tax
FROM [sales data]
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------