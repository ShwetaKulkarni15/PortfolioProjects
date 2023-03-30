/*
Cleaning Data in SQL
*/

Select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date format
Select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = Convert(Date,Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = Convert(Date,Saledate)

-- Populate Property address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as address
,Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) 

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 

Select *
from PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.') ,3)
, PARSENAME(Replace(OwnerAddress, ',','.') ,2)
, PARSENAME(Replace(OwnerAddress, ',','.') ,1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.') ,3) 

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.') ,2) 

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.') ,1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

-- Remove Duplicates
With RowNumCTE As(
select *,
ROW_NUMBER() over (
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by uniqueID
			 ) row_num
from NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete Unused Columns
Select * 
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, Taxdistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate