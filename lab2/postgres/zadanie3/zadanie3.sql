select productid, productname, unitprice, categoryid,
       row_number() over(partition by categoryid order by unitprice desc) as rowno,
       rank() over(partition by categoryid order by unitprice desc) as rankprice,
       dense_rank() over(partition by categoryid order by unitprice desc) as denserankprice
from products;

-- ROW_NUMBER

select
    p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        select count(*)
        from products p2
        where p2.categoryid = p1.categoryid
          and (
            p2.unitprice > p1.unitprice
                or (
                p2.unitprice = p1.unitprice
                    and p2.productid < p1.productid
                )
            )
    ) + 1 as rowno
from products p1
order by categoryid, rowno;

-- RANK

select
    p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        select count(*)
        from products p2
        where p2.categoryid = p1.categoryid
          and p2.unitprice > p1.unitprice
    ) + 1 as rankprice
from products p1
order by categoryid, rankprice;

-- DENSE_RANK

select
    p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        select count(distinct p2.unitprice)
        from products p2
        where p2.categoryid = p1.categoryid
          and p2.unitprice > p1.unitprice
    ) + 1 as denserankprice
from products p1
order by categoryid, denserankprice;
