--Project 2- Lee Saar

/*
שאלה 1
כתבו שאילתה המציגה 
את מידע על מוצרים שלא נרכשו בטבלת הזמנות.
Productid,name(Productname),Color,ListPrice,Size :הציגו
מיינו את הדוח עפ"י Productid
*/

SELECT PP.Productid,PP.Name,PP.Color,PP.ListPrice,PP.Size
FROM Production.Product AS PP
WHERE NOT EXISTS (SELECT Productid
				  FROM Sales.SalesOrderDetail AS SS
				  WHERE PP.ProductID=SS.ProductID)
ORDER BY PP.ProductID

/*
שאלה 2
כתבו שאילתה המציגה מידע על לקוחות שלא ביצעו אף הזמנה. 
הציגו LastName ,Customerid – של הלקוח ומיינו את הדוח עפ"י Customerid בסדר 
עולה . אם ללקוח אין LastName או FirstName, הציגו ‘Unknown ‘במקום השם
לפני השאלה להריץ את הקוד
*/

----UPDATE sales.customer SET personid=customerid
----WHERE customerid <=290
----UPDATE sales.customer SET personid=customerid+1700
----WHERE customerid >= 300 AND customerid<=350
----UPDATE sales.customer SET personid=customerid+1700
----WHERE customerid >= 352 AND customerid<=701


SELECT SC.CustomerID,
	   CASE WHEN PP.LastName <> '' THEN PP.LastName 
			ELSE 'UnKnown' END AS LastName,
	   CASE WHEN PP.FirstName <> '' THEN PP.FirstName 
			ELSE 'UnKnown' END AS FirstName
FROM Sales.Customer AS SC 
	 LEFT JOIN Person.Person AS PP
	 ON SC.PersonID=PP.BusinessEntityID
WHERE NOT EXISTS (SELECT CustomerID
				  FROM Sales.SalesOrderHeader AS SS
				  WHERE SC.CustomerID=SS.CustomerID)
ORDER BY CustomerID 


/*
שאלה 3
כתבו שאילתה המציגה את פרטי 10 הלקוחות שביצעו את מספר הרב ביותר של הזמנות. 
הציגו LastName ,FirstName ,Customerid ומספר הזמנות שביצעו הלקוחות ממוינות בסדר 
יורד
*/

SELECT *
FROM
(
	SELECT SC.CustomerID,PP.FirstName,PP.LastName,
		   COUNT(SS.CustomerID) AS CountOfOrders
	FROM Sales.Customer AS SC 
		 JOIN Person.Person AS PP
	     ON SC.PersonID=PP.BusinessEntityID
	     JOIN Sales.SalesOrderHeader AS SS
	     ON SC.CustomerID=SS.CustomerID
	GROUP BY SC.CustomerID,PP.FirstName,PP.LastName
)A
ORDER BY CountOfOrders DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 


/*
שאלה 4
 כתבו שאילתה המציגה מידע על עובדים ותפקידים שלהם ) ,LastName ,FirstName
HireDate ,JobTitle, (ומספר העובדים הנמצאים באותו התפקיד שהעובד נמצא בו 
*/

SELECT PP.FirstName,PP.LastName,HE.JobTitle,HE.HireDate,
	   COUNT(*)OVER(PARTITION BY HE.JobTitle) AS CountOfTitle
FROM HumanResources.Employee AS HE
	 JOIN Person.Person AS PP
	 ON HE.BusinessEntityID=PP.BusinessEntityID


/*
שאלה 5
 כתבו שאילתה המציגה עבור כל לקוח את תאריך הזמנה אחרונה שביצע ותאריך הזמנה לפני 
האחרונה שביצע. 
הציגו: FirstName , LastName,CustomerID,SalesOrderID , תאריך הזמנה אחרונה, 
ואחת שלפניה.
*/

SELECT SalesOrderID,CustomerID,LastName,
	   FirstName,LastOrder,PreviousOrder
FROM
(
	SELECT SS.SalesOrderID,SS.CustomerID,
		   PP.LastName,PP.FirstName,
		   SS.OrderDate AS LastOrder,
		   LEAD(OrderDate)OVER(PARTITION BY SS.CustomerID
				               ORDER BY OrderDate DESC) AS PreviousOrder,
		   DENSE_RANK()OVER(PARTITION BY SS.CustomerID 
				            ORDER BY SS.OrderDate DESC)AS RNK
	FROM Sales.SalesOrderHeader AS SS
		 JOIN Sales.Customer AS SC
		 ON SC.CustomerID=SS.CustomerID
		 JOIN Person.Person AS PP
		 ON SC.PersonID=PP.BusinessEntityID
)A
WHERE RNK=1
ORDER BY (CustomerID)%29484




/*
שאלה 6
כתבו שאילתה המציגה את סכום מוצרים בהזמנה היקרה ביותר בכל שנה,
יש להציג לאילו לקוחות 
שייכים הזמנות אלו. 
הציגו : שנ ת תאריך הזמנה, מספר הזמנה,
שם משפחה ושם פרטי של לקוח, ועמודת Total היא 
מבוססת על חישוב OrderQty)*UnitPriceDiscount 1-*(UnitPrice
יש לעצב את עמודת Total כפי שמופיע בתרשים
*/


WITH CTE_BestCustomerInYear
AS
(
	SELECT "Year",SalesOrderID,LastName,FirstName,Total,RNK,
			ROW_NUMBER()OVER(PARTITION BY "Year" 
								ORDER BY Total DESC) AS RN
	FROM 
	(
			SELECT "Year",SalesOrderID,LastName,FirstName,
					SUM(PerProduct)OVER(PARTITION BY SalesOrderID)AS Total,
					ROW_NUMBER()OVER (PARTITION BY SalesOrderID 
										ORDER BY SalesOrderID) AS RNK
			FROM
			(
					SELECT YEAR(SH.OrderDate) AS "Year",
							SH.SalesOrderID,PP.LastName,PP.FirstName,
							SO.UnitPrice*(1-SO.UnitPriceDiscount)*SO.OrderQty AS PerProduct
					FROM Sales.SalesOrderDetail AS SO
							JOIN Sales.SalesOrderHeader AS SH
							ON SO.SalesOrderID=SH.SalesOrderID
						 	JOIN Sales.Customer AS SC
							ON SH.CustomerID=SC.CustomerID
							JOIN Person.Person AS PP
							ON SC.PersonID=PP.BusinessEntityID
					GROUP BY YEAR(SH.OrderDate),SH.SalesOrderID,PP.LastName,
								PP.FirstName,SO.ProductID,SO.OrderQty,SO.UnitPrice,
								SO.UnitPriceDiscount
			)A
	)Ab
	WHERE RNK=1
)
SELECT TOP 4 "Year",SalesOrderID,LastName,FirstName,FORMAT(Total,'#,#.0')
FROM CTE_BestCustomerInYear
WHERE RN=1
ORDER BY "Year"


/*
שאלה 7
הציגו באמצעות מטריצה מספר הזמנות שנעשו בכל חודש בשנה.
*/

SELECT *
FROM
(
	   SELECT MONTH(OrderDate) AS "Month",YEAR(OrderDate) AS Y,SalesOrderID
	   FROM Sales.SalesOrderHeader
)AB
PIVOT(COUNT(SalesOrderID) FOR Y IN ([2011],[2012],[2013],[2014]))ABC
ORDER BY "Month"



/*
שאלה 8
כתבו שאילתה המציגה סכום מוצרים בהזמנה עבור כל חודש בשנה וגם את סכו ם מצטבר בכל 
שנה. שימו לב לנראות הדוח. יש להציג שורה המדגישה את סיכום השנה 
*/

SELECT "Year",
		CASE WHEN "Month" IS NULL THEN 'grand_total'
			 ELSE CAST("Month" AS VARCHAR)
			 END AS "Month",
		Sum_Price,
		IIF(CumSum IS NULL,CumSum1,CumSum) AS CumSum	
FROM
(
		SELECT "Year","Month",
				IIF("Month" IS NULL,'grand_total','') AS Month1,
				Sum_Price,CumSum
				,LAG(CumSum,1)OVER(PARTITION BY "year" ORDER BY "year") AS CumSum1				
		FROM
		(
			    SELECT "Year","Month",Sum_Price,CumSum,
						CASE WHEN "Month" IS NULL THEN 1
							 WHEN Sum_Price>0 AND CumSum>0 THEN 1
							 END AS B
				FROM
				(
						SELECT "Year","Month",Sum_Price,
							   SUM(Sum_Price) OVER(PARTITION BY "Year" ORDER BY "year" 
											  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumSum
						FROM
						(
								SELECT "Year","Month",ROUND(Sum_Price,2) AS Sum_Price,															   
										ROW_NUMBER()OVER(PARTITION BY "Year","Month" 
														ORDER BY "Year") AS RN
								FROM
								(
										SELECT "Year","Month",
												SUM(UnitPrice*(1-UnitPriceDiscount))OVER(
																			PARTITION BY "Year","Month" 
																			ORDER BY "Year") AS Sum_Price
										FROM
										(
												SELECT YEAR(ModifiedDate) "Year",MONTH(ModifiedDate) "Month",
												SalesOrderID,ProductID,UnitPrice,UnitPriceDiscount
												FROM Sales.SalesOrderDetail																	
										)A
								)AB
						 )AC
						 WHERE RN=1
				)AD
				GROUP BY ROLLUP("Year","Month",Sum_Price,CumSum)
		)AE
		WHERE B=1
)AF
WHERE Month1 LIKE 'grand_total' AND "Year" IS NOT NULL OR Sum_Price>0 AND CumSum>0

/*
שאלה 9
כתבו שאילתה המציגה את העובדים עפ"י סדר קבלתם לעבודה בכל מחלקה מהעובד החדש 
ביותר לעובד הוותיק ביותר.
הציגו את העמודות שם מחלקה, מס' עובד, שמו המלא, תאריך העסקתו ,הוותק שלו בחברה 
בחודשים, שם מלא ותאריך העסקה של העובד שהתקבל לפניו לעבודה, ומספר הימים שחלפו בין 
תאריך העסקת העובד לעובד שלפניו.
*/

SELECT DepartmentName,"Employee'sId",
	   "Employee'sFullName",HireDate,Seniority,
	   PriviuseEmpName,PriviuseEmpHDate,
	   DATEDIFF(DAY,PriviuseEmpHDate,HireDate) AS DiffDays
FROM
(
	   SELECT DepartmentName,"Employee'sId",
			  "Employee'sFullName",HireDate,Seniority,
			   LAG("Employee'sFullName",1)OVER(PARTITION BY DepartmentName 
								          ORDER BY HireDate) AS PriviuseEmpName,
			   LAG(HireDate,1)OVER(PARTITION BY DepartmentName 
							  ORDER BY HireDate) AS PriviuseEmpHDate
	   FROM
	   (
			SELECT HD.Name AS DepartmentName,
					HE.BusinessEntityID AS "Employee'sId",
					PP.FirstName+' '+PP.LastName AS "Employee'sFullName",
					HE.HireDate,
					DATEDIFF(MONTH,HE.HireDate,GETDATE())AS Seniority
			FROM HumanResources.Employee AS HE
					JOIN Person.Person AS PP
					ON HE.BusinessEntityID=PP.BusinessEntityID
					JOIN HumanResources.EmployeeDepartmentHistory AS DH
					ON HE.BusinessEntityID=DH.BusinessEntityID
					JOIN HumanResources.Department AS HD
					ON DH.DepartmentID=HD.DepartmentID
		)A
)Ab
ORDER BY DepartmentName,HireDate DESC

/*
שאלה 10
 כתבו שאילתה המציגה את פרטי עובדים אשר עובדים באותו המחלקה והתקבלו לעבודה באותו 
התאריך . פרטי העובדים יוצגו כרשימה מול כל שילוב של תאריך קבלה ומספר מחלקה ממוינים 
עפ"י תאריכים בסדר יורד. )אפשרות אחת היא להשתמש ב- Path XML
*/

WITH CTE_SameDay
AS
(
	SELECT *
	FROM
	(
		SELECT HireDate,DepartmentID,TeamEmployee,
				CASE WHEN TeamEmployee LIKE '%,%' THEN 1
				ELSE 0
				END AS B
		FROM
		(
				SELECT HE1.HireDate AS HireDate, ED1.DepartmentID,
					   STUFF((SELECT ', '+ CONCAT(HE.BusinessEntityID,' ',PP.LastName,PP.FirstName)
							  FROM HumanResources.Employee AS HE
								   JOIN Person.Person AS PP
								   ON HE.BusinessEntityID=PP.BusinessEntityID
							       JOIN HumanResources.EmployeeDepartmentHistory AS ED
								   ON HE.BusinessEntityID=ED.BusinessEntityID
							  WHERE HE.HireDate=HE1.HireDate AND ED.DepartmentID=ED1.DepartmentID 
							  FOR XML PATH('')),1,2,'')AS TeamEmployee
				FROM HumanResources.EmployeeDepartmentHistory AS ED1
					 JOIN HumanResources.Employee AS HE1
					 ON ED1.BusinessEntityID=HE1.BusinessEntityID
				GROUP BY HE1.HireDate,ED1.DepartmentID
		)A
	)Ab
	WHERE B=1
),
CTE_NoSameDay
AS
(
	SELECT HireDate,DepartmentID,TeamEmployee
	FROM
	(
			SELECT HireDate,DepartmentID,TeamEmployee,BusinessEntityID,RNK,
						   ROW_NUMBER()OVER(PARTITION BY RNK ORDER BY BusinessEntityID) AS RN
			FROM 
			(					
					SELECT HireDate,DepartmentID,TeamEmployee,BusinessEntityID,
							RANK()OVER(PARTITION BY B ORDER BY BusinessEntityID) AS RNK	
					FROM
					(
							SELECT HireDate,DepartmentID,TeamEmployee,BusinessEntityID,
									CASE WHEN TeamEmployee LIKE '%,%' THEN 1
									ELSE 0
									END AS B
							FROM
							(
									SELECT HE1.HireDate AS HireDate, ED1.DepartmentID,HE1.BusinessEntityID,
											STUFF((SELECT ', '+ CONCAT(HE.BusinessEntityID,' ',PP.LastName,PP.FirstName)
													FROM HumanResources.Employee AS HE
														JOIN Person.Person AS PP
														ON HE.BusinessEntityID=PP.BusinessEntityID
														JOIN HumanResources.EmployeeDepartmentHistory AS ED
														ON HE.BusinessEntityID=ED.BusinessEntityID
													WHERE HE.HireDate=HE1.HireDate AND ED.DepartmentID=ED1.DepartmentID 
													FOR XML PATH('')),1,2,'')AS TeamEmployee
									FROM HumanResources.EmployeeDepartmentHistory AS ED1
									JOIN HumanResources.Employee AS HE1
									ON ED1.BusinessEntityID=HE1.BusinessEntityID
									GROUP BY HE1.HireDate,ED1.DepartmentID,HE1.BusinessEntityID
							)A
					)Ab
					WHERE B=0					
			)Ac
	)Ad
	WHERE RN=1
)
SELECT HireDate,DepartmentID,TeamEmployee FROM CTE_SameDay
UNION 
SELECT HireDate,DepartmentID,TeamEmployee FROM CTE_NoSameDay
ORDER BY HireDate DESC

