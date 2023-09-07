CREATE TABLE dwh.Dim_Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(255),
    Category VARCHAR(255)
)

CREATE TABLE dwh.Dim_Date (
    Date_ID INT PRIMARY KEY,
    Order_Date DATE,
    Year INT,
    Quarter VARCHAR(5),
    Month VARCHAR(10),
    Day INT
    -- Otros atributos de tiempo si los tienes
)

CREATE TABLE dwh.Dim_Location (
    Location_ID INT PRIMARY KEY,
    Purchase_Address VARCHAR(255),
    street_number VARCHAR(10),
    street_name VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    postal_code CHAR(5)
)

CREATE TABLE dwh.Fact_Sales (
    Order_ID INT PRIMARY KEY,
    Product_ID INT,
    Date_ID INT,
    Location_ID INT,
    Quantity_Ordered INT,
    Price_Each DECIMAL(10, 2),
    Total_Sales DECIMAL(10, 2),
    FOREIGN KEY (Product_ID) REFERENCES  dwh.Dim_Product(Product_ID),
    FOREIGN KEY (Date_ID) REFERENCES  dwh.Dim_Date(Date_ID),
    FOREIGN KEY (Location_ID) REFERENCES  dwh.Dim_Location(Location_ID)
)
