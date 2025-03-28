-- WINDOW FUNCTION
WITH t AS (
    SELECT datepart(YEAR, DATE) AS YEAR,
        productid,
        productname,
        unitprice,
        DATE,
        row_number() over (
            PARTITION BY datepart(YEAR, DATE),
            productid
            ORDER BY unitprice DESC
        ) AS ranking
    FROM producthistory
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
    WHERE datepart(YEAR, DATE) = 1940
),
t AS (
    SELECT datepart(YEAR, DATE) AS YEAR,
        ph.productid,
        productname,
        ph.unitprice,
        DATE,
        (
            SELECT COUNT(*)
            FROM limited_data AS ph2
            WHERE datepart(YEAR, ph2.date) = datepart(YEAR, ph.date)
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
)
SELECT *
FROM t
WHERE ranking < 5
ORDER BY YEAR,
    productid,
    ranking;