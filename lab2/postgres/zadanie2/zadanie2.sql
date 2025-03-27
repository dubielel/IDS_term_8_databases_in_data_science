-- WINDOW FUNCTION
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice,
    AVG(unitprice) over category_window AS avgpricecategory,
    SUM(VALUE) over category_window AS sumpricecategory,
    AVG(unitprice) over product_window AS avgpriceproduct,
    SUM(VALUE) over product_window AS sumpriceproduct
FROM producthistory window category_window AS (PARTITION BY categoryid),
    product_window AS (PARTITION BY productid);

-- JOIN
SELECT id,
    pp.productid,
    productname,
    pp.categoryid,
    unitprice,
    avgpricecategory,
    sumpricecategory,
    avgpriceproduct,
    sumpriceproduct
FROM producthistory AS pp
    JOIN (
        SELECT categoryid,
            AVG(unitprice) AS avgpricecategory,
            SUM(VALUE) AS sumpricecategory
        FROM producthistory
        GROUP BY categoryid
    ) AS ct ON pp.categoryid = ct.categoryid
    JOIN (
        SELECT productid,
            AVG(unitprice) AS avgpriceproduct,
            SUM(VALUE) AS sumpriceproduct
        FROM producthistory
        GROUP BY productid
    ) AS pt ON pp.productid = pt.productid;

-- SUBQUERY
WITH limited_data AS (
    SELECT *
    FROM producthistory
    ORDER BY id
    LIMIT 10000
)
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice,
    (
        SELECT AVG(unitprice)
        FROM limited_data AS t
        WHERE t.categoryid = limited_data.categoryid
    ) AS avgpricecategory,
    (
        SELECT SUM(unitprice)
        FROM limited_data AS t
        WHERE t.categoryid = limited_data.categoryid
    ) AS sumpricecategory,
    (
        SELECT AVG(unitprice)
        FROM limited_data AS t
        WHERE t.productid = limited_data.productid
    ) AS avgpriceproduct,
    (
        SELECT SUM(unitprice)
        FROM limited_data AS t
        WHERE t.productid = limited_data.productid
    ) AS sumpriceproduct
FROM limited_data;