create database motor
use motor

CREATE TABLE customer (
    customer_tc INT PRIMARY KEY,
    customer_name NVARCHAR(50),
    customer_surname NVARCHAR(50),
    customer_city NVARCHAR(70),
    customer_email NVARCHAR(250),
    customer_password INT,
    driving_license_type CHAR(1),
    driving_license_age INT
);

CREATE TABLE category (
    category_id INT PRIMARY KEY,
    category_name NVARCHAR(50)
);

CREATE TABLE motorcycles (
    motor_id INT PRIMARY KEY,
    motor_brand NVARCHAR(50),
    motor_model NVARCHAR(50),
    stock INT,
    price MONEY,
    motor_photo VARBINARY(max),
    motor_photo2 VARBINARY(max),
    motor_photo3 VARBINARY(max),
    motor_photo4 VARBINARY(max),
    motor_info VARCHAR(200),
    motor_condition VARCHAR(200),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE details (
    detail_id INT PRIMARY KEY,
    motor_id INT,
    motor_info VARCHAR(200),
    FOREIGN KEY (motor_id) REFERENCES motorcycles(motor_id),
);

CREATE TABLE location (
    location_id INT PRIMARY KEY,
    location_name NVARCHAR(200),
    status NVARCHAR(200)
);

CREATE TABLE rental (
    rental_id INT PRIMARY KEY,
    motor_id INT,
    location_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    price MONEY,
    rental_days INT,
    total_price MONEY,
    FOREIGN KEY (motor_id) REFERENCES motorcycles(motor_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_tc)

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    invoice_series INT,
    invoice_sequence INT,
    invoice_date INT,
    tax NVARCHAR(100),
    pickup_location NVARCHAR(100),
    return_location NVARCHAR(100),
    total_days INT,
    total_price MONEY
);

CREATE TABLE invoice_item (
    invoice_item_id INT PRIMARY KEY,
    invoice_id INT,
    description NVARCHAR(50),
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id)
);

CREATE TABLE motor_location (
    motor_location_id INT PRIMARY KEY,
    motor_location_name NVARCHAR(100)
);

CREATE TABLE expense (
    expense_id INT PRIMARY KEY,
    description NVARCHAR(100),
    date DATE,
    price MONEY
);

CREATE TABLE admin (
    user_id INT PRIMARY KEY,
    username NVARCHAR(100),
    password CHAR(16),
	salt VARCHAR(255)
);

CREATE TABLE Discounts (
    Discount_id INT PRIMARY KEY,
    Discount_name VARCHAR(255),
    Percentage DECIMAL(5, 2)
);

CREATE TABLE CustomerDiscounts (
    Customer_discount_id INT PRIMARY KEY,
    CustomerID INT,
    DiscountID INT,
    FOREIGN KEY (CustomerID) REFERENCES customer(customer_tc),
    FOREIGN KEY (DiscountID) REFERENCES Discounts(Discount_id)
);

/*CUSTOMER TABLOSU*/
SELECT * FROM customer;

/*araba listeleme*/
SELECT * FROM motorcycles;

/*Kiralama geçmiþini listele*/
SELECT rental.*, customer.customer_name, customer.customer_surname
FROM rental
JOIN customer ON rental.customer_id = customer.customer_tc;

/*boþ araç bulma*/
DECLARE @belirli_tarih DATE = '2024-02-01';

SELECT *
FROM motorcycles
WHERE motor_id NOT IN (
    SELECT motor_id
    FROM rental
    WHERE @belirli_tarih BETWEEN rental_date AND return_date
);

/*Belirli müþterinin kiralama geçmiþi*/
DECLARE @musteri_tc INT = 123456789; -- Müþteri TC'sini belirtin

SELECT *
FROM rental
WHERE customer_id = @musteri_tc;

/*yeni kiralama eklemek*/
INSERT INTO rental (motor_id, location_id, customer_tc, rental_date, return_date, price, rental_days, total_price)
VALUES (1, 2, 123456789, '2024-02-01', '2024-02-05', 100.00, 5, 500.00);


/*kiralamayý güncelle*/
DECLARE @kiralama_id INT = 1; -- Güncellenecek kiralamanýn ID'sini belirtin
DECLARE @yeni_return_date DATE = '2024-02-10'; -- Yeni dönüþ tarihini belirtin

UPDATE rental
SET return_date = @yeni_return_date
WHERE rental_id = @kiralama_id;


/*müþteri ekle*/
INSERT INTO customer (customer_tc, customer_name, customer_surname, customer_city, customer_email, customer_password, driving_license_type, driving_license_age)
VALUES (123456789, 'Ahmet', 'Yýlmaz', 'Istanbul', 'ahmet@example.com', 123456, 'B', 25);


/*ADMÝN TABLOSU:*/
/*yönetici ekleme:*/
INSERT INTO admin(user_id, username, password, salt)
VALUES (1, 'admin', 'hashed_password_here', 'salt_here');

/*Giriþ yapma:*/
SELECT * FROM admin
WHERE username = 'admin' AND password = 'hashed_password_input' AND salt = 'salt_input';