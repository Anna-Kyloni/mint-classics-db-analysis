/*
===================================================================
MINT CLASSICS INVENTORY & WAREHOUSE OPTIMIZATION SCRIPT
Author: Sofianna (Data Analyst Portfolio)
Purpose: Exploratory Data Analysis (EDA) for Facility Decommissioning
===================================================================
*/

-- Step 1: Establish the operational database context
USE mintclassics;


-- ================================================================
-- INSIGHT LIGHT 1: WAREHOUSE STOCK PROFILES
-- Target Question: Where are items stored and what is the distribution?
-- Objective: Determine the total stock and product diversity per facility.
-- ================================================================

SELECT 
    w.warehouseCode, 
    w.warehouseName, 
    COUNT(p.productCode) AS total_products, 
    SUM(p.quantityInStock) AS total_stock
FROM warehouses w
LEFT JOIN products p ON w.warehouseCode = p.warehouseCode
GROUP BY w.warehouseCode, w.warehouseName
ORDER BY total_stock DESC;


-- ================================================================
-- INSIGHT LIGHT 2: INVENTORY TO SALES VELOCITY EVALUATION
-- Target Question: How are inventory numbers related to sales figures?
-- Objective: Identify overstocked items with high storage footprints 
--            but low sales velocity.
-- ================================================================

SELECT 
    p.productCode, 
    p.productName, 
    p.warehouseCode,
    p.quantityInStock AS current_stock, 
    SUM(od.quantityOrdered) AS total_sold,
    (p.quantityInStock - SUM(od.quantityOrdered)) AS stock_vs_sales_difference
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode, p.quantityInStock
ORDER BY stock_vs_sales_difference DESC;


-- ================================================================
-- INSIGHT LIGHT 3: DEAD STOCK IDENTIFICATION
-- Target Question: Are we storing items that are not moving?
-- Objective: Isolate items with heavy stock levels but zero client orders,
--            making them prime candidates to be dropped from the product line.
-- ================================================================

SELECT 
    p.productCode, 
    p.productName, 
    p.warehouseCode,
    p.quantityInStock AS current_stock,
    SUM(od.quantityOrdered) AS total_sold
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode, p.quantityInStock
HAVING total_sold IS NULL OR total_sold = 0
ORDER BY current_stock DESC;