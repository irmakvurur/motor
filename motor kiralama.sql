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
	total_km_used INT,
	current_km INT,
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
	rental_distance INT,
    price MONEY,
    rental_days INT,
    total_price MONEY,
    FOREIGN KEY (motor_id) REFERENCES motorcycles(motor_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_tc)
);

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

--cotogary ekle
INSERT INTO category ( category_id,category_name)
Values
   (1,'racing'),
   (2,'naked'),
   (3,'touring');


/*motor km*/

-- Tabloları oluşturduktan sonra motorların verilerini ekleyin
INSERT INTO motorcycles (motor_id, motor_brand, motor_model, stock, price, total_km_used, current_km, category_id)
VALUES
    (1, 'Yamaha', 'YZF R25', 2, 1000, 8000, 13000, 1),
    (2, 'CF Moto', 'NK250', 1, 800, 4000,7000, 2),
	(3, 'Bajaj', 'Model', 8, 12000, 0, 0, 2),
	(4, 'Ducati', 'Model', 8, 12000, 0, 0, 2),
	(5, 'Honda', 'Model', 8, 12000, 0, 0, 2),
	(6, 'Kawasaki', 'Model', 8, 12000, 0, 0, 2),
	(7, 'KTM', 'Model', 8, 12000, 0, 0, 2),
	(8, 'Suzuki', 'Model', 8, 12000, 0, 0, 2),
	(9, 'Triumph', 'Model', 8, 12000, 0, 0, 2),
	(10, 'Aprilia', 'Model', 8, 12000, 0, 0, 2),
	(11, 'BMW', 'Model', 8, 12000, 0, 0, 2);

-- Motosikletin km bilgisini güncelle
UPDATE motorcycles
SET total_km_used = total_km_used + 50, -- Örnek: 50 km ekledik
    current_km = 5000 -- Örnek: Güncel km bilgisi
WHERE motor_id = 1; -- Örnek: motor_id 1 olan motosiklet

-- Motosikletin km bilgisini al
SELECT motor_id, current_km, total_km_used
FROM motorcycles
WHERE motor_id = 1;

/*CUSTOMER TABLOSU*/
SELECT * FROM customer;

/*motor listeleme*/
SELECT * FROM motorcycles;

/*Kiralama geçmişini listele*/
SELECT rental.*, customer.customer_name, customer.customer_surname
FROM rental
JOIN customer ON rental.customer_id = customer.customer_tc;

/*boş motor bulma*/
DECLARE @belirli_tarih DATE = '2024-02-01';

SELECT *
FROM motorcycles
WHERE motor_id NOT IN (
    SELECT motor_id
    FROM rental
    WHERE @belirli_tarih BETWEEN rental_date AND return_date
);

/*Belirli müşterinin kiralama geçmişi*/
DECLARE @musteri_tc INT = 123456789; -- Müşteri TC'sini belirtin

SELECT *
FROM rental
WHERE customer_id = @musteri_tc;

/*yeni kiralama eklemek*/
INSERT INTO rental (motor_id, location_id, customer_id, rental_date, return_date, price, rental_days, total_price)
VALUES (1, 2, 123456789, '2024-02-01', '2024-02-05', 100.00, 5, 500.00);


/*kiralamayı güncelle*/
DECLARE @kiralama_id INT = 1; -- Güncellenecek kiralamanın ID'sini belirtin
DECLARE @yeni_return_date DATE = '2024-02-10'; -- Yeni dönüş tarihini belirtin

UPDATE rental
SET return_date = @yeni_return_date
WHERE rental_id = @kiralama_id;


/*müşteri ekle*/
INSERT INTO customer (customer_tc, customer_name, customer_surname, customer_city, customer_email, customer_password, driving_license_type, driving_license_age)
VALUES (123456789, 'Ahmet', 'Yılmaz', 'Istanbul', 'ahmet@example.com', 123456, 'B', 25);


/*ADMİN TABLOSU:*/
/*yönetici ekleme:*/
INSERT INTO admin(user_id, username, password, salt)
VALUES (1, 'admin', 'hashed_password_here', 'salt_here');

/*Giriş yapma:*/
SELECT * FROM admin
WHERE username = 'admin' AND password = 'hashed_password_input' AND salt = 'salt_input';

/*Stok arttırma*/
DECLARE @motor_id INT = 1; -- Artırılacak aracın ID'sini belirtin
DECLARE @artirma_miktari INT = 1; -- Artırılacak miktarı belirtin

UPDATE motorcycles
SET stock = stock + @artirma_miktari
WHERE motor_id = @motor_id;



/*Stok azaltma*/

DECLARE @kiralanan_miktar INT = 1; -- Kiralanan miktarı belirtin

-- Kiralanan aracın stoktan düşürülmesi
UPDATE motorcycles
SET stock = stock - @kiralanan_miktar
WHERE motor_id = @motor_id;

-- Kiralama işleminin kaydedilmesi (rental tablosuna ekleme)
INSERT INTO rental (motor_id, location_id, customer_id, rental_date, return_date, price, rental_days, total_price)
VALUES (@motor_id);/* Diğer parametreleri burada belirtin */

-- Kiralama işlemi sonrasında stok durumunu kontrol edebilirsiniz
SELECT * FROM motorcycles WHERE motor_id = @motor_id;


--motor markaları listeleme
SELECT DISTINCT motor_brand
FROM motorcycles;

--belirli bir lokasyondaki stok durumu
SELECT motor_brand, motor_model, stock
FROM motorcycles
JOIN rental ON motorcycles.motor_id = rental.motor_id
JOIN location ON rental.location_id = location.location_id
WHERE location.location_name = 'Belirli Lokasyon';


--müşterinin kullandığı motorlar
SELECT motor_brand, motor_model, rental_date, return_date
FROM motorcycles
JOIN rental ON motorcycles.motor_id = rental.motor_id
JOIN customer ON rental.customer_id = customer.customer_tc
WHERE customer.customer_tc = [customer_tc]


--en fazla kiralanan motor markası
SELECT TOP 1 motor_brand, COUNT(*) AS kiralama_sayisi
FROM motorcycles
JOIN rental ON motorcycles.motor_id = rental.motor_id
GROUP BY motor_brand
ORDER BY kiralama_sayisi DESC;


--belirli bir tarihte kiralanabilir motorlar

SELECT motorcycles.motor_id, motorcycles.motor_brand, motorcycles.motor_model, motorcycles.stock
FROM motorcycles
LEFT JOIN rental ON motorcycles.motor_id = rental.motor_id
WHERE rental.rental_id IS NULL 
    OR (rental.rental_date > '2024-02-01' OR rental.return_date < '2024-02-01');
