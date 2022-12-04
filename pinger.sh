#!/bin/bash

# If adding to cron,
# make sure you set this in your crontab so the script can tell if it's a cron run:
# RUN_BY_CRON=1


# ----------------------------------
# ----------------------------------

# 1 ping per second.
# 600 = 10m
# 18000 = 5 hours
default_pings=900


#ping="/sbin/ping"	#mac os
ping="/bin/ping"	#ubuntu


# no trailing slash
out_dir="${HOME}/logs_pings"


# ----------------------------------
# ----------------------------------


# Get config & do light validation

cfgfile="${HOME}/.pinger/config.cfg"

function get_config_item(){
  # given a string $1 corresponding to a config item in $cfgfile
  # e.g.,
  # my_ping_interval=2
  # return the value for it,
  # erroring if it can't be retrieved.

  # Configfile line must begin with exactly $1;
  # no whitespace or other characters before; only =[value] following.

  local cfgname
  local cfgline
  local cfgval

  cfgname="$1"

  # make sure the config item exists
  cfgline=$(grep ^"${cfgname}\=" "$cfgfile")
  if [[ -z "$cfgline" ]]; then
    >&2 echo "error: config item $cfgname not found in $cfgfile"
    exit 0
  fi

  # make sure the config value is non-null
  # shellcheck disable=SC1001
  cfgval=$(echo "$cfgline" | cut -d\= -f2 | sed -e 's/^[[:space:]]*//;s/[[;space:]]*$//')

  if [[ -z "$cfgval" ]]; then
    >&2 echo "error: config item $cfgname is missing a value in $cfgfile"
    exit 0
  fi

  echo "$cfgval"

}

if [[ ! -f "$cfgfile" ]]; then
  echo "config file does not exist: $cfgfile"
  exit 1
fi

if [[ ! -d "$out_dir" ]]; then
  echo "output dir does not seem to exist, creating it: $out_dir"
  mkdir -p "$out_dir"
fi

#cfg=$(cat "$cfgfile")
#ping_destination=$(echo "$cfg" | grep ^ping_destination | cut -d\= -f2)
ping_destination=$(get_config_item "ping_destination")
#host=$(echo "$cfg" | grep ^host | cut -d\= -f2)
host=$(get_config_item "host")


if [[ "$1" -gt 0 ]]; then
  pings="$1"
else
  pings="$default_pings"
fi

if [[ -z "$ping_destination" ]]; then
  echo "error: please configure the ping_destination variable"
  exit 0
fi

if [[ -z "$host" ]]; then
  echo "error: please configure the host variable"
  exit 0
fi


# ----------------------------------
# ----------------------------------

if [[ "$RUN_BY_CRON" -gt 0 ]]; then
  #echo "cron $(date)"
  print_output=0
  cron_str="cron_"
else
  # echo output when run interactively
  print_output=1
  echo "nocron $(date)"
fi

echo "pd: $ping_destination"
echo "host: $host"

exit 0

ymd=$(date '+%Y-%m-%d_%H-%M')
echo "$ymd"


final=0
# warns about read without -r mangling backspaces, but we shouldn't have any backspaces
# shellcheck disable=SC2162
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
  echo "$str" >> "${out_dir}/pinglog_${cron_str}${ymd}.txt"
  if [[ "$print_output" -eq 1 ]]; then
    echo "$str"
  fi
done
