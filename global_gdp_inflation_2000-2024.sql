create database gloable_gdp;
use gloable_gdp;


select * from `global_gdp_inflation_synthetic_enriched`;
-- (economic_record_id, year,country,iso3,gdp_growth_percent,inflation_percent,Data_type,source , population , gdp_total_usd,gdp_per_capita,
-- unemployment_rate_percent,region)

select * from dim_country;
-- (country_id,country_name,iso3,region,income_group,economic_type)

select * from country_risk_classification;
-- (risk_id,country_id,year,growth_category,inflation_risk,unemployment_risk )

drop table country_risk_classification;

select * from fact_macro_economic;
-- (record_id,country_id,year,gdp_growth_percent,inflation_percent,unemployment_rate_percent,gdp_total_usd,gdp_per_capita,population)
drop table fact_macro_economic;

DESCRIBE fact_macro_economic;
DESCRIBE dim_country;
DESCRIBE country_risk_classification;
DESCRIBE global_gdp_inflation_synthetic_enriched;


-- Row Count Check (Data Loaded Properly?)

SELECT COUNT(*) FROM fact_macro_economic; -- (5160)
SELECT COUNT(*) FROM dim_country;  -- (5204)
SELECT COUNT(*) FROM country_risk_classification;  -- (5204)
SELECT COUNT(*) FROM global_gdp_inflation_synthetic_enriched; -- (5160)


-- Preview Data (Samajhne ke liye)
SELECT * FROM fact_macro_economic LIMIT 10;
SELECT * FROM dim_country LIMIT 10;
SELECT * FROM country_risk_classification LIMIT 10;


-- NULL Value Check (Very Important)

SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN ISO3 IS NULL THEN 1 ELSE 0 END) AS missing_iso3
FROM fact_macro_economic;
select * from fact_macro_economic;

SELECT
COUNT(*) AS total_rows,

SUM(CASE WHEN country_id IS NULL THEN 1 ELSE 0 END) AS null_country_id,
SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS null_year,
SUM(CASE WHEN gdp_growth_percent IS NULL THEN 1 ELSE 0 END) AS null_gdp_growth,
SUM(CASE WHEN inflation_percent IS NULL THEN 1 ELSE 0 END) AS null_inflation,
SUM(CASE WHEN unemployment_rate_percent IS NULL THEN 1 ELSE 0 END) AS null_unemployment,
SUM(CASE WHEN gdp_total_usd IS NULL THEN 1 ELSE 0 END) AS null_gdp_total,
SUM(CASE WHEN gdp_per_capita IS NULL THEN 1 ELSE 0 END) AS null_gdp_per_capita,
SUM(CASE WHEN population IS NULL THEN 1 ELSE 0 END) AS null_population

FROM fact_macro_economic;

SELECT *
FROM fact_macro_economic
WHERE inflation_percent IS NULL;
SELECT COUNT(*)
FROM fact_macro_economic
WHERE inflation_percent IS NULL;





--  Join Between fact_macro_economic and dim_country

SELECT
f.country_id,
d.country_name,
f.year,
f.gdp_growth_percent,
f.inflation_percent
FROM fact_macro_economic f
LEFT JOIN dim_country d
ON f.country_id = d.country_id
LIMIT 20;

--  join with  Risk Table 

SELECT
d.country_name,
r.inflation_risk,
f.year,
f.gdp_growth_percent,
f.inflation_percent
FROM fact_macro_economic f
JOIN dim_country d
ON f.country_id = d.country_id
LEFT JOIN country_risk_classification r
ON f.country_id = r.country_id
LIMIT 20;

select * from country_risk_classification ;


-- Analysis 1 — Overall Economic Trend (Year-wise Average)
SELECT
year,
ROUND(AVG(gdp_growth_percent),2) AS avg_gdp_growth,
ROUND(AVG(inflation_percent),2) AS avg_inflation,
ROUND(AVG(unemployment_rate_percent),2) AS avg_unemployment
FROM fact_macro_economic
GROUP BY year
ORDER BY year;
-- (Global level par GDP growth aur Inflation time ke saath kaise change hue?)



-- Step 7 — Country Performance Comparison

SELECT
d.country_name,
ROUND(AVG(f.gdp_growth_percent),2) AS avg_gdp_growth,
ROUND(AVG(f.inflation_percent),2) AS avg_inflation,
ROUND(AVG(f.unemployment_rate_percent),2) AS avg_unemployment
FROM fact_macro_economic f
JOIN dim_country d
ON f.country_id = d.country_id
GROUP BY d.country_name
ORDER BY avg_gdp_growth DESC;

-- ( Query — Average GDP Growth by Country )


-- Step 8 — Risk Level vs Economic Performance Analysis

SELECT
r.inflation_risk,
COUNT(DISTINCT f.country_id) AS total_countries,
ROUND(AVG(f.gdp_growth_percent),2) AS avg_gdp_growth,
ROUND(AVG(f.inflation_percent),2) AS avg_inflation,
ROUND(AVG(f.unemployment_rate_percent),2) AS avg_unemployment
FROM fact_macro_economic f
JOIN country_risk_classification r
ON f.country_id = r.country_id
GROUP BY r.inflation_risk
ORDER BY avg_gdp_growth DESC;

-- Step 9 — GDP vs Inflation Relationship (Macroeconomic Insight)

SELECT
ROUND(gdp_growth_percent,1) AS gdp_growth_bucket,
ROUND(AVG(inflation_percent),2) AS avg_inflation,
COUNT(*) AS observations
FROM fact_macro_economic
GROUP BY ROUND(gdp_growth_percent,1)
ORDER BY gdp_growth_bucket;


-- Step 11 — Create Population Categories (SQL Bucketing)

SELECT
CASE
    WHEN population < 10000000 THEN 'Low Population'
    WHEN population BETWEEN 10000000 AND 50000000 THEN 'Medium Population'
    WHEN population BETWEEN 50000001 AND 200000000 THEN 'High Population'
    ELSE 'Very High Population'
END AS population_category,

COUNT(DISTINCT country_id) AS total_countries,
ROUND(AVG(gdp_growth_percent),2) AS avg_gdp_growth,
ROUND(AVG(inflation_percent),2) AS avg_inflation,
ROUND(AVG(unemployment_rate_percent),2) AS avg_unemployment

FROM fact_macro_economic
GROUP BY population_category
ORDER BY avg_gdp_growth DESC;



--  Region / Income Group Performance Analysis

SELECT
d.region,
d.income_group,
COUNT(DISTINCT f.country_id) AS total_countries,
ROUND(AVG(f.gdp_growth_percent),2) AS avg_gdp_growth,
ROUND(AVG(f.inflation_percent),2) AS avg_inflation,
ROUND(AVG(f.unemployment_rate_percent),2) AS avg_unemployment
FROM fact_macro_economic f
JOIN dim_country d
ON f.country_id = d.country_id
GROUP BY d.region, d.income_group
ORDER BY avg_gdp_growth DESC;


-- Task 13 — Economic Stability Check (Growth Volatility)

SELECT
d.country_name,
ROUND(AVG(f.gdp_growth_percent),2) AS avg_growth,
ROUND(STDDEV(f.gdp_growth_percent),2) AS growth_volatility
FROM fact_macro_economic f
JOIN dim_country d
ON f.country_id = d.country_id
GROUP BY d.country_name
ORDER BY growth_volatility DESC;