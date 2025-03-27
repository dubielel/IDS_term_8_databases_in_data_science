-- WINDOW FUNCTION
WITH t AS (
    SELECT id,
        productid,
        productname,
        categoryid,
        unitprice,
        AVG(unitprice) OVER (PARTITION BY categoryid) AS avgprice
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
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice
FROM producthistory
WHERE unitprice > (
        SELECT AVG(unitprice)
        FROM producthistory AS t
        WHERE t.categoryid = producthistory.categoryid
    )