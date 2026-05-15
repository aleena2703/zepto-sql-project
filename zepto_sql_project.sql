-- ==================================================
-- PROJECT TITLE : ZEPTO PRODUCT, INVENTORY & PRICING ANALYSIS
-- ==================================================

-- PROJECT TYPE  : Advanced SQL Portfolio Project

-- DESCRIPTION :
-- This project analyzes product pricing, inventory,
-- discounts, stock availability using SQL.

-- ===============
-- PROJECT SUMMARY
-- ===============

-- 1. DATABASE SETUP
-- 2. RAW DATA IMPORT
-- 3. DATA VALIDATION
-- 4. DATA CLEANING
-- 5. DATA VALIDATION & CHECKS
-- 6. EXPLORATORY DATA ANALYSIS
-- 7. BUSINESS ANALYSIS
-- 8. ADVANCED SQL ANALYSIS
-- 9. COMMON TABLE EXPRESSIONS (CTEs)
-- 10. FINAL BUSINESS INSIGHTS

-- =================
-- 1. DATABASE SETUP
-- =================

CREATE DATABASE IF NOT EXISTS zepto_sql_project;

USE zepto_sql_project;

DROP TABLE IF EXISTS zepto_data;
DROP TABLE IF EXISTS temp_zepto;

-- ==================
-- 2. RAW DATA IMPORT
-- ==================

-- CREATE STAGING TABLE

CREATE TABLE temp_zepto (
	category TEXT,
    name TEXT,
    mrp TEXT,
    discountpercent TEXT,
    availablequantity TEXT,
    discountedsellingprice TEXT,
    weightingms TEXT,
    outofstock TEXT,
    quantity TEXT
);

-- LOAD CSV

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zepto.csv'
INTO TABLE temp_zepto
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ==================
-- 3. DATA VALIDATION
-- ==================

-- VALIDATE IMPORT COUNT

SELECT COUNT(*) AS raw_row_count
FROM temp_zepto;

-- CHECK FOR NULL VALUES

SELECT
    SUM(category IS NULL) AS category_nulls,
    SUM(name IS NULL) AS name_nulls,
    SUM(mrp IS NULL) AS mrp_nulls,
    SUM(discountpercent IS NULL) AS discount_nulls,
    SUM(availablequantity IS NULL) AS stock_nulls,
    SUM(discountedsellingprice IS NULL) AS sellingprice_nulls,
    SUM(weightingms IS NULL) AS weight_nulls,
    SUM(outofstock IS NULL) AS stockstatus_nulls,
    SUM(quantity IS NULL) AS quantity_nulls
FROM temp_zepto;

-- CHECK FOR EMPTY STRING VALUES

SELECT *
FROM temp_zepto
WHERE
    category = ''
    OR name = ''
    OR mrp = ''
    OR discountpercent = ''
    OR availablequantity = ''
    OR discountedsellingprice = ''
    OR weightingms = ''
    OR outofstock = ''
    OR quantity = '';

-- ===============
-- 4.DATA CLEANING
-- ===============

DROP TABLE IF EXISTS zepto_data;

CREATE TABLE zepto_data (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255),
    name VARCHAR(500),
    mrp DECIMAL(10,2),
    discountpercent DECIMAL(5,2),
    availablequantity INT,
    discountedsellingprice DECIMAL(10,2),
    weightingms INT,
    outofstock VARCHAR(10),
    quantity INT
);

-- INSERT CLEANED DATA INTO FINAL TABLE

INSERT INTO zepto_data (
    category,
    name,
    mrp,
    discountpercent,
    availablequantity,
    discountedsellingprice,
    weightingms,
    outofstock,
    quantity
)
SELECT
    TRIM(category),
    TRIM(name),

    CAST(NULLIF(mrp, '') AS DECIMAL(10,2)) / 100.0,

    CAST(NULLIF(discountpercent, '') AS DECIMAL(5,2)),

    CAST(NULLIF(availablequantity, '') AS SIGNED),

    CAST(NULLIF(discountedsellingprice, '') AS DECIMAL(10,2)) / 100.0,

    CAST(NULLIF(weightingms, '') AS SIGNED),

    UPPER(TRIM(outofstock)),

    CAST(NULLIF(quantity, '') AS SIGNED)

FROM temp_zepto;

-- CHECK FINAL ROW COUNT

SELECT COUNT(*) AS cleaned_row_count
FROM zepto_data;

SHOW TABLES;
DROP TABLE IF EXISTS temp_zepto;

-- ===========================
-- 5. DATA VALIDATION & CHECKS
-- ===========================

SELECT *
FROM zepto_data
LIMIT 10;

-- to preview cleaned dataset

SELECT *
FROM zepto_data
WHERE category IS NULL
OR category = '';

-- To identify : missing categories, incomplete records

-- DUPLICATE PRODUCT ANALYSIS

SELECT 
	category,
	name,
    mrp,
    COUNT(*) AS duplicate_product
FROM zepto_data
GROUP BY category, name, mrp
HAVING COUNT(*) > 1
ORDER BY duplicate_product DESC;

-- BUSINESS VALIDATION CHECK

SELECT 
	name,
    mrp,
    discountedsellingprice,
    availablequantity,
    quantity
FROM zepto_data
WHERE mrp <= 0 
OR discountedsellingprice <= 0
OR availablequantity < 0 
OR quantity < 0
OR mrp < discountedsellingprice;

-- Cherry Blossom Liquid Shoe Polish Neutral	0.00	0.00	1	75

-- ============================
-- 6. EXPLORATORY DATA ANALYSIS
-- ============================

-- ADVANCED BUSINESS QUESTION

 SELECT 
	name,
    category,
    discountpercent,
    availablequantity
FROM zepto_data
WHERE discountpercent > 20 
AND availablequantity <= 5
ORDER BY discountpercent DESC, 
		 availablequantity ASC;
         
-- Find total products, average price, minimum price,
-- maximum price, and average discount for each category

SELECT 
	category,
    COUNT(*) AS total_products,
    ROUND(AVG(discountedsellingprice), 2) AS average_price,
    ROUND(MIN(discountedsellingprice), 2) AS minimum_price,
    ROUND(MAX(discountedsellingprice), 2) AS maximum_price,
    ROUND(AVG(discountpercent), 2) AS average_discount
FROM zepto_data
WHERE discountedsellingprice > 0
GROUP BY category
ORDER BY average_price DESC;

-- Which categories have the highest stock availability?

SELECT 
	category,
    SUM(availablequantity) AS total_inventory
FROM zepto_data
GROUP BY category
ORDER BY total_inventory DESC;

-- Which categories receive the highest average discounts?

SELECT 
    category,
    ROUND(AVG(discountpercent), 2) AS avg_discount
FROM zepto_data
GROUP BY category
ORDER BY avg_discount DESC;

-- What are the highest-priced products in the catalog?

SELECT 
    name,
    category,
    discountedsellingprice
FROM zepto_data
WHERE discountedsellingprice > 0
ORDER BY discountedsellingprice DESC
LIMIT 10;

-- Which products are at risk of stock-out?

SELECT
	name,
    category,
    availablequantity
FROM zepto_data
WHERE availablequantity <= 5
ORDER BY availablequantity ASC;

-- Outofstock Analysis

SELECT
    outofstock,
    COUNT(*) AS total_products
FROM zepto_data
GROUP BY outofstock;

-- Price Range Segmentation

SELECT
    CASE
        WHEN discountedsellingprice < 100 THEN 'Below 100'
        WHEN discountedsellingprice BETWEEN 100 AND 500 THEN '100-500'
        WHEN discountedsellingprice BETWEEN 501 AND 1000 THEN '501-1000'
        ELSE 'Above 1000'
    END AS price_range,

    COUNT(*) AS total_products

FROM zepto_data
WHERE discountedsellingprice > 0
GROUP BY price_range
ORDER BY total_products DESC;

-- ==========================
-- 7. KPI & BUSINESS ANALYSIS
-- ==========================

-- KPI 1: categories contributing the highest inventory value

SELECT 
	 category,
     ROUND(SUM(discountedsellingprice * availablequantity), 2) AS total_inventory_value
FROM zepto_data
GROUP BY category
ORDER BY total_inventory_value DESC;

-- KPI 2: Total Products Per Category

SELECT 
	category,
    COUNT(*) AS total_products
FROM zepto_data
GROUP BY category
ORDER BY total_products DESC;

-- KPI 3: Average Discount By Category

SELECT
	category,
    ROUND(AVG(discountpercent), 2) AS average_discount
FROM zepto_data
GROUP BY category
ORDER BY average_discount DESC;

-- KPI 4: Outofstock Percentage

SELECT
	ROUND(
		(SUM(CASE WHEN outofstock = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS outofstock_percentage
FROM zepto_data;

-- KPI 5: Low stock Product

SELECT
    COUNT(*) AS low_stock_products
FROM zepto_data
WHERE availablequantity <= 3;

-- ========================
-- 8. ADVANCED SQL ANALYSIS
-- ========================

SELECT *
FROM zepto_data
ORDER BY discountedsellingprice DESC
LIMIT 3;

-- This gives overall top 3 products in entire dataset

-- Management asks show me the top 3 most expensive products within EACH category.

SELECT *
FROM (
	SELECT
		category,
		name,
        discountedsellingprice,
        
		DENSE_RANK() OVER( 
			PARTITION BY category
            ORDER BY discountedsellingprice DESC
		) AS price_rank
	FROM zepto_data
) t
WHERE price_rank <= 3;

-- 1. Find second highest priced product in each category

SELECT *
FROM (
	SELECT 
		category,
        name,
        discountedsellingprice,
        
        DENSE_RANK() OVER(
        PARTITION BY category
        ORDER BY discountedsellingprice DESC
	) AS price_rank
FROM zepto_data
) t
WHERE price_rank = 2;

-- 2. Find top product by discount in each category

SELECT *
FROM (
	SELECT 
		category,
		name,
        discountpercent,
        ROW_NUMBER() OVER(
        PARTITION BY category
        ORDER BY discountpercent DESC
	) AS  discount_rank
FROM zepto_data
) t
WHERE discount_rank = 1;

-- 3. Assign row numbers to products within each category

SELECT 
	category,
	name,
	discountpercent,
        
	ROW_NUMBER() OVER(
	PARTITION BY category
	ORDER BY discountpercent DESC
) AS  row_numbers
FROM zepto_data;

-- 4. Find products whose price rank is greater than 5

SELECT *
FROM (
	SELECT 
		category,
		name,
		discountpercent,
        
		DENSE_RANK() OVER(
		PARTITION BY category
		ORDER BY discountpercent DESC
	) AS  discount_rank
FROM zepto_data
) t
WHERE discount_rank > 5;

-- 5. Find products whose selling price is ABOVE the average selling price of THEIR OWN
       
	SELECT *
    FROM (
		SELECT
			category,
            name,
            discountedsellingprice,
            ROUND(
				AVG(discountedsellingprice) OVER(
				PARTITION BY category
				), 2
			) AS avg_selling_price
		FROM zepto_data
	) t
    WHERE discountedsellingprice > avg_selling_price;
            
-- 6. Find products whose discount is ABOVE the average discount of their category.

SELECT *
FROM (
	SELECT
		category,
		name,
		discountpercent,
        ROUND(    
			AVG(discountpercent) OVER(
			PARTITION BY category
			), 2
		) AS avg_discount
	FROM zepto_data
) t
WHERE discountpercent > avg_discount;
 
-- ==================================
-- 9. COMMON TABLE EXPRESSIONS (CTEs)
-- ==================================

WITH estimated_revenue_cte AS (
	SELECT 
		category,
		name,
		ROUND(
			(discountedsellingprice * quantity), 2
		) AS estimated_revenue
	FROM zepto_data
)
SELECT *
FROM estimated_revenue_cte
ORDER BY estimated_revenue DESC
LIMIT 5;

 -- 1. Management wants products generating above-average revenue  
 
 WITH estimated_revenue_cte AS (
	SELECT 
		category,
        name,
        ROUND(
			(discountedsellingprice * quantity), 2
		) AS estimated_revenue
	FROM zepto_data
)
SELECT 
	category,
    name,
    estimated_revenue
FROM estimated_revenue_cte
WHERE estimated_revenue > (
	SELECT AVG(estimated_revenue)
    FROM estimated_revenue_cte
);

-- 2. Management wants categories having low total stock

WITH stock_cte AS (
	SELECT 
		category,
        SUM(availablequantity) AS total_stock
	FROM zepto_data
    GROUP BY category
)
SELECT *
FROM stock_cte
WHERE total_stock < (
    SELECT AVG(total_stock)
    FROM stock_cte
)
 ORDER BY total_stock DESC;
 
 -- WITHOUT CTE
 
 SELECT 
    category,
    SUM(availablequantity) AS total_stock
FROM zepto_data
GROUP BY category
HAVING SUM(availablequantity) < (
    SELECT 
        AVG(category_stock)
    FROM (
        SELECT 
            SUM(availablequantity) AS category_stock
        FROM zepto_data
        GROUP BY category
    ) t
);

 -- CREATE VIEW
 
 CREATE VIEW high_discount_product AS 
 SELECT *
 FROM (
	SELECT
        category,
        name,
        discountpercent,
        ROUND(
            AVG(discountpercent) OVER(
                PARTITION BY category
            ), 2
        ) AS avg_discount
    FROM zepto_data
) t
WHERE discountpercent > avg_discount;
	
 SELECT *
 FROM high_discount_product
 LIMIT 10;
 
-- =============================================
-- 10. FINAL BUSINESS INSIGHTS & RECOMMENDATIONS
-- =============================================

-- High Value Products With Low Stock

SELECT
    category,
    name,
    availablequantity,
    ROUND(discountedsellingprice * availablequantity, 2) AS inventory_value
FROM zepto_data
WHERE availablequantity <= 5
ORDER BY inventory_value DESC;

-- Top Revenue Generating Categories

SELECT 
	category,
    ROUND(SUM(discountedsellingprice * quantity), 2) AS total_estimated_revenue
FROM zepto_data
GROUP BY category
ORDER BY total_estimated_revenue DESC
LIMIT 10;

-- -- Ice Cream & Desserts and Chocolates & Candies generate the highest estimated revenue.

SELECT
    category,
    name,
    mrp,
    discountedsellingprice,
    quantity,
    COUNT(*) AS duplicate_count
FROM zepto_data
GROUP BY
    category,
    name,
    mrp,
    discountedsellingprice,
    quantity
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Products with high discount and low stock

SELECT
    category,
    name,
    discountpercent,
    availablequantity
FROM zepto_data
WHERE discountpercent > 25
AND availablequantity < 5
ORDER BY discountpercent DESC;

-- Categories with above average product pricing

SELECT
    category,
    ROUND(AVG(discountedsellingprice), 2) AS avg_price
FROM zepto_data
GROUP BY category
HAVING AVG(discountedsellingprice) >
(
    SELECT AVG(discountedsellingprice)
    FROM zepto_data
)
ORDER BY avg_price DESC;

-- Products contributing highest inventory value

SELECT
    category,
    name,
    ROUND(discountedsellingprice * availablequantity, 2) AS inventory_value
FROM zepto_data
ORDER BY inventory_value DESC
LIMIT 10;

-- Categories with below average stock

SELECT
    category,
    SUM(availablequantity) AS total_stock
FROM zepto_data
GROUP BY category
HAVING SUM(availablequantity) <
(
    SELECT AVG(category_stock)
    FROM
    (
        SELECT
            SUM(availablequantity) AS category_stock
        FROM zepto_data
        GROUP BY category
    ) t
);

-- ===============
-- RECOMMENDATIONS    
-- ===============
    
-- 1. High-discount products with low stock should be restocked quickly
-- to avoid losing potential sales opportunities.

-- 2. Categories with high inventory value should be monitored carefully
-- to reduce inventory holding risk.

-- 3. Products priced above category average may require promotional
-- strategies to improve sales performance.

-- 4. Frequently out-of-stock categories may indicate strong customer demand
-- or supply chain inefficiencies.

-- 5. Categories with consistently high discounts should be analyzed
-- to maintain profit margins.
    
    
    
