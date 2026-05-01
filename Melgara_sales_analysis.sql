/* Smaya Melgara Sales Analysis 
Sales Territory: East Region (Connecticut)
*/

USE sample_sales;

/*
- What is total revenue overall for sales in the assigned territory, plus the start date and end date
that tell you what period the data covers?*/

-- INPERSON store sales total in connecticut
SELECT SUM(Sale_Amount) AS 'In Person Revenue'
FROM store_sales 
WHERE store_id IN (SELECT StoreID
				FROM store_locations
				WHERE state = 'Connecticut');
-- Online sales total in connecticut  
SELECT SUM(SalesTotal) AS 'Online Revenue'
FROM online_sales
WHERE ShiptoState = 'Connecticut';

-- TOTAL Revenue 
SELECT ( 
SELECT SUM(Sale_Amount) AS 'In Person Revenue'
FROM store_sales 
WHERE store_id IN (SELECT StoreID
				FROM store_locations
				WHERE state = 'Connecticut') 
) + 
( 
SELECT SUM(SalesTotal) AS 'Online Revenue'
FROM online_sales
WHERE ShiptoState = 'Connecticut'
) 
AS Total_Revenue; 
-- Dates for in person revenue 
SELECT MIN(Transaction_Date) AS store_start, MAX(Transaction_Date) AS store_end
FROM store_sales
WHERE Store_ID IN (
	SELECT storeID 
    FROM store_locations
	WHERE state = 'Connecticut');
-- Online revenue dates
SELECT MIN(Date) AS online_start, MAX(Date) AS online_end 
FROM online_sales
WHERE ShiptoState = 'Connecticut'; 




/*- What is the month by month revenue breakdown for the sales territory?*/
-- Inperson monthly revenue 
SELECT YEAR(Transaction_Date) AS SalesYear, MONTH(Transaction_Date) AS SalesMonth , SUM(Sale_Amount) AS Store_Revenue 
FROM store_sales 
WHERE store_ID IN (
	SELECT storeID
    FROM store_locations
    WHERE state = 'Connecticut') 
GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
ORDER BY SalesYear, SalesMonth;

-- Online Sales monthly revenue 
SELECT YEAR(Date) AS salesYear, MONTH(Date) AS salesMonth, SUM(SalesTotal) AS Online_Revenue 
FROM online_sales 
WHERE ShiptoState = 'Connecticut' 
GROUP BY YEAR(Date) , MONTH(Date) 
ORDER BY salesYear, salesMonth;

-- TOTAL MONTH TO MONTH REVENUE 
SELECT SalesYear, SalesMonth, Sum(Revenue) AS Total_Monthly_Revenue 
FROM (
	SELECT YEAR(Transaction_Date) AS SalesYear, MONTH(Transaction_Date) AS SalesMonth, SUM(Sale_Amount) AS Revenue 
    FROM store_sales
    WHERE store_id IN (
		SELECT storeID 
        FROM store_locations
        WHERE state = 'Connecticut'
        )
	GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
UNION ALL 
	SELECT YEAR(Date) AS salesYear, MONTH(Date) AS salesMonth, SUM(SalesTotal) AS Revenue 
	FROM online_sales
	WHERE ShiptoState = 'Connecticut' 
    GROUP BY YEAR(Date), MONTH(Date)
) AS Combined_MonthToMonth_Revenue
GROUP BY SalesYear, SalesMonth
ORDER BY SalesYear, SalesMonth;




/*- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.*/
-- Connecticut total revenue 
SELECT ( 
SELECT SUM(Sale_Amount) AS 'In Person Revenue'
FROM store_sales 
WHERE store_id IN (SELECT StoreID
				FROM store_locations
				WHERE state = 'Connecticut') 
) + 
( 
SELECT SUM(SalesTotal) AS 'Online Revenue'
FROM online_sales
WHERE ShiptoState = 'Connecticut'
) 
AS Connecticut_Total_Revenue; 

-- East Region total Revenue 
SELECT (
	SELECT SUM(Sale_Amount)
    FROM store_sales 
    WHERE Store_Id IN (
		SELECT StoreID 
        FROM Store_Locations
        WHERE state IN (
			SELECT state
            FROM Management 
            WHERE Region = 'East'
            )
		)
	)
    +
    ( 
	SELECT SUM(SalesTotal)
    FROM online_sales 
    WHERE ShiptoState IN (
		SELECT state
        FROM management
        WHERE region = 'East'
        )
	) AS East_Region_Revenue;
-- Conneticut made $3,202,493.38 of the $10,671,322.31 total East Region Revenue. 

/*- What is the number of transactions per month and average transaction size by product category
for the sales territory?*/

-- Find number of monthly transactions of in-person 
-- Find number of monthly transaction of online 
-- ADD numbers of monthly transactions 
-- Find Average transaction size
-- order by product category 

SELECT SalesYear, SalesMonth, Product_Category, SUM(Number_Of_Transactions) AS Total_Transactions, 
AVG(Average_Transaction_Size) AS Average_Transaction_Size
FROM (
-- In Person Sales 
-- Count the transactions and list the average sale amount with month and category included 
	SELECT YEAR(ss.Transaction_Date) AS SalesYear, MONTH(ss.Transaction_Date) AS SalesMonth, ic.Category AS Product_Category,
	COUNT(*) AS Number_Of_Transactions, AVG(ss.Sale_Amount) AS Average_Transaction_Size
	FROM store_sales ss
-- find product info 
	JOIN products p 
		ON ss.Prod_Num = p.ProdNum
-- find category info 
	JOIN inventory_categories AS ic
		ON p.Categoryid = ic.Categoryid
	WHERE ss.Store_ID IN (
	SELECT Store_ID
    FROM store_locations
    WHERE state = 'Connecticut'
    )
GROUP BY YEAR(ss.Transaction_Date), MONTH(ss.Transaction_Date), ic.Category
UNION ALL 
-- online sales 
-- Count the transactions and include the order of category and average sale 
	SELECT YEAR(os.Date) AS SalesYear, MONTH(os.Date) AS SalesMonth, ic.Category AS Product_Category, 
    Count(*) AS Number_of_Transactions, AVG(os.SalesTotal) AS Average_Transaction_Size
    FROM online_sales os
-- Find product info 
    JOIN products p 
		on os.ProdNum = p.ProdNum
-- Find category info 
	JOIN inventory_categories ic 
		on p.CategoryID = ic.Categoryid
	WHERE os.ShiptoState = 'Connecticut' 
    GROUP BY YEAR(os.Date), MONTH(os.Date), ic.Category
) AS monthly_transaction_data
-- Present the info 
GROUP BY SalesYear, SalesMonth, Product_Category 
ORDER BY SalesYear, SalesMonth, Product_Category ;




/*- Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory?*/
-- Find each stores total revenue
SELECT sl.StoreID, sl.StoreLocation, sl.State, SUM(ss.Sale_Amount) AS total_store_revenue
FROM store_sales ss
-- Find sale information according to location 
JOIN store_locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Connecticut' 
GROUP BY sl.StoreID, sl.StoreLocation, sl.State
-- Establish Descending to sort from highest to lowest sales 
ORDER BY total_store_revenue DESC;




/*- What is your recommendation for where to focus sales attention in the next quarter?
 I would recommend focusing sales attention on products that have the lowest average transaction value. 
Even if the total transactions is a large number the amount of money coming out would be low 
if the average transaction size is small. I would encourage more attention on 
that coloumn within the monthly transaction data query. 
This change would help the overall total revenue within the region. 


*/
