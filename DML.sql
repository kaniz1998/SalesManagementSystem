USE SalesDB
GO

-----SELECT------
SELECT * FROM Category
SELECT * FROM Products
SELECT * FROM Suppliers
SELECT * FROM Stock
SELECT * FROM Customers
SELECT * FROM Orders
GO

------INSERT VALUES----
INSERT INTO Category(CategoryID,CategoryName)
VALUES(1,'Mobile'),
      (2,'Tablet'),
      (3,'Camera'),
      (4,'Laptop'),
      (5,'Desktop');
GO

INSERT INTO Products(ProductID,ProductName,CategoryID,UnitPrice)
VALUES(1,'Asus',4,45000),
      (2,'Sumsang',2,15000),
	  (3,'Canon',3,40000),
	  (4,'Sony',3,70000),
	  (5,'Nokia',1,20000),
	  (6,'Gigabyte',5,25000),
	  (7,'HP',4,60000),
	  (8,'Sumsang',1,35000),
      (9,'Dell',5,45000),
	  (10,'Philips',5,30000);
GO

INSERT INTO Suppliers(SupplierID,SupplierName,SupplierAddress,SupplierPhone)
VALUES(1,'Galaxy Electro Power Ltd.','Dhaka','01859878021'),
      (2,'Lion Electronics (Pvt.) Ltd.','Dhaka','01950850056'),
	  (3,'Wave Electronics','Dhaka','01521787267'),
	  (4,'Transcom','Dhaka','01740280022');
GO

INSERT INTO Stock(StockID,SupplierID,CategoryID,ProductID,ProductName,Quantity,Status)
VALUES(1,2,5,9,'Dell',2,'In'),
      (2,1,3,3,'Canon',5,'In'),
	  (3,3,1,5,'Nokia',7,'In'),
	  (4,4,5,6,'Gigabyte',3,'In'),
	  (5,4,5,10,'Philips',2,'In'),
	  (6,3,2,2,'Sumsang',0,'Out'),
	  (7,2,4,7,'HP',1,'In'),
	  (8,3,1,8,'Sumsang',4,'In'),
	  (9,1,3,4,'Sony',3,'In');
GO

INSERT INTO Customers(CustomerID,CustomerName,CustomerAddress,CustomerPhone)
VALUES(1,'Neoyaz Sharif','Dhaka','01793478021'),
      (2,'Faisal Ahmed','Dhaka','01950855556'),
	  (3,'Adnan Rabby','Dhaka','01521234567'),
	  (4,'Rezaur Rahman','Dhaka','01962846022');
GO

INSERT INTO Orders(OrderID,OrderDate,CustomerID,CustomerName,ProductID,StockID,Quantity,UnitPrice,Vat)
VALUES(1,'2022-07-21',2,'Faisal Ahmed',4,9,1,70000,0.15),
      (2,'2022-09-25',4,'Rezaur Rahman',7,7,1,60000,0.15),
	  (3,'2022-11-29',3,'Adnan Rabby',3,2,1,15000,0.15),
	  (4,'2022-12-17',1,'Neoyaz Sharif',5,5,1,20000,0.15),
	  (5,'2023-01-25',2,'Faisal Ahmed',9,9,1,45000,0.15),
	  (6,'2023-02-21',1,'Neoyaz Sharif',6,6,1,25000,0.15),
	  (7,'2023-03-03',1,'Neoyaz Sharif',8,8,1,35000,0.15);
GO

------UPDATE----
UPDATE Category 
SET CategoryName ='TV'
WHERE CategoryID = 5;
GO

------DELETE-----
DELETE From Category 
WHERE CategoryID = 5;
GO

-----SELECT/DISTINCT/ORDER BY----
SELECT CustomerID,CustomerName 
FROM Customers;

SELECT DISTINCT CustomerAddress 
FROM Customers;

SELECT * 
FROM Products 
ORDER BY ProductName DESC;
GO

----TOP---
SELECT TOP 5 *
FROM Products
WHERE UnitPrice >=25000
ORDER BY ProductID DESC
GO

-----BETWEEN/AND-----
SELECT *
FROM Orders
WHERE OrderDate BETWEEN '2022-07-01' AND '2023-03-01';
GO

-----OR-----
SELECT *
FROM Orders
WHERE OrderDate > '2023-03-01' OR UnitPrice > 25000;
GO

-----NOT-----
SELECT *
FROM Orders
WHERE NOT UnitPrice > 25000;
GO

-----IN-----
SELECT CustomerName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Orders);
GO

-----LIKE-----
SELECT * 
FROM Suppliers
WHERE SupplierAddress LIKE 'Dha%';
GO

-----JOIN----
SELECT Cu.CustomerName,Pr.ProductName,OrderDate,St.Quantity,Pr.UnitPrice  
FROM Orders Ord
join Customers Cu
on Cu.CustomerID = Ord.CustomerID
join Stock St
on St.StockID= Ord.StockID
join Products Pr
on St.ProductID = Pr.ProductID
where ProductName = 'Nokia'
ORDER BY Ord.OrderID
GO

-----UNION-----
SELECT ProductID AS SaledProduct FROM Products
UNION
SELECT ProductID AS SaledProduct FROM Orders;
GO

-----AGGREGRATE FUNCTIONS-----

----COUNT FUNCTION
SELECT COUNT(CustomerID),CustomerName 
FROM Customers 
GROUP BY CustomerName;
GO

----AVERAGE OF QUANTITY
SELECT AVG(ProductID) AS AvgOfProducts
FROM Products 
GROUP BY ProductID;
GO

----SUM OF QUANTITY
SELECT StockID, SUM(Quantity) AS AveOfStock
FROM Stock 
GROUP BY StockID;
GO

-----GROUP BY & HAVING-----
SELECT Stock.ProductID,Orders.Quantity,UnitPrice,
(Unitprice * Orders.Quantity) AS TotalPrice, Vat,
SUM(Unitprice *Orders.Quantity * Vat) AS TotalVat
FROM Orders
JOIN Stock
ON Stock.ProductID = Orders.ProductID
GROUP BY Stock.ProductID,UnitPrice,Orders.Quantity,Vat
HAVING SUM(Unitprice * Orders.Quantity * Vat) <> 0;
GO

-----ROLLUP-----
SELECT SupplierName, SupplierAddress
FROM Suppliers
WHERE SupplierAddress IN ('Dhaka')
GROUP BY SupplierName, SupplierAddress WITH ROLLUP;
GO

-----CUBE-----
SELECT SupplierName, SupplierAddress
FROM Suppliers
WHERE SupplierAddress IN ('Dhaka')
GROUP BY SupplierName, SupplierAddress WITH CUBE;
GO

-----GROUPING SETS-----
SELECT SupplierName, SupplierAddress
FROM Suppliers
WHERE SupplierAddress IN ('Dhaka')
GROUP BY GROUPING SETS (SupplierName, SupplierAddress);
GO

------OVER-----
SELECT ProductId,Quantity,OrderDate, 
COUNT(*) OVER(PARTITION BY Quantity) AS OverColumn
FROM Orders;

-----SUB QUERY----
SELECT Stock.ProductID,Orders.Quantity,UnitPrice,
(Unitprice * Orders.Quantity) AS TotalPrice, Vat,
SUM(Unitprice *Orders.Quantity * Vat) AS TotalVat
FROM Orders
JOIN Stock
ON Stock.ProductID = Orders.ProductID
GROUP BY Stock.ProductID,UnitPrice,Orders.Quantity,Vat
HAVING SUM(Unitprice * Orders.Quantity * Vat) <> 0;
GO

------ALL-----
SELECT CustomerName, ProductName, OrderDate
FROM Orders JOIN Stock 
ON Orders.ProductID=Stock.ProductID
WHERE UnitPrice > ALL
                     (SELECT UnitPrice
					 FROM Orders
					 WHERE ProductID=9)
ORDER BY CustomerName;

-----ANY-----
SELECT CustomerName, ProductName, OrderDate
FROM Orders JOIN Stock 
ON Orders.ProductID=Stock.ProductID
WHERE UnitPrice < ANY
                    (SELECT UnitPrice 
					FROM Orders
					WHERE ProductID=5);
GO

----SOME----
SELECT CustomerName, ProductName, OrderDate
FROM Orders JOIN Stock 
ON Orders.ProductID=Stock.ProductID
WHERE UnitPrice < SOME
                    (SELECT UnitPrice 
					FROM Orders
					WHERE ProductID=5);
GO

-----EXIST-----
SELECT * FROM Orders
WHERE EXISTS(
			SELECT *
			FROM Products
			WHERE Products.ProductID = Orders.ProductID
			);
GO

-----CTE-----
WITH CTE_JoinQuery
AS(
SELECT Cu.CustomerName,Pr.ProductName,OrderDate,St.Quantity,Pr.UnitPrice  
FROM Orders Ord
join Customers Cu
on Cu.CustomerID = Ord.CustomerID
join Products Pr
on Pr.ProductID = Ord.ProductID
join Stock St
on St.StockID= Ord.StockID
where ProductName = 'Nokia'
)
SELECT *
FROM CTE_JoinQuery;

-----MERGE------
CREATE TABLE Category_Merge
(
CategoryID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
CategoryName VARCHAR(50) 
);

MERGE INTO Category_Merge M
USING dbo.Category AS C
ON M.CategoryID=C.CategoryID
WHEN MATCHED THEN 
UPDATE SET M.CategoryName=C.CategoryName
WHEN NOT MATCHED THEN
INSERT(CategoryName)
VALUES (C.CategoryName);
GO

------CAST-----
SELECT CAST('2023-Jun-01' AS DATE)
GO

-----CONVERT-----
SELECT DATETIME =CONVERT(DATETIME, '12-JUNE-2023 10:20:17')
GO

-----CASE----
SELECT CASE
    WHEN Status ='In' THEN 'Good'
    WHEN Status ='Out' THEN 'Bad'
    ELSE 'Not Found'
END AS StockInfo
FROM Stock
GROUP BY Status;
GO

----IIF----
SELECT ProductName,
IIF (Quantity > 3,'Good','Bad') AS StockUpdate
FROM Stock;
GO

-----CHOOSE-----
SELECT CHOOSE (ProductID,'Saled','Not Saled') AS SaledProduct
FROM Products;
GO

-----STRING FUNCTIONS----
SELECT CONCAT('Hello', ' ', 'World') AS Result;
SELECT LEN('Hello') AS Result;
SELECT SUBSTRING('Hello World', 7, 5) AS Result;
SELECT UPPER('hello') AS Result;
SELECT LOWER('WORLD') AS Result;
SELECT TRIM('   Hello   ') AS Result;
SELECT REPLACE('Hello World', 'World', 'John') AS Result;
SELECT CHARINDEX('World', 'Hello World') AS Result;
SELECT LEFT('Hello World', 5) AS Result;
SELECT RIGHT('Hello World', 5) AS Result;
GO
