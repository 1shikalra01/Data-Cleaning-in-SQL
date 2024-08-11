/*

Cleaning Data in SQL Queries

*/

Select *
From MySQLProjects..NashvilleHousing

-----------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From MySQLProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From MySQLProjects..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From MySQLProjects..NashvilleHousing a
JOIN MySQLProjects..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From MySQLProjects..NashvilleHousing a
JOIN MySQLProjects..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Column (Address, City, State)

Select PropertyAddress
From MySQLProjects..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From MySQLProjects..NashvilleHousing

ALTER TABLE MySQLProjects..NashvilleHousing
Add PropertySplitAddress NVarchar(255);

Update MySQLProjects..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE MySQLProjects..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update MySQLProjects..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From MySQLProjects..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From MySQLProjects..NashvilleHousing

ALTER TABLE MySQLProjects..NashvilleHousing
Add OwnerSplitAddress NVarchar(255);

Update MySQLProjects..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE MySQLProjects..NashvilleHousing
Add OwnerSplitCity NVarchar(255);

Update MySQLProjects..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
ALTER TABLE MySQLProjects..NashvilleHousing
Add OwnerSplitState NVarchar(255);

Update MySQLProjects..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From MySQLProjects..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ElSE SoldAsVacant
		END
From MySQLProjects..NashvilleHousing

Update MySQLProjects..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ElSE SoldAsVacant
						END

------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             Propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From MySQLProjects..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From MySQLProjects..NashvilleHousing

ALTER TABLE MySQLProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, Propertyaddress

ALTER TABLE MySQLProjects..NashvilleHousing
DROP COLUMN SaleDate

