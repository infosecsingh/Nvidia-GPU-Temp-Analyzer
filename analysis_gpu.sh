#!/bin/bash
#####################################################################################################################
##     anaylsis_gpu.sh
##
## DESCRIPTION:
##      This script will analysis the collected Nvidia GPU Tempareture Timestamp and give us report with gpu_temp_report.txt
##      This script can be used for all NVIDIa based GPU. 
##
##
## AUTHOR:
##      Inderjeet Singh
##      Senior IT Specialist 
##
## DATE: 4th June 2024
#####################################################################################################################

# Define log file and report file
LOG_FILE="gpu_temp_log.csv"
REPORT_FILE="gpu_temp_report.txt"

# Get the current date and the date one month ago
current_date=$(date '+%Y-%m-%d')
one_month_ago=$(date -d "$current_date -1 month" '+%Y-%m-%d')

# Filter data for the last month and analyze it using awk
awk -F, -v start_date="$one_month_ago" -v end_date="$current_date" '
BEGIN {
  OFS = FS
  print "GPU Temperature Report"
  print "From: " start_date " To: " end_date
  print ""
}
NR > 1 {
  split($1, date, " ")
  if (date[1] >= start_date && date[1] <= end_date) {
    gpu_id[$2]++
    sum[$2] += $3
    if ($3 > max[$2] || !max[$2]) max[$2] = $3
    if ($3 < min[$2] || !min[$2]) min[$2] = $3
  }
}
END {
  for (id in gpu_id) {
    avg = sum[id] / gpu_id[id]
    print "GPU " id ":"
    print "  Average Temperature: " avg " °C"
    print "  Max Temperature: " max[id] " °C"
    print "  Min Temperature: " min[id] " °C"
    if (max[id] > 80) {
      print "  Action Required: Physical cleaning recommended.\n"
    } else {
      print "  Status: No action required.\n"
    }
  }
}' "$LOG_FILE" > "$REPORT_FILE"