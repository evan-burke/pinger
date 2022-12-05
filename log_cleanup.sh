#!/bin/bash

# WIP

# This organizes old ping logs by date.
# Only archives cron-generated ping logs, not manually run ones.

log_dir="${HOME}/logs_pings"

cleanup_log="${log_dir}/cleanup.log"

archive_dir="${log_dir}/archive"


# ======================================
# ======================================


function parse_date(){
    # given a ping log file, get the date string from it
    # pinglog_cron_2022-12-02_13-30.txt

    logdate=$(echo "$1" | sed "s/pinglog_cron_//g" | cut -d\_ -f1)
    if [[ -n "$logdate" ]]; then
      echo "error: couldn't parse date from filename $1"
      exit 1
    fi
    echo "$logdate"
}


if [[ ! -d "$archive_dir" ]]; then
  mkdir -p "$archive_dir"
fi




old_files=$(find "$log_dir" -maxdepth 1 -name "pinglog_cron*" -mtime +7)

file_count=$(echo "$old_files" | wc -l)

if [[ "$file_count" -lt 1 ]]; then
  echo "no old files found $(date)" >> "$cleanup_log"
  exit 0
else
  echo "found $file_count files to clean up" >> "$cleanup_log"
fi





echo "$old_files" | 
while read in; do
  file_date=$(parse_date "$in")
  echo "$in  $file_date"

done