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




