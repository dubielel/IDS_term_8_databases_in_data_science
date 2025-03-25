-- Create a recursive CTE to generate numbers from 1 to 30000
WITH RECURSIVE numbers(cnt) AS (
    SELECT 1
    UNION ALL
    SELECT cnt + 1 FROM numbers WHERE cnt < 30000
)
INSERT INTO producthistory(productid, productname, supplierid,
                           categoryid, quantityperunit,
                           unitprice, quantity, value, date)
SELECT 
    p.productid, 
    p.productname, 
    p.supplierid, 
    p.categoryid,
    p.quantityperunit,
    ROUND((ABS(RANDOM() % 100) / 10.0 + 10), 2), -- Simulating random unit price
    CAST(ABS(RANDOM() % 100) + 10 AS INTEGER), -- Simulating random quantity
    0, -- Default value
    DATE('1940-01-01', '+' || n.cnt || ' days') -- Incrementing dates
FROM products p
CROSS JOIN numbers n; -- No need for LIMIT, as CTE ensures 30,000 rows

-- Update the value column
UPDATE producthistory
SET value = unitprice * quantity;