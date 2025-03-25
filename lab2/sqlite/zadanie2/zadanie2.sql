 -- WINDOW FUNCTION

 -- explain query plan
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

 -- explain query plan
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
        sum(value) as sumpricecategory
    from producthistory
    group by categoryid
) as ct
on pp.categoryid = ct.categoryid
join (
    select
        productid,
        avg(unitprice) as avgpriceproduct,
        sum(value) as sumpriceproduct
    from producthistory
    group by productid
) as pt
on pp.productid = pt.productid;
-- order by id;

 -- SUBQUERY

 -- explain query plan
WITH limited_data AS (
    SELECT *
    FROM producthistory
    ORDER BY id
    LIMIT 10000
)

select
    id,
    productid,
    productname,
    categoryid,
    unitprice,
    (
        select avg(unitprice)
        from limited_data as t
        where t.categoryid = limited_data.categoryid
    ) as avgpricecategory,
    (
        select sum(unitprice)
        from limited_data as t
        where t.categoryid = limited_data.categoryid
    ) as sumpricecategory,
    (
        select avg(unitprice)
        from limited_data as t
        where t.productid = limited_data.productid
    ) as avgpriceproduct,
    (
        select sum(unitprice)
        from limited_data as t
        where t.productid = limited_data.productid
    ) as sumpriceproduct
from limited_data;







