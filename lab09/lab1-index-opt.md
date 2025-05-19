
# Indeksy,  optymalizator <br>Lab1

<!-- <style scoped>
 p,li {
    font-size: 12pt;
  }
</style>  -->

<!-- <style scoped>
 pre {
    font-size: 8pt;
  }
</style>  -->


---

**Imiona i nazwiska: Kacper Cienkosz, Miłosz Dubiel**

--- 

Celem ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans), oraz z budową i możliwością wykorzystaniem indeksów.

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---
> Wyniki: 

```sql
--  ...
```

---

Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki
- dołącz kod rozwiązania w formie tekstowej/źródłowej
- można dołączyć plik .md albo .sql

Zwróć uwagę na formatowanie kodu

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie
- MS SQL Server
- SSMS - SQL Server Management Studio    
	- ewentualnie inne narzędzie umożliwiające komunikację z MS SQL Server i analizę planów zapytań
- przykładowa baza danych AdventureWorks2017.
    
Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej


## Przygotowanie  
    
Stwórz swoją bazę danych o nazwie lab4. 

```sql
CREATE database lab1
GO

USE lab1
GO
```


# Część 1

Celem tej części ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans) oraz narzędziem do automatycznego generowania indeksów.

## Dokumentacja/Literatura

Przydatne materiały/dokumentacja. Proszę zapoznać się z dokumentacją:
- [https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor)
- [https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor)
- [https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer](https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer)
- [https://blog.quest.com/sql-server-execution-plan-what-is-it-and-how-does-it-help-with-performance-problems/](https://blog.quest.com/sql-server-execution-plan-what-is-it-and-how-does-it-help-with-performance-problems/)


Operatory (oraz reprezentujące je piktogramy/Ikonki) używane w graficznej prezentacji planu zapytania opisane są tutaj:
- [https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference](https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference)

<div style="page-break-after: always;"></div>


Wykonaj poniższy skrypt, aby przygotować dane:

```sql
SELECT * INTO [ salesorderheader ]
FROM [ adventureworks2017 ].sales.[ salesorderheader ]
GO

SELECT * INTO [ salesorderdetail ]
FROM [ adventureworks2017 ].sales.[ salesorderdetail ]
GO
```


# Zadanie 1 - Obserwacja


Wpisz do MSSQL Managment Studio (na razie nie wykonuj tych zapytań):

```sql
-- zapytanie 1
SELECT *
FROM salesorderheader sh
INNER JOIN salesorderdetail sd ON sh.salesorderid = sd.salesorderid
WHERE orderdate = '2008-06-01 00:00:00.000'
GO

-- zapytanie 1.1
SELECT *
FROM salesorderheader sh
INNER JOIN salesorderdetail sd ON sh.salesorderid = sd.salesorderid
WHERE orderdate = '2013-01-28 00:00:00.000'
GO

-- zapytanie 2
SELECT orderdate,
       productid,
       SUM(orderqty) AS orderqty,
       SUM(unitpricediscount) AS unitpricediscount,
       SUM(linetotal)
FROM salesorderheader sh
INNER JOIN salesorderdetail sd ON sh.salesorderid = sd.salesorderid
GROUP BY orderdate, productid
HAVING SUM(orderqty) >= 100
GO

-- zapytanie 3
SELECT salesordernumber,
       purchaseordernumber,
       duedate,
       shipdate
FROM salesorderheader sh
INNER JOIN salesorderdetail sd ON sh.salesorderid = sd.salesorderid
WHERE orderdate IN (
    '2008-06-01', '2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05'
)
GO

-- zapytanie 4
SELECT sh.salesorderid,
       salesordernumber,
       purchaseordernumber,
       duedate,
       shipdate
FROM salesorderheader sh
INNER JOIN salesorderdetail sd ON sh.salesorderid = sd.salesorderid
WHERE carriertrackingnumber IN ('ef67-4713-bd', '6c08-4c4c-b8')
ORDER BY sh.salesorderid
GO
```


Włącz dwie opcje: **Include Actual Execution Plan** oraz **Include Live Query Statistics**:



<!-- ![[_img/index1-1.png | 500]] -->


<img src="_img/index1-1.png" alt="image" width="500" height="auto">


Teraz wykonaj poszczególne zapytania (najlepiej każde analizuj oddzielnie). Co można o nich powiedzieć? Co sprawdzają? Jak można je zoptymalizować?  

---
> Wyniki: 

```sql
--  ...
```

---

# Zadanie 2 - Dobór indeksów / optymalizacja

Do wykonania tego ćwiczenia potrzebne jest narzędzie SSMS

Zaznacz wszystkie zapytania, i uruchom je w **Database Engine Tuning Advisor**:

<!-- ![[_img/index1-12.png | 500]] -->

<img src="_img/index1-2.png" alt="image" width="500" height="auto">


Sprawdź zakładkę **Tuning Options**, co tam można skonfigurować?

---
> Wyniki: 

```sql
--  ...
```

---


Użyj **Start Analysis**:

<!-- ![[_img/index1-3.png | 500]] -->

<img src="_img/index1-3.png" alt="image" width="500" height="auto">


Zaobserwuj wyniki w **Recommendations**.

Przejdź do zakładki **Reports**. Sprawdź poszczególne raporty. Główną uwagę zwróć na koszty i ich poprawę:


<!-- ![[_img/index4-1.png | 500]] -->

<img src="_img/index1-4.png" alt="image" width="500" height="auto">


Zapisz poszczególne rekomendacje:

Uruchom zapisany skrypt w Management Studio.

Opisz, dlaczego dane indeksy zostały zaproponowane do zapytań:

---
> Wyniki: 

```sql
--  ...
```

---


Sprawdź jak zmieniły się Execution Plany. Opisz zmiany:

---
> Wyniki: 
[[lab2-index-opt]]
```sql
--  ...
```

---

# Część 2

Celem ćwiczenia jest zapoznanie się z różnymi rodzajami  indeksów  oraz możliwością ich wykorzystania

## Dokumentacja/Literatura

Przydatne materiały/dokumentacja. Proszę zapoznać się z dokumentacją:
- [https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes)
- [https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide)
- [https://www.simple-talk.com/sql/performance/14-sql-server-indexing-questions-you-were-too-shy-to-ask/](https://www.simple-talk.com/sql/performance/14-sql-server-indexing-questions-you-were-too-shy-to-ask/)
- [https://www.sqlshack.com/sql-server-query-execution-plans-examples-select-statement/](https://www.sqlshack.com/sql-server-query-execution-plans-examples-select-statement/)

# Zadanie 3 - Indeksy klastrowane I nieklastrowane


Skopiuj tabelę `Customer` do swojej bazy danych:

```sql
SELECT * INTO customer
FROM adventureworks2017.sales.customer
```

Wykonaj analizy zapytań:

```sql
SELECT *
FROM customer
WHERE storeid = 594
  
SELECT *
FROM customer
WHERE storeid BETWEEN 594 AND 610
```

Zanotuj czas zapytania oraz jego koszt koszt:

---
> Wyniki:
>

### Zapytanie 1:
```sql
SELECT *
FROM customer
WHERE storeid = 594
1 row retrieved starting from 1 in 42 ms (execution: 20 ms, fetching: 22 ms)
```

![img1.png](zad3/img1.png)

Koszt zapytania: 0.139

Wynik: 

| CustomerID | PersonID | StoreID | TerritoryID | AccountNumber | ModifiedDate             | rowguid                               |
|------------|----------|---------|-------------|----------------|--------------------------|----------------------------------------|
| 517        |          | 594     | 7           | AW00000517     | 2014-09-12 11:15:07.263  | A7726BAE-8C2D-4FE5-B25F-281083AEAF2C   |


### Zapytanie 2:
```sql
SELECT *
FROM customer
WHERE storeid BETWEEN 594 AND 610
16 rows retrieved starting from 1 in 47 ms (execution: 17 ms, fetching: 30 ms)
```

![img2.png](zad3/img2.png)

Koszt zapytania: 0.139

Wynik: 

| CustomerID | PersonID | StoreID | TerritoryID | AccountNumber | rowguid                                | ModifiedDate             |
|------------|----------|---------|-------------|----------------|----------------------------------------|--------------------------|
| 350        |          | 610     | 5           | AW00000350     | 51AF3285-9533-4172-A4B9-7E654169FB33   | 2014-09-12 11:15:07.263  |
| 353        |          | 608     | 6           | AW00000353     | 3B2E5C36-0827-4A31-B112-F347AD588822   | 2014-09-12 11:15:07.263  |
| 356        |          | 606     | 8           | AW00000356     | C5ADD2B4-2679-46D0-B6BC-649592C7DA61   | 2014-09-12 11:15:07.263  |
| 359        |          | 604     | 2           | AW00000359     | 68E332E9-2929-4149-8086-FA8D7E4BC859   | 2014-09-12 11:15:07.263  |
| 430        |          | 602     | 10          | AW00000430     | D18DFA60-7D7E-4900-A0B6-78DF78E4DEEF   | 2014-09-12 11:15:07.263  |
| 433        |          | 600     | 1           | AW00000433     | EB0B1054-FF23-4E35-BCFC-10B84B47EA47   | 2014-09-12 11:15:07.263  |
| 436        |          | 598     | 4           | AW00000436     | 506DD7E7-E6D0-49E7-ADDC-5CD6C811DD35   | 2014-09-12 11:15:07.263  |
| 517        |          | 594     | 7           | AW00000517     | A7726BAE-8C2D-4FE5-B25F-281083AEAF2C   | 2014-09-12 11:15:07.263  |
| 520        |          | 596     | 10          | AW00000520     | 34C094D7-8C79-47A5-B192-9597826BD55D   | 2014-09-12 11:15:07.263  |
| 29615      | 595      | 596     | 10          | AW00029615     | C7E5D895-EABA-4CC6-A7AB-50B8569541D3   | 2014-09-12 11:15:07.263  |
| 29616      | 597      | 598     | 4           | AW00029616     | 21DF3FF8-0A8F-434B-9290-E562B7DA6DCA   | 2014-09-12 11:15:07.263  |
| 29617      | 599      | 600     | 1           | AW00029617     | 96E154EB-8F02-4651-A117-5E248685341D   | 2014-09-12 11:15:07.263  |
| 29618      | 601      | 602     | 10          | AW00029618     | 89BE0FA2-162C-400D-9D8B-F2E557242088   | 2014-09-12 11:15:07.263  |
| 29619      | 603      | 604     | 2           | AW00029619     | F31ACC7A-52DF-456E-A5CD-63858F724AEC   | 2014-09-12 11:15:07.263  |
| 29620      | 607      | 608     | 6           | AW00029620     | A2268D9A-2511-43C3-95CC-D7DE094109F1   | 2014-09-12 11:15:07.263  |
| 29621      | 609      | 610     | 5           | AW00029621     | BFF0A6DF-D5F0-4A5D-982B-79890E20F63A   | 2014-09-12 11:15:07.263  |

Dodaj indeks:

```sql
CREATE INDEX customer_store_cls_idx ON customer(storeid)
```

### Zapytanie 1:
```sql
SELECT *
FROM customer
WHERE storeid = 594
1 row retrieved starting from 1 in 52 ms (execution: 33 ms, fetching: 19 ms)
```

![img3.png](zad3/img3.png)

Koszt zapytania: 0.00657

Wynik: jest taki sam jak w przypadku zapytania bez indeksu


### Zapytanie 2:
```sql
SELECT *
FROM customer
WHERE storeid BETWEEN 594 AND 610
16 rows retrieved starting from 1 in 44 ms (execution: 20 ms, fetching: 24 ms)
```

![img4.png](zad3/img4.png)

Koszt zapytania: 0.0507

Wynik: jest taki sam jak w przypadku zapytania bez indeksu

Jak zmienił się plan i czas? Czy jest możliwość optymalizacji?

Zanim utworzony został indeks serwer musiał wykonać pełen skan tabeli.
Po utworzeniu indeksu serwer wykonał Index Scan do znalezienia odpowiednich wartości StoreID.

Przed dodaniem indexu: Table Scan
Po dodaniu indexu: Index Scan + RID Lookup

Koszt zapytania znacznie się zmniejszył, natomiast czas wykonania nieznacznie wzrósł.

Może to być spowodowane tym, że serwer musiał wykonać dodatkowe operacje związane z RID Lookup przy zapytaniu `select *`.
Można wykorzystać Covering index i zawrzeć pozostałe kolumny w indeksie (korzystając z INCLUDE), aby uniknąć dodatkowych operacji.
Można skorzystać z clustered index, aby przyspieszyć wyszukiwanie, bo serwer będzie korzystać z key lookup, które jest bardziej wydajne.
---
> Wyniki: 

```sql
--  ...
```


Dodaj indeks klastrowany:

```sql
CREATE clustered INDEX customer_store_cls_idx ON customer(storeid)
```

Czy zmienił się plan/koszt/czas? Skomentuj dwa podejścia w wyszukiwaniu krotek.


---
> Wyniki: 

```sql
--  ...
```


# Zadanie 4 - dodatkowe kolumny w indeksie

Celem zadania jest porównanie indeksów zawierających dodatkowe kolumny.

Skopiuj tabelę `Address` do swojej bazy danych:

```sql
SELECT * INTO address
FROM adventureworks2017.person.address
```

W tej części będziemy analizować następujące zapytanie:

```sql
SELECT addressline1,
    addressline2,
    city,
    stateprovinceid,
    postalcode
FROM address
WHERE postalcode BETWEEN n'98000' AND n'99999'
```

```sql
CREATE INDEX address_postalcode_1 ON address (postalcode) INCLUDE (
    addressline1,
    addressline2,
    city,
    stateprovinceid
);
GO

CREATE INDEX address_postalcode_2 ON address (
    postalcode,
    addressline1,
    addressline2,
    city,
    stateprovinceid
);
GO
```


Czy jest widoczna różnica w planach/kosztach zapytań? 
- w sytuacji gdy nie ma indeksów
- przy wykorzystaniu indeksu:
	- address_postalcode_1
	- address_postalcode_2
Jeśli tak to jaka? 

Aby wymusić użycie indeksu użyj `WITH(INDEX(Address_PostalCode_1))` po `FROM`

> Wyniki: 

```sql
--  ...
```

Sprawdź rozmiar Indeksów:

```sql
SELECT i.name AS indexname,
       SUM(s.used_page_count) * 8 AS indexsizekb
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.object_id = i.object_id
    AND s.index_id = i.index_id
WHERE i.name = 'address_postalcode_1'
    OR i.name = 'address_postalcode_2'
GROUP BY i.name
GO
```


Który jest większy? Jak można skomentować te dwa podejścia do indeksowania? Które kolumny na to wpływają?


> Wyniki: 

```sql
--  ...
```


# Zadanie 5 – Indeksy z filtrami

Celem zadania jest poznanie indeksów z filtrami.

Skopiuj tabelę `BillOfMaterials` do swojej bazy danych:

```sql
SELECT * INTO billofmaterials
FROM adventureworks2017.production.billofmaterials
```


W tej części analizujemy zapytanie:

```sql
SELECT productassemblyid,
       componentid,
       startdate
FROM billofmaterials
WHERE enddate IS NOT NULL
    AND componentid = 327
    AND startdate >= '2010-08-05'
```

Zastosuj indeks:

```sql
CREATE nonclustered INDEX billofmaterials_cond_idx ON billofmaterials (componentid, startdate)
WHERE enddate IS NOT NULL
```

Sprawdź czy działa.

Przeanalizuj plan dla poniższego zapytania:

Czy indeks został użyty? Dlaczego?

Indeks nie został użyty. Spełniał on warunek `enddate is not null`.
Możliwe, że serwer SQL nie użył indeksu, ponieważ nie byłoby to optymalne.

![img1.png](zad5/img1.png)

> Wyniki: 

```sql
SELECT productassemblyid,
       componentid,
       startdate
FROM billofmaterials
WHERE enddate IS NOT NULL
    AND componentid = 327
    AND startdate >= '2010-08-05'
14 rows retrieved starting from 1 in 66 ms (execution: 28 ms, fetching: 38 ms)
```

Spróbuj wymusić indeks. Co się stało, dlaczego takie zachowanie?

> Wyniki: 

```sql
SELECT productassemblyid,
       componentid,
       startdate
FROM billofmaterials WITH (INDEX(billofmaterials_cond_idx))
WHERE enddate IS NOT NULL
    AND componentid = 327
    AND startdate >= '2010-08-05';
14 rows retrieved starting from 1 in 29 ms (execution: 13 ms, fetching: 16 ms)
```

![img2.png](zad5/img2.png)

Po wymuszeniu indeksu plan zapytania zmienił się. Oznacza to, że serwer SQL poprzednio umyślnie nie użył indeksu, ponieważ nie byłoby to optymalne.
Jeśli porównamy koszt zapytania z indeksem i bez niego, to zauważymy, że koszt zapytania z indeksem jest wyższy.
Oznacza to, że istotinie serwer SQL umyślnie nie użył indeksu.


---

Punktacja:

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 3   |
| 2       | 3   |
| 3       | 3   |
| 4       | 3   |
| 5       | 3   |
| razem   | 15  |
|         |     |
