import pandas as pd
import datetime as dt

# Define log file
LOG_FILE = "gpu_temp_log.csv"
# Define report file
REPORT_FILE = "gpu_temp_report.txt"

# Load data
data = pd.read_csv(LOG_FILE, parse_dates=['timestamp'])

# Filter data for the last month
one_month_ago = dt.datetime.now() - pd.DateOffset(months=1)
filtered_data = data[data['timestamp'] >= one_month_ago]

# Analyze data
report = []
for gpu_id in filtered_data['gpu_id'].unique():
    gpu_data = filtered_data[filtered_data['gpu_id'] == gpu_id]
    avg_temp = gpu_data['temperature'].mean()
    max_temp = gpu_data['temperature'].max()
    min_temp = gpu_data['temperature'].min()
    
    report.append(f"GPU {gpu_id}:")
    report.append(f"  Average Temperature: {avg_temp:.2f} °C")
    report.append(f"  Max Temperature: {max_temp} °C")
    report.append(f"  Min Temperature: {min_temp} °C")
    
    # Check if cleaning is needed
    if max_temp > 80:  # Example threshold for cleaning
        report.append(f"  Action Required: Physical cleaning recommended.\n")
    else:
        report.append(f"  Status: No action required.\n")

# Write report to file
with open(REPORT_FILE, 'w') as f:
    f.write('\n'.join(report))