#!/bin/bash

# 600 = 10m
# 18000 = 5 hours
default_pings=900

ping_destination=""
host=""

#ping="/sbin/ping"	#mac os
ping="/bin/ping"	#ubuntu

# no trailing slash
out_dir="~/logs_pings"


# ------------------------------


if [[ ! -z "$1" ]]; then
  pings="$1"
else
  pings="$default_pings"
fi

if [[ "$RUN_BY_CRON" -gt 0 ]]; then
  #echo "cron `date`"
  print_output=0
  cron_str="cron_"
else
  # echo output when run interactively
  print_output=1
  echo "nocron `date`"
fi

if [[ -z "$ping_destination" ]]; then
  echo "error: please configure the ping_destination variable"
  exit 0
fi

if [[ -z "$host" ]]; then
  echo "error: please configure the host variable"
  exit 0
fi


ymd=$(date '+%Y-%m-%d_%H-%M')
echo "$ymd"

final=0
$ping -c "$pings" "$ping_destination" |
while read in; do
  if echo "$in" | grep "baconridge.org ping statistics" > /dev/null; then
    final=1
    echo
  fi
  if [[ "$final" -eq 0 ]]; then
    str=$(echo "$host	$(date '+%s')     $(date)        $in" | sed "s/icmp_seq/ icmp_seq/g;s/icmp_seq /icmp_seq=/g;s/ ttl=/	ttl=/g;s/ time=/	time=/g")
  else
    str="$in"
  fi
  echo "$str" >> ${out_dir}/pinglog_${cron_str}${ymd}.txt
  if [[ "$print_output" -eq 1 ]]; then
    echo "$str"
  fi
done
