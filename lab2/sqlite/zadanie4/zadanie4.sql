 -- WINDOW FUNCTION

explain query plan
with t as (
    select
        strftime('%Y', date) as year,
        productid,
        productname,
        unitprice,
        date,
        row_number() over (partition by strftime('%Y', date), productid order by unitprice desc) as ranking
    from producthistory
    order by year, productid, ranking
)

select * from t
where ranking < 5
order by year, productid, ranking;


 -- SUBQUERY

explain query plan
with limited_data as (
    select *
    from producthistory
    where strftime('%Y', date) = '1940'
    order by date
),
t as (
    select
        strftime('%Y', date) as year,
        ph.productid,
        productname,
        ph.unitprice,
        date,
        (
            select count(*)
            from limited_data as ph2
            where strftime('%Y', ph2.date) = strftime('%Y', ph.date)
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
    order by year, productid, ranking
)

select * from t
where ranking < 5
order by year, productid, ranking;