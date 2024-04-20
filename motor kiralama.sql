create database motor
use motor

CREATE TABLE customer (
    customer_tc INT PRIMARY KEY  NOT NULL,
    customer_name NVARCHAR(50),
    customer_surname NVARCHAR(50),
    customer_city NVARCHAR(70),
    customer_email NVARCHAR(250),
    customer_password INT,
    driving_license_type CHAR(1),
    driving_license_age INT
);

CREATE TABLE category (
    category_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    category_name NVARCHAR(50)
);

CREATE TABLE motorcycles (
    motor_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    motor_brand NVARCHAR(50),
    motor_model NVARCHAR(50),
    stock INT,
    price MONEY,
	total_km_used INT,
	current_km INT,
    motor_info VARCHAR(200),
    motor_condition VARCHAR(200),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);
CREATE TABLE motor_ýmages (
    ýmages_id INT IDENTITY (1, 1) NOT NULL,
    moto_id INT NULL,
    ýmage_path NVARCHAR (MAX) NULL,
    motor_ýmage_date DATETIME  NULL,
    PRIMARY KEY CLUSTERED (ýmages_id ASC),
    FOREIGN KEY (moto_id) REFERENCES motorcycles (motor_id)
);

CREATE TABLE details (
    detail_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    motor_id INT,
    motor_info VARCHAR(200),
    FOREIGN KEY (motor_id) REFERENCES motorcycles(motor_id),
);

CREATE TABLE location (
    location_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    location_name NVARCHAR(200),
    status NVARCHAR(200)
);


CREATE TABLE rental (
    rental_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
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
    invoice_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
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
    invoice_item_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    invoice_id INT,
    description NVARCHAR(50),
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id)
);

CREATE TABLE motor_location (
    motor_location_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    motor_location_name NVARCHAR(100)
);

CREATE TABLE expense (
    expense_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    description NVARCHAR(100),
    date DATE,
    price MONEY
);

CREATE TABLE admin (
    user_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    username NVARCHAR(100),
    password CHAR(16),
	salt VARCHAR(255)
);

CREATE TABLE creditcard (
    credi_id INT IDENTITY (1, 1) NOT NULL,
    admin_id INT  NULL,
    card_number VARCHAR (50) NOT NULL,
    full_name VARCHAR (50) NOT NULL,
    ccv char (3) NOT NULL,
    expiration_month char (2) NOT NULL,
    expiration_year char (2) NOT NULL,
    PRIMARY KEY CLUSTERED (credi_id ASC),
    FOREIGN KEY (admin_id) REFERENCES admin (user_id),
);

CREATE TABLE Discounts (
    Discount_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Discount_name VARCHAR(255),
    Percentage DECIMAL(5, 2)
);

CREATE TABLE CustomerDiscounts (
    Customer_discount_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    CustomerID INT,
    DiscountID INT,
    FOREIGN KEY (CustomerID) REFERENCES customer(customer_tc),
    FOREIGN KEY (DiscountID) REFERENCES Discounts(Discount_id)
);


-- Stok arttýrma tetikleyicisi
CREATE TRIGGER UpdateStockTrigger
ON rental
AFTER UPDATE
AS
BEGIN
    DECLARE @motor_id INT;
    DECLARE @kiralanan_miktar INT;

    -- Güncellenen tablodan etkilenen satýrlarý al
    SELECT TOP 1 @motor_id = motor_id, @kiralanan_miktar = 1 
    FROM inserted 
    WHERE return_date IS NOT NULL; -- Kiralama süresi bitmiþ olanlarý seç

    -- Stok güncelleme iþlemi
    IF @motor_id IS NOT NULL
    BEGIN
        UPDATE motorcycles
        SET stock = stock + @kiralanan_miktar
        WHERE motor_id = @motor_id;
    END
END;

-- Stok azaltma tetikleyicisi
CREATE TRIGGER DecreaseStockTrigger
ON rental
AFTER INSERT
AS
BEGIN
    DECLARE @motor_id INT;
    DECLARE @kiralanan_miktar INT;

    -- Temp tablo kullanarak her motorun kiralandýðý miktarý bul
    SELECT motor_id, COUNT(*) AS kiralanan_miktar
    INTO #TempKiralanmaMiktarý
    FROM inserted
    GROUP BY motor_id;

    -- Her motor için stoktan düþme iþlemini yap
    DECLARE KiralanmaCursor CURSOR FOR
    SELECT motor_id, kiralanan_miktar FROM #TempKiralanmaMiktarý;

    OPEN KiralanmaCursor;
    FETCH NEXT FROM KiralanmaCursor INTO @motor_id, @kiralanan_miktar;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE motorcycles
        SET stock = stock - @kiralanan_miktar
        WHERE motor_id = @motor_id;

        FETCH NEXT FROM KiralanmaCursor INTO @motor_id, @kiralanan_miktar;
    END;

    CLOSE KiralanmaCursor;
    DEALLOCATE KiralanmaCursor;

    DROP TABLE #TempKiralanmaMiktarý;
END;
GO


-- Kiralama güncelleme tetikleyicisi
CREATE TRIGGER UpdateRentalTrigger
ON rental
AFTER UPDATE
AS
BEGIN
    DECLARE @motor_id INT;
    DECLARE @yeni_return_date DATE;

    SELECT @motor_id = motor_id, @yeni_return_date = return_date FROM inserted;

    UPDATE rental
    SET return_date = @yeni_return_date
    WHERE motor_id = @motor_id;
END;
GO


-- Motosikletin km bilgisini güncelleme prosedürü
CREATE PROCEDURE UpdateMotorcycleKilometers
    @motor_id INT,
    @additional_km INT, -- Eklenen kilometre miktarý
    @current_km INT -- Yeni güncel kilometre bilgisi
AS
BEGIN
    UPDATE motorcycles
    SET total_km_used = total_km_used + @additional_km,
        current_km = @current_km
    WHERE motor_id = @motor_id;
END;
GO

-- Belirli bir motorun km bilgisini almak için prosedür
CREATE PROCEDURE GetMotorcycleKilometers
    @motor_id INT
AS
BEGIN
    SELECT motor_id, current_km, total_km_used
    FROM motorcycles
    WHERE motor_id = @motor_id;
END;
GO

-- Boþ motorlarý bulmak için prosedür
CREATE PROCEDURE FindEmptyMotorcycles
    @belirli_tarih DATE
AS
BEGIN
    SELECT *
    FROM motorcycles
    WHERE motor_id NOT IN (
        SELECT motor_id
        FROM rental
        WHERE @belirli_tarih BETWEEN rental_date AND return_date
    );
END;
GO

-- Belirli bir müþterinin kiralama geçmiþi için prosedür
CREATE PROCEDURE GetCustomerRentalHistory
    @musteri_tc INT
AS
BEGIN
    SELECT *
    FROM rental
    WHERE customer_id = @musteri_tc;
END;
GO

-- Kiralama iþlemini güncellemek için prosedür
CREATE PROCEDURE UpdateRental
    @kiralama_id INT,
    @yeni_return_date DATE
AS
BEGIN
    UPDATE rental
    SET return_date = @yeni_return_date
    WHERE rental_id = @kiralama_id;
END;
GO

-- Müþteri ekleme prosedürü
CREATE PROCEDURE AddCustomer
    @customer_tc INT,
    @customer_name NVARCHAR(50),
    @customer_surname NVARCHAR(50),
    @customer_city NVARCHAR(50),
    @customer_email NVARCHAR(100),
    @customer_password NVARCHAR(50),
    @driving_license_type NVARCHAR(1),
    @driving_license_age INT
AS
BEGIN
    INSERT INTO customer (customer_tc, customer_name, customer_surname, customer_city, customer_email, customer_password, driving_license_type, driving_license_age)
    VALUES (@customer_tc, @customer_name, @customer_surname, @customer_city, @customer_email, @customer_password, @driving_license_type, @driving_license_age);
END;
GO

-- Yönetici ekleme prosedürü
CREATE PROCEDURE AddAdmin
    @user_id INT,
    @username NVARCHAR(50),
    @password NVARCHAR(100),
    @salt NVARCHAR(100)
AS
BEGIN
    INSERT INTO admin (user_id, username, password, salt)
    VALUES (@user_id, @username, @password, @salt);
END;
GO
-- Kiralama iþleminin kaydedilmesi prosedürü
CREATE PROCEDURE AddRental
    @motor_id INT,
    @location_id INT,
    @customer_id INT,
    @rental_date DATE,
    @return_date DATE,
    @price DECIMAL(10, 2),
    @rental_days INT,
    @total_price DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO rental (motor_id, location_id, customer_id, rental_date, return_date, price, rental_days, total_price)
    VALUES (@motor_id, @location_id, @customer_id, @rental_date, @return_date, @price, @rental_days, @total_price);
END;
GO

-- Belirli bir motorun stok durumunu kontrol etmek için prosedür
CREATE PROCEDURE CheckMotorcycleStock
    @motor_id INT
AS
BEGIN
    SELECT * FROM motorcycles WHERE motor_id = @motor_id;
END;
GO

-- Motor markalarýný listeleme prosedürü
CREATE PROCEDURE ListMotorBrands
AS
BEGIN
    SELECT DISTINCT motor_brand FROM motorcycles;
END;
GO

-- Belirli bir lokasyondaki stok durumunu listeleme prosedürü
CREATE PROCEDURE ListStockInLocation
    @location_name NVARCHAR(50)
AS
BEGIN
    SELECT motor_brand, motor_model, stock
    FROM motorcycles
    JOIN rental ON motorcycles.motor_id = rental.motor_id
    JOIN location ON rental.location_id = location.location_id
    WHERE location.location_name = @location_name;
END;
GO

-- Belirli bir müþterinin kullandýðý motorlarý listeleme prosedürü
CREATE PROCEDURE ListCustomerMotorcycles
    @customer_tc INT
AS
BEGIN
    SELECT motor_brand, motor_model, rental_date, return_date
    FROM motorcycles
    JOIN rental ON motorcycles.motor_id = rental.motor_id
    JOIN customer ON rental.customer_id = customer.customer_tc
    WHERE customer.customer_tc = @customer_tc;
END;
GO

-- En fazla kiralanan motor markasýný bulan prosedür
CREATE PROCEDURE FindMostRentedMotorBrand
AS
BEGIN
    SELECT TOP 1 motor_brand, COUNT(*) AS kiralama_sayisi
    FROM motorcycles
    JOIN rental ON motorcycles.motor_id = rental.motor_id
    GROUP BY motor_brand
    ORDER BY kiralama_sayisi DESC;
END;
GO

-- Belirli bir tarihte kiralanabilir motorlarý listeleme prosedürü
CREATE PROCEDURE ListAvailableMotorcyclesOnDate
    @belirli_tarih DATE
AS
BEGIN
    SELECT motorcycles.motor_id, motorcycles.motor_brand, motorcycles.motor_model, motorcycles.stock
    FROM motorcycles
    LEFT JOIN rental ON motorcycles.motor_id = rental.motor_id
    WHERE rental.rental_id IS NULL 
        OR (rental.rental_date > @belirli_tarih OR rental.return_date < @belirli_tarih);
END;
GO


-- Kiralama iþlemi gerçekleþtiðinde fatura oluþturup e-posta gönderen prosedür
CREATE PROCEDURE GenerateAndSendInvoice
    @rental_id INT
AS
BEGIN
    DECLARE @customer_email NVARCHAR(250);
    DECLARE @subject NVARCHAR(100);
    DECLARE @body NVARCHAR(MAX);

    -- Kiralama bilgilerini ve müþterinin e-posta adresini al
    SELECT c.customer_email, r.rental_date, r.return_date, DATEDIFF(day, r.rental_date, r.return_date) AS total_days, r.total_price
    INTO #RentalInfo
    FROM rental r
    JOIN customer c ON r.customer_id = c.customer_tc
    WHERE rental_id = @rental_id;

    -- Fatura bilgilerini oluþtur
    DECLARE @pickup_location NVARCHAR(100) = 'PickupLocation';
    DECLARE @return_location NVARCHAR(100) = 'ReturnLocation';
    INSERT INTO invoice (invoice_series, invoice_sequence, invoice_date, tax, pickup_location, return_location, total_days, total_price)
    SELECT 1, 1, CONVERT(VARCHAR(10), GETDATE(), 112), '18%', @pickup_location, @return_location, total_days, total_price
    FROM #RentalInfo;

    -- Fatura detaylarýný oluþtur
    INSERT INTO invoice_item (invoice_id, description)
    SELECT SCOPE_IDENTITY(), 'Motor kiralama'
    FROM #RentalInfo;

    -- E-posta konusu
    SET @subject = 'Kiralama Faturasý';

    -- E-posta içeriði
    SET @body = CONCAT('Sayýn Müþterimiz,<br><br>',
                       'Kiralama Tarihi: ', CONVERT(VARCHAR(10), (SELECT rental_date FROM #RentalInfo), 104), '<br>',
                       'Ýade Tarihi: ', CONVERT(VARCHAR(10), (SELECT return_date FROM #RentalInfo), 104), '<br>',
                       'Toplam Gün: ', (SELECT total_days FROM #RentalInfo), '<br>',
                       'Toplam Fiyat: ', (SELECT total_price FROM #RentalInfo), ' TL<br><br>',
                       'Ýyi günler dileriz.');

    -- Müþteriye e-posta gönder
    EXEC msdb.dbo.sp_send_dbmail
        @recipients = @customer_email,
        @subject = @subject,
        @body = @body,
        @body_format = 'HTML';

    -- Geçici tabloyu temizle
    DROP TABLE #RentalInfo;
END;
