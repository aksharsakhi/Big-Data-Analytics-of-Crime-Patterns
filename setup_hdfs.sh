#!/bin/bash

# Script to set up HDFS directories and upload the dataset

HDFS_DIR="/user/${USER}/bigdata_project/crimes"
LOCAL_FILE="dataset/chicago_crimes_clean.csv"

echo "Creating HDFS directory: ${HDFS_DIR}"
hdfs dfs -mkdir -p ${HDFS_DIR}

echo "Uploading dataset to HDFS..."
hdfs dfs -put -f ${LOCAL_FILE} ${HDFS_DIR}/

echo "Verifying upload..."
hdfs dfs -ls ${HDFS_DIR}/

echo "Dataset uploaded to HDFS successfully."
