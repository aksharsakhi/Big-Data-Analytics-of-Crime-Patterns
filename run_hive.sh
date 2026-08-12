#!/bin/bash

# Script to run the Hive analysis

echo "Starting Hive script execution..."
echo "This may take a few minutes."

# Run the Hive script and redirect output to a file for saving screenshots later
hive -f crime_analysis.hql > hive_output.txt 2> hive_error.log

if [ $? -eq 0 ]; then
    echo "Hive execution completed successfully."
    echo "Results saved to hive_output.txt."
    echo ""
    echo "=== Top 20 lines of Hive Output ==="
    head -n 20 hive_output.txt
else
    echo "Hive execution failed. Check hive_error.log for details."
    exit 1
fi
