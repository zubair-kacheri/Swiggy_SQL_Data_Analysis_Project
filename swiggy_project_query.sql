CREATE TABLE swiggy_data (
    State VARCHAR(100),
    City VARCHAR(100),
    Order_Date date,
    Restaurant_Name VARCHAR(255),
    Location VARCHAR(255),
    Category VARCHAR(100),
    Dish_Name VARCHAR(255),
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(3,1),
    Rating_Count INT
);

select * 
from swiggy_data;

select 
count(*) 
from swiggy_data;



-- checking NUll values
SELECT 
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;


-- Empty values
select *
from swiggy_data
where state = '' or City = ''  or Restaurant_Name = '' or 
Location = '' or Category = '' or Dish_Name = '';


-- Duplicates
select State, City, Order_Date, Restaurant_Name, Location,
    Category, Dish_Name, Price_INR, Rating, Rating_Count, count(*)
	from swiggy_data
	group by 
	State, City, Order_Date, Restaurant_Name, Location,
    Category, Dish_Name, Price_INR, Rating, Rating_Count
	Having count(*) > 1;	
	

-- droping Duplicate rows

WITH cte AS (
    SELECT 
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY State, City, Order_Date, Restaurant_Name, Location,
                         Category, Dish_Name, Price_INR, Rating, Rating_Count
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM swiggy_data
)
DELETE FROM swiggy_data
USING cte
WHERE swiggy_data.ctid = cte.ctid
  AND cte.rn > 1;



-- Create Schema
-- dim_date table
create table dim_date(
 date_id INT generated always as IDENTITY PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter INT,
    Day INT,
    Week INT
);


-- dim_location table
CREATE TABLE dim_location(
	location_id int generated always as identity primary key,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);


--dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);


--dim_category
CREATE TABLE dim_category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Category VARCHAR(200)
);

--dim_dish
CREATE TABLE dim_dish (
    dish_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Dish_Name VARCHAR(200)
);


--CREATE FACT TABLE
CREATE TABLE fact_swiggy_orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,
	location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,
	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

-- Insert Data in all Tables
-- dim_date
INSERT INTO dim_date (full_date, year, month, month_name, quarter, day, week)
SELECT DISTINCT
    order_date,
    EXTRACT(YEAR FROM order_date)::int AS year,
    EXTRACT(MONTH FROM order_date)::int AS month,
    TO_CHAR(order_date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM order_date)::int AS quarter,
    EXTRACT(DAY FROM order_date)::int AS day,
    EXTRACT(WEEK FROM order_date)::int AS week
FROM swiggy_data
WHERE order_date IS NOT NULL;

-- dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT 
    State, 
    City, 
    Location
FROM swiggy_data;

-- dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT 
    Restaurant_Name
FROM swiggy_data;

-- dim_category
INSERT INTO dim_category (Category)
SELECT DISTINCT 
    Category
FROM swiggy_data;


-- dim_dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT 
    Dish_Name
FROM swiggy_data;

-- INSERT INTO FACT TABLE
INSERT INTO fact_swiggy_orders
(
    date_id, 
    Price_INR, 
    Rating, 
    Rating_Count,
    location_id, 
    restaurant_id, 
    category_id, 
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,
	dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data s
JOIN dim_date dd
    ON dd.Full_Date = s.Order_Date
JOIN dim_location dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.Location = s.Location
JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name
JOIN dim_category dc
    ON dc.Category = s.Category
JOIN dim_dish dsh
    ON dsh.Dish_Name = s.Dish_Name;

-- SEE DATA IN ALL TABLES
SELECT * FROM dim_date;
SELECT * FROM dim_location;
SELECT * FROM dim_restaurant;
SELECT * FROM dim_category;
SELECT * FROM dim_dish;
SELECT * FROM fact_swiggy_orders;

SELECT * FROM fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id;


-- -------------------------------------------------------------------------------------------------------------------------
-- KPI's

-- Total Orders
select count(*) as Total_Orders 
from fact_swiggy_orders;

-- Total Revenue
SELECT
    to_char(
        SUM(price_inr::numeric) / 1000000,
        'FM999,999,990.00'
    ) || ' INR Million' AS total_revenue_million
FROM fact_swiggy_orders;
 

-- Average Dish Price
SELECT
    to_char(
        AVG(price_inr::numeric),
        'FM999,999,990.00'
    ) || ' INR' AS avg_price_inr
FROM fact_swiggy_orders;

-- Average Rating
SELECT AVG(rating) AS avg_rating
FROM fact_swiggy_orders;

--------------------------------------------------------------------------------------------------------------------------------------

-- GRANULAR REQUIREMENTS

-- Monthly Orders (YYYY-MM)
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Quarterly Orders (Q1, Q2, Q3, Q4)
SELECT 
    d.year,
    d.quarter,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;


-- Yearly Orders
SELECT 
    d.year,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


-- Orders by Day of Week (Mon–Sun)
SELECT
    TO_CHAR(d.full_date, 'Day') AS day_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
    TO_CHAR(d.full_date, 'Day'),
    EXTRACT(DOW FROM d.full_date)
ORDER BY
    EXTRACT(DOW FROM d.full_date);



-- Top 10 Cities by Orders
SELECT 
    l.city,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY total_orders DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-- Top 10 Restaurants by Orders
SELECT 
    r.restaurant_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-- Top Categories by Order Volume
SELECT 
    c.category,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY total_orders DESC limit 10;


-- Most Ordered Dishes
SELECT 
    d.dish_name,
    COUNT(*) AS order_count
FROM fact_swiggy_orders f
JOIN dim_dish d ON f.dish_id = d.dish_id
GROUP BY d.dish_name
ORDER BY order_count DESC limit 10;


-- Total Revenue by State
SELECT
    l.state,
    SUM(f.price_inr::numeric) AS total_revenue_inr
FROM fact_swiggy_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.state
ORDER BY total_revenue_inr DESC;



-- Total Orders by Price Range
SELECT
    CASE
        WHEN price_inr < 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY price_range
ORDER BY total_orders DESC;




-- Rating Count Distribution (1–5)
SELECT 
    rating,
    COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY rating
ORDER BY rating;


-- Cuisine Performance (Orders + Avg Rating)
SELECT
    c.category,
    COUNT(*) AS total_orders,
    ROUND(AVG(f.rating::numeric), 2) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY total_orders DESC;





