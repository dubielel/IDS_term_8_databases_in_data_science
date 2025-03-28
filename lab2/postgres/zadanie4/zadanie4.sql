-- WINDOW FUNCTION
WITH t AS (
    SELECT date_part('year', DATE) AS YEAR,
        productid,
        productname,
        unitprice,
        DATE,
        row_number() over (
            PARTITION BY date_part('year', DATE),
            productid
            ORDER BY unitprice DESC
        ) AS ranking
    FROM producthistory
    ORDER BY YEAR,
        productid,
        ranking
)
SELECT *
FROM t
WHERE ranking < 5
ORDER BY YEAR,
    productid,
    ranking;

-- SUBQUERY
WITH limited_data AS (
    SELECT *
    FROM producthistory
    WHERE date_part('year', DATE) = 1940
    ORDER BY DATE
),
t AS (
    SELECT date_part('year', DATE) AS YEAR,
        ph.productid,
        productname,
        ph.unitprice,
        DATE,
        (
            SELECT COUNT(*)
            FROM limited_data AS ph2
            WHERE date_part('year', ph2.date) = date_part('year', ph.date)
                AND ph2.productid = ph.productid
                AND (
                    ph2.unitprice > ph.unitprice
                    OR (
                        ph2.unitprice = ph.unitprice
                        AND ph2.date < ph.date
                    )
                )
        ) + 1 AS ranking
    FROM limited_data AS ph
    ORDER BY YEAR,
        productid,
        ranking
)
SELECT *
FROM t
WHERE ranking < 5
ORDER BY YEAR,
    productid,
    ranking;