 -- WINDOW FUNCTION

with t as (
    select
        datepart(year, date) as year,
        productid,
        productname,
        unitprice,
        date,
        row_number() over (partition by datepart(year, date), productid order by unitprice desc) as ranking
    from producthistory
)

select * from t
where ranking < 5
order by year, productid, ranking;


 -- SUBQUERY

with limited_data as (
    select *
    from producthistory
    where datepart(year, date) = 1940
),

t as (
    select
        datepart(year, date) as year,
        ph.productid,
        productname,
        ph.unitprice,
        date,
        (
            select count(*)
            from limited_data as ph2
            where datepart(year, ph2.date) = datepart(year, ph.date)
            and ph2.productid = ph.productid
            and (
                ph2.unitprice > ph.unitprice
                or (
                    ph2.unitprice = ph.unitprice
                    and ph2.date < ph.date
                )
            )
        ) + 1 as ranking
    from limited_data as ph
)

select * from t
where ranking < 5
order by year, productid, ranking;


SET SHOWPLAN_ALL ON;