declare @i int
set @i = 1
while @i <= 30000
begin
    insert producthistory
select productid, ProductName, SupplierID, CategoryID,
       QuantityPerUnit,round(RAND() * unitprice + 10,2),
       cast(RAND() * productid + 10 as int), 0,
       dateadd(day, @i, '1940-01-01')
from products
    set @i = @i + 1;
end;

update producthistory
set value = unitprice * quantity
where 1=1;