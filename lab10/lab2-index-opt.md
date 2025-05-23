# Indeksy, optymalizator <br>Lab 2

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

**Imię i nazwisko: Kacper Cienkosz, Miłosz Dubiel**

---

Celem ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans), oraz z budową i możliwością wykorzystaniem indeksów

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---

> Wyniki:

```sql
--  ...
```

---

Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki, (dołącz kod rozwiązania w formie tekstowej/źródłowej)

Zwróć uwagę na formatowanie kodu

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie

- MS SQL Server
- SSMS - SQL Server Management Studio
  - ewentualnie inne narzędzie umożliwiające komunikację z MS SQL Server i analizę planów zapytań
- przykładowa baza danych AdventureWorks2017.

Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej

## Przygotowanie

Uruchom Microsoft SQL Managment Studio.

Stwórz swoją bazę danych o nazwie lab2.

```sql
CREATE DATABASE lab2
GO

USE lab2
GO
```

Przydatne wywołania w MSSQL:

```sql
SET STATISTICS IO ON
SET STATISTICS TIME ON

-- Use this when you want to clear the cache
-- Recommended after each query
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS
```

<div style="page-break-after: always;"></div>

# Zadanie 1

Skopiuj tabelę `Person` do swojej bazy danych:

```sql
SELECT businessentityid,
       persontype,
       namestyle,
       title,
       firstname,
       middlename,
       lastname,
       suffix,
       emailpromotion,
       rowguid,
       modifieddate
INTO person
FROM adventureworks2017.person.person
```

---

Wykonaj analizę planu dla trzech zapytań:

```sql
SELECT *
FROM [ person ]
WHERE lastname = 'Agbonile'

SELECT *
FROM [ person ]
WHERE lastname = 'Agbonile'
    AND firstname = 'Osarumwense'

SELECT *
FROM [ person ]
WHERE firstname = 'Osarumwense'
```

Co można o nich powiedzieć?

---

> Wyniki:

```sql
--  ...
```

Przygotuj indeks obejmujący te zapytania:

```sql
CREATE INDEX person_first_last_name_idx
ON person(lastname, firstname)
```

Sprawdź plan zapytania. Co się zmieniło?

---

> Wyniki:

```sql
--  ...
```

Przeprowadź ponownie analizę zapytań tym razem dla parametrów: `FirstName = ‘Angela’` `LastName = ‘Price’`. (Trzy zapytania, różna kombinacja parametrów).

Czym różni się ten plan od zapytania o `'Osarumwense Agbonile'` . Dlaczego tak jest?

---

> Wyniki:

```sql
--  ...
```

# Zadanie 2

Skopiuj tabelę Product do swojej bazy danych:

```sql
SELECT * INTO product
FROM adventureworks2017.production.product
```

Stwórz indeks z warunkiem przedziałowym:

```sql
CREATE nonclustered INDEX product_range_idx
ON product (productsubcategoryid, listprice) INCLUDE (name)
WHERE productsubcategoryid >= 27
    AND productsubcategoryid <= 36
```

Sprawdź, czy indeks jest użyty w zapytaniu:

```sql
SELECT name,
       productsubcategoryid,
       listprice
FROM product
WHERE productsubcategoryid >= 27
    AND productsubcategoryid <= 36
```

Sprawdź, czy indeks jest użyty w zapytaniu, który jest dopełnieniem zbioru:

```sql
SELECT name,
       productsubcategoryid,
       listprice
FROM product
WHERE productsubcategoryid < 27
    OR productsubcategoryid > 36
```

Skomentuj oba zapytania. Czy indeks został użyty w którymś zapytaniu, dlaczego? Jak działają indeksy z warunkiem?

---

> Wyniki:

```sql
--  ...
```

# Zadanie 3

Skopiuj tabelę `PurchaseOrderDetail` do swojej bazy danych:

```sql
SELECT *
INTO purchaseorderdetail
FROM adventureworks2017.purchasing.purchaseorderdetail
```

Wykonaj analizę zapytania:

```sql
SELECT rejectedqty,
       ((rejectedqty / orderqty) * 100) AS rejectionrate,
       productid,
       duedate
FROM purchaseorderdetail
ORDER BY rejectedqty DESC, productid ASC
```

Która część zapytania ma największy koszt?

---

> Wyniki:

```sql
--  ...
```

Jaki indeks można zastosować aby zoptymalizować koszt zapytania? Przygotuj polecenie tworzące index.

---

> Wyniki:

```sql
--  ...
```

Ponownie wykonaj analizę zapytania:

---

> Wyniki:

```sql
--  ...
```

# Zadanie 4 – indeksy column store

Celem zadania jest poznanie indeksów typu column store

Utwórz tabelę testową:

```sql
CREATE TABLE dbo.saleshistory(
    salesorderid INT NOT NULL,
    salesorderdetailid INT NOT NULL,
    carriertrackingnumber NVARCHAR(25) NULL,
    orderqty SMALLINT NOT NULL,
    productid INT NOT NULL,
    specialofferid INT NOT NULL,
    unitprice MONEY NOT NULL,
    unitpricediscount MONEY NOT NULL,
    linetotal NUMERIC(38, 6) NOT NULL,
    rowguid UNIQUEIDENTIFIER NOT NULL,
    modifieddate DATETIME NOT NULL
)
```

Załóż indeks:

```sql
CREATE clustered INDEX saleshistory_idx
ON saleshistory(salesorderdetailid)
```

Wypełnij tablicę danymi:

(UWAGA `GO 100` oznacza 100 krotne wykonanie polecenia. Jeżeli podejrzewasz, że Twój serwer może to zbyt przeciążyć, zacznij od GO 10, GO 20, GO 50 (w sumie już będzie 80))

```sql
INSERT INTO saleshistory
SELECT sh. *
FROM adventureworks2017.sales.salesorderdetail sh
GO 100
```

Sprawdź jak zachowa się zapytanie, które używa obecny indeks:

```sql
SELECT productid,
       SUM(unitprice),
       AVG(unitprice),
       SUM(orderqty),
       AVG(orderqty)
FROM saleshistory
GROUP BY productid
ORDER BY productid
```

Załóż indeks typu column store:

```sql
CREATE NONCLUSTERED COLUMNSTORE INDEX saleshistory_columnstore
ON saleshistory(unitprice, orderqty, productid)
```

Sprawdź różnicę pomiędzy przetwarzaniem w zależności od indeksów. Porównaj plany i opisz różnicę.
Co to są indeksy colums store? Jak działają? (poszukaj materiałów w internecie/literaturze)

---

> Wyniki:

```sql
--  ...
```

# Zadanie 5 – własne eksperymenty

Należy zaprojektować tabelę w bazie danych, lub wybrać dowolny schemat danych (poza używanymi na zajęciach), a następnie wypełnić ją danymi w taki sposób, aby zrealizować poszczególne punkty w analizie indeksów. Warto wygenerować sobie tabele o większym rozmiarze.

Do analizy, proszę uwzględnić następujące rodzaje indeksów:

- Klastrowane (np.  dla atrybutu nie będącego kluczem głównym)
- Nieklastrowane
- Indeksy wykorzystujące kilka atrybutów, indeksy include
- Filtered Index (Indeks warunkowy)
- Kolumnowe

## Analiza

Proszę przygotować zestaw zapytań do danych, które:

- wykorzystują poszczególne indeksy
- które przy wymuszeniu indeksu działają gorzej, niż bez niego (lub pomimo założonego indeksu, tabela jest w pełni skanowana)
  Odpowiedź powinna zawierać:
- Schemat tabeli
- Opis danych (ich rozmiar, zawartość, statystyki)
- Opis indeksu
- Przygotowane zapytania, wraz z wynikami z planów (zrzuty ekranow)
- Komentarze do zapytań, ich wyników
- Sprawdzenie, co proponuje Database Engine Tuning Advisor (porównanie czy udało się Państwu znaleźć odpowiednie indeksy do zapytania)

> Wyniki:

```sql
--  ...
```

|         |     |     |
| ------- | --- | --- |
| zadanie | pkt |     |
| 1       | 2   |     |
| 2       | 2   |     |
| 3       | 2   |     |
| 4       | 2   |     |
| 5       | 5   |     |
| razem   | 15  |     |
