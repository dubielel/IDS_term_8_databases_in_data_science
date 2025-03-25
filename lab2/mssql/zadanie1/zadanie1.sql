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

select categoryid, count(*) from t
where t.unitprice > t.avgprice
group by categoryid;

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
SET SHOWPLAN_ALL OFF;
select id,
       productid,
       productname,
       categoryid,
       unitprice
from producthistory
where unitprice > (
    select avg(unitprice)
    from producthistory as t
    where t.categoryid = producthistory.categoryid
)







