/*

Cleaning Data in SQL Queries

*/

select *
from nashville_housing;
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select sale_date 
from nashville_housing;

UPDATE nashville_housing
SET sale_date = str_to_date(sale_date, '%M %d, %Y');

ALTER TABLE  nashville_housing
MODIFY COLUMN sale_date DATE;


--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT * 
FROM nashville_housing
WHERE property_address is null;

select a.parcel_id, a.property_address, b.parcel_id, b.property_address, ifnull(a.property_address, b.property_address)
from nashville_housing a
join nashville_housing b 
on a.parcel_id = b.parcel_id
and a.unique_id != b.unique_id
where a.property_address is null;

-- update table

update nashville_housing a
join nashville_housing b 
on a.parcel_id = b.parcel_id
and a.unique_id != b.unique_id
set a.property_address = ifnull(a.property_address, b.property_address)
where a.property_address is null;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select property_address
from nashville_housing;

SELECT property_address,
substring_index(property_address,',',1) as address,
substring_index(property_address,',',-1) as city
from nashville_housing;

alter table nashville_housing
add column property_split_address varchar(255),
add column property_city varchar(255);


update nashville_housing
set property_split_address = substring_index(property_address, ',',1),
property_city = substring_index(property_address,',',-1);

select property_split_address, property_city
from nashville_housing;

-- owner address

select owner_address,
substring_index(owner_address,',',1),
substring_index(substring_index(owner_address,',',2),',',-1),
substring_index(owner_address,',',-1)
from nashville_housing

alter table nashville_housing
add column owner_split_address varchar(255),
add column owner_split_city varchar(255),
add column owner_split_state varchar(255);

update nashville_housing
set owner_split_address = substring_index(owner_address,',',1),
owner_split_city = substring_index(substring_index(owner_address,',',2),',',-1),
owner_split_state = substring_index(owner_address,',',-1);

select owner_address, owner_split_address, owner_split_city, owner_split_state
from nashville_housing;



--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(sold_as_vacant), count(sold_as_vacant) 
from nashville_housing
group by sold_as_vacant
order by 2 asc;

select sold_as_vacant,
case when sold_as_vacant = 'Y' then 'Yes'
	when sold_as_vacant = 'N' then 'No'
    else sold_as_vacant
    end
from nashville_housing;

update nashville_housing
set sold_as_vacant  = case when sold_as_vacant = 'Y' then 'Yes'
	when sold_as_vacant = 'N' then 'No'
    else sold_as_vacant
    end;


--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
select *
from nashville_housing;

with row_num_cte as (
select *, 
ROW_NUMBER() over(partition by parcel_id, 
property_address, 
sale_date, sale_price, 
legal_reference, 
owner_name 
order by unique_id) as row_num
from nashville_housing) ;

select * 
from row_num_cte
where row_num > 1;

-- delete the duplicates value

delete from nashville_housing
where unique_id in(
select unique_id from(
				select unique_id, 
				ROW_NUMBER() over(partition by parcel_id, 
											property_address, 
											sale_date, sale_price, 
											legal_reference, 
											owner_name 
											order by unique_id) as row_num
				from nashville_housing) as sub_query
	where row_num > 1);



--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select * 
from nashville_housing;

alter table nashville_housing
drop column property_address,
drop column owner_address,
drop column tax_district;




--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------









