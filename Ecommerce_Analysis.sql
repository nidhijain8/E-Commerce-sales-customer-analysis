SHOW DATABASES;
USE ecommerce_analysis;
SELECT COUNT(*) FROM ecommerce_cleaned;

USE ecommerce_analysis;
DROP TABLE IF EXISTS ecommerce_cleaned;

SELECT COUNT(*) FROM ecommerce_cleaned;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) FROM online_retail;

USE ecommerce_analysis;
DROP TABLE IF EXISTS ecommerce_cleaned;

DROP TABLE IF EXISTS ecommerce_cleaned;
USE ecommerce_analysis;

SHOW TABLES;
DROP TABLE IF EXISTS online_retail;

USE ecommerce_analysis;

CREATE TABLE online_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DOUBLE,
    CustomerID VARCHAR(20),
    Country VARCHAR(50),
    Revenue DOUBLE
);
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'D:/E- Commerce/Data set/Ecommerce_Cleaned.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country, Revenue);
SHOW VARIABLES LIKE 'local_infile';
SELECT COUNT(*) FROM online_retail;
LOAD DATA LOCAL INFILE 'D:/E- Commerce/Data set/Ecommerce_Cleaned.csv'
INTO TABLE online_retail
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country, Revenue);
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) AS Total_Records
FROM online_retail;
SELECT *
FROM online_retail
LIMIT 10;
SELECT InvoiceDate
FROM online_retail
LIMIT 10;
SELECT
    COUNT(DISTINCT InvoiceNo) AS Total_Transactions,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    COUNT(DISTINCT StockCode) AS Total_Products,
    SUM(Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM online_retail;
UPDATE online_retail
SET CustomerID = NULL
WHERE TRIM(CustomerID) = '';
SET SQL_SAFE_UPDATES = 0;
UPDATE online_retail
SET CustomerID = NULL
WHERE TRIM(CustomerID) = '';
SELECT COUNT(DISTINCT CustomerID)
FROM online_retail;
SET SQL_SAFE_UPDATES = 1;
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
    ROUND(SUM(Revenue), 2) AS Monthly_Revenue
FROM online_retail
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Sales_Month;
SELECT
    Description,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    SUM(Quantity) AS Total_Quantity_Sold
FROM online_retail
WHERE Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY Description
ORDER BY Total_Revenue DESC
LIMIT 10;
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Total_Transactions,
    COUNT(DISTINCT CustomerID) AS Total_Customers
FROM online_retail
GROUP BY Country
ORDER BY Total_Revenue DESC
LIMIT 10;
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;
SELECT
    CASE
        WHEN Order_Count = 1 THEN 'One-Time Customers'
        ELSE 'Repeat Customers'
    END AS Customer_Type,
    COUNT(*) AS Total_Customers
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Order_Count
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS Customer_Orders
GROUP BY Customer_Type;
SELECT
    Order_Count,
    COUNT(*) AS Total_Customers
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Order_Count
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS Customer_Orders
GROUP BY Order_Count
ORDER BY Order_Count;
WITH Customer_Spending AS (
    SELECT
        CustomerID,
        SUM(Revenue) AS Total_Spending
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
Customer_Segments AS (
    SELECT
        CustomerID,
        Total_Spending,
        NTILE(4) OVER (ORDER BY Total_Spending) AS Spending_Quartile
    FROM Customer_Spending
)
SELECT
    CONCAT('Q', Spending_Quartile) AS Customer_Segment,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(Total_Spending), 2) AS Average_Spending,
    ROUND(SUM(Total_Spending), 2) AS Segment_Revenue
FROM Customer_Segments
GROUP BY Spending_Quartile
ORDER BY Spending_Quartile;
SELECT
    COUNT(*) AS Total_Orders,
    ROUND(AVG(Order_Revenue), 2) AS Average_Order_Value,
    ROUND(MAX(Order_Revenue), 2) AS Highest_Order_Value,
    ROUND(MIN(Order_Revenue), 2) AS Lowest_Order_Value
FROM (
    SELECT
        InvoiceNo,
        SUM(Revenue) AS Order_Revenue
    FROM online_retail
    GROUP BY InvoiceNo
) AS Order_Summary;
SELECT
    DAYNAME(InvoiceDate) AS Day_Name,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM online_retail
GROUP BY DAYOFWEEK(InvoiceDate), DAYNAME(InvoiceDate)
ORDER BY DAYOFWEEK(InvoiceDate);
WITH Monthly_Sales AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
        SUM(Revenue) AS Monthly_Revenue
    FROM online_retail
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
),
Revenue_Comparison AS (
    SELECT
        Sales_Month,
        Monthly_Revenue,
        LAG(Monthly_Revenue) OVER (ORDER BY Sales_Month) AS Previous_Month_Revenue
    FROM Monthly_Sales
)
SELECT
    Sales_Month,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,
    ROUND(Previous_Month_Revenue, 2) AS Previous_Month_Revenue,
    ROUND(
        (Monthly_Revenue - Previous_Month_Revenue)
        / NULLIF(Previous_Month_Revenue, 0) * 100, 2
    ) AS Growth_Percentage
FROM Revenue_Comparison
ORDER BY Sales_Month;
SELECT
    Description,
    SUM(Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM online_retail
WHERE Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;
WITH Customer_RFM AS (
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) + INTERVAL 1 DAY FROM online_retail),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        ROUND(SUM(Revenue), 2) AS Monetary
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT *
FROM Customer_RFM
ORDER BY Monetary DESC
LIMIT 20;
WITH Customer_RFM AS (
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) + INTERVAL 1 DAY
             FROM online_retail),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
RFM_Scores AS (
    SELECT
        CustomerID,
        Recency,
        Frequency,
        ROUND(Monetary, 2) AS Monetary,
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM Customer_RFM
)
SELECT
    *,
    (R_Score + F_Score + M_Score) AS RFM_Total_Score
FROM RFM_Scores
ORDER BY RFM_Total_Score DESC;
WITH Customer_RFM AS (
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) + INTERVAL 1 DAY
             FROM online_retail),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
RFM_Scores AS (
    SELECT
        CustomerID,
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM Customer_RFM
),
Customer_Segments AS (
    SELECT *,
        CASE
            WHEN R_Score >= 3 AND F_Score >= 3
                THEN 'Loyal Customers'
            WHEN R_Score = 4 AND F_Score <= 2
                THEN 'New Customers'
            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'
            WHEN R_Score <= 2 AND F_Score <= 2
                THEN 'Lost Customers'
            ELSE 'Regular Customers'
        END AS Customer_Segment
    FROM RFM_Scores
)
SELECT
    Customer_Segment,
    COUNT(*) AS Total_Customers
FROM Customer_Segments
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;
CREATE VIEW monthly_sales AS
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
    ROUND(SUM(Revenue), 2) AS Monthly_Revenue,
    SUM(Quantity) AS Total_Quantity
FROM online_retail
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m');
SELECT *
FROM monthly_sales
ORDER BY Sales_Month;
CREATE VIEW product_sales AS
SELECT
    Description,
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM online_retail
WHERE Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY Description;
SELECT *
FROM product_sales
ORDER BY Total_Revenue DESC
LIMIT 10;
CREATE VIEW country_sales AS
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    SUM(Quantity) AS Total_Quantity,
    COUNT(DISTINCT InvoiceNo) AS Total_Transactions
FROM online_retail
GROUP BY Country;
SELECT *
FROM country_sales
ORDER BY Total_Revenue DESC;
CREATE VIEW customer_analysis AS
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    SUM(Quantity) AS Total_Quantity_Purchased,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    MIN(InvoiceDate) AS First_Purchase_Date,
    MAX(InvoiceDate) AS Last_Purchase_Date
FROM online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;
SELECT *
FROM customer_analysis
ORDER BY Total_Revenue DESC
LIMIT 10;