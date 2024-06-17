# GPU Temperature Monitoring and Reporting

This repository contains scripts for monitoring GPU temperatures on a server with Nvidia GPUs and generating monthly reports. The scripts use `nvidia-smi` to collect temperature data and `awk` to analyze the data.

## Author
  - Inderjeet Singh(Infosecsingh)
    -DevOps Engineer

## Files

- `collect_gpu_temp.sh`: Script to collect GPU temperature data.
- `analyze_gpu_temp.sh`: Script to analyze GPU temperature data and generate a monthly report.
- `gpu_temp_log.csv`: Log file storing temperature data.
- `gpu_temp_report.txt`: Monthly report file.

## Prerequisites

- Nvidia GPU drivers and `nvidia-smi` installed.
- Bash shell and `awk` available.

## Usage

### 1. Data Collection Script

The `collect_gpu_temp.sh` script collects the current temperature of all Nvidia GPUs and appends the data to `gpu_temp_log.csv`.

#### Script Contents:

```bash
#!/bin/bash

# Define log file
LOG_FILE="/path/to/gpu_temp_log.csv"

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
```

### 2. Analysis Script

The `analyze_gpu_temp.sh` script analyzes the temperature data collected over the last month and generates a report.

#### Script Contents:

```bash
#!/bin/bash

# Define log file and report file
LOG_FILE="/path/to/gpu_temp_log.csv"
REPORT_FILE="/path/to/gpu_temp_report.txt"

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
```

## Scheduling with Cron

### Data Collection

To schedule the `collect_gpu_temp.sh` script to run every hour, add the following entry to your crontab:

```bash
crontab -e
```

Add:
```bash
0 * * * * /path/to/collect_gpu_temp.sh
```

### Monthly Report Generation

To schedule the `analyze_gpu_temp.sh` script to run at the beginning of each month, add the following entry to your crontab:

```bash
crontab -e
```

Add:
```bash
0 0 1 * * /path/to/analyze_gpu_temp.sh
```

## Log Rotation

To prevent the log file from growing indefinitely, use `logrotate` to rotate the logs periodically.

### Logrotate Configuration

Create a configuration file for log rotation:

```bash
sudo nano /etc/logrotate.d/gpu_temp_log
```

Add the following content:

```plaintext
/path/to/gpu_temp_log.csv {
    monthly
    rotate 12
    compress
    missingok
    notifempty
    create 0644 root root
    postrotate
        /usr/bin/killall -HUP syslogd
    endscript
}
```

This configuration will:

- Rotate the log file monthly.
- Keep 12 months of logs.
- Compress old logs to save space.
- Skip rotation if the log file is missing or empty.
- Create a new log file with the specified permissions after rotation.


By following these instructions, you can monitor GPU temperatures, generate monthly reports, and manage log file sizes efficiently.

### Author : Inderjeet Singh (Infosecsingh)
