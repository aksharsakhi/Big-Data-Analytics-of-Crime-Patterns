-- crime_analysis.hql
-- Script to create tables and run analysis on Chicago Crimes dataset

-- Create the crimes table using OpenCSVSerde to handle quoted commas
DROP TABLE IF EXISTS crimes;
CREATE TABLE crimes (
    id STRING,
    case_number STRING,
    crime_date STRING,
    block STRING,
    iucr STRING,
    primary_type STRING,
    description STRING,
    location_description STRING,
    arrest STRING,
    domestic STRING,
    beat STRING,
    district STRING,
    ward STRING,
    community_area STRING,
    fbi_code STRING,
    x_coordinate STRING,
    y_coordinate STRING,
    year STRING,
    updated_on STRING,
    latitude STRING,
    longitude STRING,
    location STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ",",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
TBLPROPERTIES("skip.header.line.count"="1");

-- Load data into the table
LOAD DATA LOCAL INPATH 'dataset/chicago_crimes_clean.csv' INTO TABLE crimes;

-- Create community_areas reference table
DROP TABLE IF EXISTS community_areas;
CREATE TABLE community_areas (
    area_code STRING,
    area_name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH 'dataset/community_areas.csv' INTO TABLE community_areas;

-- ==========================================
-- 10 MEANINGFUL HIVE QUERIES
-- ==========================================

-- Q1: SELECT - Retrieve the first 10 crime records
SELECT id, primary_type, description, crime_date
FROM crimes
LIMIT 10;

-- Q2: WHERE - Find all incidents where an arrest was made for narcotics
SELECT id, primary_type, description, arrest
FROM crimes
WHERE primary_type = 'NARCOTICS' AND arrest = 'true'
LIMIT 10;

-- Q3: ORDER BY - List recent homicides ordered by date
SELECT case_number, primary_type, crime_date
FROM crimes
WHERE primary_type = 'HOMICIDE'
ORDER BY crime_date DESC
LIMIT 10;

-- Q4: GROUP BY and COUNT - Find the number of crimes per location description
SELECT location_description, COUNT(*) AS crime_count
FROM crimes
GROUP BY location_description
ORDER BY crime_count DESC
LIMIT 15;

-- Q5: HAVING - Find primary crime types that occurred more than 500 times
SELECT primary_type, COUNT(*) as total
FROM crimes
GROUP BY primary_type
HAVING COUNT(*) > 500
ORDER BY total DESC;

-- Q6: SUM - Calculate the total number of arrests made per district
-- We cast the boolean string to an integer for summing (true = 1, false = 0)
SELECT district, SUM(CASE WHEN arrest = 'true' THEN 1 ELSE 0 END) AS total_arrests
FROM crimes
WHERE district IS NOT NULL AND district != ''
GROUP BY district
ORDER BY total_arrests DESC
LIMIT 10;

-- Q7: AVG - Calculate the average number of domestic crimes per beat
SELECT beat, AVG(CASE WHEN domestic = 'true' THEN 1.0 ELSE 0.0 END) AS avg_domestic_crimes
FROM crimes
WHERE beat IS NOT NULL AND beat != ''
GROUP BY beat
ORDER BY avg_domestic_crimes DESC
LIMIT 10;

-- Q8: MAX - Find the district with the maximum reported cases in this dataset
SELECT district, COUNT(*) AS district_total
FROM crimes
WHERE district IS NOT NULL AND district != ''
GROUP BY district
ORDER BY district_total DESC
LIMIT 1;

-- Q9: MIN - Find the district with the minimum reported cases (excluding empty districts)
SELECT district, COUNT(*) AS district_total
FROM crimes
WHERE district IS NOT NULL AND district != ''
GROUP BY district
ORDER BY district_total ASC
LIMIT 1;

-- Q10: JOIN - Join crimes and community_areas to display the community name for recent crimes
SELECT c.case_number, c.primary_type, a.area_name
FROM crimes c
JOIN community_areas a ON (c.community_area = a.area_code)
LIMIT 15;
