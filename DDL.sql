-------CREATE DATABASE------
DROP DATABASE SalesDB
GO

CREATE DATABASE SalesDB
ON PRIMARY  
(
NAME ='Sales_DATA_1',  
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Sales_DATA_1.mdf',
Size=25MB, 
Maxsize=100MB , 
Filegrowth=5%
)
LOG ON 
(
NAME ='Sales_Log_1', 
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Sales_LOG_1.ldf',
Size=2MB, 
Maxsize=50MB , 
Filegrowth=1%
);
GO

------USE DATABASE------
USE SalesDB
GO

----CREATE TABLES-----
CREATE TABLE Category
(
CategoryID int Primary Key,
CategoryName varchar(50)
);
GO

CREATE TABLE Products
(
ProductID int Primary Key,
ProductName varchar(50) ,
CategoryID int References Category(CategoryID),
UnitPrice money 
);
GO

CREATE TABLE Suppliers
(
SupplierID int Primary Key,
SupplierName varchar(50),
SupplierAddress varchar(50),
SupplierPhone int
);
GO

CREATE TABLE Stock
(
StockID int Primary Key,
SupplierID int References Suppliers(SupplierID),
CategoryID int References Category(CategoryID),
ProductID int References Products(ProductID),
ProductName varchar(50),
Quantity int,
Available bit
);
GO

CREATE TABLE Customers
(
CustomerID int Primary Key,
CustomerName varchar(50),
CustomerAddress varchar(50),
CustomerPhone int
);
GO

-----TRANSACTION TABLE----
CREATE TABLE Orders
(
OrderID int,
OrderDate datetime,
CustomerID int References Customers(CustomerID),
CustomerName varchar(50),
ProductID int References Products(ProductID),
StockID int References Stock(StockID),
Quantity int,
UnitPrice money,
Vat numeric(18,3)
);
GO

--------CLUSTERED INDEX-----
CREATE CLUSTERED INDEX IX_OrderDate
ON Orders(OrderDate);
GO

-----NONCLUSTERED INDEX----
CREATE NONCLUSTERED INDEX IX_Orders_Quantity
ON Orders(Quantity);
GO

-----ALTER,MODIFY AND DROP-----

ALTER TABLE Orders ADD CategoryID int;

ALTER TABLE Orders DROP COLUMN CategoryID;

ALTER TABLE Stock DROP COLUMN Available;

ALTER TABLE Stock ADD Status varchar(10);

ALTER TABLE Suppliers 
ADD CONSTRAINT SupplierAddress
DEFAULT 'Dhaka' FOR SupplierAddress;

DROP DATABASE SalesDB;
DROP TABLE Orders;
DROP INDEX IX_OrderDate;
GO

--------CREATE A VIEW-------------

--VIEW WITH ENCRYPTION
CREATE VIEW Encryp_Stock
WITH ENCRYPTION
AS
SELECT StockID,Quantity 
FROM Stock;
GO

--VIEW WITH SCHEMABINDING
CREATE VIEW Schema_Stock
WITH SCHEMABINDING
AS
SELECT StockID,Quantity 
FROM dbo.Stock
GO

--VIEW WITH SCHEMABINDING, ENCRYPTION
CREATE VIEW VW_PlantingDetails
WITH SCHEMABINDING, ENCRYPTION
AS
SELECT StockID,Quantity 
FROM dbo.Stock
GO

-----------User-Defined Functions---------------

--A SIMPLE TABLE VALUED FUNCTION
CREATE FUNCTION Fn_Category()
RETURNS TABLE
RETURN
(
SELECT CategoryID,CategoryName
FROM Category
)
GO
SELECT * FROM dbo.Fn_Category()
GO

----A SCALAR FUNCTION
CREATE FUNCTION Sc_Category()
RETURNS INT
BEGIN 
DECLARE @C INT
SELECT @C=COUNT(*) FROM Category
RETURN @C
END
GO
SELECT dbo.Sc_Category()
GO

----A MULTISTATEMENT TABLE VALUED FUNCTION-----
CREATE FUNCTION Mlst_Products()
RETURNS @PriceUpdate TABLE
(
ProductID int,
UnitPrice money,
UnitPrice_Extra money)
AS
BEGIN
  INSERT INTO @PriceUpdate(ProductID,UnitPrice,UnitPrice_Extra)
  SELECT ProductID,UnitPrice,UnitPrice=UnitPrice+500
  FROM Products;
RETURN
END
GO
SELECT * FROM dbo.Mlst_Products();
GO

----STORED PROCEDURE SELECT-INSERT-UPDATE-DELETE----
SELECT * FROM Category
GO
CREATE PROCEDURE SP_SelectInsertUpdateDeleteCategory
(
@CategoryID INT,
@CategoryName VARCHAR(100),    
@StatementType NVARCHAR(20) = '')
AS
IF @StatementType = 'SELECT'
BEGIN
SELECT * FROM Category
END

IF @StatementType = 'INSERT'
BEGIN
INSERT INTO Category(CategoryID, CategoryName)
VALUES (@CategoryID, @CategoryName)
END

IF @StatementType = 'UPDATE'
BEGIN
UPDATE Category
SET CategoryName = @CategoryName
WHERE CategoryID = @CategoryID
END

IF @StatementType = 'DELETE'
BEGIN
DELETE Category
WHERE CategoryID = @CategoryID
END
----TEST PROCEDURE
EXECUTE SP_SelectInsertUpdateDeleteCategory 6,'TV','INSERT'
EXECUTE SP_SelectInsertUpdateDeleteCategory 6, 'UPS','UPDATE'
EXECUTE SP_SelectInsertUpdateDeleteCategory 6,'TV','DELETE'
GO

--------CREATE STORED PROCEDURE USING PARAMETER-------
-----INPUT
CREATE PROC SP_Input
@CategoryID INT,
@CategoryName VARCHAR(50)
AS
INSERT INTO Category 
VALUES(@CategoryID,@CategoryName)
GO
EXEC SP_Input 6,'TV'
GO

---OUTPUT
GO
CREATE PROC SP_Output
@CategoryID INT OUTPUT
AS
SELECT COUNT(*) FROM Category
GO
EXEC SP_Output 6
GO

----RETURN
CREATE PROCEDURE SP_Return
(@CategoryID INT OUTPUT)
AS
SELECT CategoryID,CategoryName
FROM Category
WHERE CategoryID = @CategoryID
GO
Declare @Return_Value int
Exec @Return_Value = SP_Return @CategoryID = 3
SELECT 'Return_Value' = @Return_Value
GO

-----AFTER TRIGGER------

CREATE TABLE BackTblCategory
(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50)
)
GO

CREATE TRIGGER TR_AfterCategory
ON Category
AFTER UPDATE, INSERT
AS
BEGIN
INSERT INTO BackTblCategory
SELECT i.CategoryID,i.CategoryName,SUSER_NAME(),GETDATE()
FROM inserted i 
END
GO
SELECT * FROM BackTblCategory
GO

----INSTEAD OF DELETE-----
CREATE TABLE CategoryLog
(
LogID INT IDENTITY(1,1) NOT NULL,
CategoryID INT PRIMARY KEY,
ActionLog VARCHAR(50)
);
GO

CREATE TRIGGER TR_Category
ON Category
INSTEAD OF DELETE
AS
BEGIN
       DECLARE @CategoryID INT
       SELECT @CategoryID = DELETED.CategoryID       
       FROM DELETED
       IF @CategoryID = 2
       BEGIN
              RAISERROR('ID 2 record cannot be deleted',16 ,1)
              ROLLBACK
              INSERT INTO CategoryLog
              VALUES(@CategoryID, 'Record cannot be deleted.')
       END
       ELSE
       BEGIN
              DELETE FROM Category
              WHERE CategoryID = @CategoryID
              INSERT INTO CategoryLog
              VALUES(@CategoryID, 'Instead Of Delete')
       END
END
GO

SELECT * FROM Category
SELECT * FROM CategoryLog

DELETE FROM Category WHERE CategoryID = 2
