create database motor
use motor

create table musteri(
musteri_tc int primary key,
musteri_ad nvarchar(50),
musteri_soyad nvarchar(50),
musteri_sehir nvarchar(70),
musteri_mail nvarchar(250),
musteri_sifre int,
ehliyet_tipi char,
ehliyet_yasi int
);
/* müsteriyi kiralama ile baðla*/

create table kategori(
kategori_id int primary key,
kategori_ismi nvarchar(50),
)

create table motorlar(
motorId int primary key,
motor_marka nvarchar(50),
motor_model nvarchar(50),
stok int,/* triger ekle stoktan düþme olsun*/
fiyat money,
arac_fotograf BLOB,/*resimlerc için bak*/
arac_fotograf2 BLOB,
arac_fotograf3 BLOB,
arac_fotograf4 BLOB,
motor_bilgi varchar(200),
motor_durum varchar (200),
kategori_id int foreign key (kategori_id) references kategori(kategori_id),
);

create table detay(
detay_id int primary key,
motorId int foreign key (motorId) references motorlar(motorId),
motor_bilgi varchar(200) foreign key (motor_bilgi) references motorlar(motor_bilgi),
)

create table konum(
konum_id int primary key,
konum_ad nvarchar(200),
durum nvarchar(200),
)

create table kiralama(
kiralama_id int primary key,
motorId int foreign key (motorId) references motorlar(motorId),
konum_id int foreign key (konum_id) references konum(konum_id),
musteri_tc int foreign key (musteri_tc) references musteri(musteri_tc),
kiralama_tarihi date,
iade_tarihi date,
fiyat money,
kiralama_gun int,
toplam_fiyat money,
)

create  table fatura(
fatura_id int primary key,
farura_seri int,
fatura_sýra int,
fatura_tarih int,
vergi nvarchar(100),
alýnan_yer nvarchar(100),
býrakýlan_yer nvarchar(100),
total_gun int,
total_fiyat money,
)

create table faturaKalemi(
faturak_id int primary key,
fatura_id int foreign key (fatura_id)references fatura(fatura_id),
aciklama nvarchar(50),
)

create table motor_konum(
motork_id int primary key,
motork_ad nvarchar(100),
)

create table gider(
gider_id int primary key,
aciklama nvarchar(100),
tarih date,
fiyat money,
)

create table admin(
kullanýcý_id int primary key,
kullanýcý_ad nvarchar(100),
sifre char(16),
)