-- ================================
-- CAFE SALES DATA CLEANING PIPELINE
-- ================================


-- 1. Create staging table (all columns as VARCHAR to load raw data safely)
CREATE TABLE staging_cafe_sales (
    `Transaction ID`   VARCHAR(255),
    `Item`             VARCHAR(255),
    `Quantity`         VARCHAR(255),
    `Price Per Unit`   VARCHAR(255),
    `Total Spent`      VARCHAR(255),
    `Payment Method`   VARCHAR(255),
    `Location`         VARCHAR(255),
    `Transaction Date` VARCHAR(255)
);


-- 2. Preview raw data
SELECT * FROM staging_cafe_sales LIMIT 5;
SELECT COUNT(*) AS Total_Rows FROM staging_cafe_sales;


-- 3. Count dirty/invalid values per column
SELECT
    SUM(CASE WHEN `Item`           IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Item_Errors,
    SUM(CASE WHEN `Payment Method` IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Payment_Errors,
    SUM(CASE WHEN `Location`       IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Location_Errors,
    SUM(CASE WHEN `Quantity`       IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Quantity_Errors,
    SUM(CASE WHEN `Price Per Unit` IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Price_Errors,
    SUM(CASE WHEN `Total Spent`    IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ') THEN 1 ELSE 0 END) AS Total_Errors
FROM staging_cafe_sales;


-- 4. Replace invalid strings with NULL
SET SQL_SAFE_UPDATES = 0;

UPDATE staging_cafe_sales SET `Item`             = NULL WHERE `Item`             IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Quantity`         = NULL WHERE `Quantity`         IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Price Per Unit`   = NULL WHERE `Price Per Unit`   IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Total Spent`      = NULL WHERE `Total Spent`      IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Payment Method`   = NULL WHERE `Payment Method`   IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Location`         = NULL WHERE `Location`         IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');
UPDATE staging_cafe_sales SET `Transaction Date` = NULL WHERE `Transaction Date` IN ('ERROR', 'UNKNOWN', 'N/A', '', ' ');


-- 5. Cast columns to their correct data types
ALTER TABLE staging_cafe_sales
    MODIFY COLUMN `Quantity`         INT,
    MODIFY COLUMN `Price Per Unit`   DECIMAL(10, 2),
    MODIFY COLUMN `Total Spent`      DECIMAL(10, 2),
    MODIFY COLUMN `Transaction Date` DATE;


-- 6. Fill NULL categorical columns with the most frequent value (mode)

-- Payment Method
SELECT `Payment Method`, COUNT(*) AS freq
FROM staging_cafe_sales WHERE `Payment Method` IS NOT NULL
GROUP BY `Payment Method` ORDER BY freq DESC LIMIT 1;

UPDATE staging_cafe_sales SET `Payment Method` = 'Digital Wallet' WHERE `Payment Method` IS NULL;

-- Item
SELECT `Item`, COUNT(*) AS freq
FROM staging_cafe_sales WHERE `Item` IS NOT NULL
GROUP BY `Item` ORDER BY freq DESC LIMIT 1;

UPDATE staging_cafe_sales SET `Item` = 'Juice' WHERE `Item` IS NULL;

-- Location
SELECT `Location`, COUNT(*) AS freq
FROM staging_cafe_sales WHERE `Location` IS NOT NULL
GROUP BY `Location` ORDER BY freq DESC LIMIT 1;

UPDATE staging_cafe_sales SET `Location` = 'Takeaway' WHERE `Location` IS NULL;


-- 7. Fill NULL numeric columns with the median value

-- Quantity median
WITH OrderedData AS (
    SELECT `Quantity`,
           ROW_NUMBER() OVER (ORDER BY `Quantity`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM staging_cafe_sales WHERE `Quantity` IS NOT NULL
)
SELECT AVG(`Quantity`) AS Median_Quantity
FROM OrderedData
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));

UPDATE staging_cafe_sales SET `Quantity` = 3 WHERE `Quantity` IS NULL;

-- Price Per Unit median
WITH OrderedData AS (
    SELECT `Price Per Unit`,
           ROW_NUMBER() OVER (ORDER BY `Price Per Unit`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM staging_cafe_sales WHERE `Price Per Unit` IS NOT NULL
)
SELECT AVG(`Price Per Unit`) AS Median_Price
FROM OrderedData
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));

UPDATE staging_cafe_sales SET `Price Per Unit` = 3.00 WHERE `Price Per Unit` IS NULL;


-- 8. Recalculate Total Spent to ensure consistency
UPDATE staging_cafe_sales
SET `Total Spent` = `Quantity` * `Price Per Unit`;


-- 9. Create final clean table (deduplicated)
CREATE TABLE cleaned_cafe_sales AS
SELECT DISTINCT * FROM staging_cafe_sales;


-- 10. Validate final output
SELECT * FROM cleaned_cafe_sales LIMIT 10;
SELECT COUNT(*) AS Final_Clean_Rows FROM cleaned_cafe_sales;

-- Check no NULLs remain
SELECT
    SUM(CASE WHEN `Item`           IS NULL THEN 1 ELSE 0 END) AS Item_Nulls,
    SUM(CASE WHEN `Payment Method` IS NULL THEN 1 ELSE 0 END) AS Payment_Nulls,
    SUM(CASE WHEN `Location`       IS NULL THEN 1 ELSE 0 END) AS Location_Nulls,
    SUM(CASE WHEN `Quantity`       IS NULL THEN 1 ELSE 0 END) AS Quantity_Nulls,
    SUM(CASE WHEN `Price Per Unit` IS NULL THEN 1 ELSE 0 END) AS Price_Nulls,
    SUM(CASE WHEN `Total Spent`    IS NULL THEN 1 ELSE 0 END) AS Total_Nulls
FROM cleaned_cafe_sales;

select * from cleaned_cafe_sales;