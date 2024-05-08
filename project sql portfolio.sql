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
----------------------------- Ingénierie des Caractéristiques ---------------------------------------------------------------------------------------------

-- heure de la date
SELECT time,
  (CASE 
    WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
	end
  ) AS heure de la date
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

--- Nom du jour
select Date,
 DATENAME(dw, Date)as day_name
from [sales data]

ALTER TABLE [sales data]
ADD day_name VARCHAR(10);

update [sales data]
set day_name = DATENAME(dw, Date);

---Nom du mois
SELECT Date,
       DATENAME(month, Date) AS MonthName
FROM [sales data];

ALTER TABLE [sales data]
ADD monthname VARCHAR(10);

update [sales data]
set monthname = DATENAME(month, Date)

------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------générique------------------------------------------------------------------------------------------------------

------Combien de villes uniques contient la donnée ?

select 
    distinct City
	from [sales data]

----Dans quelle ville se trouve chaque succursale ?
	select 
    distinct Branch
	from [sales data]

	
	select 
    distinct City, Branch
	from [sales data]


-----------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------produits-------------------------------------------------------------------------------------------------------------

-----Combien de lignes de produits uniques contient la donnée ?
 select 
     count(distinct Product_line)
 from [sales data]


 -- DECIMAL, selon vos besoins
ALTER TABLE [sales data]
ALTER COLUMN quantity INT;

 -- Quelle est la ligne de produit la plus vendue ?
SELECT
	SUM(quantity) as qty,
    product_line
FROM [sales data]
GROUP BY product_line
ORDER BY qty DESC;

--Ajustez la précision et l'échelle.
ALTER TABLE [sales data]
ALTER COLUMN total DECIMAL(10, 2); 

-- Quel est le revenu total par mois ?
SELECT
	monthname AS month,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY monthname 
ORDER BY total_revenue;

--Ajustez la précision et l'échelle selon vos besoins.

ALTER TABLE [sales data]
ALTER COLUMN cogs DECIMAL(10, 2); 

-- Quel mois a eu le COGS le plus élevé ?
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


-- Quelle est la ville avec le plus grand revenu ?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY city, branch 
ORDER BY total_revenue;

-- Ajustez la précision et l'échelle selon vos besoins.
ALTER TABLE [sales data]
ALTER COLUMN Tax_5 DECIMAL(10, 2); 

-- Quelle ligne de produit a eu la plus grande TAXE ?
SELECT
	product_line,
	AVG(Tax_5) as avg_tax
FROM [sales data]
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Quelle succursale a vendu plus de produits que la moyenne des produits vendus ?
SELECT 
    Branch,
    SUM(quantity) AS qty
FROM [sales data]
GROUP BY Branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM [sales data] AS subquery);


-- Quelle est la ligne de produit la plus courante par sexe ?
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
-- -------------------------- clients -------------------------------
-- --------------------------------------------------------------------

-- Combien de types de clients uniques contient la donnée ?
SELECT
	DISTINCT customer_type
FROM [sales data]

-- Combien de méthodes de paiement uniques contient la donnée ?
SELECT
	DISTINCT payment
FROM [sales data];


--Quel est le type de client le plus courant ?
SELECT
	customer_type,
	count(*) as count
FROM [sales data]
GROUP BY customer_type
ORDER BY count DESC;

--Quel type de client achète le plus ?
SELECT
	customer_type,
    COUNT(*)
FROM [sales data]
GROUP BY customer_type;


--Quel est le genre de la plupart des clients ?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM [sales data]
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Quelle est la répartition des genres par succursale ?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM [sales data]
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Le genre par succursale est plus ou moins le même,
---donc je ne pense pas que cela ait un effet sur les ventes par succursale et d'autres facteurs.


-- À quel moment de la journée les clients donnent-ils le plus d'évaluations ?

-- Ajustons la précision et l'échelle.

ALTER TABLE [sales data]
ALTER COLUMN rating DECIMAL (2) ; 

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM [sales data]
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Il semble que l'heure de la journée n'affecte pas vraiment la notation,
-- c'est plus ou moins la même notation à chaque heure de la journée.


-- À quelle heure de la journée les clients donnent-ils le plus d'évaluations par succursale ?

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM [sales data]
WHERE branch = 'a'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Les succursales A et C obtiennent de bons résultats en termes de notation, 
--tandis que la succursale B doit faire un peu plus d'efforts pour obtenir de meilleures notes.


-- Quel jour de la semaine a la meilleure moyenne de notes ?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM [sales data]
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Lundi, mardi et vendredi sont les meilleurs jours pour de bonnes notes.
-- Pourquoi est-ce le cas ? Combien de ventes sont réalisées ces jours-là ?



-- Quel jour de la semaine a la meilleure moyenne de notes par succursale ?
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
-- ---------------------------- Ventes ---------------------------------
-- --------------------------------------------------------------------

-- Nombre de ventes réalisées à chaque heure de la journée par jour de la semaine
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM [sales data]
WHERE day_name = 'Sunday'
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Les soirées connaissent le plus de ventes,
-- les magasins sont remplis pendant les heures du soir.

-- Quel type de client génère le plus de revenus ?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM [sales data]
GROUP BY customer_type
ORDER BY total_revenue;

-- Quelle ville a le pourcentage de taxe/TVA le plus élevé ?
SELECT
	city,
    ROUND(AVG(Tax_5), 2) AS avg_tax_pct
FROM [sales data]
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Quel type de client paie le plus de TVA ?
SELECT
	customer_type,
	AVG(tax_5) AS total_tax
FROM [sales data]
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
