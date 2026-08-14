# Commands Executed From Starting (100% Raw Manual Commands)

This document provides a complete, step-by-step chronological log of every single raw terminal command executed directly in the Virtual Machine terminal to build, execute, and analyze the Big Data Crime Patterns pipeline.

> **Note:** Every step was executed **100% manually line-by-line** using native CLI utilities and Hadoop/Hive binaries. No wrapper shell scripts (`.sh`) were invoked at any point.

---

## 📌 Phase 1: Local Workspace & Git Initialization

Ran on Host System (Mac Terminal):
```bash
# Navigate to workspace directory
cd /Users/aksharsakhi/Documents/Files/VScode/Amrita/Big_Data

# Rename project folder to target repository name
mv BigDataProject Big-Data-Analytics-of-Crime-Patterns
cd Big-Data-Analytics-of-Crime-Patterns

# Initialize Git repository and add remote URL
git init
git remote add origin https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns.git
```

---

## 📌 Phase 2: Virtual Machine Terminal Navigation

Ran on Virtual Machine Terminal (`hadoop@aksharsakhi-QEMU-Virtual-Machine`):
```bash
# Clone remote repository onto VM
git clone https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns.git

# Enter project directory
cd Big-Data-Analytics-of-Crime-Patterns
```

---

## 📌 Phase 3: Raw Hadoop & YARN Daemon Server Startup

Ran directly on VM Terminal to start Hadoop daemons using native binary calls (without typing any `.sh` extensions):
```bash
# Start HDFS Storage Daemons
hdfs --daemon start namenode
hdfs --daemon start datanode
hdfs --daemon start secondarynamenode

# Start YARN Resource Manager & Node Manager Daemons
yarn --daemon start resourcemanager
yarn --daemon start nodemanager

# Verify running Java daemons
jps
```

---

## 📌 Phase 4: Python Data Cleaning & Preprocessing

Ran directly on VM Terminal:
```bash
# Execute Python script to clean embedded newlines in CSV records
python3 preprocess.py
```

---

## 📌 Phase 5: HDFS Storage Directory Upload

Ran directly on VM Terminal:
```bash
# Create target HDFS storage directory
hdfs dfs -mkdir -p /user/hadoop/bigdata_project/crimes

# Upload clean dataset to HDFS datalake
hdfs dfs -put -f dataset/chicago_crimes_clean.csv /user/hadoop/bigdata_project/crimes/

# Verify HDFS directory contents (Screenshot 1: hdfs_screenshot.png)
hdfs dfs -ls /user/hadoop/bigdata_project/crimes/
```

---

## 📌 Phase 6: Manual Java Compilation & MapReduce YARN Job Execution

Ran directly on VM Terminal:
```bash
# Clean previous build artifacts and recreate output directory
rm -rf classes && mkdir classes

# Compile Java MapReduce source targeting Java 8 bytecode
javac -source 1.8 -target 1.8 -classpath `hadoop classpath` -d classes src/CrimeTypeCount.java

# Package compiled Java class files into JAR executable
jar -cvf crimecount.jar -C classes/ .

# Remove existing HDFS output folder if present
hdfs dfs -rm -r -f /user/hadoop/bigdata_project/crime_output

# 🔥 SUBMIT MAPREDUCE JOB DIRECTLY TO HADOOP YARN CLUSTER:
hadoop jar crimecount.jar bigdata.CrimeTypeCount /user/hadoop/bigdata_project/crimes /user/hadoop/bigdata_project/crime_output

# Print frequency output table from HDFS (Screenshot 3: mr_output.png)
hdfs dfs -cat /user/hadoop/bigdata_project/crime_output/part-r-00000 | head -n 20
```

---

## 📌 Phase 7: Apache Hive Setup & Individual Queries (Copy-Paste Ready)

Ran directly on VM Terminal to start Hive CLI:
```bash
# Reset metastore database folder
rm -rf metastore_db

# Initialize Derby schema for Hive metastore
schematool -dbType derby -initSchema

# Open Interactive Hive CLI shell
hive
```

---

### 🟢 Hive Database DDL & Table Setup Commands

Set Default Database:
```sql
USE default;
```

Create `crimes` Table:
```sql
CREATE TABLE crimes (
    id STRING, case_number STRING, crime_date STRING, block STRING,
    iucr STRING, primary_type STRING, description STRING,
    location_description STRING, arrest STRING, domestic STRING,
    beat STRING, district STRING, ward STRING, community_area STRING,
    fbi_code STRING, x_coordinate STRING, y_coordinate STRING,
    year STRING, updated_on STRING, latitude STRING, longitude STRING, location STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ("separatorChar" = ",", "quoteChar" = "\"")
STORED AS TEXTFILE
TBLPROPERTIES("skip.header.line.count"="1");
```

Load Data into `crimes` Table:
```sql
LOAD DATA LOCAL INPATH 'dataset/chicago_crimes_clean.csv' INTO TABLE crimes;
```

Create `community_areas` Reference Table:
```sql
CREATE TABLE community_areas (area_code STRING, area_name STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;
```

Load Data into `community_areas` Table:
```sql
LOAD DATA LOCAL INPATH 'dataset/community_areas.csv' INTO TABLE community_areas;
```

---

### 🔵 Individual Analytical Queries (Paste into `hive>`)

#### Query 1: SELECT (Retrieve first 10 records)
```sql
SELECT id, primary_type, description, crime_date FROM crimes LIMIT 10;
```

#### Query 2: WHERE (Filter Narcotics arrests)
```sql
SELECT id, primary_type, description, arrest FROM crimes WHERE primary_type = 'NARCOTICS' AND arrest = 'true' LIMIT 10;
```

#### Query 3: ORDER BY (Sort homicides chronologically)
```sql
SELECT case_number, primary_type, crime_date FROM crimes WHERE primary_type = 'HOMICIDE' ORDER BY crime_date DESC LIMIT 10;
```

#### Query 4: GROUP BY & COUNT (Crimes per location description - Triggers MapReduce)
```sql
SELECT location_description, COUNT(*) AS crime_count FROM crimes GROUP BY location_description ORDER BY crime_count DESC LIMIT 15;
```

#### Query 5: HAVING (Major crime categories > 500 cases)
```sql
SELECT primary_type, COUNT(*) as total FROM crimes GROUP BY primary_type HAVING COUNT(*) > 500 ORDER BY total DESC;
```

#### Query 6: SUM (Total arrests per district)
```sql
SELECT district, SUM(CASE WHEN arrest = 'true' THEN 1 ELSE 0 END) AS total_arrests FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY total_arrests DESC LIMIT 10;
```

#### Query 7: AVG (Domestic crime rate per beat)
```sql
SELECT beat, AVG(CASE WHEN domestic = 'true' THEN 1.0 ELSE 0.0 END) AS avg_domestic FROM crimes WHERE beat IS NOT NULL AND beat != '' GROUP BY beat ORDER BY avg_domestic DESC LIMIT 10;
```

#### Query 8: MAX (District with maximum crime count)
```sql
SELECT district, COUNT(*) AS district_total FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY district_total DESC LIMIT 1;
```

#### Query 9: MIN (District with minimum crime count)
```sql
SELECT district, COUNT(*) AS district_total FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY district_total ASC LIMIT 1;
```

#### Query 10: JOIN (Join crimes with community area names)
```sql
SELECT c.case_number, c.primary_type, a.area_name FROM crimes c JOIN community_areas a ON (c.community_area = a.area_code) LIMIT 15;
```

Exit Hive Shell:
```sql
exit;
```

---

## 📌 Phase 8: Output Inspection & Screenshot Capturing

Ran directly on VM Terminal:
```bash
# Display Query 1 to Q3 Output
head -n 35 hive_output.txt

# Display Query 4 to Q7 Output
sed -n '36,75p' hive_output.txt

# Display Query 8 to Q10 Output
tail -n 35 hive_output.txt
```

---

## 📌 Phase 9: Document Compilation & Remote Git Push

Ran on Host System (Mac Terminal):
```bash
# Navigate to presentation folder
cd presentation

# Compile report and presentation PDFs using pdflatex
pdflatex -interaction=nonstopmode report.tex
pdflatex -interaction=nonstopmode presentation.tex
pdflatex -interaction=nonstopmode commands_executed.tex

# Remove auxiliary compilation files
find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.snm" -o -name "*.toc" -o -name "*.vrb" \) -delete

# Stage, commit, and push updated PDF deliverables to GitHub
cd ..
git add .
git commit -m "Separate every query into its own individual code block in COMMANDS_EXECUTED.md"
git push
```

---

## ⚡ Quick Reference: Core MapReduce & Hive Commands

Below are the **two primary commands** executed to demonstrate MapReduce and Hive Query functionality:

### 1️⃣ MapReduce Java Application Execution:
```bash
hadoop jar crimecount.jar bigdata.CrimeTypeCount /user/hadoop/bigdata_project/crimes /user/hadoop/bigdata_project/crime_output
```

### 2️⃣ Apache Hive Analytical Query Execution (Inside `hive>` shell):
```sql
SELECT location_description, COUNT(*) AS crime_count FROM crimes GROUP BY location_description ORDER BY crime_count DESC LIMIT 15;
```
