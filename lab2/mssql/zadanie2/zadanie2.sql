-- WINDOW FUNCTION
-- z jakiegoś powodu nie działa mi window :((
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice,
    AVG(unitprice) over (PARTITION BY categoryid) AS avgpricecategory,
    SUM(VALUE) over (PARTITION BY categoryid) AS sumpricecategory,
    AVG(unitprice) over (PARTITION BY productid) AS avgpriceproduct,
    SUM(VALUE) over (PARTITION BY productid) AS sumpriceproduct
FROM producthistory;

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
SELECT id,
    productid,
    productname,
    categoryid,
    unitprice,
    (
        SELECT AVG(unitprice)
        FROM producthistory AS t
        WHERE t.categoryid = producthistory.categoryid
    ) AS avgpricecategory,
    (
        SELECT SUM(unitprice)
        FROM producthistory AS t
        WHERE t.categoryid = producthistory.categoryid
    ) AS sumpricecategory,
    (
        SELECT AVG(unitprice)
        FROM producthistory AS t
        WHERE t.productid = producthistory.productid
    ) AS avgpriceproduct,
    (
        SELECT SUM(unitprice)
        FROM producthistory AS t
        WHERE t.productid = producthistory.productid
    ) AS sumpriceproduct
FROM producthistory;