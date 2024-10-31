---------------------------------------------------- DATA PREPARATION AND UNDERSTANDING-------------------------------------------------------------

-- 1. What is the total number of rows in each of the 3 tables in the database?

select 'Customer' as table_name, COUNT(*) as count_records from Customer
union
select 'Product_cat' as table_name, COUNT(*) as count_records from prod_cat_info
union
select 'Transactions' as table_name, COUNT(*) as count_records from Transactions

-- 2. What is the total number of transactions that have a return?

select COUNT(transaction_id) as no_of_returns
from Transactions
where Qty < 0



-- 3. As you would have noticed, the dates provided across the datasets are not in a correct format.
--    As first steps, pls convert the date variables into valid date formats before proceeding ahead.

select CONVERT(date,DOB,105) as new_dob from Customer
select CONVERT(date,tran_date,105) as new_tran_date from Transactions

-- 4.What is the time range of the transaction data available for analysis? 
--	Show the output in number of days, months and years simultaneously
--	in different columns.

select DATEDIFF(DAY,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105))) as Days,
DATEDIFF(MONTH,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105))) as Months,
DATEDIFF(YEAR,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105))) as Years
from Transactions

-- 5. Which product category does the sub-category “DIY” belong to?

select prod_cat
from prod_cat_info
where prod_subcat = 'diy'

----------------------------------------------------------DATA ANALYSIS------------------------------------------------------------------------------------
-- 1. Which channel is most frequently used for transactions?

select top 1 Store_type,COUNT(transaction_id) as count_type
from Transactions
group by Store_type
order by count_type desc

-- 2.What is the count of Male and Female customers in the database?

select Gender, COUNT(customer_Id) as total_count
from Customer
where Gender <> ' '
group by Gender

-- 3. From which city do we have the maximum number of customers and how many?

select top 1 city_code , COUNT(customer_Id) as no_of_customers
from Customer
group by city_code
order by no_of_customers desc

-- 4. How many sub-categories are there under the Books category?

select prod_cat,COUNT(prod_subcat) as count_subcat
from prod_cat_info
where prod_cat = 'books'
group by prod_cat


-- 5. What is the maximum quantity of products ever ordered?

select top 1 Qty
from Transactions
order by Qty desc 


-- 6.What is the net total revenue generated in categories Electronics and Books?

select prod_cat,SUM(CAST(total_amt as float)) as total_revenue
from prod_cat_info as I
inner join Transactions as T
on I.prod_cat_code = T.prod_cat_code and I.prod_sub_cat_code = T.prod_subcat_code
where prod_cat in ('electronics','books') 
GROUP BY ROLLUP(prod_cat)

-- 7. How many customers have >10 transactions with us, excluding returns?

select count(*) as no_of_customers
from(select cust_id, COUNT(transaction_id) as transactions
	from Transactions
	where Qty > 0
	group by cust_id
	having COUNT(transaction_id) >10
) as x


 
-- 8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

select SUM(CAST(total_amt as float)) as comb_revenue
from Transactions as T
inner join prod_cat_info as I
on T.prod_cat_code = I.prod_cat_code and T.prod_subcat_code = I.prod_sub_cat_code
where prod_cat in ('clothing','electronics') and Store_type = 'flagship store' 

                                                       

-- 9.What is the total revenue generated from “Male” customers  in “Electronics” category? Output should display total revenue by prod sub-cat.

select prod_subcat, SUM(CAST(total_amt as float)) as total_revenue
from Customer as C
inner join Transactions as T
on C.customer_Id = T.cust_id
inner join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where Gender = 'm' and prod_cat = 'electronics' 
group by prod_subcat	

-- 10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

SELECT TOP 5 prod_subcat , SALES / (SELECT SUM(CONVERT(FLOAT,total_amt)) FROM Transactions WHERE CONVERT(FLOAT,total_amt) >0) * 100 AS PERC_SALES,
		TARGETS / (SELECT SUM(CONVERT(FLOAT,total_amt)) FROM Transactions WHERE CONVERT(FLOAT,total_amt) <0) * 100 AS PERC_RETURN
FROM
	(
		SELECT  prod_subcat,
		SUM(CASE WHEN CONVERT(float,total_amt) > 0 THEN CONVERT(float,total_amt) ELSE 0 END)  AS SALES,
		SUM(CASE WHEN CONVERT(float,total_amt) < 0 THEN CONVERT(float,total_amt) ELSE 0 END)  AS TARGETS
		FROM Transactions AS T 
		INNER JOIN prod_cat_info AS I ON T.prod_cat_code = I.prod_cat_code AND T.prod_subcat_code = I.prod_sub_cat_code
		GROUP BY prod_subcat
	) AS X
ORDER BY PERC_SALES DESC



-- 11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions
--	   from max transaction date available in the data?

SELECT SUM(CONVERT(float,total_amt)) AS TOTAL_REVENUE
FROM Customer AS C
INNER JOIN Transactions AS T ON C.customer_Id = T.cust_id
WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,105),GETDATE()) BETWEEN 25 AND 35 
                      AND
	   CONVERT(date,tran_date,105) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(date,tran_date,105)) FROM TRANSACTIONS))
							AND (SELECT MAX(CONVERT(date,tran_date,105)) FROM TRANSACTIONS)


-- 12. Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT top 1 prod_cat
FROM Transactions AS T
INNER JOIN prod_cat_info AS I ON T.prod_cat_code = I.prod_cat_code AND T.prod_subcat_code = I.prod_sub_cat_code
WHERE CONVERT(float,total_amt) < 0 AND
	  CONVERT(date,tran_date,105) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(date,tran_date,105)) FROM TRANSACTIONS))
							AND (SELECT MAX(CONVERT(date,tran_date,105)) FROM TRANSACTIONS)
GROUP BY prod_cat
ORDER BY SUM(CONVERT(float,Qty))



-- 13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select TOP 1 Store_type,SUM(CAST(total_amt as float)) as total_sales,SUM(CAST(qty as int)) as total_quantity_sold
from Transactions
group by Store_type
order by total_sales desc 


-- 14. What are the categories for which average revenue is above the overall average
select prod_cat,AVG(CONVERT(FLOAT,total_amt)) as avg_amt
from prod_cat_info as I
inner join Transactions T
on I.prod_cat_code = T.prod_cat_code and I.prod_sub_cat_code = T.prod_subcat_code
group by prod_cat
having 	AVG(CONVERT(FLOAT,total_amt)) > (select AVG(CONVERT(FLOAT,total_amt)) from Transactions)

									

 -- 15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

select prod_cat,prod_subcat, AVG(CAST(total_amt as float)) as avg_revenue, sum(CAST(total_amt as float)) as total_revenue
from Transactions as T
inner join prod_cat_info as I
on T.prod_cat_code = I.prod_cat_code and T.prod_subcat_code = I.prod_sub_cat_code
where prod_cat in 
	(
		select top 5 prod_cat
		from Transactions as T
		inner join prod_cat_info as I
		on T.prod_cat_code = I.prod_cat_code and T.prod_subcat_code = I.prod_sub_cat_code
		group by prod_cat
		order by SUM(CAST(Qty as int)) desc
	) 
group by prod_cat,prod_subcat  




