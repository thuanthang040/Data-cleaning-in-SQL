/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted date
UPDATE NashvilleHousing 
SET SaleDateConverted = FORMAT(SaleDate,'yyyy-MM-dd')

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress nvarchar(255)
UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity nvarchar(255)
UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

--OwnerAddress

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAdress nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH
row_num_cte AS
(
SELECT *,
	  ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
						ORDER BY UniqueID
					   ) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM row_num_cte
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
