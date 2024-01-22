
USE Data_cleaning_Project
-- Cleaning Data in SQL Queries

Select *
From Data_cleaning_Project.dbo.NashvilleHousing


-- Standardise the Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From Data_cleaning_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Add a an empty Date column then set the SaleDate column to it

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From Data_cleaning_Project.dbo.NashvilleHousing

--Populate Property Address data


Select *
From Data_cleaning_Project.dbo.NashvilleHousing
order by ParcelID

--ParcelID and PropertyAddress is the same, if Property Address is missing from ParcelID, we can populate it
--Joining the same table to itself, saying the parcel ID is the same and it's a unique row i.e not the same Unique ID
--Going to use Select ISNULL, so if a.PropertyAddress is null we're going to insert b.PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Data_cleaning_Project.dbo.NashvilleHousing a
JOIN Data_cleaning_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Data_cleaning_Project.dbo.NashvilleHousing a
JOIN Data_cleaning_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Select PropertyAddress
From Data_cleaning_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- If you look at CHARINDEX(','), it gives the position of the , in the string, i.e, if you just left that you'd get , in the Address and you don't want that
-- so we're going to do -1 to take one away from where the , is located in the char index to only select up until that point in the SUBSTRING

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Data_cleaning_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select OwnerAddress
From Data_cleaning_Project.dbo.NashvilleHousing

-- PARSENAME looks for . we have, in our address so we're going to replace them.

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From Data_cleaning_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
FROM Data_cleaning_Project.dbo.NashvilleHousing

-- SoldAsVacant column shows mixture of Y, N, Yes, No. We're going to standardise this and change Y and N to Yes and No Respectfully.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Data_cleaning_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
FROM Data_cleaning_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Data_cleaning_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--Remove Duplicates

-- Here we're using ROW_NUMBER to assign each duplicate to a specific row, if everything we've partitioned by is the same it will show as row_num 2

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From Data_cleaning_Project.dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
Where row_num > 1

--Delete unused columns
Select *
From Data_cleaning_Project.dbo.NashvilleHousing

ALTER TABLE Data_cleaning_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

