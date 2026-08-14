# Big Data Analytics of Crime Patterns using Hadoop MapReduce and Apache Hive

**Course:** 23CSE352: Big Data Analytics  
**Institution:** Amrita Vishwa Vidyapeetham  
**Team Members:** Sheela Akshar Sakhi & Nishanth S Gowda  

---

## 📌 Project Overview

This project implements an end-to-end Big Data analytics pipeline to process, analyze, and extract actionable public safety intelligence from large-scale incident records in the **City of Chicago Crimes dataset**. 

Using **Hadoop MapReduce** for parallel frequency aggregation and **Apache Hive** for relational data warehousing, the system extracts high-crime spatial hotspots, domestic crime rates, arrest efficiencies, and category-wise statistics.

---

## 📄 Key Deliverables & Quick Links

* 📑 **[Project Report (PDF)](presentation/report.pdf)** - Complete 17-section academic report aligned with rubric instructions, featuring 17 embedded VM execution screenshots.
* 📊 **[Presentation Deck (PDF)](presentation/presentation.pdf)** - 20-slide academic Beamer presentation with live execution proof slides.
* 🛠️ **[VM Execution Guide (Markdown)](VM_GUIDE.md)** - Step-by-step walkthrough for running the pipeline on a Linux Virtual Machine.

---

## 🏗️ System Architecture

```
+------------------+      +-------------------+      +-----------------------+
| Chicago Crimes   | ---> | Python            | ---> | HDFS Distributed      |
| API / Raw CSV    |      | Preprocessing     |      | Data Lake             |
+------------------+      +-------------------+      +-----------------------+
                                                                |
                                                +---------------+---------------+
                                                |                               |
                                                v                               v
                                    +-----------------------+       +-----------------------+
                                    | Hadoop MapReduce      |       | Apache Hive           |
                                    | (Java YARN Job)       |       | (OpenCSVSerde SQL)    |
                                    +-----------------------+       +-----------------------+
```

1. **Data Ingestion & Preprocessing:** 
   - Real-world crime incident records downloaded via the Socrata Open Data API.
   - Cleaned via `preprocess.py` to replace embedded newlines (`\n`) inside double-quoted text fields, ensuring row alignment for Hadoop `TextInputFormat` (29,913 clean rows).
   - Uploaded into HDFS at `/user/hadoop/bigdata_project/crimes/chicago_crimes_clean.csv`.

2. **Hadoop MapReduce:**
   - **Mapper (`CrimeMapper`):** Uses regular expression splitting `,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)` to parse CSV columns safely and emit `(CrimeType, 1)`.
   - **Reducer (`CrimeReducer`):** Aggregates intermediate key-value pairs to compute frequency counts per category (`THEFT: 2,150`, `BATTERY: 1,857`, `CRIMINAL DAMAGE: 1,207`).

3. **Apache Hive Analytics:**
   - External table `crimes` created with `org.apache.hadoop.hive.serde2.OpenCSVSerde`.
   - 10 complex queries executed covering `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `MAX`, `MIN`, and `JOIN` operations.

---

## 📊 Hive Queries Mapping Table

| Requirement | Query Focus | Business Intelligence Goal |
| :--- | :--- | :--- |
| **SELECT** | Q1: Retrieve basic records | Previewing raw incident data attributes |
| **WHERE** | Q2: Filter Narcotics arrests | Measuring targeted drug enforcement incidents |
| **ORDER BY** | Q3: Sort Homicides chronologically | Analyzing severe violent crime recency |
| **GROUP BY & COUNT** | Q4: Crimes per location type | Identifying high-crime spatial hotspots (Street: 6,244) |
| **HAVING** | Q5: Major categories (> 500 cases) | Filtering out low-frequency outlier crimes |
| **SUM** | Q6: Arrests per district | Calculating total arrests per police district (Dist 11: 280) |
| **AVG** | Q7: Domestic crime rate per beat | Computing average domestic violence ratio per beat (Beat 1024: 46.3%) |
| **MAX** | Q8: District with highest crime | Pinpointing maximum incident volume district (Dist 12: 1,276) |
| **MIN** | Q9: District with lowest crime | Pinpointing minimum incident volume district (Dist 20: 404) |
| **JOIN** | Q10: Join Crimes & Community Areas | Merging area codes with neighborhood names |

---

## 🚀 Step-by-Step Manual Execution Guide (VM Terminal)

### 1. Start Hadoop Daemons
```bash
hdfs --daemon start namenode
hdfs --daemon start datanode
hdfs --daemon start secondarynamenode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
jps
```

### 2. Ingestion & HDFS Upload
```bash
python3 preprocess.py
hdfs dfs -mkdir -p /user/hadoop/bigdata_project/crimes
hdfs dfs -put -f dataset/chicago_crimes_clean.csv /user/hadoop/bigdata_project/crimes/
hdfs dfs -ls /user/hadoop/bigdata_project/crimes/
```

### 3. Compile & Run MapReduce
```bash
rm -rf classes && mkdir classes
javac -source 1.8 -target 1.8 -classpath `hadoop classpath` -d classes src/CrimeTypeCount.java
jar -cvf crimecount.jar -C classes/ .
hdfs dfs -rm -r -f /user/hadoop/bigdata_project/crime_output
hadoop jar crimecount.jar bigdata.CrimeTypeCount /user/hadoop/bigdata_project/crimes /user/hadoop/bigdata_project/crime_output
hdfs dfs -cat /user/hadoop/bigdata_project/crime_output/part-r-00000 | head -n 20
```

### 4. Run Apache Hive Analytics
```bash
rm -rf metastore_db
schematool -dbType derby -initSchema
hive -f crime_analysis.hql > hive_output.txt
```

---

## 📂 Repository Structure

```
.
├── README.md                           # Comprehensive project documentation
├── VM_GUIDE.md                         # Step-by-step VM screenshot & execution guide
├── preprocess.py                       # Python script to fix embedded newlines in CSV
├── download_dataset.sh                 # Script to fetch Chicago Crimes data
├── setup_hdfs.sh                       # Script to initialize HDFS directories
├── run_mapreduce.sh                    # Script to compile & run MapReduce job
├── run_hive.sh                         # Script to execute Hive queries
├── crime_analysis.hql                  # 10 HiveQL analytical queries
├── dataset/
│   └── community_areas.csv             # Community area code mapping for Hive JOIN
├── src/
│   └── CrimeTypeCount.java             # MapReduce Java source code (Mapper + Reducer)
└── presentation/
    ├── report.tex                      # Complete 17-section LaTeX report source
    ├── report.pdf                      # Final compiled report PDF
    ├── presentation.tex                # LaTeX Beamer presentation source
    ├── presentation.pdf                # Final compiled presentation PDF
    └── new_img/                        # 17 live VM execution screenshots
```

---

## 🛠️ Technology Stack
* **Storage:** Hadoop Distributed File System (HDFS)
* **Compute:** Apache Hadoop MapReduce (Java YARN)
* **Data Warehouse:** Apache Hive (OpenCSVSerde)
* **Languages:** Java 8, Python 3, HiveQL, LaTeX (Beamer & Article)
