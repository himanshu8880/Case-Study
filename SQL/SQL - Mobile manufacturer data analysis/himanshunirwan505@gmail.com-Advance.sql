--SQL Advance Case Study


--Q1--BEGIN 
	SELECT DISTINCT State
	FROM DIM_LOCATION AS L
	INNER JOIN FACT_TRANSACTIONS AS T
	ON L.IDLocation = T.IDLocation
	WHERE Year(Date) BETWEEN 2005 AND GETDATE()



--Q1--END

--Q2--BEGIN
	
select top 1 state, SUM(Quantity) as count_phones
from DIM_LOCATION as L
inner join FACT_TRANSACTIONS AS T
on L.IDLocation = T.IDLocation
inner join DIM_MODEL as M
on T.IDModel = M.IDModel
inner join DIM_MANUFACTURER as D
on M.IDManufacturer = D.IDManufacturer
where Manufacturer_Name = 'samsung' and  Country = 'US'
group by State
order by count_phones desc



--Q2--END

--Q3--BEGIN     
select 	T.IDModel,Model_Name,ZipCode,State, COUNT(IDCustomer) as no_of_transaction
from FACT_TRANSACTIONS as T
inner join DIM_MODEL as M
on T.IDModel = M.IDModel
inner join DIM_LOCATION as L
on T.IDLocation = L.IDLocation
group by T.IDModel,ZipCode,State,Model_Name
order by Model_Name

--Q3--END

--Q4--BEGIN
select top 1 * from DIM_MODEL
order by Unit_price 


--Q4--END

--Q5--BEGIN

select M.IDManufacturer,Model_Name , SUM(TotalPrice) / SUM(Quantity) AS AVG_PRICE
from DIM_MODEL as M
inner join DIM_MANUFACTURER MF on M.IDManufacturer = MF.IDManufacturer
INNER JOIN FACT_TRANSACTIONS T ON T.IDModel = M.IDModel
where manufacturer_name in
   (   select top 5 Manufacturer_Name
	   from FACT_TRANSACTIONS as T
	   inner join DIM_MODEL as M
	   on T.IDModel = M.IDModel
	   inner join DIM_MANUFACTURER as F
	   on M.IDManufacturer = F.IDManufacturer
	   group by Manufacturer_Name
	   order by SUM(Quantity) desc
	) 
group by Model_Name, M.IDManufacturer
order by AVG_PRICE 



--Q5--END

--Q6--BEGIN

select Customer_Name , avg(TotalPrice) as avg_amount
from DIM_CUSTOMER as C
inner join FACT_TRANSACTIONS as T
on C.IDCustomer = T.IDCustomer
where year(date) = 2009
group by Customer_Name
having avg(TotalPrice) > 500






--Q6--END
	
--Q7--BEGIN  
	
SELECT IDModel  FROM
 (

	SELECT TOP 5 IDModel 
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date)  = 2008
	GROUP BY IDModel 
	ORDER BY SUM(Quantity) DESC
  ) AS X



INTERSECT

SELECT IDModel  FROM
 (

	SELECT TOP 5 IDModel 
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date) = 2009
	GROUP BY IDModel
	ORDER BY SUM(Quantity) DESC
  ) AS X



INTERSECT

SELECT IDModel FROM
 (

	SELECT TOP 5 IDModel 
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date)  = 2010
	GROUP BY IDModel
	ORDER BY SUM(Quantity) DESC
  ) AS X







--Q7--END	

--Q8--BEGIN


SELECT  IDManufacturer FROM
	(
		SELECT IDManufacturer ,YEAR(Date) AS YEARS,  DENSE_RANK() OVER(PARTITION BY YEAR(DATE) ORDER BY SUM(TOTALPRICE) DESC) AS RANKS
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_MODEL AS M ON T.IDModel = M.IDModel
		WHERE YEAR(Date) IN (2009,2010)
		GROUP BY IDManufacturer, YEAR(DATE)
	) AS X
WHERE RANKS = 2





--Q8--END
--Q9--BEGIN
	

select Manufacturer_Name
from DIM_MODEL as M
inner join FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
inner join DIM_MANUFACTURER as S
on M.IDManufacturer = S.IDManufacturer
where YEAR(Date) = 2010
except
select Manufacturer_Name
from DIM_MODEL as M
inner join FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
inner join DIM_MANUFACTURER as S
on M.IDManufacturer = S.IDManufacturer
where YEAR(Date) = 2009




--Q9--END

--Q10--BEGIN




WITH TOP_10 
AS (
		SELECT TOP 10 IDCustomer , SUM(TotalPrice) AS TOTAL_SPEND
		FROM FACT_TRANSACTIONS AS T
		GROUP BY IDCustomer
		ORDER BY SUM(TotalPrice) DESC
	),

AVG_BY_YEAR
AS (
		SELECT IDCustomer,YEAR(Date) AS YEARS, AVG(TotalPrice) AS CURR_AVG_SPEND, AVG(Quantity) AS AVG_QUANTITY
		FROM FACT_TRANSACTIONS
		WHERE IDCustomer IN (SELECT IDCustomer FROM TOP_10)
		GROUP BY IDCustomer,YEAR(Date)
		
	),

PREV_SPEND
AS (
		SELECT *, LAG(CURR_AVG_SPEND,1) OVER(PARTITION BY IDCUSTOMER ORDER BY years ) AS PREV_AVG_SPEND
		FROM AVG_BY_YEAR 
	)
SELECT * , (CURR_AVG_SPEND - PREV_AVG_SPEND)/PREV_AVG_SPEND * 100 AS PERCENT_CHANGE
FROM PREV_SPEND	



--Q10--END
	