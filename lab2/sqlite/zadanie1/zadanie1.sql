-- WINDOW FUNCTION
WITH t AS (
    SELECT id,
        productid,
        productname,
        categoryid,
        unitprice,
        AVG(unitprice) over (PARTITION BY categoryid) AS avgprice
    FROM producthistory
)
SELECT *
FROM t
WHERE t.unitprice > t.avgprice;

-- JOIN
SELECT id,
    productid,
    productname,
    pp.categoryid,
    unitprice
FROM producthistory AS pp
    JOIN (
        SELECT categoryid,
            AVG(unitprice) AS avgprice
        FROM producthistory
        GROUP BY categoryid
    ) AS t ON pp.categoryid = t.categoryid
WHERE pp.unitprice > t.avgprice;

-- SUBQUERY
WITH limited_data AS (
    SELECT *
    FROM producthistory
    ORDER BY id
    LIMIT 100000
)
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice
FROM limited_data
WHERE unitprice > (
        SELECT AVG(unitprice)
        FROM limited_data AS t
        WHERE t.categoryid = limited_data.categoryid
    );