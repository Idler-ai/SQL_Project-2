  -- Populate Property Address Data
SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
  `Nashville.Housing` a
JOIN
  `Nashville.Housing` b
ON
  a.UniqueID_ <> b.UniqueID_
  AND a.parcelid= b.ParcelID
WHERE
  a.PropertyAddress IS NULL;
UPDATE
  `Nashville.Housing` a
SET
  propertyaddress= b.propertyaddress
FROM (
  SELECT
    parcelid,
    MAX( PropertyAddress) propertyaddress
  FROM
    `Nashville.Housing`
  WHERE
    NOT propertyaddress IS NULL
  GROUP BY
    parcelid) b
WHERE
  a.parcelid = b.parcelid
  AND a.propertyaddress IS NULL;
  -- Breaking out Address into Individual Columns (Address, City)
  #Method 1
SELECT
  propertyaddress,
  SPLIT(propertyaddress, ',') [SAFE_ORDINAL(1)] AS Address,
  SPLIT(propertyaddress, ',') [SAFE_ORDINAL(2)] AS City
FROM
  `Nashville.Housing`;
  #Method 2
SELECT
  SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',') -1) AS Address,
  SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',') +1, LENGTH(PropertyAddress)) AS City
FROM
  `Nashville.Housing`;
ALTER TABLE
  `Nashville.Housing` ADD COLUMN PropertySplitAddress STRING;
UPDATE
  `Nashville.Housing`
SET
  PropertySplitAddress = SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',') -1)
WHERE
  TRUE;
ALTER TABLE
  `Nashville.Housing` ADD COLUMN PropertySplitCity STRING;
UPDATE
  `Nashville.Housing`
SET
  PropertySplitCity = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',') +1, LENGTH(PropertyAddress))
WHERE
  TRUE;
  -- Owner's Address
  #Method 1
SELECT
  OwnerAddress,
  SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(1)] AS Address,
  SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(2)] AS City,
  SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(3)] AS State
FROM
  `Nashville.Housing`;
  #Method 2
SELECT
  SPLIT(OwnerAddress, ",") [
OFFSET
  (0)] AS Address,
  SPLIT(OwnerAddress, ',') [
OFFSET
  (1)] AS City,
  SPLIT(OwnerAddress, ',') [
OFFSET
  (2)] AS State
FROM
  `Nashville.Housing`;
ALTER TABLE
  `Nashville.Housing` ADD COLUMN OwnerSplitAddress string;
UPDATE
  `Nashville.Housing`
SET
  OwnerSplitAddress = SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(1)]
WHERE
  TRUE;
ALTER TABLE
  `Nashville.Housing` ADD COLUMN OwnerSplitCity string;
UPDATE
  `Nashville.Housing`
SET
  OwnerSplitCity = SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(2)]
WHERE
  TRUE;
ALTER TABLE
  `Nashville.Housing` ADD COLUMN OwnerSplitState string;
UPDATE
  `Nashville.Housing`
SET
  OwnerSplitState = SPLIT(OwnerAddress, ',') [SAFE_ORDINAL(2)]
WHERE
  TRUE;
  -- Remove Duplicates
CREATE OR REPLACE TABLE
  `Nashville.Housing` AS
SELECT
  *,
  ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID_) row_num
FROM
  `Nashville.Housing`;
DELETE
FROM
  `Nashville.Housing`
WHERE
  row_num >1;
  -- Delete Unused Colums
ALTER TABLE
  `Nashville.Housing` DROP COLUMN row_num;
ALTER TABLE
  `Nashville.Housing` DROP COLUMN PropertyAddress;
ALTER TABLE
  `Nashville.Housing` DROP COLUMN TaxDistrict;