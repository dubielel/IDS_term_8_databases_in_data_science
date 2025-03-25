 -- WINDOW FUNCTION

EXPLAIN ANALYSE
select
    id,
    productid,
    productname,
    categoryid,
    unitprice,
    avg(unitprice) over category_window as avgpricecategory,
    sum(value) over category_window as sumpricecategory,
    avg(unitprice) over product_window as avgpriceproduct,
    sum(value) over product_window as sumpriceproduct
from producthistory
window
    category_window as (partition by categoryid),
    product_window as (partition by productid);
-- order by id;

 -- JOIN

EXPLAIN ANALYSE
select
    id,
    pp.productid,
    productname,
    pp.categoryid,
    unitprice,
    avgpricecategory,
    sumpricecategory,
    avgpriceproduct,
    sumpriceproduct
from producthistory as pp
join (
    select
        categoryid,
        avg(unitprice) as avgpricecategory,
        sum(unitprice) as sumpricecategory
    from producthistory
    group by categoryid
) as ct
on pp.categoryid = ct.categoryid
join (
    select
        productid,
        avg(unitprice) as avgpriceproduct,
        sum(unitprice) as sumpriceproduct
    from producthistory
    group by productid
) as pt
on pp.productid = pt.productid;
-- order by id;

 -- SUBQUERY

EXPLAIN ANALYSE
WITH limited_data AS (
    SELECT *
    FROM producthistory
    ORDER BY id
    LIMIT 10000
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







