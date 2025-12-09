# Swiggy_SQL_Data_Analysis_Project

## Project Overview
This project involves end-to-end analysis of Swiggy food delivery data using **PostgreSQL**.  
The objective is to clean raw transactional data, design a **Star Schema**, and generate meaningful **business KPIs and insights** through optimized SQL queries.

The project is structured to reflect **real-world data warehousing and analytics practices**.

---

## Business Objectives
- Ensure high data quality through systematic cleaning and validation
- Design a scalable **dimensional model (Star Schema)**
- Enable fast and reliable analytical querying
- Derive actionable business insights for decision-making

---

## Data Cleaning & Validation (PostgreSQL)
Performed on the raw table `swiggy_data`:

- **Null value checks**  
  (State, City, Order_Date, Restaurant, Category, Dish, Price, Rating, Rating_Count)

- **Blank / empty string detection**

- **Duplicate record identification**  
  Using grouping on business-critical columns

- **Duplicate removal**  
  Implemented using `ROW_NUMBER()` window function to retain one clean record per order

---

## Data Model – Star Schema
To support analytical queries and BI tools, the dataset was redesigned into a **Star Schema**.

### Dimension Tables
- `dim_date` → Year, Month, Quarter, Week
- `dim_location` → State, City, Location
- `dim_restaurant` → Restaurant_Name
- `dim_category` → Cuisine / Category
- `dim_dish` → Dish_Name

### Fact Table
- `fact_swiggy_orders`
  - Price_INR
  - Rating
  - Rating_Count
  - Foreign keys to all dimensions

This structure improves:
- Query performance
- Data clarity
- Scalability for dashboards and reports

---

## Key Performance Indicators (KPIs)

### Core KPIs
- Total Orders
- Total Revenue (INR Millions)
- Average Dish Price
- Average Rating

### Time-Based Analysis
- Monthly order trends
- Quarterly performance
- Year-over-year growth
- Day-of-week demand patterns

### Location-Based Analysis
- Top 10 cities by order volume
- Revenue contribution by state

### Food & Restaurant Performance
- Top 10 restaurants by orders
- Most ordered dishes
- Category-wise performance (Orders & Avg Rating)

### Customer Spending Analysis
Order value buckets:
- Under 100
- 100–199
- 200–299
- 300–499
- 500+

### Ratings Analysis
- Distribution of ratings (1–5)
- High vs low-rated dish performance

---

## Tools & Technologies
- **PostgreSQL**
  - CTEs
  - Window Functions
  - Joins & Aggregations
- SQL-based dimensional modeling
- GitHub for version control & documentation

---

## Visualization
All analytical results and charts are organized separately for clarity.

**Charts & visual summaries:** [View Charts Folder](https://github.com/zubair-kacheri/Swiggy_SQL_Data_Analysis_Project/tree/main/Charts)


---

## Project Purpose
This project is developed to demonstrate:
- Strong SQL and PostgreSQL fundamentals
- Data warehousing concepts
- Analytical thinking & business interpretation
- Portfolio-ready data analysis skills

---

## Author
**Zubair Kacheri**  
Data Analyst | SQL • PostgreSQL • Data Warehousing
