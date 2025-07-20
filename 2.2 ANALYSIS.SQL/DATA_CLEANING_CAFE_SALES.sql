-- ==============================================
# DATA CLEANING 
-- ==============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT COUNT(*) FROM cafe_dataset;
SELECT * FROM cafe_dataset LIMIT 10000;
DROP TABLE cafe_dataset;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#1. Membuat Tabel Baru Untuk Proses Cleaning Data
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CREATE TABLE clean_dataset
LIKE cafe_dataset;

INSERT clean_dataset
SELECT * FROM cafe_dataset;

SELECT * FROM clean_dataset LIMIT 10000;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#2. Mencari Value 'ERROR', 'UNKNOWN', & '' Di Tiap Kolom Lalu Update Menjadi NULL Values
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Transaction ID Field -
SELECT * 
FROM clean_dataset
WHERE `Transaction ID` = 'ERROR' OR `Transaction ID` = 'UNKNOWN' OR `Transaction ID` = '';

-- Item Field --
SELECT * 
FROM clean_dataset
WHERE item = 'ERROR' OR item = 'UNKNOWN' OR item = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET item = NULL
WHERE item = 'ERROR' OR item = 'UNKNOWN' OR item = '';

-- Quantity Field --
SELECT * 
FROM clean_dataset
WHERE quantity = 'ERROR' OR quantity = 'UNKNOWN' OR quantity = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET quantity = NULL
WHERE quantity = 'ERROR' OR quantity = 'UNKNOWN' OR quantity = '';

-- Price Per Unit Field --
SELECT * 
FROM clean_dataset
WHERE `Price Per Unit` = 'ERROR' OR `Price Per Unit` = 'UNKNOWN' OR `Price Per Unit` = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET `Price Per Unit` = NULL
WHERE `Price Per Unit` = 'ERROR' OR `Price Per Unit` = 'UNKNOWN' OR `Price Per Unit` = '';

-- Total Spent Field --
SELECT * 
FROM clean_dataset
WHERE `Total Spent` = 'ERROR' OR `Total Spent` = 'UNKNOWN' OR `Total Spent` = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET `Total Spent` = NULL
WHERE `Total Spent` = 'ERROR' OR `Total Spent` = 'UNKNOWN' OR `Total Spent` = '';

-- Payment Method Field --
SELECT * 
FROM clean_dataset
WHERE `Payment Method` = 'ERROR' OR `Payment Method` = 'UNKNOWN' OR `Payment Method` = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET `Payment Method` = NULL
WHERE `Payment Method` = 'ERROR' OR `Payment Method` = 'UNKNOWN' OR `Payment Method` = '';

-- Location Field -- 
SELECT * 
FROM clean_dataset
WHERE location = 'ERROR' OR location = 'UNKNOWN' OR location = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET location = NULL
WHERE location = 'ERROR' OR location = 'UNKNOWN' OR location = '';

-- Transaction Date -- 
SELECT * 
FROM clean_dataset
WHERE `Transaction Date` = 'ERROR' OR `Transaction Date` = 'UNKNOWN' OR `Transaction Date` = '';
-- Setelah didapatkan value yang tidak tepat update menjadi NULL
UPDATE clean_dataset
SET `Transaction Date` = NULL
WHERE `Transaction Date` = 'ERROR' OR `Transaction Date` = 'UNKNOWN' OR `Transaction Date` = '';
-- ==================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#3. Menyesuaikan Tipe Data Pada Field (Semua Field Bertipe Text di Raw Dataset)
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DESCRIBE clean_dataset;

-- Quantity Field --
ALTER TABLE clean_dataset
MODIFY COLUMN Quantity INT;

-- Price Per Unit Field -- 
ALTER TABLE clean_dataset
MODIFY COLUMN `Price Per Unit` DECIMAL(2,1);

-- Total Spent Field -- 
ALTER TABLE clean_dataset
MODIFY COLUMN `Total Spent` DECIMAL(3,1);

-- Transaction Date Field -- 
ALTER TABLE clean_dataset
MODIFY COLUMN `Transaction Date` DATE;
-- ==================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#4. Menghapus Duplikat Rows (Jika Ada)
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Transaction ID`, `Item`, `Quantity`, `Price Per Unit`, `Total Spent`, `Payment Method`, `Location`, `Transaction Date`) AS row_num
FROM clean_dataset
LIMIT 10000;

WITH duplikat_cte AS(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY `Transaction ID`, `Item`, `Quantity`, `Price Per Unit`, `Total Spent`, `Payment Method`, `Location`, `Transaction Date`) AS row_num
	FROM clean_dataset
    LIMIT 10000
)
SELECT * FROM duplikat_cte
WHERE row_num > 1;
-- ==================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#5. Standarisasi Data (Temukan dan Perbaiki Masalah)
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Mencari typo, penggunaan kata yang tidak efektif, dan spasi pada value
-- Item Field -- 
SELECT DISTINCT `Item`
FROM clean_dataset;

-- Payment Method Field--
SELECT DISTINCT `Payment Method`
FROM clean_dataset;

-- Location -- 
SELECT DISTINCT `Location`
FROM clean_dataset;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#6. Membersihkan Rows Yang Terdapat Banyak Null 
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Sebelum melakukan cleaning data di tiap rows, kita harus mengetahui terlebih dahulu kaitan antara field satu sama lain (memahami tabel)
-- Misal, field item itu berkaitan dengan field price per unit (item/harga per satuan)
-- Lalu field quantity berkaitan dengan field price per unit dan total spent (total spent = quantity * price per unit)

-- Membersihkan Field Item dan Price Per Unit -- 
SELECT COUNT(*) AS 'Null Item'
FROM clean_dataset
WHERE `Item` IS NULL
LIMIT 10000;

SELECT COUNT(*) AS 'Null Price'
FROM clean_dataset
WHERE `Price Per Unit` IS NULL
LIMIT 10000;

-- Terdapat 8 Jenis Item --
SELECT DISTINCT `Item`
FROM clean_dataset;

-- Cake Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Cake'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 3.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 3.0
WHERE `Item` = 'Cake';

-- Coffee Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Coffee'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 2.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 2.0
WHERE `Item` = 'Coffee';
UPDATE clean_dataset
SET `Item` = 'Coffee'
WHERE `Price Per Unit` = 2.0;

-- Cookie Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Cookie'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 1.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 1.0
WHERE `Item` = 'Cookie';
UPDATE clean_dataset
SET `Item` = 'Cookie'
WHERE `Price Per Unit` = 1.0;

-- Salad Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Salad'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 5.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 5.0
WHERE `Item` = 'Salad';
UPDATE clean_dataset
SET `Item` = 'Salad'
WHERE `Price Per Unit` = 5.0;

-- Sandwich Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Sandwich'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 4.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 4.0
WHERE `Item` = 'Sandwich';

-- Smoothie Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Smoothie'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 4.0
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 4.0
WHERE `Item` = 'Smoothie';

-- Tea Item -- 
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Item` = 'Tea'
LIMIT 10000;
SELECT * -- COUNT(*)
FROM clean_dataset
WHERE `Price Per Unit` = 1.5
LIMIT 10000;

UPDATE clean_dataset
SET `Price Per Unit` = 1.5
WHERE `Item` = 'Tea';
UPDATE clean_dataset
SET `Item` = 'Tea'
WHERE `Price Per Unit` = 1.5;

# Membuat Backup (Jika terjadi kesalahan ketika update, masih ada backup dataset yang sebelumnya)
CREATE TABLE clean_dataset_backup
LIKE clean_dataset;

INSERT clean_dataset_backup
SELECT * FROM clean_dataset;

SELECT * FROM clean_dataset_backup LIMIT 10000;
DROP TABLE clean_dataset_backup;

-- Membersihkan Field Quantity, Price Per Unit, & Total Spent -- 
-- Quantity Field -- 
SELECT  COUNT(*)
FROM clean_dataset_backup
WHERE `Quantity` IS NULL;
UPDATE clean_dataset_backup
SET `Quantity` = `Total Spent` / `Price Per Unit`
WHERE `Quantity` IS NULL;
  
-- Price Per Unit Field --
SELECT COUNT(*)
FROM clean_dataset_backup
WHERE `Price Per Unit` IS NULL;
UPDATE clean_dataset_backup
SET `Price Per Unit` = `Total Spent` / `Quantity`
WHERE `Price Per Unit` IS NULL;

-- Total Spent Field --
SELECT COUNT(*)
FROM clean_dataset_backup
WHERE `Total Spent` IS NULL;
UPDATE clean_dataset_backup
SET `Total Spent` = `Price Per Unit` * `Quantity`
WHERE `Total Spent` IS NULL;

SELECT * FROM clean_dataset_backup LIMIT 10000;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#7. Menghapus Rows Yang Terdapat Banyak NULL (Pointless Rows)
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Menghapus Rows Yang Terdapat NULL Di Field Quantity dan Price Per Unit
SELECT * 
FROM clean_dataset_backup
WHERE `Quantity` IS NULL AND `Price Per Unit` IS NULL
LIMIT 10000;
DELETE FROM clean_dataset_backup
WHERE `Quantity` IS NULL AND `Price Per Unit` IS NULL;

-- Menghapus Rows Yang Terdapat NULL Di Field Quantity dan Total Spent 
SELECT * 
FROM clean_dataset_backup
WHERE `Quantity` IS NULL AND `Total Spent` IS NULL
LIMIT 10000;
DELETE FROM clean_dataset_backup
WHERE `Quantity` IS NULL AND `Total Spent` IS NULL;

-- Menghapus Rows Yang Terdapat NULL Di Field Price Per Unit dan Total Spent 
SELECT * 
FROM clean_dataset_backup
WHERE `Price Per Unit` IS NULL AND `Total Spent` IS NULL
LIMIT 10000;
DELETE FROM clean_dataset_backup
WHERE `Price Per Unit` IS NULL AND `Total Spent` IS NULL;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
RENAME TABLE clean_dataset_backup TO clean_dataset_final;
SELECT * FROM clean_dataset_final
LIMIT 10000;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>




