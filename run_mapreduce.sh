#!/bin/bash

# Script to compile and run the MapReduce program

echo "Cleaning up old compiled classes..."
rm -rf classes
mkdir classes

echo "Compiling CrimeTypeCount.java..."
javac -classpath `hadoop classpath` -d classes src/CrimeTypeCount.java

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Creating JAR file..."
jar -cvf crimecount.jar -C classes/ .

HDFS_INPUT="/user/${USER}/bigdata_project/crimes"
HDFS_OUTPUT="/user/${USER}/bigdata_project/crime_output"

echo "Removing old HDFS output directory if exists..."
hdfs dfs -rm -r -f ${HDFS_OUTPUT}

echo "Running MapReduce job..."
hadoop jar crimecount.jar bigdata.CrimeTypeCount ${HDFS_INPUT} ${HDFS_OUTPUT}

if [ $? -eq 0 ]; then
    echo "MapReduce job completed successfully."
    echo "Displaying output:"
    hdfs dfs -cat ${HDFS_OUTPUT}/part-r-00000 | head -n 20
else
    echo "MapReduce job failed."
    exit 1
fi
