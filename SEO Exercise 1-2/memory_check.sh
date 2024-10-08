#!/bin/bash
# Use free command, filtered by memory through grep to store machine's total and current memory into variables
TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }' )
CURRENT_MEMORY=$( free | grep Mem: | awk '{ print $3 }' )

# Loop to store parameters of -c, -w, and -e into variables
while getopts c:w:e: arg; do
    case $arg in
        c) ca=$OPTARG;;
        w) wa=$OPTARG;;
        e) ea=$OPTARG;;
        # Check for foreign parameters
        /?) echo "Required parameters are -c for critical level in percentage, -w for warning level in percentage, and -e for email address to send warnings to."
    esac
done

# Check if there are any missing parameters
if [ ! "$ca" ] || [ ! "$wa" ] || [ ! "$ea" ] ; then
    echo "Must provide parameters for c, w, and e"
    exit 1
fi

# Terminates program if critical threshold is lower than warning threshold
if [ $wa -ge $ca ]; then
    echo "(c)ritical threshold must be higher than (w)arning threshold."
    exit 1
fi

# Use awk to allow for percentage to be expressed as float
critical=$(awk "BEGIN {print $ca / 100}")
warning=$(awk "BEGIN {print $wa / 100}")

# Use awk to check what critical and warning levels are by multiplying total memory to the ratios
CRITICAL_MEMORY=$(awk "BEGIN {print $TOTAL_MEMORY * $critical}")
WARNING_MEMORY=$(awk "BEGIN {print $TOTAL_MEMORY * $warning}")

# Converts memory from float to int for comparison below
CRITICAL_MEMORY=$(printf "%.0f" "$CRITICAL_MEMORY")
WARNING_MEMORY=$(printf "%.0f" "$WARNING_MEMORY")

# Checks the value of current memory vs critical then warning memory
if [ $CURRENT_MEMORY -gt $CRITICAL_MEMORY ]; then
    echo "Memory is above critical threshold."
    # Runs ps command filtered by top memory usage
    ERROR_LOG=$(ps -eo pid,cmd,%mem --sort=-%mem | head)
    # Gets current time and date for email subject
    timestamp=$(date +"%Y%m%d %H:%M Memory check - critical")
    # Sends email report to -e email
    echo "$ERROR_LOG" | mailx -s "$timestamp" "$ea"
    exit 2
fi

if [ $CURRENT_MEMORY -ge $WARNING_MEMORY ]; then
    echo "Memory is above warning threshold."
    exit 1
fi

if [ $CURRENT_MEMORY -lt $WARNING_MEMORY ]; then
    echo "Memory is below warning threshold."
    exit 0
fi