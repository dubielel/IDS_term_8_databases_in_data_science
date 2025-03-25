 -- WINDOW FUNCTION

EXPLAIN ANALYSE
with t as (
    select
        date_part('year', date) as year,
        productid,
        productname,
        unitprice,
        date,
        row_number() over (partition by date_part('year', date), productid order by unitprice desc) as ranking
    from producthistory
    order by year, productid, ranking
)

select * from t
where ranking < 5
order by year, productid, ranking;


 -- SUBQUERY

 EXPLAIN ANALYSE
with limited_data as (
    select *
    from producthistory
    where date_part('year', date) = 1940
    order by date
),
t as (
    select
        date_part('year', date) as year,
        ph.productid,
        productname,
        ph.unitprice,
        date,
        (
            select count(*)
            from limited_data as ph2
            where date_part('year', ph2.date) = date_part('year', ph.date)
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