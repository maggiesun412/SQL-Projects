/*

-- Exploratory data analysis on Nashville housing data

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions

*/


SELECT *
FROM housing_data;

-- Standardize date

SELECT 
    SaleDate, 
    STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedSaleDate
FROM housing_data;
    
UPDATE housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');


-- Populate property address data


SELECT PropertyAddress
FROM housing_data
WHERE PropertyAddress = '';


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM housing_data a
JOIN housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

UPDATE housing_data a
JOIN housing_data b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';


-- Breaking out address into individual columns (address, city, state)


SELECT PropertyAddress
FROM housing_data;


SELECT
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1) AS City
FROM housing_data;


ALTER TABLE housing_data
ADD PropertySplitAddress nvarchar(255);

UPDATE housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

ALTER TABLE housing_data
ADD PropertySplitCity nvarchar(255);

UPDATE housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1);


SELECT OwnerAddress
FROM housing_data;


SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM housing_data;


ALTER TABLE housing_data
ADD OwnerAddress1 nvarchar(255);

UPDATE housing_data
SET OwnerAddress1 = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE housing_data
ADD OwnerCity nvarchar(255);

UPDATE housing_data
SET OwnerCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE housing_data
ADD OwnerState nvarchar(255);

UPDATE housing_data
SET OwnerState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));


-- Change Y and N to Yes and No in "Sold as Vacant"

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_data
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM housing_data;

UPDATE housing_data
SET SoldAsVacant =
CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;



-- Remove Duplicates


DELETE FROM housing_data
WHERE UniqueID IN (
	SELECT UniqueID 
	FROM (
		SELECT 
			UniqueID,
			ROW_NUMBER() OVER (
			PARTITION BY ParcelID, 
					 PropertyAddress, 
					 SalePrice, 
					 SaleDate, 
					 LegalReference 
					 ORDER BY UniqueID
					 ) AS row_num
		FROM housing_data
    ) AS duplicates
	WHERE row_num > 1
);


-- Delete unused columns


SELECT *
FROM housing_data;

ALTER TABLE housing_data
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;



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
ORDER BY citlayoffs_staging2yrank;








