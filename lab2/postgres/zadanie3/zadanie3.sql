SELECT productid,
    productname,
    unitprice,
    categoryid,
    row_number() over(
        PARTITION BY categoryid
        ORDER BY unitprice DESC
    ) AS rowno,
    rank() over(
        PARTITION BY categoryid
        ORDER BY unitprice DESC
    ) AS rankprice,
    dense_rank() over(
        PARTITION BY categoryid
        ORDER BY unitprice DESC
    ) AS denserankprice
FROM products;

-- ROW_NUMBER
SELECT p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        SELECT COUNT(*)
        FROM products p2
        WHERE p2.categoryid = p1.categoryid
            AND (
                p2.unitprice > p1.unitprice
                OR (
                    p2.unitprice = p1.unitprice
                    AND p2.productid < p1.productid
                )
            )
    ) + 1 AS rowno
FROM products p1
ORDER BY categoryid,
    rowno;

-- RANK
SELECT p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        SELECT COUNT(*)
        FROM products p2
        WHERE p2.categoryid = p1.categoryid
            AND p2.unitprice > p1.unitprice
    ) + 1 AS rankprice
FROM products p1
ORDER BY categoryid,
    rankprice;

-- DENSE_RANK
SELECT p1.productid,
    p1.productname,
    p1.unitprice,
    p1.categoryid,
    (
        SELECT COUNT(DISTINCT p2.unitprice)
        FROM products p2
        WHERE p2.categoryid = p1.categoryid
            AND p2.unitprice > p1.unitprice
    ) + 1 AS denserankprice
FROM products p1
ORDER BY categoryid,
    denserankprice;