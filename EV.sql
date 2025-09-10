create database Project;


use Project;

select * from dim_date;

ALTER TABLE dim_date
ADD COLUMN month VARCHAR(10);

ALTER TABLE dim_date
ADD COLUMN month_id INT;

UPDATE dim_date
SET month_id = CASE
    WHEN month = 'Jan' THEN 1
    WHEN month = 'Feb' THEN 2
    WHEN month = 'Mar' THEN 3
    WHEN month = 'Apr' THEN 4
    WHEN month = 'May' THEN 5
    WHEN month = 'Jun' THEN 6
    WHEN month = 'Jul' THEN 7
    WHEN month = 'Aug' THEN 8
    WHEN month = 'Sep' THEN 9
    WHEN month = 'Oct' THEN 10
    WHEN month = 'Nov' THEN 11
    WHEN month = 'Dec' THEN 12
END;

UPDATE dim_date
SET month = DATE_FORMAT(STR_TO_DATE(date, '%d-%b-%Y'), '%b');

UPDATE dim_date
SET quarter = CASE
    WHEN month in ('Jan', 'Feb', 'Mar') THEN 'Q1'
    WHEN month in ('Apr', 'May', 'Jun') THEN 'Q2'
    WHEN month in ('Jul', 'Aug', 'Sep') THEN 'Q3'
    WHEN month in ('Oct', 'Nov', 'Dec') THEN 'Q4'
END;


select * from makers;

select sum(electric_vehicles_sold) from makers;

select * from state;

select sum(electric_vehicles_sold) from state;
