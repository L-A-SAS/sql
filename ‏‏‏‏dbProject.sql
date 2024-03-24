--Lee Saar-SQL Basic-Project 1 
--Create Database Sales

CREATE DATABASE Sales
go
USE Sales
go
--Create Shcema
CREATE SCHEMA Sales
go
CREATE SCHEMA Person
go
CREATE SCHEMA Purchasing
go

--Create tabels
--Table 1-Address
CREATE TABLE Person.Address(
			AddressID INT PRIMARY KEY NOT NULL,
			AddressLine1 NVARCHAR(60)NOT NULL,
			AddressLine2 NVARCHAR(60),
			City NVARCHAR(30)NOT NULL,
			StateProvinceID INT NOT NULL,
			PostalCode NVARCHAR(15)NOT NULL,
			SpatialLocation GEOGRAPHY,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 2-CreditCard
CREATE TABLE Sales.CreditCard(
			CreditCardID INT PRIMARY KEY NOT NULL,
			CardType NVARCHAR(50)NOT NULL,
			CardNumber NVARCHAR(25)NOT NULL,
			ExpMonth TINYINT NOT NULL,
			ExpYear SMALLINT NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 3-CurrencyRate
CREATE TABLE Sales.CurrencyRate(
			CurrencyID INT PRIMARY KEY NOT NULL,
			CurrencyRateDate DATETIME NOT NULL,
			FromCurrencyCode NCHAR(3) NOT NULL,
			ToCurrencyCode NCHAR(3) NOT NULL,
			AverageRate MONEY NOT NULL,
			EndOfDayRate MONEY NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 4-SalesTerritory
CREATE TABLE Sales.SalesTerritory(
			TerritoryID INT PRIMARY KEY NOT NULL,
			"Name" NVARCHAR(50)NOT NULL,
			CountryRegionCode NVARCHAR(3)NOT NULL,
			[Group] NVARCHAR(50)NOT NULL,
			SalesYTD MONEY NOT NULL,
			SalesLastYear MONEY NOT NULL,
			CostYTD MONEY NOT NULL,
			CostLastYear MONEY NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 5-ShipMethod
CREATE TABLE Purchasing.ShipMethod(
			ShipMethodID INT PRIMARY KEY NOT NULL,
			"Name" VARCHAR(50) NOT NULL,
			ShipBase MONEY NOT NULL,
			ShipRate MONEY NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 6-SpecialOfferProduct
CREATE TABLE Sales.SpecialOfferProduct(
			SpecialOfferID INT NOT NULL,
			ProductID INT NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL,
			PRIMARY KEY(SpecialOfferID,ProductID)) 

--Table 7-SalesPerson
CREATE TABLE Sales.SalesPerson(
			BusinessEntityID INT PRIMARY KEY NOT NULL,
			TerritoryID INT FOREIGN KEY REFERENCES 
						Sales.SalesTerritory(TerritoryID),
			SalesQuota MONEY,
			Bonus MONEY NOT NULL,
			CommissionPct SMALLMONEY NOT NULL,
			SalesYTD MONEY NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 8-Customer
CREATE TABLE Sales.Customer(
			CustomerID INT PRIMARY KEY NOT NULL,
			PersonID INT,
			StoreID INT,
			TerritoryID INT FOREIGN KEY REFERENCES 
						Sales.SalesTerritory(TerritoryID),
			AccountNumber VARCHAR(10) NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL)

--Table 9-SalesOrderHeader
CREATE TABLE Sales.SalesOrderHeader(
			SalesOrderID INT PRIMARY KEY NOT NULL,
			RevisionNumber TINYINT NOT NULL,
			OrderDate DATETIME NOT NULL,
			DueDate DATETIME NOT NULL,
			ShipDate DATETIME,
			"Status" TINYINT NOT NULL,
			OnlineOrderFlag BIT NOT NULL,
			SalesOrderNumber NVARCHAR(25) NOT NULL,
			PurchaseOrderNumber NVARCHAR(25),
			AccountNumber NVARCHAR(15),
			CustomerID INT FOREIGN KEY REFERENCES 
						Sales.Customer(CustomerID) NOT NULL,
			SalesPersonID INT FOREIGN KEY REFERENCES 
						Sales.SalesPerson(BusinessEntityID),
			BillToAddressID INT FOREIGN KEY REFERENCES
						Person.Address(AddressID)NOT NULL,
			TerritoryID INT FOREIGN KEY REFERENCES
						Sales.SalesTerritory(TerritoryID)NOT NULL,
			ShipToAddressID INT FOREIGN KEY REFERENCES 
						Person.Address(AddressID) NOT NULL,
			ShipMethodID INT FOREIGN KEY REFERENCES 
						Purchasing.ShipMethod(ShipMethodID) NOT NULL,
			CreditCardID INT FOREIGN KEY REFERENCES
						Sales.CreditCard(CreditCardID),
			CreditCardApprovalCode VARCHAR(15),
			CurrencyRateID INT FOREIGN KEY REFERENCES
						Sales.CurrencyRate(CurrencyID),
			SubTotal MONEY NOT NULL,
			TaxAmt MONEY NOT NULL,
			Freight MONEY NOT NULL)
		
--Table 10-SalesOrderDetail
CREATE TABLE Sales.SalesOrderDetail(
			SalesOrderID INT FOREIGN KEY REFERENCES
						Sales.SalesOrderHeader(SalesOrderID)NOT NULL,
			SalesOrderDetailID INT NOT NULL,
			CarrierTrackingNumber NVARCHAR(25),
			OrderQty SMALLINT NOT NULL,
			ProductID INT NOT NULL,
			SpecialOfferID INT NOT NULL,
			UnitPrice MONEY NOT NULL,
			UnitPriceDiscount MONEY NOT NULL,
			LineTotal INT NOT NULL,
			rowguid uniqueidentifier NOT NULL,
			ModifiedDate DATETIME NOT NULL
			PRIMARY KEY(SalesOrderID,SalesOrderDetailID),
			CONSTRAINT FK_ProductIDSpecialOfferID
			FOREIGN KEY(SpecialOfferID,ProductID)
			REFERENCES Sales.SpecialOfferProduct(SpecialOfferID,ProductID))

--Insert data into Sales db
--From AdventureWorks2022 db 
USE Sales
go

--Insert into Table 1-Address
--From AdventureWorks2022.Person.Address
INSERT INTO Sales.Person.Address(
			AddressID,
			AddressLine1,
			AddressLine2,
			City,
			StateProvinceID,
			PostalCode,
			SpatialLocation,
			rowguid,
			ModifiedDate)
SELECT AddressID,
			AddressLine1,
			AddressLine2,
			City,
			StateProvinceID,
			PostalCode,
			SpatialLocation,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Person.Address

--Insert into Table 2-CreditCard
--From AdventureWorks2022.Sales.CreditCard
INSERT INTO Sales.CreditCard(
			CreditCardID,
			CardType,
			CardNumber,
			ExpMonth,
			ExpYear,
			ModifiedDate)
SELECT CreditCardID,
			CardType,
			CardNumber,
			ExpMonth,
			ExpYear,
			ModifiedDate
FROM AdventureWorks2022.Sales.CreditCard

--Insert into Table 3-CurrencyRate
--From AdventureWorks2022.Sales.CurrencyRate
INSERT INTO Sales.CurrencyRate(
		    CurrencyID,
			CurrencyRateDate,
			FromCurrencyCode,
			ToCurrencyCode,
			AverageRate,
			EndOfDayRate,
			ModifiedDate)
SELECT CurrencyRateID,
			CurrencyRateDate,
			FromCurrencyCode,
			ToCurrencyCode,
			AverageRate,
			EndOfDayRate,
			ModifiedDate
FROM AdventureWorks2022.Sales.CurrencyRate

--Insert into Table 4-SalesTerritory
--From AdventureWorks2022.Sales.SalesTerritory
INSERT INTO Sales.SalesTerritory(
			TerritoryID,
			"Name",
			CountryRegionCode,
			[Group],
			SalesYTD,
			SalesLastYear,
			CostYTD,
			CostLastYear,
			rowguid,
			ModifiedDate)
SELECT TerritoryID,
			"Name",
			CountryRegionCode,
			[Group],
			SalesYTD,
			SalesLastYear,
			CostYTD,
			CostLastYear,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Sales.SalesTerritory

--Insert into Table 5-ShipMethod
--From AdventureWorks2022.Purchasing.ShipMethod
INSERT INTO Purchasing.ShipMethod(
			ShipMethodID,
			"Name",
			ShipBase,
			ShipRate,
			rowguid,
			ModifiedDate)
SELECT ShipMethodID,
			"Name",
			ShipBase,
			ShipRate,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Purchasing.ShipMethod

--Insert into Table 6-SpecialOfferProduct
--From AdventureWorks2022.SpecialOfferProduct
INSERT INTO Sales.SpecialOfferProduct(
			SpecialOfferID,
			ProductID,
			rowguid,
			ModifiedDate)
SELECT SpecialOfferID,
			ProductID,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Sales.SpecialOfferProduct

--Insert into Table 7-SalesPerson 
--From AdventureWorks2022.Sales.SalesPerson
INSERT INTO Sales.SalesPerson(
			BusinessEntityID,
			TerritoryID,
			SalesQuota,
			Bonus,
			CommissionPct,
			SalesYTD,
			rowguid,
			ModifiedDate)
SELECT BusinessEntityID,
			TerritoryID,
			SalesQuota,
			Bonus,
			CommissionPct,
			SalesYTD,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Sales.SalesPerson

--Insert into Table 8-customer
--From AdventureWorks2022.Sales.Customer
INSERT INTO Sales.Customer(
			CustomerID,
			PersonID,
			StoreID,
			TerritoryID,
			AccountNumber,
			rowguid,
			ModifiedDate)
SELECT CustomerID,
			PersonID,
			StoreID,
			TerritoryID,
			AccountNumber,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Sales.Customer

--Insert into Table 9-SalesOrderHeader
--From AdventureWorks2022.SalesOrderHeader
INSERT INTO Sales.SalesOrderHeader(
			SalesOrderID,
			RevisionNumber,
			OrderDate,
			DueDate,
			ShipDate,
			"Status",
			OnlineOrderFlag,
			SalesOrderNumber,
			PurchaseOrderNumber,
			AccountNumber,
			CustomerID, 
			SalesPersonID,
			TerritoryID,
			BillToAddressID,
			ShipToAddressID,
			ShipMethodID,
			CreditCardID,
			CreditCardApprovalCode,
			CurrencyRateID,
			SubTotal,
			TaxAmt,
			Freight)
SELECT SalesOrderID,
			RevisionNumber,
			OrderDate,
			DueDate,
			ShipDate,
			"Status",
			OnlineOrderFlag,
			SalesOrderNumber,
			PurchaseOrderNumber,
			AccountNumber,
			CustomerID, 
			SalesPersonID,
			TerritoryID,
			BillToAddressID,
			ShipToAddressID,
			ShipMethodID,
			CreditCardID,
			CreditCardApprovalCode,
			CurrencyRateID,
			SubTotal,
			TaxAmt,
			Freight
FROM AdventureWorks2022.Sales.SalesOrderHeader

--Insert into Table 10-SalesOrderDetail
--From AdventureWorks2022.Sales.SalesOrderDetail
INSERT INTO Sales.SalesOrderDetail(
			SalesOrderID,
			SalesOrderDetailID,
			CarrierTrackingNumber,
			OrderQty,
			ProductID,
			SpecialOfferID,
			UnitPrice,
			UnitPriceDiscount,
			LineTotal,
			rowguid,
			ModifiedDate)
SELECT SalesOrderID,
			SalesOrderDetailID,
			CarrierTrackingNumber,
			OrderQty,
			ProductID,
			SpecialOfferID,
			UnitPrice,
			UnitPriceDiscount,
			LineTotal,
			rowguid,
			ModifiedDate
FROM AdventureWorks2022.Sales.SalesOrderDetail


--ScoreForStudent IIF(CodeWorks=Yes!,'Great Job','Fix&Resubmit');)
--Lee Saar


