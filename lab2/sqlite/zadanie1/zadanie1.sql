 -- WINDOW FUNCTION

with t as (
 select
     id,
     productid,
     productname,
     categoryid,
     unitprice,
     avg(unitprice) over (PARTITION BY categoryid) as avgprice
 from producthistory
)

select * from t
where t.unitprice > t.avgprice;
 -- JOIN

select id,
       productid,
       productname,
       pp.categoryid,
       unitprice
from producthistory as pp
join (
    select
        categoryid,
        avg(unitprice) as avgprice
    from producthistory
    group by categoryid
) as t
on pp.categoryid = t.categoryid
where pp.unitprice > t.avgprice;

 -- SUBQUERY

WITH limited_data AS (
    SELECT *
    FROM producthistory
    ORDER BY id
    LIMIT 100000
)

select id,
       productid,
       productname,
       categoryid,
       unitprice
from limited_data
where unitprice > (
    select avg(unitprice)
    from limited_data as t
    where t.categoryid = limited_data.categoryid
);








