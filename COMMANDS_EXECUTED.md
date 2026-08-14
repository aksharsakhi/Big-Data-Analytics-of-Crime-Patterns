# Commands Executed From Starting

This document provides a complete, step-by-step chronological log of every single terminal command executed to build, run, evaluate, and generate deliverables for this project.

---

## 📌 Phase 1: Project Repository Setup & Git Initializing

Run on Host System (Mac Terminal):
```bash
# Navigate to workspace directory
cd /Users/aksharsakhi/Documents/Files/VScode/Amrita/Big_Data

# Create and rename project directory
mv BigDataProject Big-Data-Analytics-of-Crime-Patterns
cd Big-Data-Analytics-of-Crime-Patterns

# Initialize Git repository and add remote
git init
git remote add origin https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns.git
```

---

## 📌 Phase 2: Virtual Machine Environment Setup

Run on Virtual Machine Terminal (`hadoop@aksharsakhi-QEMU-Virtual-Machine`):
```bash
# Clone the repository onto the VM
git clone https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns.git

# Enter project folder
cd Big-Data-Analytics-of-Crime-Patterns

# Grant execution permissions to shell scripts
chmod +x *.sh
```

---

## 📌 Phase 3: Hadoop & YARN Daemon Startup

Run on VM Terminal to manually start Hadoop services (no `.sh` extensions):
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

## 📌 Phase 4: Data Download & Preprocessing

Run on VM Terminal:
```bash
# Pull latest repository updates
git pull

# Download Chicago Crimes dataset (10,000 records via Socrata API)
mkdir -p dataset
wget -q -O dataset/chicago_crimes_10k.csv "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?\$limit=10000"

# Clean multi-line string newlines using Python
python3 preprocess.py
```

---

## 📌 Phase 5: HDFS Storage Upload

Run on VM Terminal:
```bash
# Create HDFS destination directory
hdfs dfs -mkdir -p /user/hadoop/bigdata_project/crimes

# Upload cleaned dataset to HDFS datalake
hdfs dfs -put -f dataset/chicago_crimes_clean.csv /user/hadoop/bigdata_project/crimes/

# Verify HDFS upload (Screenshot 1: hdfs_screenshot.png)
hdfs dfs -ls /user/hadoop/bigdata_project/crimes/
```

---

## 📌 Phase 6: MapReduce Compilation & YARN Execution

Run on VM Terminal:
```bash
# Clean previous build artifacts
rm -rf classes && mkdir classes

# Compile Java MapReduce program targeting Java 8 runtime
javac -source 1.8 -target 1.8 -classpath `hadoop classpath` -d classes src/CrimeTypeCount.java

# Package compiled class files into JAR executable
jar -cvf crimecount.jar -C classes/ .

# Remove stale HDFS output directory if present
hdfs dfs -rm -r -f /user/hadoop/bigdata_project/crime_output

# Execute MapReduce job on Hadoop YARN Cluster (Screenshot 2: mr_execution2.png)
hadoop jar crimecount.jar bigdata.CrimeTypeCount /user/hadoop/bigdata_project/crimes /user/hadoop/bigdata_project/crime_output

# Display MapReduce frequency counts output (Screenshot 3: mr_output.png)
hdfs dfs -cat /user/hadoop/bigdata_project/crime_output/part-r-00000 | head -n 20
```

---

## 📌 Phase 7: Apache Hive Metastore Reset & SQL Analytics Execution

Run on VM Terminal:
```bash
# Reset Derby metastore to prevent locks
rm -rf metastore_db

# Initialize Derby Metastore database schema
schematool -dbType derby -initSchema

# Option A: Batch execution of all 10 SQL queries
hive -f crime_analysis.hql > hive_output.txt

# Option B: Interactive Hive execution
hive
```

Interactive Hive Queries executed inside `hive>` shell:
```sql
-- Set active database
USE default;

-- Query 1: SELECT
SELECT id, primary_type, description, crime_date FROM crimes LIMIT 10;

-- Query 2: WHERE
SELECT id, primary_type, description, arrest FROM crimes WHERE primary_type = 'NARCOTICS' AND arrest = 'true' LIMIT 10;

-- Query 3: ORDER BY
SELECT case_number, primary_type, crime_date FROM crimes WHERE primary_type = 'HOMICIDE' ORDER BY crime_date DESC LIMIT 10;

-- Query 4: GROUP BY & COUNT
SELECT location_description, COUNT(*) AS crime_count FROM crimes GROUP BY location_description ORDER BY crime_count DESC LIMIT 15;

-- Query 5: HAVING
SELECT primary_type, COUNT(*) as total FROM crimes GROUP BY primary_type HAVING COUNT(*) > 500 ORDER BY total DESC;

-- Query 6: SUM
SELECT district, SUM(CASE WHEN arrest = 'true' THEN 1 ELSE 0 END) AS total_arrests FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY total_arrests DESC LIMIT 10;

-- Query 7: AVG
SELECT beat, AVG(CASE WHEN domestic = 'true' THEN 1.0 ELSE 0.0 END) AS avg_domestic FROM crimes WHERE beat IS NOT NULL AND beat != '' GROUP BY beat ORDER BY avg_domestic DESC LIMIT 10;

-- Query 8: MAX
SELECT district, COUNT(*) AS district_total FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY district_total DESC LIMIT 1;

-- Query 9: MIN
SELECT district, COUNT(*) AS district_total FROM crimes WHERE district IS NOT NULL AND district != '' GROUP BY district ORDER BY district_total ASC LIMIT 1;

-- Query 10: JOIN
SELECT c.case_number, c.primary_type, a.area_name FROM crimes c JOIN community_areas a ON (c.community_area = a.area_code) LIMIT 15;

-- Exit Hive shell
exit;
```

---

## 📌 Phase 8: Query Output Extraction for Screenshots

Run on VM Terminal to extract clean terminal views for screenshots:
```bash
# Query 1 to Q3 Output
head -n 35 hive_output.txt

# Query 4 to Q7 Output
sed -n '36,75p' hive_output.txt

# Query 8 to Q10 Output
tail -n 35 hive_output.txt
```

---

## 📌 Phase 9: LaTeX Compilation & Git Pushing

Run on Host System (Mac Terminal):
```bash
# Change to presentation directory
cd presentation

# Compile LaTeX Report PDF twice to build TOC and references
pdflatex -interaction=nonstopmode report.tex
pdflatex -interaction=nonstopmode report.tex

# Compile LaTeX Presentation PDF twice to build Beamer frames
pdflatex -interaction=nonstopmode presentation.tex
pdflatex -interaction=nonstopmode presentation.tex

# Clean up auxiliary LaTeX build files
find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.nav" -o -name "*.out" -o -name "*.snm" -o -name "*.toc" -o -name "*.vrb" \) -delete

# Navigate back to repository root
cd ..

# Stage, commit, and push all changes to GitHub
git add .
git commit -m "Add COMMANDS_EXECUTED.md detailing all commands executed from starting"
git push
```

---

## 🏆 Summary of Generated Deliverables
* 🌐 **GitHub Repository:** `https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns`
* 📑 **Project Report:** `presentation/report.pdf`
* 📊 **Presentation Deck:** `presentation/presentation.pdf`
* 📁 **Screenshots Folder:** `presentation/new_img/` (17 execution screenshots)
