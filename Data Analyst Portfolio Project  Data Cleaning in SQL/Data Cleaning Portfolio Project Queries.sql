/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format
select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = convert(Date, SaleDate)


select SaleDate
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = convert(Date, SaleDate)


select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
	--we want to fill the null PropertyAddress so we will say if that NULL PropertyAddress
	-- has ParcelID find the addres that match this ParcelID and put it at NULL PropertyAddress
	-- TO achive that we will use selfjoin

-- check that there is a null values
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

-- Every thing can change but PropertyAddress is not going to change
-- we want to make a refrence point to base that off 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
order by ParcelID

--self join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- NOW we want to populate the address "we will use is null"
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- LET'S updata our table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- let's chect if all null value fill in.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
-- WE PUT THIS CONDITION TO ACHIVE "Excluding self-matching rows"
-- Which means preventing a row from being joined with itself in a self-join operation.
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.[UniqueID ] = b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

--we note that address contain address and name of city seperated by dilimeter like that"3124  MARGIE DR, JOELTON".
-- so we will use SUBSTRING to sperete it in different columns

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CityName
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Seperated OwnerAdderss column
--"https://www.mssqltips.com/sqlservertip/6321/split-delimited-string-into-columns-in-sql-server-with-parsename/"
SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1)) AS [Street]
   , REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2)) AS [City]
   , REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3)) AS [State]
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1))

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2))



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3))


Select *
From PortfolioProject.dbo.NashvilleHousing







--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

--change bu using case
SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant ='Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

--UPDATE COLUMN
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant ='Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END

--LET'S chect that every thing is correct
SELECT DISTINCT SoldAsVacant, count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RemoveDuplicates  AS(
select *, ROW_NUMBER() OVER( 
		  PARTITION BY ParcelID,
					   PropertyAddress,
				       SalePrice,
				       SaleDate,
				       LegalReference
		ORDER BY  UniqueID) Duplicates
FROM  PortfolioProject.dbo.NashvilleHousing
)
SELECT * 
FROM RemoveDuplicates
WHERE Duplicates > 1


-- TO REMOVE Duplicates ---> USE DELETE

WITH RemoveDuplicates  AS(
select *, ROW_NUMBER() OVER( 
		  PARTITION BY ParcelID,
					   PropertyAddress,
				       SalePrice,
				       SaleDate,
				       LegalReference
		ORDER BY  UniqueID) Duplicates
FROM  PortfolioProject.dbo.NashvilleHousing
)
DELETE 
FROM RemoveDuplicates
WHERE Duplicates > 1


--LET'S CHECK
WITH RemoveDuplicates  AS(
select *, ROW_NUMBER() OVER( 
		  PARTITION BY ParcelID,
					   PropertyAddress,
				       SalePrice,
				       SaleDate,
				       LegalReference
		ORDER BY  UniqueID) Duplicates
FROM  PortfolioProject.dbo.NashvilleHousing
)
SELECT * 
FROM RemoveDuplicates
WHERE Duplicates > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--TO CHECK 

Select *
From PortfolioProject.dbo.NashvilleHousing




