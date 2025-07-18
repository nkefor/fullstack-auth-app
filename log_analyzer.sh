#!/bin/bash

# log_analyzer.sh - A script to analyze web server log files.

# --- Configuration ---
LOG_FILE="access.log"

# --- Check if log file exists ---
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found at $LOG_FILE"
    exit 1
fi

# --- Report Generation ---

echo "======================================="
echo "      Web Server Log Analysis Report   "
echo "======================================="
echo "Generated on: $(date)"
echo ""

# --- Analysis --- 

# 1. Total number of requests
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")
echo "[*] Total Requests: $TOTAL_REQUESTS"
echo ""

# 2. Top 5 most requested pages
echo "[*] Top 5 Most Requested Pages:"
# awk prints the 7th column (the URL), sort groups them, uniq counts them,
# sort -nr sorts numerically in reverse, and head -n 5 gets the top 5.
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5
echo ""

# 3. Top 5 visitor IP addresses
echo "[*] Top 5 Visitor IP Addresses:"
# awk prints the 1st column (the IP), sort groups them, uniq counts them,
# sort -nr sorts numerically in reverse, and head -n 5 gets the top 5.
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5
echo ""

# 4. Count of HTTP status codes
echo "[*] HTTP Status Code Summary:"
# awk prints the 9th column (the status code), sort groups them, uniq counts them.
awk '{print $9}' "$LOG_FILE" | sort | uniq -c
echo ""

# 5. Count of 404 Not Found errors
NOT_FOUND_ERRORS=$(grep ' 404 ' "$LOG_FILE" | wc -l)
echo "[*] Total 404 (Not Found) Errors: $NOT_FOUND_ERRORS"
echo ""

echo "======================================="
echo "          End of Report              "
echo "======================================="
