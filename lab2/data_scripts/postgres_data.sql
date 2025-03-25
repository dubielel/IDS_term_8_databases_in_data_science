do $$
    begin
        for cnt in 1..30000 loop
                insert into producthistory(productid, productname, supplierid,
                                            categoryid, quantityperunit,
                                            unitprice, quantity, value, date)
                select productid, productname, supplierid, categoryid,
                       quantityperunit,
                       round((random() * unitprice + 10)::numeric,2),
                       cast(random() * productid + 10 as int), 0,
                       cast('1940-01-01' as date) + cnt
                from products;
            end loop;
    end; $$;

update producthistory
set value = unitprice * quantity
where 1=1;