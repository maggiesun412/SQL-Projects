SELECT *
FROM amazon_products;

SELECT *
FROM amazon_categories;

ALTER TABLE amazon_products
RENAME COLUMN listPrice TO list_price;

ALTER TABLE amazon_products
RENAME COLUMN isBestSeller TO best_seller;

ALTER TABLE amazon_products
RENAME COLUMN boughtInLastMonth TO bought_in_september_2023;


-- best sellers by category

SELECT DISTINCT ap.category_id, ac.category_name, ap.best_seller
FROM amazon_products ap
JOIN amazon_categories ac
ON ap.category_id = ac.id
WHERE best_seller = 'TRUE';


-- top 10 asins by category with the highest savings
-- top savings generally fall in the computer & tablets category

SELECT asin, category_name,
(SELECT (list_price - price)) AS savings
FROM amazon_products ap
JOIN amazon_categories ac
ON ap.category_id = ac.id
WHERE list_price <> 0
ORDER BY 3 DESC
LIMIT 10;



-- highest reviewed asin and the star rating

SELECT asin, reviews, stars
FROM amazon_products
ORDER BY reviews DESC
LIMIT 10;



-- top 5 asins with highest revenue

SELECT asin, (price * bought_in_september_2023) AS revenue
FROM amazon_products
ORDER BY 2 DESC
LIMIT 5;



-- comparing the price of the item to the average price in that category

SELECT ap.asin, ac.category_name, ap.price, AVG(ap.price) 
OVER(PARTITION BY ac.category_name) AS avg_price_by_category
FROM amazon_products ap
JOIN amazon_categories ac
ON ap.category_id = ac.id
WHERE ap.price <> 0
ORDER BY 2, 3;



-- top 5 asins with the highest ranked prices by category

WITH ranked_price AS (
	SELECT ap.asin, ac.category_name, ap.price, 
	ROW_NUMBER() OVER(PARTITION BY ac.category_name ORDER BY ap.price DESC) AS rank_price
	FROM amazon_products ap
	JOIN amazon_categories ac
	ON ap.category_id = ac.id
	WHERE ap.price <> 0
)
SELECT asin, category_name, price, rank_price
FROM ranked_price
WHERE rank_price <= 5
ORDER BY category_name;





SELECT *
FROM amazon_products;











