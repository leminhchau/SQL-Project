/* Project 2 */


/*SQL command to create table Customer */
  CREATE TABLE CUSTOMER (CUSTOMERID NUMBER(*,0) NOT NULL, 
                        CUSTOMERNAME VARCHAR2(30), 
                        CUSTOMERADDRESS VARCHAR2(30), 
                        CUSTOMERCITY VARCHAR2(30), 
                        CUSTOMERSTATE VARCHAR2(30), 
                        CUSTOMERPOSTALCODE VARCHAR2(30), 
                        CUSTOMEREMAIL VARCHAR2(30), 
                        CUSTOMERUSERNAME VARCHAR2(30), 
                        CUSTOMERPASSWORD VARCHAR2(30), 
                        PRIMARY KEY (CUSTOMERID));

						
/*SQL command to create Table SalesPerson */ 
CREATE TABLE SalesPerson
(
  SALESPERSONID NUMBER(*, 0) NOT NULL 
, SALESPERSONNAME VARCHAR2(30 BYTE) 
, SALESPERSONPHONE NUMBER(*, 0) 
, SALESPERSONEMAIL VARCHAR2(30 BYTE) 
, SALESPERSONUSERNAME VARCHAR2(30 BYTE) 
, SALESPERSONPASSWORD VARCHAR2(30 BYTE) 
, TERRITORYID NUMBER(*, 0)
, PRIMARY KEY (SALESPERSONID)
, FOREIGN KEY (TERRITORYID) REFERENCES TERRITORY (TERRITORYID)
); 

/*SQL command to create Table Product_Line*/
CREATE TABLE Product_Line (Product_Line_ID NUMBER(*,0) NOT NULL,
                            Product_Line_Name VARCHAR2(30),
                            PRIMARY KEY (Product_Line_ID));
                            
/*SQL command to create Table Territory*/
CREATE TABLE TERRITORY 
(
  TERRITORYID NUMBER(*,0) NOT NULL, TERRITORYNAME VARCHAR2(30), PRIMARY KEY (TERRITORYID)
);

/*SQL command to create Table Product*/
CREATE TABLE PRODUCT
(
  PRODUCTID NUMBER(*, 0) NOT NULL 
, PRODUCTNAME VARCHAR2(30 BYTE) 
, PRODUCTFINISH VARCHAR2(30 BYTE) 
, PRODUCTSTANDARDPRICE NUMBER(*, 0) 
, PRODUCTLINEID NUMBER(*, 0) 
, PHOTO VARCHAR2(20 BYTE)
, PRIMARY KEY (PRODUCTID)
, FOREIGN KEY (PRODUCTLINEID) REFERENCES PRODUCT_LINE (PRODUCT_LINE_ID)
);


/*SQL command to create Table Orders*/
CREATE TABLE ORDERS
(
  ORDERID NUMBER(*, 0) NOT NULL 
, ORDERDATE DATE 
, CUSTOMERID NUMBER(*, 0) 
, Primary key (ORDERID)
, FOREIGN KEY(CUSTOMERID) REFERENCES CUSTOMER(CUSTOMERID)
);


/*SQL Command to create Table OrderLine*/
CREATE TABLE ORDERLINE
(
  ORDERID NUMBER(*, 0) 
, PRODUCTID NUMBER(*, 0) 
, ORDEREDQUANTITY NUMBER(*, 0) 
, SALEPRICE FLOAT(70)
, FOREIGN KEY(ORDERID) REFERENCES Orders (ORDERID)
, FOREIGN KEY(PRODUCTID) REFERENCES PRODUCT(PRODUCTID)
);


/*SQL Command to create Table DoesBusinessIn*/
CREATE TABLE DoesBusinessIn (CustomerID VARCHAR2(30),
                            TerritoryID NUMBER(*,0) NOT NULL,
                            FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
                            FOREIGN KEY (TerritoryID) REFERENCES Territory (TerritoryID));
                            
                        

/*SQL Command to create Table PriceUpdate*/
CREATE TABLE PRICEUPDATE
(
  PRICEUPDATEID NUMBER(*, 0) 
, DATECHANGED DATE 
, OLDPRICE FLOAT(70) 
, NEWPRICE FLOAT(70)
, PRIMARY KEY (PRICEUPDATEID)
);


/*Create View Product Lines Sales Comparison Report*/
DROP VIEW Product_Lines_Sales_Comparison;  
CREATE VIEW Product_Lines_Sales_Comparison(ProductLine,totalSales)
AS
SELECT PL.PRODUCT_LINE_ID, SUM(OL.ORDEREDQUANTITY)
FROM PRODUCT_LINE PL, PRODUCT P, ORDERLINE OL
WHERE P.PRODUCTLINEID = PL.PRODUCT_LINE_ID AND P.PRODUCTID = OL.PRODUCTID
GROUP BY PL.PRODUCT_LINE_ID; 


/*Create View Total Value for Products Report*/
DROP VIEW Total_Value_For_Products;
CREATE VIEW TOTAL_VALUE_FOR_PRODUCTS (PRODUCTID,PRODUCTNAME,TOTALVALUE)
AS
SELECT final.PRODUCTID,final.PRODUCTNAME, final.TOTALPRICE
FROM 
    ( SELECT P.PRODUCTID AS PRODUCTID, P.PRODUCTNAME AS PRODUCTNAME, (P.PRODUCTSTANDARDPRICE * Z.TOTALCOUNT) AS TOTALPRICE  
      FROM PRODUCT P,(   
            SELECT O.PRODUCTID AS PRODUCTID, SUM(O.ORDEREDQUANTITY) AS TOTALCOUNT
            FROM ORDERLINE O
            GROUP BY O.PRODUCTID) Z
      WHERE P.PRODUCTID = Z.PRODUCTID
    ) final;
/*


/*Create view for each customer in respective territory*/
CREATE VIEW CUSTOMERDATA (PRODUCTID,PRODUCTNAME,PRODUCTPRICE)
AS
SELECT P.PRODUCTID,P.PRODUCTNAME,P.PRODUCTSTANDARDPRICE
FROM PRODUCT P;




/*Create view for the count of number of customers with addresses in each state*/
CREATE VIEW CUSTOMER_BY_STATES_SHIPMENT (STATES,numCOUNTs)
AS
SELECT C.CUSTOMERSTATE, SUM(C.CUSTOMERID)
FROM CUSTOMER C
GROUP BY C.CUSTOMERSTATE;


/*Create view for customer's purchase history displaying order date, quantity, price, and name of products*/
CREATE VIEW PAST_PURCHASE_HISTORY_REPORT (CUSTOMERNAME,ORDER_DATE,QUANTITY, TOTALPRICE, PRODUCTNAME)
AS
SELECT C.CUSTOMERNAME,O.ORDERDATE, OL.ORDEREDQUANTITY, P.PRODUCTSTANDARDPRICE*OL.ORDEREDQUANTITY, P.PRODUCTNAME
FROM CUSTOMER C, ORDERS O, ORDERLINE OL, PRODUCT P
WHERE C.CUSTOMERID = O.CUSTOMERID AND OL.ORDERID = O.ORDERID AND OL.PRODUCTID = P.PRODUCTID;



/*Create trigger for every price update for the product*/
CREATE OR REPLACE TRIGGER StandardPriceUpdate
BEFORE UPDATE
   ON PRODUCT
   FOR EACH ROW
DECLARE
   oldPrice number(38);
   newPrice number(38);
   productName varchar(30);
   updateId number(38);
   currDate Date;
BEGIN
   updateID := dbms_random.value(1,1000);
   oldPrice := :old.PRODUCTSTANDARDPRICE; 
   newPrice := :new.PRODUCTSTANDARDPRICE;
   productName := :old.PRODUCTNAME;
   SELECT SYSDATE
   INTO currDate
   FROM dual;
   
   INSERT INTO PRICEUPDATE(PRICEUPDATEID,DATECHANGED,OLDPRICE,NEWPRICE)
   values (updateID, currDate,oldPrice,newPrice);
END;


/*SQL Command to insert data into Table Customer*/
INSERT ALL 
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(1, 'Contemporary Casuals', '1355 S Hines Blvd', 'Gainesville', 'FL', '32601-2871','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(2, 'Value Furnitures', '15145 S.W. 17th St.', 'Plano', 'TX', '75094-7734','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(3, 'Home Furnishings', '1900 Allard Ave', 'Albany', 'NY', '12209-1125',  'homefurnishings?@gmail.com', 'CUSTOMER1', 'CUSTOMER1#')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(4, 'Eastern Furniture', '1925 Beltline Rd.', 'Carteret', 'NJ', '07008-3188','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(5, 'Impressions', '5585 Westcott Ct.', 'Sacramento', 'CA', '94206-4056','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(6, 'Furniture Gallery', '325 Flatiron Dr.', 'Boulder', 'CO', '80514-4432','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(7, 'New Furniture', 'Palace Ave', 'Farmington', 'NM', '','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(8, 'Dunkins Furniture', '7700 Main St', 'Syracuse', 'NY', '31590','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(9, 'A Carpet', '434 Abe Dr', 'Rome', 'NY', '13440','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(12, 'Flanigan Furniture', 'Snow Flake Rd', 'Ft Walton Beach', 'FL', '32548','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(13, 'Ikards', '1011 S. Main St', 'Las Cruces', 'NM', '88001','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(14, 'Wild Bills', 'Four Horse Rd', 'Oak Brook', 'Il', '60522','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(15, 'Janet''s Collection', 'Janet Lane', 'Virginia Beach', 'VA', '10012','','','')
    
    INTO CUSTOMER(CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail, CustomerUserName, CustomerPassword) 
    VALUES(16, 'ABC Furniture Co.', '152 Geramino Drive', 'Rome', 'NY', '13440','','','')
    
SELECT 1 FROM DUAL;



/*SQL command to insert data into Table Salesperson*/
INSERT ALL 
    INTO Salesperson (SalespersonID, SalespersonName, SalespersonPhone, SalespersonEmail, SalespersonUserName, SalespersonPassword,TerritoryID) 
    VALUES(1, 'Doug Henny', '8134445555', 'salesperson?@gmail.com', SALESPERSON, SALESPERSON#,1)
    
    INTO Salesperson (SalespersonID, SalespersonName, SalespersonPhone, SalespersonEmail, SalespersonUserName, SalespersonPassword,TerritoryID) 
    VALUES(2, 'Robert Lewis', '8139264006', '', '', '', 2)
    
    INTO Salesperson (SalespersonID, SalespersonName, SalespersonPhone, SalespersonEmail, SalespersonUserName, SalespersonPassword,TerritoryID) 
    VALUES(3, 'William Strong', '5053821212', '', '', '', 3)
    
    INTO Salesperson (SalespersonID, SalespersonName, SalespersonPhone, SalespersonEmail, SalespersonUserName, SalespersonPassword,TerritoryID) 
    VALUES(4, 'Julie Dawson', '4355346677', '', '', '', 4)
    
    INTO Salesperson (SalespersonID, SalespersonName, SalespersonPhone, SalespersonEmail, SalespersonUserName, SalespersonPassword,TerritoryID) 
    VALUES(5, 'Jacob Winslow', '2238973498', '', '', '', 5)
    
SELECT 1 FROM DUAL;



/*SQL Command to insert data into Table Territory*/
INSERT ALL 
    INTO Territory (TerritoryID, TerritoryName) 
    VALUES(1, 'SouthEast')
    
    INTO Territory (TerritoryID, TerritoryName) 
    VALUES(2, 'SouthWest')
    
    INTO Territory (TerritoryID, TerritoryName) 
    VALUES(3, 'NorthEast')
    
    INTO Territory (TerritoryID, TerritoryName) 
    VALUES(4, 'NorthWest')
    
    INTO Territory (TerritoryID, TerritoryName) 
    VALUES(5, 'Central')
    
SELECT 1 FROM DUAL;
    
 
/*SQL command to insert data into table DoesBusinessIn*/
INSERT ALL

    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(1, 1)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(2, 2)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(3,3)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(4, 4)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(5, 5)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(6,1)
    
    INTO DOESBUSINESSIN(CustomerID, TerritoryID)
    VALUES(7,2)
    
SELECT 1 FROM DUAL;
    
    
/*SQL command to insert data into table Product*/
INSERT ALL
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(1, 'End Table', 'Cherry', 175, 1, 'table.jpg')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(2, 'Coffee Table', 'Natural Ash', 200, 2,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(3, 'Computer Desk', 'Natural Ash', 375, 2,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(4, 'Entertainment Center', 'Natural Maple', 650, 3,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(5, 'Writers Desk', 'Cherry', 325, 1,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(6, '8-Drawer Desk', 'White Ash', 750, 2,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(7, 'Dining Table', 'Natural Ash', 800, 2,'')
    
    INTO PRODUCT(ProductID, ProductName, ProductFinish, ProductStandardPrice, ProductLineID, Photo)
    VALUES(8, 'Computer Desk', 'Walnut', 250, 3,'')
    
SELECT 1 FROM DUAL;


/*SQL command to insert data into table Product_Line*/
INSERT ALL
    INTO Product_Line (Product_Line_ID, Product_Line_Name) VALUES (1, 'Cherry Tree')
    INTO Product_Line (Product_Line_ID, Product_Line_Name) VALUES (2, 'Scandinavia')
    INTO Product_Line (Product_Line_ID, Product_Line_Name) VALUES (3, 'Country Look')
SELECT 1 FROM DUAL;    
    


/*SQL command to insert data to table Orders */
INSERT ALL 
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1001, '21/Aug/16', 1)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1002, '21/Jul/16', 8)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1003, '22/ Aug/16', 15)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1004, '22/Oct/16', 5)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1005, '24/Jul/16', 3)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1006, '24/Oct/16', 2)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1007, '27/ Aug/16', 5)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1008, '30/Oct/16', 12)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1009, '05/Nov/16', 4)
    INTO ORDERS (OrderID, OrderDate, CustomerID) VALUES (1010, '05/Nov/16', 1)
SELECT 1 FROM DUAL;



/*SQL command to insert data to table OrderLine */
INSERT ALL 
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1001, 1, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1001, 2, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1001, 2, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1002, 3, 5, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1003, 3, 3, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1004, 6, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1004, 8, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1005, 4, 4, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1006, 4, 1, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1006, 5, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1006, 7, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1007, 1, 3, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1007, 2, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1008, 3, 3, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1008, 8, 3, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1009, 4, 2, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1009, 7, 3, '')
    INTO ORDERLINE (OrderID, ProductID, OrderedQuantity, SalePrice) VALUES (1010, 8, 10, '')
SELECT 1 FROM DUAL;
    

									    /*List product name, finish and standard price for all desks and all tables that cost more than $300 in the Product table*/
SELECT P.ProductName, P.ProductFinish, P.ProductStandardPrice
FROM Product P
WHERE P.ProductStandardPrice > 300 AND (P.ProductName LIKE '%Table%' OR P.ProductName LIKE '%Desk%');


/*List customer, city, and state for all customers in the Customer table whose address is Florida, Texas, California, or Hawaii. 
List the customers alphabetically by state and alphabetically by customer within each state*/
SELECT X.CustomerName, X.CustomerCity, X.CustomerState
FROM 
  (SELECT C.CustomerName, C.CustomerCity, C.CustomerState
  FROM Customer C
  WHERE C.CustomerState IN ('FL','TX','CA','HI')
  ORDER BY C.CustomerName) X
ORDER BY X.CustomerState;


/*Count the number of customers with addresses in each state to which we ship*/
SELECT C.CustomerState, COUNT(C.CustomerID) AS NumberOfCustomer
FROM Customer C
GROUP BY C.CustomerState;


/*Count the number of customers with addresses in each city to which we ship. List the cities by state*/
SELECT X.NumberOfCustomer, X.CustomerCity, C.CustomerState
FROM Customer C, 
  (SELECT C.CustomerCity, COUNT(C.CustomerID) AS NumberOfCustomer
  FROM Customer C
  GROUP BY C.CustomerCity) X
WHERE C.CustomerCity = X.CustomerCity
ORDER BY C.CustomerState;


/*List in alphabetical order the product finish and the average standard price for each finish for selected finishes having an average standard price less than 750*/
SELECT X.ProductFinish, X.AveragePriceForEachFinish
FROM 
  (SELECT P.ProductFinish, AVG(P.ProductStandardPrice) AS AveragePriceForEachFinish
  FROM Product P
  GROUP BY P.ProductFinish) X
WHERE X.AveragePriceForEachFinish < 750
ORDER BY X.ProductFinish;


/* What is the total value of orders placed for each furniture product*/
SELECT Final.ProductID, Final.ProductName, Final.TotalPrice
FROM 
  (SELECT P.ProductID AS ProductID, P.ProductName AS ProductName, (P.ProductStandardPrice * E.TotalCount) AS TotalPrice
  FROM Product P, (
      SELECT O.ProductID AS ProductID, SUM(O.OrderedQuantity) AS TotalCount
      FROM OrderLine O
      GROUP BY O.ProductID) Z
  WHERE P.ProductID = Z.ProductID    
  ) Final;
