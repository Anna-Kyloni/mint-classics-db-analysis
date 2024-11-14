========================================================================
MINT CLASSICS INVENTORY OPTIMIZATION & WAREHOUSE ANALYTICS
========================================================================
Developed By : Kyloni Anna Sofia

1. PROJECT OVERVIEW
-------------------
This operational data analytics project focuses on warehouse optimization and inventory management for "Mint Classics", a global distributor of classic model vehicles. Utilizing a relational database, the pipeline executes structural data auditing and business performance queries inside MySQL Workbench to identify slow-moving products, assess warehouse utilization, and support data-backed decisions regarding potential storage facility consolidation.

2. DATA SOURCE & AUDITING (SQL)
-------------------------------
- Data Source: Mint Classics relational database schema (Classic Models dataset).
- Audit Framework: Examined the core relational layout involving tables such as 'products', 'warehouses', 'orderdetails', and 'orders'. Mapped product lines against current in-stock quantities to detect overstocking anomalies and identify storage facilities operating at suboptimal capacity.

3. RELATIONAL SCHEMA REFERENCE (SQL)
------------------------------------
The inventory and sales optimization models were executed using the existing production schema layout:

USE mintclassics;

-- Primary entities analyzed:
-- warehouses (warehouseCode, warehouseName)
-- products (productCode, productName, quantityInStock, buyPrice, MSRP, warehouseCode)
-- orderdetails (orderNumber, productCode, quantityOrdered, priceEach)

4. EXECUTIVE BUSINESS QUERIES (SQL)
-----------------------------------
- Query 1: Warehouse Stock Distribution vs. Sales Velocity
SELECT 
    w.warehouseCode,
    w.warehouseName,
    COUNT(DISTINCT p.productCode) AS Unique_Products,
    SUM(p.quantityInStock) AS Total_Stock_In_Hand,
    IFNULL(SUM(od.quantityOrdered), 0) AS Total_Units_Sold,
    ROUND((IFNULL(SUM(od.quantityOrdered), 0) / SUM(p.quantityInStock)) * 100, 2) AS Inventory_Turnover_Ratio
FROM warehouses w
LEFT JOIN products p ON w.warehouseCode = p.warehouseCode
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY w.warehouseCode, w.warehouseName
ORDER BY Inventory_Turnover_Ratio ASC;

- Query 2: Dead Stock Identification (Stagnant Inventory)
SELECT 
    p.warehouseCode,
    p.productCode,
    p.productName,
    p.quantityInStock,
    IFNULL(SUM(od.quantityOrdered), 0) AS Total_Quantity_Ordered,
    (p.quantityInStock - IFNULL(SUM(od.quantityOrdered), 0)) AS Excess_Stock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.warehouseCode, p.productName, p.quantityInStock
HAVING Total_Quantity_Ordered < 100
ORDER BY p.warehouseCode, p.quantityInStock DESC;

- Query 3: Revenue Performance Matrix by Product Line
SELECT 
    p.productLine,
    SUM(od.quantityOrdered) AS Total_Units_Sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS Gross_Revenue,
    RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS Revenue_Rank
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine;

5. KEY ANALYTICAL INSIGHTS
--------------------------
- Warehouse Efficiency: Warehouse C handles similar product lines to Warehouse B but operates at a significantly lower capacity utilization rate, making it a prime candidate for consolidation.
- Stagnant Assets: Multiple product IDs (such as specific legacy vehicle models) hold extensive stock volumes while logging under 100 total ordered units, tying up operational capital.
- Revenue Concentrators: The 'Classic Cars' product line exhibits the highest order velocity, proving that warehouse space priority should be dynamically shifted toward high-margin segments.

6. STRATEGIC RECOMMENDATIONS
----------------------------
1. Consider closing Warehouse C and consolidating its inventory into Warehouse B to optimize underutilized capacity and reduce facility overhead.
2. Halt restocking runs for identified stagnant stock models and implement targeted promotional discount bundles to liquidate excess inventory.
3. Align procurement cycles strictly with historical product line velocity to prevent future capital containment in low-turnover storage.