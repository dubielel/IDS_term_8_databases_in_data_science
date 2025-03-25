CREATE TABLE producthistory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    productid INTEGER,
    productname TEXT NOT NULL,
    supplierid INTEGER NULL,
    categoryid INTEGER NULL,
    quantityperunit TEXT NULL,
    unitprice REAL NULL,
    quantity INTEGER,
    value REAL,
    date DATE
);