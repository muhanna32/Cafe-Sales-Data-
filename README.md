# ☕ Cafe Sales Data Cleaning: A Multi-Tool Pipeline

## 📌 Project Overview
Real-world data is rarely ready for analysis. It often contains errors, missing values, incorrect data types, and duplicates that can severely distort business insights. 

The objective of this project was to design a robust, logical **Data Cleaning Pipeline** for a messy cafe sales dataset (10,000 records) and execute the *exact same pipeline* across four foundational data tools: **Python, SQL, Power BI, and MS Excel**. 

This approach ensures data integrity and proves that solid data engineering principles are tool-agnostic.

---

## 🛠️ The 5-Step Cleaning Pipeline (The Core Logic)

Regardless of the tool used, the dataset went through the following rigorous sequence to achieve 100% cleanliness:

### 1. Handling Dirty Placeholders
* **Issue:** The dataset contained invalid text values like `'ERROR'`, `'UNKNOWN'`, `'N/A'`, and blank spaces.
* **Action:** Identified and replaced all occurrence of these placeholders with standard `Null`/`NaN` values to handle missing data systematically.

### 2. Formatting & Data Types
* **Issue:** All columns were initially imported as text.
* **Action:** Converted columns to their analysis-ready formats:
  * `Transaction Date` ➔ Date (`YYYY-MM-DD`)
  * `Price Per Unit` & `Total Spent` ➔ Decimal / Float
  * `Quantity` ➔ Integer

### 3. Handling Missing Values (Imputation)
* **Categorical Data:** Imputed missing values in `Item`, `Payment Method`, and `Location` using the **Mode** (most frequent value) to preserve the natural distribution.
* **Numerical Data:** Imputed missing values in `Quantity` and `Price Per Unit` using the **Median** to avoid the distortion caused by outliers.

### 4. Fixing Business Logic
* **Issue:** Some records had incorrect `Total Spent` values due to system errors.
* **Action:** Recalculated the `Total Spent` column mathematically for every row enforcing the rule: `(Quantity * Price Per Unit = Total Spent)`.

### 5. Removing Duplicates
* **Issue:** Duplicate transactions skew revenue reporting.
* **Action:** Identified and dropped fully duplicated rows to guarantee 100% unique transactions.

---

## 💻 Tools Utilized

This exact logical pipeline was successfully translated and executed across four different environments:

* **Python (Pandas):** For scripted, highly scalable, and reproducible cleaning.
* **SQL (MySQL):** For robust, database-level ETL transformations using staging tables.
* **Power BI (Power Query):** For a UI-driven, step-by-step visual cleaning workflow.
* **MS Excel:** For quick visual checks and spreadsheet-based formatting.

---

## 🎯 Conclusion
By applying the exact same logic across four distinct platforms, this project demonstrates a deep understanding of data quality principles. While visual tools like Excel and Power BI are excellent for profiling, and SQL is robust for database transformations, Python remains the preferred choice for automated, large-scale data pipelines. 

The final output is a pristine, analysis-ready dataset: `cleaned_cafe_sales.csv`.

---
*Prepared by: Muhanna Al-mutairi*
