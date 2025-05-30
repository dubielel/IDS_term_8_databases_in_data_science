# Dokumentowe bazy danych – MongoDB

Ćwiczenie/zadanie

---

**Imiona i nazwiska autorów: Kacper Cienkosz, Miłosz Dubiel**

---

Odtwórz z backupu bazę `north0`

```
mongorestore --nsInclude='north0.*' ./dump/
```

```
use north0
```

Baza `north0` jest kopią relacyjnej bazy danych `Northwind`

- poszczególne kolekcje odpowiadają tabelom w oryginalnej bazie `Northwind`

# Wprowadzenie

zapoznaj się ze strukturą dokumentów w bazie `North0`

```js
db.customers.find();
db.orders.find();
db.orderdetails.find();
```

# Operacje wyszukiwania danych, przetwarzanie dokumentów

# Zadanie 1

stwórz kolekcję `OrdersInfo` zawierającą następujące dane o zamówieniach

- kolekcję `OrdersInfo` należy stworzyć przekształcając dokumenty w oryginalnych kolekcjach `customers, orders, orderdetails, employees, shippers, products, categories, suppliers` do kolekcji w której pojedynczy dokument opisuje jedno zamówienie

```js
[
  {
    "_id": ...

    "OrderID": ... numer zamówienia

    "Customer": {  ... podstawowe informacje o kliencie skladającym
      "CustomerID": ... identyfikator klienta
      "CompanyName": ... nazwa klienta
      "City": ... miasto
      "Country": ... kraj
    },

    "Employee": {  ... podstawowe informacje o pracowniku obsługującym zamówienie
      "EmployeeID": ... idntyfikator pracownika
      "FirstName": ... imie
      "LastName": ... nazwisko
      "Title": ... stanowisko

    },

    "Dates": {
       "OrderDate": ... data złożenia zamówienia
       "RequiredDate": data wymaganej realizacji
    }

    "Orderdetails": [  ... pozycje/szczegóły zamówienia - tablica takich pozycji
      {
        "UnitPrice": ... cena
        "Quantity": ... liczba sprzedanych jednostek towaru
        "Discount": ... zniżka
        "Value": ... wartośc pozycji zamówienia
        "product": { ... podstawowe informacje o produkcie
          "ProductID": ... identyfikator produktu
          "ProductName": ... nazwa produktu
          "QuantityPerUnit": ... opis/opakowannie
          "CategoryID": ... identyfikator kategorii do której należy produkt
          "CategoryName" ... nazwę tej kategorii
        },
      },
      ...
    ],

    "Freight": ... opłata za przesyłkę
    "OrderTotal"  ... sumaryczna wartosc sprzedanych produktów

    "Shipment" : {  ... informacja o wysyłce
        "Shipper": { ... podstawowe inf o przewoźniku
           "ShipperID":
            "CompanyName":
        }
        ... inf o odbiorcy przesyłki
        "ShipName": ...
        "ShipAddress": ...
        "ShipCity": ...
        "ShipCountry": ...
    }
  }
]
```

```js
db.orders.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Customer"
    }
  },
  {
    $unwind: "$Customer"
  },
  {
    $lookup: {
      from: "employees",
      localField: "EmployeeID",
      foreignField: "EmployeeID",
      as: "Employee"
    }
  },
  {
    $unwind: "$Employee"
  },
  {
    $lookup: {
      from: "orderdetails",
      localField: "OrderID",
      foreignField: "OrderID",
      as: "Orderdetails"
    }
  },
  {
    $lookup: {
      from: "products",
      localField: "Orderdetails.ProductID",
      foreignField: "ProductID",
      as: "Products"
    }
  },
  {
    $lookup: {
      from: "categories",
      localField: "Products.CategoryID",
      foreignField: "CategoryID",
      as: "Categories"
    }
  },
  {
    $lookup: {
      from: "shippers",
      localField: "ShipVia",
      foreignField: "ShipperID",
      as: "Shipper"
    }
  },
  {
    $unwind: "$Shipper"
  },
  {
    $project: {
      _id: 0,
      OrderID: 1,
      Customer: {
        CustomerID: "$Customer.CustomerID",
        CompanyName: "$Customer.CompanyName",
        City: "$Customer.City",
        Country: "$Customer.Country"
      },
      Employee: {
        EmployeeID: "$Employee.EmployeeID",
        FirstName: "$Employee.FirstName",
        LastName: "$Employee.LastName",
        Title: "$Employee.Title"
      },
      Dates: {
        OrderDate: "$OrderDate",
        RequiredDate: "$RequiredDate"
      },
      Orderdetails: {
        $map: {
          input: "$Orderdetails",
          as: "detail",
          in: {
            UnitPrice: "$$detail.UnitPrice",
            Quantity: "$$detail.Quantity",
            Discount: "$$detail.Discount",
            Value: {
              $multiply: [
                "$$detail.UnitPrice",
                "$$detail.Quantity",
                { $subtract: [1, "$$detail.Discount"] }
              ]
            },
            product: {
              ProductID: "$$detail.ProductID",
              ProductName: {
                $arrayElemAt: [
                  "$Products.ProductName",
                  { $indexOfArray: ["$Products.ProductID", "$$detail.ProductID"] }
                ]
              },
              QuantityPerUnit: {
                $arrayElemAt: [
                  "$Products.QuantityPerUnit",
                  { $indexOfArray: ["$Products.ProductID", "$$detail.ProductID"] }
                ]
              },
              CategoryID: {
                $arrayElemAt: [
                  "$Products.CategoryID",
                  { $indexOfArray: ["$Products.ProductID", "$$detail.ProductID"] }
                ]
              },
              CategoryName: {
                $arrayElemAt: [
                  "$Categories.CategoryName",
                  { $indexOfArray: ["$Categories.CategoryID", "$$detail.CategoryID"] }
                ]
              }
            }
          }
        }
      },
      Freight: "$Freight",
      OrderTotal: {
        $sum: {
          $map: {
            input: "$Orderdetails",
            as: "detail",
            in: {
              $multiply: [
                "$$detail.UnitPrice",
                "$$detail.Quantity",
                { $subtract: [1, "$$detail.Discount"] }
              ]
            }
          }
        }
      },
      Shipment: {
        Shipper: {
          ShipperID: "$Shipper.ShipperID",
          CompanyName: "$Shipper.CompanyName"
        },
        ShipName: "$ShipName",
        ShipAddress: "$ShipAddress",
        ShipCity: "$ShipCity",
        ShipCountry: "$ShipCountry"
      }
    }
  },
  {
    $out: "OrdersInfo"
  }
]);
```

# Zadanie 2

stwórz kolekcję `CustomerInfo` zawierającą następujące dane o każdym kliencie

- pojedynczy dokument opisuje jednego klienta

```js
[
  {
    "_id": ...

    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
    "City": ... miasto
    "Country": ... kraj

	  "Orders": [
      ... tablica zamówień klienta o strukturze takiej jak w punkcie a) (oczywiście bez informacji o kliencie)
    ]
  }

]
```

```js
db.customers.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Orders"
    }
  },
  {
    $unwind: {
      path: "$Orders",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "employees",
      localField: "Orders.EmployeeID",
      foreignField: "EmployeeID",
      as: "Orders.Employee"
    }
  },
  {
    $unwind: {
      path: "$Orders.Employee",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "orderdetails",
      localField: "Orders.OrderID",
      foreignField: "OrderID",
      as: "Orders.Orderdetails"
    }
  },
  {
    $lookup: {
      from: "shippers",
      localField: "Orders.ShipVia",
      foreignField: "ShipperID",
      as: "Orders.Shipper"
    }
  },
  {
    $unwind: {
      path: "$Orders.Shipper",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $group: {
      _id: "$CustomerID", // Trzeba zminić ID na generowane losowo
      CustomerID: { $first: "$CustomerID" },
      CompanyName: { $first: "$CompanyName" },
      City: { $first: "$City" },
      Country: { $first: "$Country" },
      Orders: {
        $push: {
          OrderID: "$Orders.OrderID",
          Employee: {
            EmployeeID: "$Orders.Employee.EmployeeID",
            FirstName: "$Orders.Employee.FirstName",
            LastName: "$Orders.Employee.LastName",
            Title: "$Orders.Employee.Title"
          },
          Dates: {
            OrderDate: "$Orders.OrderDate",
            RequiredDate: "$Orders.RequiredDate"
          },
          Orderdetails: "$Orders.Orderdetails",
          Freight: "$Orders.Freight",
          Shipment: {
            Shipper: {
              ShipperID: "$Orders.Shipper.ShipperID",
              CompanyName: "$Orders.Shipper.CompanyName"
            },
            ShipName: "$Orders.ShipName",
            ShipAddress: "$Orders.ShipAddress",
            ShipCity: "$Orders.ShipCity",
            ShipCountry: "$Orders.ShipCountry"
          }
        }
      }
    }
  },
  {
    $out: "CustomerInfo"
  }
]);
```

# Zadanie 3

Napisz polecenie/zapytanie: Dla każdego klienta pokaż wartość zakupionych przez niego produktów z kategorii 'Confections' w 1997r

- Spróbuj napisać to zapytanie wykorzystując

- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
- kolekcję `OrderInfo`
- kolekcję `CustomerInfo`

Porównaj zapytania/polecenia/wyniki.

Zamieść odpowiedni komentarz

Które wersje zapytań były "prostsze"?

```js
[
  {
    "_id":
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
	  "ConfectionsSale97": ... wartość zakupionych przez niego produktów z kategorii 'Confections'  w 1997r
  }
]
```

# Zadanie 4

Napisz polecenie/zapytanie: Dla każdego klienta podaj wartość sprzedaży z podziałem na lata i miesiące

Spróbuj napisać to zapytanie wykorzystując

- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
- kolekcję `OrderInfo`
- kolekcję `CustomerInfo`

Porównaj zapytania/polecenia/wyniki.

Zamieść odpowiedni komentarz

Które wersje zapytań były "prostsze"?

```js
[
  {
    "_id":

    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta

	  "Sale": [ ... tablica zawierająca inf o sprzedazy
	    {
            "Year":  ....
            "Month": ....
            "Total": ...
	    }
	    ...
	  ]
  }
]
```

---

Punktacja:

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 3   |
| 2       | 3   |
| 3       | 3   |
| 4       | 3   |
| razem   | 12  |
