use Project;

#List the top 3 and bottom 3 makers for the fiscal years 2023 and 2024 in terms of the number of 2-wheelers sold.

select m.maker, count(*) as count 
from dim_date dd join makers m on dd.date = m.date 
where m.vehicle_category = '2-Wheelers' and dd.fiscal_year = 2023 
group by m.maker
order by count asc
limit 3;

select m.maker, count(*) as count 
from dim_date dd join makers m on dd.date = m.date 
where m.vehicle_category = '2-Wheelers' and dd.fiscal_year = 2024
group by m.maker
order by count asc
limit 3;

#Identify the top 5 states with the highest penetration rate in 2-wheeler and 4-wheeler EV sales in FY 2024.

select state, round((sum(electric_vehicles_sold) / sum(total_vehicles_sold) * 100), 2) as penetration_rate
from state s join dim_date dd on s.date = dd.date
where vehicle_category = '2-Wheelers' and dd.fiscal_year = 2024
group by state
order by penetration_rate desc
limit 5;

select state, round((sum(electric_vehicles_sold) / sum(total_vehicles_sold) * 100), 2) as penetration_rate
from state s join dim_date dd on s.date = dd.date
where vehicle_category = '4-Wheelers' and dd.fiscal_year = 2024
group by state
order by penetration_rate desc
limit 5;

#List the states with negative penetration (decline) in EV sales from 2022 to 2024?

SELECT
    a.state, 
    (b.pr_2022 - a.pr_2024) AS diff_pr
FROM (
    SELECT 
        state, 
        ROUND(SUM(electric_vehicles_sold) / SUM(total_vehicles_sold) * 100, 2) AS pr_2024
    FROM state s 
    JOIN dim_date dd ON s.date = dd.date
    WHERE dd.fiscal_year = 2024
    GROUP BY state
) AS a
JOIN (
    SELECT 
        state, 
        ROUND(SUM(electric_vehicles_sold) / SUM(total_vehicles_sold) * 100, 2) AS pr_2022
    FROM state s 
    JOIN dim_date dd ON s.date = dd.date
    WHERE dd.fiscal_year = 2022
    GROUP BY state
) AS b 
ON a.state = b.state
where (b.pr_2022 - a.pr_2024) < 0
order by diff_pr asc;

#What are the quarterly trends based on sales volume for the top 5 EV makers (4-wheelers) from 2022 to 2024?

select dd.fiscal_year, dd.quarter, sum(m.electric_vehicles_sold) as sales_volume 
from makers m join dim_date dd on dd.date = m.date
where m.vehicle_category = '4-Wheelers'
group by dd.fiscal_year, dd.quarter
order by sum(m.electric_vehicles_sold) desc;

#How do the EV sales and penetration rates in Delhi compare to Karnataka for 2024?

select state, round((sum(electric_vehicles_sold) / sum(total_vehicles_sold) * 100), 2) as penetration_rate, sum(electric_vehicles_sold) as EVSales
from state s join dim_date dd on s.date = dd.date
where state = 'Delhi' and dd.fiscal_year = 2024
group by state
union
select state, round((sum(electric_vehicles_sold) / sum(total_vehicles_sold) * 100), 2) as penetration_rate, sum(electric_vehicles_sold) as EVSales
from state s join dim_date dd on s.date = dd.date
where state = 'Karnataka' and dd.fiscal_year = 2024
group by state;

#List down the compounded annual growth rate (CAGR) in 4-wheeler units for the top 5 makers from 2022 to 2024.

WITH sales_2022 AS (
    SELECT 
        maker, 
        SUM(electric_vehicles_sold) AS units_2022
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022 AND m.vehicle_category = '4-Wheelers'
    GROUP BY maker
),
sales_2024 AS (
    SELECT 
        maker, 
        SUM(electric_vehicles_sold) AS units_2024
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2024 AND m.vehicle_category = '4-Wheelers'
    GROUP BY maker
)

SELECT 
    s24.maker,
    s22.units_2022,
    s24.units_2024,
    ROUND(
        (POWER(s24.units_2024 / NULLIF(s22.units_2022, 0), 1.0 / 2) - 1) * 100, 
        2
    ) AS cgar
FROM sales_2024 s24
JOIN sales_2022 s22 ON s24.maker = s22.maker
ORDER BY cgar DESC
LIMIT 5;

#List down the top 10 states that had the highest compounded annual growth rate (CAGR) from 2022 to 2024 in total vehicles sold.

WITH sales_2022 AS (
    SELECT 
        state, 
        SUM(total_vehicles_sold) AS units_2022
    FROM state m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022 AND m.vehicle_category = '4-Wheelers'
    GROUP BY state
),
sales_2024 AS (
    SELECT 
        state, 
        SUM(total_vehicles_sold) AS units_2024
    FROM state m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2024 AND m.vehicle_category = '4-Wheelers'
    GROUP BY state
)

SELECT 
    s24.state,
    s22.units_2022,
    s24.units_2024,
    ROUND(
        (POWER(s24.units_2024 / NULLIF(s22.units_2022, 0), 1.0 / 2) - 1) * 100, 
        2
    ) AS cgar
FROM sales_2024 s24
JOIN sales_2022 s22 ON s24.state = s22.state
ORDER BY cgar DESC
LIMIT 10;

#What are the peak and low season months for EV sales based on the data from 2022 to 2024?

SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2022
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold DESC
    LIMIT 1
) AS max_month
UNION ALL
SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2022
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold ASC
    LIMIT 1
) AS min_month
UNION ALL
SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2023
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold DESC
    LIMIT 1
) AS max_month
UNION ALL
SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2023
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold ASC
    LIMIT 1
) AS min_month
UNION ALL
SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2024
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold DESC
    LIMIT 1
) AS max_month
UNION ALL
SELECT * FROM (
    SELECT dd.fiscal_year, dd.month, SUM(m.electric_vehicles_sold) AS sold
    FROM dim_date dd
    JOIN makers m ON m.date = dd.date
    WHERE dd.fiscal_year = 2024
    GROUP BY dd.fiscal_year, dd.month
    ORDER BY sold ASC
    LIMIT 1
) AS min_month;

#another method

with monthly_sales as (
	select dd.fiscal_year, dd.month, sum(electric_vehicles_sold) as sold
    from dim_date dd join makers m on m.date=dd.date
    group by dd.fiscal_year, dd.month
    ),
ranked_sales as (
	select 
		*,
		row_number() over(partition by fiscal_year order by sold desc) as max_rank,
		row_number() over(partition by fiscal_year order by sold asc) as min_rank
	from monthly_sales
    )
select fiscal_year, month, sold
from ranked_sales
where max_rank = 1 or min_rank = 1
order by fiscal_year, sold desc;

#What is the projected number of EV sales (including 2-wheelers and 4-wheelers) for the top 10 states by penetration rate in 2030, 
# based on CAGR from previous years?

WITH sales_2022 AS (
    SELECT 
        state, 
        SUM(electric_vehicles_sold) AS units_2022
    FROM state m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022
    GROUP BY state
),
sales_2024 AS (
    SELECT 
        state, 
        SUM(electric_vehicles_sold) AS units_2024
    FROM state m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2024
    GROUP BY state
),
cgar AS (
    SELECT 
        s24.state,
        s22.units_2022,
        s24.units_2024,
        ROUND(
            (POWER(s24.units_2024 / NULLIF(s22.units_2022, 0), 1.0 / 2) - 1) * 100, 
            2
        ) AS cgar
    FROM sales_2024 s24
    JOIN sales_2022 s22 ON s24.state = s22.state
)

SELECT 
    state,
    units_2022,
    units_2024,
    cgar,
    ROUND(units_2024 * POWER(1 + cgar / 100.0, 6), 0) AS estimate_2030
FROM cgar
order by cgar desc
limit 10;

#Estimate the revenue growth rate of 4-wheeler and 2-wheelers EVs in India for 2022 vs 2024 and 2023 vs 2024, assuming an average unit price.
#Avg - 2 - 85000, 4 - 1500000

#2022 -2W Vs 2023 -2W
WITH rev_2W_2022 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2022,
        SUM(m.electric_vehicles_sold) * 85000 AS revenue_2022
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022
      AND m.vehicle_category = '2-Wheelers'
),
rev_2W_2023 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2023,
        SUM(m.electric_vehicles_sold) * 85000 AS revenue_2023
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2023
      AND m.vehicle_category = '2-Wheelers'
)

SELECT 
revenue_2022,
revenue_2023,
    ROUND(((revenue_2023 - revenue_2022) / revenue_2022) * 100, 2) AS estimate_growth
FROM rev_2W_2022, rev_2W_2023;


#2022 -4W Vs 2023 -4W
WITH rev_2W_2022 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2022,
        SUM(m.electric_vehicles_sold) * 1500000 AS revenue_2022
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022
      AND m.vehicle_category = '4-Wheelers'
),
rev_2W_2023 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2023,
        SUM(m.electric_vehicles_sold) * 1500000 AS revenue_2023
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2023
      AND m.vehicle_category = '4-Wheelers'
)

SELECT 
revenue_2022,
revenue_2023,
    ROUND(((revenue_2023 - revenue_2022) / revenue_2022) * 100, 2) AS estimate_growth
FROM rev_2W_2022, rev_2W_2023;


#2022 -4W Vs 2024 -4W
WITH rev_2W_2022 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2022,
        SUM(m.electric_vehicles_sold) * 1500000 AS revenue_2022
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022
      AND m.vehicle_category = '4-Wheelers'
),
rev_2W_2024 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2024,
        SUM(m.electric_vehicles_sold) * 1500000 AS revenue_2024
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2024
      AND m.vehicle_category = '4-Wheelers'
)

SELECT 
revenue_2022,
revenue_2024,
    ROUND(((revenue_2024 - revenue_2022) / revenue_2022) * 100, 2) AS estimate_growth
FROM rev_2W_2022, rev_2W_2024;

#2022 -2W Vs 2024 -2W
WITH rev_2W_2022 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2022,
        SUM(m.electric_vehicles_sold) * 85000 AS revenue_2022
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2022
      AND m.vehicle_category = '2-Wheelers'
),
rev_2W_2024 AS (
    SELECT
        SUM(m.electric_vehicles_sold) AS units_2024,
        SUM(m.electric_vehicles_sold) * 85000 AS revenue_2024
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year = 2024
      AND m.vehicle_category = '2-Wheelers'
)

SELECT 
revenue_2022,
revenue_2024,
    ROUND(((revenue_2024 - revenue_2022) / revenue_2022) * 100, 2) AS estimate_growth
FROM rev_2W_2022, rev_2W_2024;

#another method

WITH revenue_data AS (
    SELECT '2W_2022_vs_2023' AS comparison,
           SUM(CASE WHEN dd.fiscal_year = 2022 THEN m.electric_vehicles_sold ELSE 0 END) * 85000 AS revenue_2022,
           SUM(CASE WHEN dd.fiscal_year = 2023 THEN m.electric_vehicles_sold ELSE 0 END) * 85000 AS revenue_2023,
           NULL AS revenue_2024,
           '2-Wheelers' AS category
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year IN (2022, 2023)
      AND m.vehicle_category = '2-Wheelers'

    UNION ALL

    SELECT '4W_2022_vs_2023',
           SUM(CASE WHEN dd.fiscal_year = 2022 THEN m.electric_vehicles_sold ELSE 0 END) * 1500000,
           SUM(CASE WHEN dd.fiscal_year = 2023 THEN m.electric_vehicles_sold ELSE 0 END) * 1500000,
           NULL,
           '4-Wheelers'
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year IN (2022, 2023)
      AND m.vehicle_category = '4-Wheelers'

    UNION ALL

    SELECT '4W_2022_vs_2024',
           SUM(CASE WHEN dd.fiscal_year = 2022 THEN m.electric_vehicles_sold ELSE 0 END) * 1500000,
           NULL,
           SUM(CASE WHEN dd.fiscal_year = 2024 THEN m.electric_vehicles_sold ELSE 0 END) * 1500000,
           '4-Wheelers'
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year IN (2022, 2024)
      AND m.vehicle_category = '4-Wheelers'

    UNION ALL

    SELECT '2W_2022_vs_2024',
           SUM(CASE WHEN dd.fiscal_year = 2022 THEN m.electric_vehicles_sold ELSE 0 END) * 85000,
           NULL,
           SUM(CASE WHEN dd.fiscal_year = 2024 THEN m.electric_vehicles_sold ELSE 0 END) * 85000,
           '2-Wheelers'
    FROM makers m
    JOIN dim_date dd ON dd.date = m.date
    WHERE dd.fiscal_year IN (2022, 2024)
      AND m.vehicle_category = '2-Wheelers'
)

SELECT 
    comparison,
    category,
    revenue_2022,
    revenue_2023,
    revenue_2024,
    ROUND(
        CASE 
            WHEN revenue_2023 IS NOT NULL THEN ((revenue_2023 - revenue_2022) / revenue_2022) * 100
            WHEN revenue_2024 IS NOT NULL THEN ((revenue_2024 - revenue_2022) / revenue_2022) * 100
            ELSE NULL
        END, 2
    ) AS estimate_growth
FROM revenue_data;