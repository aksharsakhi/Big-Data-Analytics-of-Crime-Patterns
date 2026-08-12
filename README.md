# Big Data Analytics of Crime Patterns using Hadoop MapReduce and Apache Hive

This project demonstrates a comprehensive Big Data pipeline to analyze and process large-scale incident reports from the Chicago Crimes dataset. It utilizes Hadoop MapReduce for distributed data processing and Apache Hive for relational analytics.

## Project Architecture

1. **Data Ingestion & Preprocessing:** 
   - A dataset of 10,000 recent Chicago Crime records is downloaded via the Socrata API.
   - The data is cleaned using a Python script to ensure compatibility with Hadoop's `TextInputFormat` (removing embedded newlines).
   - The processed data is uploaded to a centralized HDFS datalake.

2. **Hadoop MapReduce:**
   - A custom Java MapReduce application processes the unstructured CSV data.
   - **Mapper:** Extracts the primary crime type from each record and emits a count of 1.
   - **Reducer:** Aggregates the counts to determine the overall frequency of each crime category (e.g., THEFT, BATTERY).

3. **Apache Hive Analytics:**
   - Data is queried using HiveQL via an `OpenCSVSerde` external table.
   - 10 complex queries are executed to extract business intelligence (including SELECT, WHERE, ORDER BY, GROUP BY, HAVING, COUNT, SUM, AVG, MAX, MIN, and JOIN operations).

## Repository Structure

* `dataset/`: Contains the initial and cleaned CSV files (tracked out via `.gitignore` to prevent large uploads).
* `src/`: Contains the Java MapReduce source code (`CrimeTypeCount.java`).
* `presentation/`: Contains the LaTeX source code and compiled PDFs for both the presentation slides and the final project report.
* `VM_GUIDE.md`: A step-by-step tutorial on how to execute the project on a VM and capture screenshots for grading.
* `download_dataset.sh`: Shell script to fetch the Chicago Crimes data.
* `preprocess.py`: Python script to clean the raw data.
* `setup_hdfs.sh`: Script to initialize HDFS directories and upload the cleaned data.
* `run_mapreduce.sh`: Script to compile the Java code into a JAR and execute it on the Hadoop cluster.
* `run_hive.sh`: Script to execute the Hive analytics queries.

## Getting Started

> **🚨 GRADING & REVIEW:** If you are running this for your university review, please follow the exact step-by-step instructions in the [VM Execution Guide](VM_GUIDE.md) to ensure you capture all required screenshots correctly!

### Quick Start
1. Download the dataset: `./download_dataset.sh`
2. Clean the dataset: `python3 preprocess.py`
3. Upload to HDFS: `./setup_hdfs.sh`
4. Run the MapReduce job: `./run_mapreduce.sh`
5. Run the Hive queries: `./run_hive.sh`

## Built With
* [Apache Hadoop](https://hadoop.apache.org/) - Distributed data processing framework.
* [Apache Hive](https://hive.apache.org/) - Data warehouse software for reading, writing, and managing large datasets.
* [Java](https://www.java.com/) - Core language for MapReduce logic.
* [LaTeX](https://www.latex-project.org/) - Used for creating the premium academic report and presentation.
