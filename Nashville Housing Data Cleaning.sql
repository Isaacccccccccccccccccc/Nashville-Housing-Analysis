-- loading data

Use PortfolioProject;

Truncate table nashvillehousing;

Load data local infile '/Users/shihaoliu/Documents/Data/Nashville Housing Data.csv'
into table nashvillehousing
Character set utf8mb4
Fields terminated by ','
Optionally enclosed by '"'  
lines terminated by '\n'
Ignore 1 lines;

Select Count(*) from nashvillehousing;


-- Cleaning data

Select * from nashvillehousing;


-- Standardize Date Format
Select SaleDate, Str_to_date(SaleDate, '%e-%b-%y') from nashvillehousing;

Update nashvillehousing
set Saledate = Str_to_date(SaleDate, '%e-%b-%y');

Alter table nashvillehousing
modify column Saledate Date;


-- Populat PropertyAddress data

Select * from nashvillehousing
Where Propertyaddress = '';


Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, Nullif(a.PropertyAddress, ''), Ifnull(Nullif(a.PropertyAddress, ''), b.PropertyAddress)
from nashvillehousing a
Join nashvillehousing b
	on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
Where a.PropertyAddress = '';


UPDATE nashvillehousing a
JOIN nashvillehousing b
  ON a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';

Select * from nashvillehousing
Where Propertyaddress = '';


-- Breaking out Address into Individual Columns (Address, City, States)

Select PropertyAddress from nashvillehousing;

Select Substring(PropertyAddress, 1, Locate(',', PropertyAddress) - 1) as Address,
Substring(PropertyAddress, Locate(',', PropertyAddress) + 2, length(PropertyAddress)) as City
from nashvillehousing;

Alter table nashvillehousing add column PropertySplitAddress varchar(255);

Update nashvillehousing
set PropertySplitAddress = Substring(PropertyAddress, 1, Locate(',', PropertyAddress) - 1);

Alter table nashvillehousing add column PropertySplitCity varchar(255);

Update nashvillehousing
set PropertySplitCity = Substring(PropertyAddress, Locate(',', PropertyAddress) + 2, length(PropertyAddress));

Select * from nashvillehousing;

Select 
Trim(Substring_index(OwnerAddress, ',', 1)) as Address,
Trim(Substring_index(Substring_index(OwnerAddress, ',', 2), ',', -1)) as City,
Trim(Substring_index(OwnerAddress, ',', -1)) as State
from nashvillehousing;

Alter table nashvillehousing add column OwnerSplitAddress varchar(255);

Update nashvillehousing
set OwnerSplitAddress = Trim(Substring_index(OwnerAddress, ',', 1));

Alter table nashvillehousing add column OwnerSplitCity varchar(255);

Update nashvillehousing
set OwnerSplitCity = Trim(Substring_index(Substring_index(OwnerAddress, ',', 2), ',', -1));

Alter table nashvillehousing add column OwnerSplitState varchar(255);

Update nashvillehousing
set OwnerSplitState = Trim(Substring_index(OwnerAddress, ',', -1));


-- Change Y and N to Yes and No in "SoldAsVacant


Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
from nashvillehousing
Group by SoldAsVacant;

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
     Else SoldAsVacant
End
from nashvillehousing;

Update nashvillehousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
     Else SoldAsVacant
End;


-- Romve Duplicates

With DuplicateRows as (
	Select *, Row_number() over (Partition by ParcelID, PropertyAddress, Saledate, SalePrice, LegalReference Order by UniqueID) as row_num
	from nashvillehousing
	Order by UniqueID
)
Select * from DuplicateRows
Where row_num > 1
Order by PropertyAddress;

With DuplicateRows as (
	Select *, Row_number() over (Partition by ParcelID, PropertyAddress, Saledate, SalePrice, LegalReference Order by UniqueID) as row_num
	from nashvillehousing
)
Delete nh
from nashvillehousing nh
Join DuplicateRows d using (UniqueID)
Where d.row_num > 1;


-- Delete Unused Columns

Select * from nashvillehousing;

Alter table nashvillehousing
Drop column PropertyAddress, 
Drop column OwnerAddress, 
Drop column TaxDistrict;








