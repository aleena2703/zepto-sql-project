# Zepto Product, Inventory & Pricing Analysis

## Project Overview

This project analyzes Zepto product and inventory data using MySQL.

The analysis focuses on understanding:

- pricing trends
- discount patterns
- inventory availability
- stock-out risks
- category performance
- estimated revenue opportunities

The project was built to practice real-world SQL analysis using retail product data.

---

# Dataset Information

- Dataset: Zepto Product Dataset
- Database: MySQL
- Tool Used: MySQL Workbench
- Records Analyzed: 3000+ product records

The dataset includes:

- category
- product name
- MRP
- discounted selling price
- discount percentage
- available quantity
- stock status
- quantity
- product weight

---

# Project Workflow

## 1. Database Setup

- Created a MySQL database
- Imported raw CSV data into MySQL
- Created staging and final tables
- Used a temporary table for data validation

## 2. Data Cleaning & Validation

Performed cleaning and validation steps such as:

- removing unwanted spaces
- handling NULL and empty values
- converting data types
- validating incorrect pricing records
- standardizing stock status values

Validation checks were also performed to identify:

- duplicate records
- missing values
- invalid prices
- incorrect stock values

Example:
- converted product prices from paise to rupees
- checked records where selling price exceeded MRP

---

# Exploratory Data Analysis

The dataset was analyzed to study product distribution, inventory levels, pricing trends, discount patterns, and stock availability across different categories.

### Product Distribution

Cooking Essentials and Munchies contained the highest number of products in the dataset, with 514 products each.

### Inventory Analysis

Cooking Essentials and Munchies also maintained the highest inventory levels, with total inventory counts of 2186 each.

### Revenue Analysis

Packaged Food, Ice Cream & Desserts, and Chocolates & Candies generated the highest estimated revenue in the dataset.

### High Discount + Low Stock Products

Several products had discounts above 50% while maintaining very low stock levels, creating possible stock-out risks during promotions.

### Stock-Out Risk Analysis

Essential grocery products such as Carrot, Beetroot, Madhur Sugar, and Maggi 2-Minute Instant Noodles were found to be out of stock.

### High Inventory Value Products

Premium edible oils and ghee products contributed the highest inventory value in the dataset.

### Pricing Analysis

Premium grocery, household, and personal care products occupied the highest pricing tiers across categories.

---

# KPI & Business Analysis

Calculated business KPIs such as:

- total inventory value
- average category discount
- total products per category
- out-of-stock percentage
- low stock products

The analysis highlighted categories contributing heavily to inventory value and estimated revenue while also identifying products facing stock-out risks.

---

# Advanced SQL Analysis

Used advanced SQL concepts including:

- Window Functions
- DENSE_RANK()
- ROW_NUMBER()
- CTEs
- Views
- Subqueries
- Aggregate Functions

Examples of analysis performed:

- identified top 3 highest-priced products within each category
- compared products against category average prices
- estimated revenue using CTE calculations
- identified duplicate product records across categories

---

# SQL Concepts Used

- GROUP BY
- HAVING
- ORDER BY
- CASE Statements
- Aggregate Functions
- Subqueries
- Window Functions
- CTEs
- Views
- Data Cleaning Techniques

---

# Project Structure

```text
zepto_sql_project/
│
├── data/
│   └── zepto.csv
│
├── images/
│
├── README.md
│
└── zepto_inventory_analysis.sql
