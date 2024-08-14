/*

-- Exploratory data analysis on supply chain metrics

Skills used: Joins, CTE's, Subqueries, Aggregate Functions

*/

SELECT *
FROM supply_chain_metrics;

CREATE TABLE supply_chain_stats
LIKE supply_chain_metrics;


SELECT *
FROM supply_chain_stats;

INSERT supply_chain_stats
SELECT * 
FROM supply_chain_metrics;


SELECT SUBSTRING(price, 1, LOCATE('.', price) + 2)
FROM supply_chain_stats;

UPDATE supply_chain_stats
SET price = SUBSTRING(price, 1, LOCATE('.', price) + 2);

SELECT SUBSTRING(revenue, 1, LOCATE('.', revenue) + 2)
FROM supply_chain_stats;

UPDATE supply_chain_stats
SET revenue = SUBSTRING(revenue, 1, LOCATE('.', revenue) + 2);

SELECT SUBSTRING(shipping_costs, 1, LOCATE('.', shipping_costs) + 2)
FROM supply_chain_stats;

UPDATE supply_chain_stats
SET shipping_costs = SUBSTRING(shipping_costs, 1, LOCATE('.', shipping_costs) + 2);

SELECT SUBSTRING(manufacturing_costs, 1, LOCATE('.', manufacturing_costs) + 2)
FROM supply_chain_stats;

UPDATE supply_chain_stats
SET manufacturing_costs = SUBSTRING(manufacturing_costs, 1, LOCATE('.', manufacturing_costs) + 2);


SELECT SUBSTRING(costs, 1, LOCATE('.', costs) + 2)
FROM supply_chain_stats;

UPDATE supply_chain_stats
SET costs = SUBSTRING(costs, 1, LOCATE('.', costs) + 2);


-- top selling product type

SELECT DISTINCT product_type, ROUND(SUM(revenue),2)
FROM supply_chain_stats
GROUP BY product_type
ORDER BY 2 DESC;


-- top selling sku

SELECT sku, ROUND(SUM(revenue),2)
FROM supply_chain_stats
GROUP BY sku
ORDER BY 2 DESC;


-- revenue by SKU compared to the average revenue

SELECT sku, revenue, 
(
SELECT AVG(revenue)
FROM supply_chain_stats
) AS avg_revenue
FROM supply_chain_stats;


-- top 5 skus sold by customer gender

SELECT sku, customer_demographics, MAX(products_sold)
FROM supply_chain_stats
GROUP BY sku, customer_demographics
ORDER BY 3 DESC
LIMIT 5;


-- average shipping time by carrier

SELECT shipping_carriers, AVG(shipping_times) avg_shipping
FROM supply_chain_stats
GROUP BY shipping_carriers
ORDER BY 2;


-- supplier with highest manufacturing costs

SELECT DISTINCT supplier_name, MAX(manufacturing_costs) highest_manufacturing_costs
FROM supply_chain_stats
GROUP BY supplier_name
ORDER BY 2 DESC;


-- production rate for each supplier

SELECT supplier_name, SUM(production_volumes)/SUM(manufacturing_lead_time) AS production_rate
FROM supply_chain_stats
GROUP BY supplier_name
ORDER BY 2 DESC;



-- lowest cost by mode of transportation

SELECT transportation_modes, AVG(costs)
FROM supply_chain_stats
GROUP BY transportation_modes
ORDER BY 2;



-- supplier with the highest defect rate

ALTER TABLE supply_chain_stats
RENAME COLUMN `Defect rates` TO defect_rates;

SELECT supplier_name, ROUND(SUM(defect_rates),2)
FROM supply_chain_stats
GROUP BY supplier_name
ORDER BY 2 DESC;



-- supplier and location average defect rate compared to the overall defect rate


SELECT supplier_name, AVG(defect_rates) AS supplier_avg_defect_rate,
(
SELECT AVG(defect_rates)
FROM supply_chain_stats
) AS avg_defect_rate
FROM supply_chain_stats
GROUP BY supplier_name
ORDER BY 2 DESC;


SELECT location, AVG(defect_rates) AS location_avg_defect_rate,
(
SELECT AVG(defect_rates)
FROM supply_chain_stats
) AS avg_defect_rate
FROM supply_chain_stats
GROUP BY location
ORDER BY 2 DESC;



-- supplier with the highest failed inspections


SELECT supplier_name, COUNT(inspection_results)
FROM supply_chain_stats
WHERE inspection_results = 'Fail'
GROUP BY supplier_name
ORDER BY 2 DESC;


SELECT transportation_modes, AVG(costs)
FROM supply_chain_stats
GROUP BY transportation_modes
ORDER BY 2;


SELECT *
FROM supply_chain_stats;

