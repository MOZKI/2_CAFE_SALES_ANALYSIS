-- ==============================================
# EDA (Exploratory Data Analysis) 
-- ==============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Tahap 1: Memahami Struktur Data
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 1.1 Menghitung Jumlah Data Yang Ada (How Much Records Or Rows)
SELECT COUNT(*) AS 'Jumlah Rows'
FROM clean_dataset_final;

-- 1.2 Cek Sample Data (Head)
SELECT *
FROM clean_dataset_final
LIMIT 10;

-- 1.3 Cek Duplikat Transaction ID 
SELECT `Transaction ID`, COUNT(*) AS jumlah
FROM clean_dataset_final
GROUP BY `Transaction ID`
HAVING jumlah > 1;

-- 1.4 Cek Missing Values (NULL)
SELECT
	SUM(CASE WHEN `Transaction ID` IS NULL THEN 1 ELSE 0 END) AS 'Missing Transaction ID',
    SUM(CASE WHEN `Item` IS NULL THEN 1 ELSE 0 END) AS 'Missing Item',
    SUM(CASE WHEN `Quantity` IS NULL THEN 1 ELSE 0 END) AS 'Missing Quantity',
    SUM(CASE WHEN `Price Per Unit` IS NULL THEN 1 ELSE 0 END) AS 'Missing Price Per Unit',
    SUM(CASE WHEN `Total Spent` IS NULL THEN 1 ELSE 0 END) AS 'Missing Total Spent',
    SUM(CASE WHEN `Payment Method` IS NULL THEN 1 ELSE 0 END) AS 'Missing Payment Method',
    SUM(CASE WHEN `Location` IS NULL THEN 1 ELSE 0 END) AS 'Missing Location',
    SUM(CASE WHEN `Transaction Date` IS NULL THEN 1 ELSE 0 END) AS 'Missing Transaction Date'
FROM clean_dataset_final;

-- 1.5 Mencari Nilai Unik Per Kolom (Yang Sifatnya Kategorikal)
SELECT DISTINCT `Item`
FROM clean_dataset_final
WHERE `Item` IS NOT NULL;
SELECT DISTINCT `Payment Method`
FROM clean_dataset_final
WHERE `Payment Method` IS NOT NULL;
SELECT DISTINCT `Location`
FROM clean_dataset_final
WHERE `Location` IS NOT NULL;

-- 1.6 Cek Tipe Data Apakah Sudah Sesuai
DESCRIBE clean_dataset_final;

-- ==============================================
#							Summary Tahap 1 Per Query (Memahami Struktur Data)
-- 1.1 Dataset terdiri dari 9.973 baris dan 8 kolom
-- 1.2 Transaction ID bersifat unik dapat dijadikan Primary Key jika mau
-- 1.3 Item, Payment Method, Location bersifat Kategorikal
-- 1.4 Terdapat 8 nilai unik pada Item, 3 nilai unik pada Payment Method, dan 2 nilai unik pada Location
-- 1.5 Quantity, Price Per Unit, Total Spent bersifat Numerikal
-- 1.6 Masih terdapat missing values pada kolom Item, Payment Method, Location, dan Transaction Date
-- ==============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Tahap 2: Statistik Deskriptif / Distribusi Awal
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 2.1 Hitung Statistik Numerikal (Cek Quantity, Price Per Unit, Total Spent)
SELECT
	MIN(`Quantity`) AS min_quantity,
    MAX(`Quantity`) AS max_quantity,
    AVG(`Quantity`) AS avg_quantity,
    
	MIN(`Price Per Unit`) AS min_price_per_unit,
    MAX(`Price Per Unit`) AS max_price_per_unit,
    AVG(`Price Per Unit`) AS avg_price_per_unit,
    
	MIN(`Total Spent`) AS min_total_spent,
    MAX(`Total Spent`) AS max_total_spent,
    AVG(`Total Spent`) AS avg_total_spent
FROM clean_dataset_final;

-- 2.2 Hitung Jumlah Transaksi Per Item
SELECT `Item`, COUNT(*) AS 'Jumlah Transaksi'
FROM clean_dataset_final
WHERE `Item` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 2.3 Hitung Jumlah Transaksi Per Payment Method
SELECT `Payment Method`, COUNT(*) AS 'Jumlah Transaksi'
FROM clean_dataset_final
WHERE `Payment Method` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 2.4 Hitung Jumlah Transaksi Per Location
SELECT `Location`, COUNT(*) AS 'Jumlah Transaksi'
FROM clean_dataset_final
WHERE `Location` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 2.5 Distribusi Waktu 
SELECT
	DATE_FORMAT(`Transaction Date`, '%Y-%m') AS 'Tahun-Bulan',
    COUNT(*) AS 'Jumlah Transaksi'
FROM clean_dataset_final
WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m') IS NOT NULL
GROUP BY 1
ORDER BY 1; 

-- ==============================================
#							Summary Tahap 2 Per Query (Statistik Deskriptif / Distribusi Awal)
-- 2.2 Coffee memiliki Jumlah Transaksi terbanyak yaitu mencapai 1.279 transaksi 
-- 2.3 Digital Wallet menjadi Payment Method paling diminati, sekitar 2.283 transaksi menggunakan metode pembayaran ini
-- 2.4 Untuk Jumlah Transaksi Takeaway dan In-Store memiliki selisih yang tidak besar yaitu Takeaway mencapai 3.015 dan In-Store 3.006
-- 2.5 Dataset berlaku dari Januari 2023 - Desember 2023, dan Jumlah Transaksi terbanyak ada di bulan Oktober mencapai 837 transaksi
-- ==============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Tahap 3: Korelasi/Keterkaitan Antar Field
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Kategorikal ~ Numerikal
-- 3.1 Total Terjual per Item
SELECT `Item`, SUM(`Quantity`)  AS 'Total Terjual'
FROM clean_dataset_final
WHERE `Item` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 3.2 Jumlah transaksi berdasarkan kuantitas item yang dibeli (frekuensi pembelian)
SELECT `Item`, `Quantity`, COUNT(*) AS Jumlah
FROM clean_dataset_final
WHERE `Item` IS NOT NULL AND `Quantity` IS NOT NULL
GROUP BY `Item`, `Quantity`
ORDER BY 3 DESC;

-- 3.3 Price per Item
SELECT `Item`, AVG(`Price Per Unit`)  AS 'Harga'
FROM clean_dataset_final
WHERE `Item` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 3.4 Jumlah transaksi berdasarkan harga barang 
SELECT `Item`, `Price Per Unit`, COUNT(*) AS Jumlah
FROM clean_dataset_final
WHERE `Item` IS NOT NULL AND `Price Per Unit` IS NOT NULL
GROUP BY `Item`, `Price Per Unit`
ORDER BY 3 DESC;

-- 3.5 Total Pendapatan per Item 
SELECT `Item`, SUM(`Total Spent`)  AS 'Total Pendapatan'
FROM clean_dataset_final
WHERE `Item` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 3.6 Jumlah transaksi berdasarkan total spent dari item yang dibeli
SELECT `Item`, `Total Spent`, COUNT(*) AS Jumlah
FROM clean_dataset_final
WHERE `Item` IS NOT NULL AND `Total Spent` IS NOT NULL
GROUP BY `Item`, `Total Spent`
ORDER BY 3 DESC;

# Kategorikal ~ Kategorikal
-- 3.7 Payment Method Per Item
WITH payment_item AS(
	SELECT 
		`Item`, 
		`Payment Method`, 
		COUNT(*) AS Jumlah,
		RANK() OVER(PARTITION BY `Payment Method` ORDER BY COUNT(*) DESC) AS Ranking
	FROM clean_dataset_final
	WHERE `Item` IS NOT NULL AND `Payment Method` IS NOT NULL
	GROUP BY `Item`, `Payment Method`
)
SELECT *
FROM payment_item
WHERE Ranking <= 3
ORDER BY `Payment Method`, Ranking;

-- 3.8 Location Per Item
WITH location_item AS(
	SELECT 
		`Item`, 
		`Location`, 
		COUNT(*) AS Jumlah, 
		RANK() OVER(PARTITION BY `Location` ORDER BY COUNT(*) DESC) AS Ranking
	FROM clean_dataset_final
	WHERE `Item` IS NOT NULL AND `Location` IS NOT NULL
	GROUP BY `Item`, `Location`
)
SELECT *
FROM location_item
WHERE Ranking <= 3
ORDER BY `Location`, Ranking;

-- 3.9 Payment Method Per Location
SELECT
	`Payment Method`,
    `Location`,
    COUNT(*) AS Jumlah,
    RANK() OVER(PARTITION BY `Location` ORDER BY COUNT(*) DESC ) AS Ranking
FROM clean_dataset_final
WHERE `Payment Method` IS NOT NULL AND `Location` IS NOT NULL
GROUP BY `Payment Method`, `Location`;

# Numerikal ~ Numerikal
-- 3.10 Total Terjual Per Harga Item
SELECT
	`Price Per Unit`,
	SUM(`Quantity`) AS 'Total Terjual'
FROM clean_dataset_final
GROUP BY `Price Per Unit`
ORDER BY 2 DESC;

-- 3.11 Total Pendapatan Per Harga Item
SELECT
	`Price Per Unit`,
	SUM(`Total Spent`) AS 'Total Pendapatan'
FROM clean_dataset_final
GROUP BY `Price Per Unit`
ORDER BY 2 DESC;

# Keterkaitan field numerikal ataupun kategorikal dengan periode waktu (tren)
-- 3.12 Jumlah Transaksi di tiap bulannya
SELECT 
	DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Bulan,
	COUNT(*) AS 'Jumlah Transaksi'
FROM clean_dataset_final
WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m') IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- 3.13 Top Item yang terjual di tiap bulannya
WITH top_item_monthly AS(
	SELECT
		`Item`,
        DATE_FORMAT(`Transaction Date`, '%Y-%m') AS 'Bulan',
        SUM(`Quantity`) AS 'Jumlah Item Terjual',
		RANK() OVER(PARTITION BY DATE_FORMAT(`Transaction Date`, '%Y-%m') ORDER BY SUM(`Quantity`)  DESC ) AS Ranking
	FROM clean_dataset_final
	WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m') IS NOT NULL
	GROUP BY 1,2
)
SELECT *
FROM top_item_monthly
WHERE Ranking = 1;

-- 3.14 Top Payment Method di tiap bulannya
WITH top_payment_monthly AS(
	SELECT 
	`Payment Method`,
	DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Bulan,
	COUNT(*) AS 'Jumlah Transaksi',
    RANK() OVER(PARTITION BY DATE_FORMAT(`Transaction Date`, '%Y-%m') ORDER BY COUNT(*) DESC) AS Ranking
	FROM clean_dataset_final
	WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m') IS NOT NULL AND `Payment Method` IS NOT NULL
	GROUP BY 1,2
)
SELECT *
FROM top_payment_monthly
WHERE Ranking = 1;

-- 3.15 Top Location di tiap bulannya
WITH top_location_monthly AS(
	SELECT 
	`Location`,
	DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Bulan,
	COUNT(*) AS 'Jumlah Transaksi',
    RANK() OVER(PARTITION BY DATE_FORMAT(`Transaction Date`, '%Y-%m') ORDER BY COUNT(*) DESC) AS Ranking
	FROM clean_dataset_final
	WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m') IS NOT NULL AND `Location` IS NOT NULL
	GROUP BY 1,2
)
SELECT *
FROM top_location_monthly
WHERE Ranking = 1;

-- 3.16 Total Pendapatan di tiap bulannya
SELECT
	DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Bulan,
    SUM(`Total Spent`) AS 'Total Pendapatan'
FROM clean_dataset_final
WHERE DATE_FORMAT(`Transaction Date`, '%Y-%m')  
GROUP BY 1
ORDER BY 1;
-- ==============================================
#							Summary Tahap 3 Per Query (Korelasi / Keterkaitan Antar Field)
-- 3.1 Coffee menjadi Item terlaris sebanyak 3.878 coffee terjual dalam satu tahun (2023), diikuti oleh salad di nomor 2 dengan total terjual 3.815
-- 3.2 Dalam satu transaksi biasanya pelanggan lebih sering membeli 5 coffee, terhitung 279 transaksi pelanggan membeli 5 coffee (frekuensi terbanyak)
-- 3.3 Harga salad = 5 | smoothie = 4 | sandwich = 4 | cake = 3 | juice = 3 | coffee = 2 | tea = 1.5 | cookie = 1 
-- 3.5 Total pendapatan paling banyak yaitu didapatkan dari Item salad mencapai 19.075 dari seluruh transaksi yang ada (karena salad merupakan item termahal, dan terlaris kedua setelah kopi)
-- 3.7 Payment Method cash dan credit card cenderung digunakan ketika pembelian salad (± 300 transaksi), dan digital wallet dominan untuk pembelian coffee (292 transaksi) atau cookie (288 transaksi)
-- 3.8 Umumnya pelanggan akan makan di tempat (in-store) jika membeli salad (403 transaksi), sedangkan untuk takeaway biasanya pelanggan cenderung membeli cookie (401 transaksi) atau coffee (392 transaksi)
-- 3.9 Jika pelanggan makan di tempat (in-store) pembayaran yang cenderung digunakan yaitu cash (700 transaksi), sedangkan untuk takeaway pembayaran yang digunakan dominan digital wallet (740 transaksi)
-- 3.13 Coffee mendominasi penjualan di bulan Oktober sebanyak 375 item terjual, sekaligus total terjual item terbanyak dalam satu bulan
-- 3.16 Namun untuk total pendapatan paling banyak dalam satu bulan yaitu ada pada bulan Juni 2023 dengan pendapatan mencapai 7.353
-- ==============================================
SELECT *
FROM clean_dataset_final
LIMIT 10000;
