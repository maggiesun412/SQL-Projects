/*

-- Exploratory Data Analysis on liquor inventory and sales data

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Converting Data Types

*/

SELECT *
FROM beg_inv_2016;

SELECT * 
FROM end_inv_2016;

SELECT *
FROM store_sales_2016;

SELECT *
FROM vendor_purchase_2016;

SELECT * 
FROM vendor_purchase_invoice_2016;

SELECT *
FROM purchase_price_dec2017;



SELECT *
FROM beg_inv_2016;

ALTER TABLE beg_inv_2016
RENAME COLUMN on_hand TO beg_on_hand;

ALTER TABLE beg_inv_2016
RENAME COLUMN startDate TO start_date;

ALTER TABLE beg_inv_2016
RENAME COLUMN InventoryId TO inventory_id;

SELECT STR_TO_DATE(start_date, '%Y-%m-%d')
FROM beg_inv_2016;

UPDATE beg_inv_2016
SET start_date = STR_TO_DATE(start_date, '%Y-%m-%d');



SELECT *
FROM end_inv_2016;


ALTER TABLE end_inv_2016
RENAME COLUMN on_hand TO end_on_hand;

ALTER TABLE end_inv_2016
RENAME COLUMN endDate TO end_date;

ALTER TABLE end_inv_2016
RENAME COLUMN InventoryId TO inventory_id;

UPDATE end_inv_2016
SET end_date = STR_TO_DATE(end_date, '%Y-%m-%d');



-- total ending inventory per store

SELECT store, SUM(end_on_hand) AS total_end_inventory
FROM end_inv_2016
GROUP BY store
ORDER BY total_end_inventory DESC;



-- total ending inventory by store and item

SELECT store, `description`, SUM(end_on_hand) AS total_end_inventory
FROM end_inv_2016
GROUP BY store, `description`
ORDER BY store ASC, total_end_inventory DESC;


SELECT beginv.store, SUM(end_on_hand - beg_on_hand) AS total_inventory
FROM beg_inv_2016 beginv
JOIN end_inv_2016 endinv
	ON beginv.brand = endinv.brand
GROUP BY beginv.store
ORDER BY total_inventory DESC;


SELECT *
FROM beg_inv_2016;

SELECT * 
FROM end_inv_2016;

SELECT *
FROM store_sales_2016;

SELECT *
FROM vendor_purchase_2016;

-- summarizes the beginning and ending inventory, along with the total quantity of purchases and sales

SELECT beg_inv.Store, 
	   beg_inv.Brand, 
       beg_inv.`Description`, 
       SUM(beg_inv.beg_on_hand) AS total_beg_on_hand, 
       SUM(end_inv.end_on_hand) AS total_end_on_hand, 
       SUM(vp.Quantity) AS total_purchase_quantity, 
       SUM(ss.SalesQuantity) AS total_sales_quantity
FROM beg_inv_2016 beg_inv 
JOIN end_inv_2016 end_inv 
	ON beg_inv.inventory_id = end_inv.inventory_id 
    AND beg_inv.Store = end_inv.Store 
    AND beg_inv.Brand = end_inv.Brand 
    AND beg_inv.`Description` = end_inv.`Description`
JOIN vendor_purchase_2016 vp
	ON beg_inv.inventory_id = vp.InventoryId 
    AND beg_inv.Store = vp.Store 
    AND beg_inv.Brand = vp.Brand 
    AND beg_inv.`Description` = vp.`Description`
JOIN store_sales_2016 ss
	ON beg_inv.inventory_id = ss.InventoryId 
    AND beg_inv.Store= ss.Store 
    AND beg_inv.Brand = ss.Brand 
    AND beg_inv.`Description` = ss.`Description`
GROUP BY beg_inv.Store, beg_inv.Brand, beg_inv.`Description`
ORDER BY total_end_on_hand DESC;



-- total quantity sold per store per month

SELECT STR_TO_DATE(SalesDate, '%Y-%m-%d')
FROM store_sales_2016;

UPDATE store_sales_2016
SET SalesDate = STR_TO_DATE(SalesDate, '%Y-%m-%d');


SELECT MONTH(SalesDate) AS sale_month, Store, SUM(SalesQuantity) AS total_quantity_sold
FROM store_sales_2016
GROUP BY sale_month, Store
ORDER BY sale_month;



-- total sales per store per month

SELECT MONTH(SalesDate) AS sale_month, Store, ROUND(SUM(SalesDollars), 2) AS total_revenue
FROM store_sales_2016
GROUP BY sale_month, Store
ORDER BY sale_month;




-- top 5 brands sold monthly

WITH brand_rank AS
(
SELECT MONTH(SalesDate) AS sale_month, Brand, `Description`, ROUND(SUM(SalesDollars),2) AS total_sales,
DENSE_RANK() OVER(PARTITION BY MONTH(SalesDate) ORDER BY ROUND(SUM(SalesDollars),2) DESC) AS brand_ranked
FROM store_sales_2016
GROUP BY sale_month, Brand, `Description`
ORDER BY sale_month ASC, total_sales DESC
)
SELECT *
FROM brand_rank
WHERE brand_ranked <= 5;



-- top 5 stores with highest sales per month

WITH store_rank AS
(
SELECT MONTH(SalesDate) AS sale_month, Store, Brand, `Description`, ROUND(SUM(SalesDollars),2) AS total_sales,
DENSE_RANK() OVER(PARTITION BY MONTH(SalesDate) ORDER BY ROUND(SUM(SalesDollars),2) DESC) AS store_ranked
FROM store_sales_2016
GROUP BY sale_month, Store, Brand, `Description`
ORDER BY sale_month ASC, total_sales DESC
)
SELECT *
FROM store_rank
WHERE store_ranked <= 5;




-- highest profit from the top 50 brands and items

SELECT vp.Store, vp.Brand, vp.`Description`, SUM(beg_inv.beg_on_hand), SUM(end_inv.end_on_hand), vp.PurchasePrice, ss.SalesPrice, 
ROUND((ss.SalesPrice - vp.PurchasePrice),2) AS profit, ROUND(((ss.SalesPrice - vp.PurchasePrice) / ss.SalesPrice) * 100, 2) AS margin_percentage
FROM beg_inv_2016 beg_inv
JOIN end_inv_2016 end_inv 
	ON beg_inv.inventory_id = end_inv.inventory_id
JOIN vendor_purchase_2016 vp
	ON end_inv.inventory_id = vp.InventoryId
JOIN store_sales_2016 ss
	ON vp.InventoryId = ss.InventoryId
GROUP BY vp.Store, vp.Brand, vp.`Description`, vp.PurchasePrice, ss.SalesPrice
ORDER BY profit DESC, margin_percentage DESC
LIMIT 50;



-- freight cost per unit by vendor and purchase order

SELECT VendorName, PONumber, SUM(Quantity) AS total_quantity, ROUND(SUM(Freight), 2) AS total_freight, ROUND(SUM(Freight) / SUM(Quantity), 2) AS freight_cost_per_unit
FROM vendor_purchase_invoice_2016
GROUP BY VendorName, PONumber
ORDER BY freight_cost_per_unit DESC;



-- vendor with the highest purchase quantity

SELECT VendorName, SUM(Quantity) AS total_quantity
FROM vendor_purchase_invoice_2016
GROUP BY VendorName
ORDER BY total_quantity DESC;



-- total purchase orders placed by each vendor

SELECT VendorNumber, VendorName, COUNT(PONumber) AS num_of_POs
FROM vendor_purchase_invoice_2016
GROUP BY VendorNumber, VendorName
ORDER BY num_of_POs DESC;


-- order total by each vendor

SELECT VendorName, ROUND(SUM(Dollars), 2) AS order_total
FROM vendor_purchase_invoice_2016
GROUP BY VendorName
ORDER BY order_total DESC;


-- number of days in transit from PO placement to receipt from highest to lowest

SELECT PONumber, 
	   STR_TO_DATE(PODate, '%Y-%m-%d') AS PO_date,
       STR_TO_DATE(ReceivingDate, '%Y-%m-%d') AS receiving_date, 
       DATEDIFF(STR_TO_DATE(ReceivingDate, '%Y-%m-%d'), STR_TO_DATE(PODate, '%Y-%m-%d')) AS days_in_transit
FROM vendor_purchase_2016
ORDER BY days_in_transit DESC;

SELECT *
FROM vendor_purchase_invoice_2016;

SELECT *
FROM vendor_purchase_2016;


-- comparing the purchase price from 2016 and 2017 to see if they match

WITH price_match AS 
(
SELECT pp.VendorName AS pp_VendorName, 
	   pp.Brand AS pp_Brand, 
       pp.`Description` AS pp_Description, 
       pp.PurchasePrice AS pp_PurchasePrice, 
       vp.VendorName AS vp_VendorName, 
       vp.Brand AS vp_Brand, 
       vp.`Description` AS vp_Description, 
       vp.PurchasePrice AS vp_PurchasePrice
FROM purchase_price_dec2017 pp
JOIN vendor_purchase_2016 vp
ON pp.VendorName = vp.VendorName AND pp.brand = vp.brand AND pp.`Description` = vp.`Description`
)
SELECT *
FROM price_match
WHERE pp_PurchasePrice <> vp_PurchasePrice;

