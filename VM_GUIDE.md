# VM Execution & Screenshot Guide

This guide will walk you through exactly how to run this project on your University Hadoop/Hive Virtual Machine (VM) and exactly **when and how to take the screenshots** required for your final report and presentation.

---

## Step 1: Get the Code onto Your VM
Open the terminal on your VM and clone your GitHub repository:
```bash
git clone https://github.com/aksharsakhi/Big-Data-Analytics-of-Crime-Patterns.git
cd Big-Data-Analytics-of-Crime-Patterns
```

---

## Step 2: Start Hadoop Services
Before doing anything, ensure your Hadoop cluster is running.
```bash
# Start HDFS and YARN (Commands may vary slightly depending on your VM setup)
start-dfs.sh
start-yarn.sh
jps
```
> **Tip:** You should see processes like `NameNode`, `DataNode`, `ResourceManager`, and `NodeManager` running.

---

## Step 3: Download & Prepare the Dataset
Run the download and preprocessing scripts:
```bash
chmod +x download_dataset.sh setup_hdfs.sh run_mapreduce.sh run_hive.sh
./download_dataset.sh
python3 preprocess.py
```
*(This will download 10,000 records and clean out bad newline characters).*

---

## Step 4: Upload to HDFS & Take Screenshot 1
Run the HDFS setup script to push the data into Hadoop:
```bash
./setup_hdfs.sh
```

📸 **SCREENSHOT 1: HDFS Storage**
Run the following command to verify the file is in HDFS, and **take a screenshot of the output**:
```bash
hdfs dfs -ls /user/$USER/bigdata_project/crimes/
```
*(Place this screenshot under "11.1 HDFS Storage" in your report).*

---

## Step 5: Run MapReduce & Take Screenshot 2
Execute the MapReduce script:
```bash
./run_mapreduce.sh
```

📸 **SCREENSHOT 2: MapReduce Execution**
While the script is running, the terminal will show lines like:
`map 0% reduce 0%`
`map 100% reduce 100%`
**Take a screenshot while this is happening or right after it finishes.** 
*(Place this under "11.2 MapReduce Execution" in your report).*

---

## Step 6: MapReduce Output & Take Screenshot 3
If Step 5 succeeds, the script will automatically print the top 20 lines of the output. 

📸 **SCREENSHOT 3: MapReduce Output**
If you missed the output in Step 5, you can run this command to see it again:
```bash
hdfs dfs -cat /user/$USER/bigdata_project/crime_output/part-r-00000 | head -n 20
```
**Take a screenshot showing the Crime Types (like THEFT, BATTERY) and their counts.**
*(Place this under "11.3 Output Screenshots" in your report).*

---

## Step 7: Run Hive Queries & Take Screenshot 4
Run the Hive script which will create the table and execute all 10 queries:
```bash
./run_hive.sh
```

📸 **SCREENSHOT 4: Hive Query Results**
The script will output the results of all 10 queries one by one. 
**Take a screenshot (or multiple screenshots) showing the SQL queries and their resulting tables on your terminal screen.**
*(Place this under "12.2 Screenshot of Query Results" in your report).*

---

## Final Step: Insert Screenshots into LaTeX
Once you have your 4 screenshots:
1. Save them in the `presentation/images/` folder on your laptop.
2. Open `presentation/report.tex` and `presentation/presentation.tex`.
3. Find the `% \includegraphics...` lines.
4. Uncomment them (remove the `%`) and change the filename to match your screenshots.
5. Recompile the LaTeX file.

You are completely done!
