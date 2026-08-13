#!/bin/bash

# Script to download a subset (10,000 records) of the Chicago Crimes dataset.
# The URL uses the Socrata Open Data API to limit the records and get them in CSV format.

DATASET_URL="https://data.cityofchicago.org/resource/ijzp-q8t2.csv?\$limit=10000"
OUTPUT_DIR="dataset"
OUTPUT_FILE="${OUTPUT_DIR}/chicago_crimes_10k.csv"

echo "Creating dataset directory..."
mkdir -p ${OUTPUT_DIR}

echo "Downloading dataset from Chicago Data Portal..."
# Using curl or wget to download the dataset
if command -v curl &> /dev/null; then
    curl -s -L "${DATASET_URL}" -o "${OUTPUT_FILE}"
elif command -v wget &> /dev/null; then
    wget -q -O "${OUTPUT_FILE}" "${DATASET_URL}"
else
    echo "Error: Neither curl nor wget is installed."
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Download completed successfully."
    echo "File saved to ${OUTPUT_FILE}"
    echo "Number of lines in dataset: $(wc -l < ${OUTPUT_FILE})"
else
    echo "Failed to download the dataset."
    exit 1
fi
