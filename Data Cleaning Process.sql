-- Quick overview
SELECT *
FROM nashville_housing;


-- Populate PropertyAddress data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing
SET PropertyAddress = (
	SELECT IFNULL(a.PropertyAddress, b.PropertyAddress)
	FROM nashville_housing a
	JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
	WHERE a.PropertyAddress IS NULL
	)
WHERE PropertyAddress IS NULL
	AND EXISTS(
		SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
		FROM nashville_housing a
		JOIN nashville_housing b
		ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
		WHERE a.PropertyAddress IS NULL
		);

		
-- Breaking out PropertyAddress into individual columns (Address, City, State)
SELECT PropertyAddress,
	SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ', ')-1) AS Adress,
	SUBSTR(PropertyAddress, INSTR(PropertyAddress, ', ')+1) AS City
from nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress TEXT;

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ', ')-1);

ALTER TABLE nashville_housing
ADD PropertySplitCity TEXT;

UPDATE nashville_housing
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ', ')+1);


-- Breaking out OwnerAddress into individual columns (Address, City, State)
SELECT
	presemicolon1 as AddressOwner,
	SUBSTR(postsemicolon1, 1, INSTR(postsemicolon1, ', ')-1) AS CityOwner,
	SUBSTR(postsemicolon1, INSTR(postsemicolon1, ', ')+1) AS CountryOwner	  
FROM (
	SELECT
		OwnerAddress,
		SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ', ')-1) AS presemicolon1,
		SUBSTR(OwnerAddress, INSTR(OwnerAddress, ', ')+1) AS postsemicolon1
	FROM nashville_housing
	);

ALTER TABLE nashville_housing
ADD OwnerSplitAddress TEXT;

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ', ')-1)

ALTER TABLE nashville_housing
ADD OwnerSplitCity TEXT;

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTR((SUBSTR(OwnerAddress, INSTR(OwnerAddress, ', ')+1)), 1, INSTR((SUBSTR(OwnerAddress, INSTR(OwnerAddress, ', ')+1)), ', ')-1)

ALTER TABLE nashville_housing
ADD OwnerSplitCountry TEXT;

UPDATE nashville_housing
SET OwnerSplitCountry = SUBSTR((SUBSTR(OwnerAddress, INSTR(OwnerAddress, ', ')+1)), INSTR((SUBSTR(OwnerAddress, INSTR(OwnerAddress, ', ')+1)), ', ')+1)

	
-- Change "Y" and "N" to "Yes" and "No" in SoldAsVacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM nashville_housing
GROUP BY SoldAsVacant;

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
													WHEN SoldAsVacant = 'N' THEN 'No'
													ELSE SoldAsVacant
										END
										
										
-- Remove duplicates
ALTER TABLE nashville_housing
ADD RowNumber TEXT;

UPDATE nashville_housing
SET RowNumber = (SELECT ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) FROM nashville_housing)

DELETE FROM nashville_housing
WHERE RowNumber > 1