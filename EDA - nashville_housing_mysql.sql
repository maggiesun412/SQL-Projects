-- Exploratory Data Analysis on Nashville Housing Data

SELECT *
FROM housing_data;

ALTER TABLE housing_data
RENAME COLUMN LandUse TO PropertyType;

-- Looking at the sale price and values based on type of property

SELECT PropertyType, 
	ROUND(AVG(SalePrice), 0) AS avg_saleprice, 
    ROUND(AVG(LandValue), 0) AS avg_landvalue, 
    ROUND(AVG(BuildingValue), 0) AS avg_buildingvalue, 
    ROUND(AVG(TotalValue), 0) AS avg_totalvalue
FROM housing_data
GROUP BY PropertyType
ORDER BY avg_saleprice DESC;


-- Looking at the average, highest, and lowest sale price based on property type


SELECT 
		PropertyType, 
        avg_saleprice, 
        max_saleprice, 
        min_saleprice
FROM
(SELECT PropertyType,
		ROUND(AVG(SalePrice),0) AS avg_saleprice, 
        MAX(SalePrice) AS max_saleprice, 
        MIN(SalePrice) AS min_saleprice
FROM housing_data
GROUP BY PropertyType
ORDER BY max_saleprice DESC) AS propertytype_table;


-- Looking at the average, highest, and lowest sale price of all properties based on city


SELECT 
		PropertySplitCity, 
        avg_saleprice, 
        max_saleprice, 
        min_saleprice
FROM
(SELECT PropertySplitCity,
		ROUND(AVG(SalePrice),0) AS avg_saleprice, 
        MAX(SalePrice) AS max_saleprice, 
        MIN(SalePrice) AS min_saleprice
FROM housing_data
GROUP BY PropertySplitCity) AS saleprice_table;


-- Looking at the total value of properties sold per year


SELECT Year(`SaleDate`) AS SaleYear, SUM(TotalValue) AS TotalPropertyValue
FROM housing_data
GROUP BY SaleYear
ORDER BY SaleYear;


-- Looking at the year built, year sold and total value of the building


SELECT YearBuilt, Year(`SaleDate`) AS SaleYear, TotalValue
FROM housing_data
ORDER BY SaleYear, TotalValue DESC;

SELECT YearBuilt, Year(`SaleDate`) AS SaleYear, SUM(TotalValue)
FROM housing_data
GROUP BY YearBuilt, SaleYear
ORDER BY 2, 3 DESC;


-- Looking at the price per acre of land


SELECT Acreage, LandValue, ROUND((LandValue/Acreage), 0) AS PricePerAcre
FROM housing_data
ORDER BY LandValue DESC;



-- Most expensive properties based on cities and sale price 


WITH TotalSalePriceByCity AS
(
SELECT 
		PropertySplitCity,
        SUM(SalePrice) AS total_saleprice
FROM housing_data
GROUP BY PropertySplitCity
),
SalePriceRank AS
(
SELECT 
		PropertySplitCity, 
        total_saleprice,
        DENSE_RANK() OVER (ORDER BY total_saleprice DESC) AS pricerank
FROM TotalSalePriceByCity
)
SELECT PropertySplitCity, total_saleprice, pricerank
FROM SalePriceRank
ORDER BY pricerank;



-- Top cities based on land values


WITH TotalLandValueByCity AS 
(
SELECT 
        PropertySplitCity, 
        SUM(LandValue) AS total_landvalue
FROM housing_data
GROUP BY PropertySplitCity
),
CityRanked AS
(
SELECT 
        PropertySplitCity, 
        total_landvalue,
        DENSE_RANK() OVER (ORDER BY total_landvalue DESC) AS cityrank 
FROM TotalLandValueByCity
)
SELECT PropertySplitCity, total_landvalue, cityrank
FROM CityRanked
ORDER BY cityrank;




