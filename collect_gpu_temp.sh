#!/bin/bash
#####################################################################################################################
##     collect_gpu_temp.sh
##
## DESCRIPTION:
##      This script will help to collect Nvidia GPU Tempareture Timestamp...
##      This script can be used for all NVIDIa based GPU. 
##
##  For EHL. recommendation to execute in worker node.
##     - For 1.5.x EHL, this script needs to run in Minion 4 
##     - For 1.3 EHL, this script needs to run in Minion 3
##
## AUTHOR:
##      Inderjeet Singh
##      Senior IT Specialist - Edison. 
##      GE HealthCare Digital
##
## DATE: 4th June 2024
#####################################################################################################################

# Define log file
LOG_FILE="gpu_temp_log.csv"

# Check if log file exists, if not create and add header
if [ ! -f "$LOG_FILE" ]; then
  echo "timestamp,gpu_id,temperature" > "$LOG_FILE"
fi

# Get the current timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Collect GPU temperature using nvidia-smi and append to log file
nvidia-smi --query-gpu=index,temperature.gpu --format=csv,noheader,nounits | while IFS=',' read -r gpu_id temperature; do
  echo "$timestamp,$gpu_id,$temperature" >> "$LOG_FILE"
done