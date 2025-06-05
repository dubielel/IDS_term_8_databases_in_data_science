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

---

> Wyniki:

> ### Zapytanie
> 
> ```js
> db.orders.aggregate([
>   // Join customers
>   {
>     $lookup: {
>       from: "customers",
>       localField: "CustomerID",
>       foreignField: "CustomerID",
>       as: "customer",
>     },
>   },
>   { $unwind: "$customer" },
>   // Join employees
>   {
>     $lookup: {
>       from: "employees",
>       localField: "EmployeeID",
>       foreignField: "EmployeeID",
>       as: "employee",
>     },
>   },
>   { $unwind: "$employee" },
>   // Join shippers
>   {
>     $lookup: {
>       from: "shippers",
>       localField: "ShipVia",
>       foreignField: "ShipperID",
>       as: "shipper",
>     },
>   },
>   { $unwind: "$shipper" },
>   // Join orderdetails
>   {
>     $lookup: {
>       from: "orderdetails",
>       localField: "OrderID",
>       foreignField: "OrderID",
>       as: "order_details",
>     },
>   },
>   // Unwind orderdetails for further lookups
>   { $unwind: "$order_details" },
>   // Join products
>   {
>     $lookup: {
>       from: "products",
>       localField: "order_details.ProductID",
>       foreignField: "ProductID",
>       as: "product",
>     },
>   },
>   { $unwind: "$product" },
>   // Join categories
>   {
>     $lookup: {
>       from: "categories",
>       localField: "product.CategoryID",
>       foreignField: "CategoryID",
>       as: "category",
>     },
>   },
>   { $unwind: "$category" },
>   // Group by order to collect order details
>   {
>     $group: {
>       _id: "$OrderID",
>       OrderID: { $first: "$OrderID" },
>       Customer: {
>         $first: {
>           CustomerID: "$customer.CustomerID",
>           CompanyName: "$customer.CompanyName",
>           City: "$customer.City",
>           Country: "$customer.Country",
>         },
>       },
>       Employee: {
>         $first: {
>           EmployeeID: "$employee.EmployeeID",
>           FirstName: "$employee.FirstName",
>           LastName: "$employee.LastName",
>           Title: "$employee.Title",
>         },
>       },
>       Dates: {
>         $first: {
>           OrderDate: "$OrderDate",
>           RequiredDate: "$RequiredDate",
>         },
>       },
>       Freight: { $first: "$Freight" },
>       Shipment: {
>         $first: {
>           Shipper: {
>             ShipperID: "$shipper.ShipperID",
>             CompanyName: "$shipper.CompanyName",
>           },
>           ShipName: "$ShipName",
>           ShipAddress: "$ShipAddress",
>           ShipCity: "$ShipCity",
>           ShipCountry: "$ShipCountry",
>         },
>       },
>       Orderdetails: {
>         $push: {
>           UnitPrice: "$order_details.UnitPrice",
>           Quantity: "$order_details.Quantity",
>           Discount: "$order_details.Discount",
>           Value: {
>             $multiply: [
>               "$order_details.UnitPrice",
>               "$order_details.Quantity",
>               { $subtract: [1, "$order_details.Discount"] },
>             ],
>           },
>           product: {
>             ProductID: "$product.ProductID",
>             ProductName: "$product.ProductName",
>             QuantityPerUnit: "$product.QuantityPerUnit",
>             CategoryID: "$category.CategoryID",
>             CategoryName: "$category.CategoryName",
>           },
>         },
>       },
>     },
>   },
>   // Calculate OrderTotal
>   {
>     $addFields: {
>       OrderTotal: {
>         $sum: "$Orderdetails.Value",
>       },
>     },
>   },
>   // Unset _id field so that it is autogenerated
>   { $unset: "_id" },
>   // Save the results to `OrdersInfo` collection
>   { $out: "OrdersInfo" },
> ]);
> ```

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
      ... tablica zamówień klienta (oczywiście bez informacji o kliencie)
      {
        "_id": ...
        "OrderID": ... numer zamówienia
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
  }
]
```

```js
db.customers.aggregate([
  // Look up orders for each customer
  {
    $lookup: {
      from: "orders",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Orders",
    },
  },
  { $unwind: { path: "$Orders", preserveNullAndEmptyArrays: true } },
  // Look up employee for each order
  {
    $lookup: {
      from: "employees",
      localField: "Orders.EmployeeID",
      foreignField: "EmployeeID",
      as: "Employee",
    },
  },
  { $unwind: { path: "$Employee", preserveNullAndEmptyArrays: true } },
  // Look up orderdetails for each order
  {
    $lookup: {
      from: "orderdetails",
      localField: "Orders.OrderID",
      foreignField: "OrderID",
      as: "Orderdetails",
    },
  },
  // Unwind orderdetails to join products and categories
  { $unwind: { path: "$Orderdetails", preserveNullAndEmptyArrays: true } },
  {
    $lookup: {
      from: "products",
      localField: "Orderdetails.ProductID",
      foreignField: "ProductID",
      as: "Product",
    },
  },
  { $unwind: { path: "$Product", preserveNullAndEmptyArrays: true } },
  {
    $lookup: {
      from: "categories",
      localField: "Product.CategoryID",
      foreignField: "CategoryID",
      as: "Category",
    },
  },
  { $unwind: { path: "$Category", preserveNullAndEmptyArrays: true } },
  // Look up shipper for each order
  {
    $lookup: {
      from: "shippers",
      localField: "Orders.ShipVia",
      foreignField: "ShipperID",
      as: "Shipper",
    },
  },
  { $unwind: { path: "$Shipper", preserveNullAndEmptyArrays: true } },
  // Group orderdetails per order
  {
    $group: {
      _id: {
        customerId: "$CustomerID",
        orderId: "$Orders.OrderID",
      },
      CustomerID: { $first: "$CustomerID" },
      CompanyName: { $first: "$CompanyName" },
      City: { $first: "$City" },
      Country: { $first: "$Country" },
      OrderID: { $first: "$Orders.OrderID" },
      Employee: {
        $first: {
          EmployeeID: "$Employee.EmployeeID",
          FirstName: "$Employee.FirstName",
          LastName: "$Employee.LastName",
          Title: "$Employee.Title",
        },
      },
      Dates: {
        $first: {
          OrderDate: "$Orders.OrderDate",
          RequiredDate: "$Orders.RequiredDate",
        },
      },
      Freight: { $first: "$Orders.Freight" },
      Shipment: {
        $first: {
          Shipper: {
            ShipperID: "$Shipper.ShipperID",
            CompanyName: "$Shipper.CompanyName",
          },
          ShipName: "$Orders.ShipName",
          ShipAddress: "$Orders.ShipAddress",
          ShipCity: "$Orders.ShipCity",
          ShipCountry: "$Orders.ShipCountry",
        },
      },
      Orderdetails: {
        $push: {
          UnitPrice: "$Orderdetails.UnitPrice",
          Quantity: "$Orderdetails.Quantity",
          Discount: "$Orderdetails.Discount",
          Value: {
            $multiply: [
              "$Orderdetails.UnitPrice",
              "$Orderdetails.Quantity",
              { $subtract: [1, "$Orderdetails.Discount"] },
            ],
          },
          product: {
            ProductID: "$Product.ProductID",
            ProductName: "$Product.ProductName",
            QuantityPerUnit: "$Product.QuantityPerUnit",
            CategoryID: "$Category.CategoryID",
            CategoryName: "$Category.CategoryName",
          },
        },
      },
    },
  },
  // Calculate OrderTotal
  {
    $addFields: {
      OrderTotal: { $sum: "$Orderdetails.Value" },
    },
  },
  // Group orders per customer
  {
    $group: {
      _id: "$CustomerID",
      CustomerID: { $first: "$CustomerID" },
      CompanyName: { $first: "$CompanyName" },
      City: { $first: "$City" },
      Country: { $first: "$Country" },
      Orders: {
        $push: {
          OrderID: "$OrderID",
          Employee: "$Employee",
          Dates: "$Dates",
          Orderdetails: "$Orderdetails",
          Freight: "$Freight",
          OrderTotal: "$OrderTotal",
          Shipment: "$Shipment",
        },
      },
    },
  },
  { $unset: "_id" },
  { $out: "CustomerInfo" },
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
