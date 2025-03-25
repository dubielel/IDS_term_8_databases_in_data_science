 -- WINDOW FUNCTION

select
    id,
    productid,
    productname,
    categoryid,
    unitprice,
    avg(unitprice) over (partition by categoryid) as avgpricecategory,
    sum(value) over (partition by categoryid) as sumpricecategory,
    avg(unitprice) over (partition by productid) as avgpriceproduct,
    sum(value) over (partition by productid) as sumpriceproduct
from producthistory;

-- z jakiegoś powodu nie działa mi window :((

 -- JOIN

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

 -- SUBQUERY

SET SHOWPLAN_ALL ON;
select
    id,
    productid,
    productname,
    categoryid,
    unitprice,
    (
        select avg(unitprice)
        from producthistory as t
        where t.categoryid = producthistory.categoryid
    ) as avgpricecategory,
    (
        select sum(unitprice)
        from producthistory as t
        where t.categoryid = producthistory.categoryid
    ) as sumpricecategory,
    (
        select avg(unitprice)
        from producthistory as t
        where t.productid = producthistory.productid
    ) as avgpriceproduct,
    (
        select sum(unitprice)
        from producthistory as t
        where t.productid = producthistory.productid
    ) as sumpriceproduct
from producthistory;







