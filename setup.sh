#!/bin/bash

# WIP

cfg_dir="${HOME}/.pinger"
cfg_file="${cfg_dir}/config.cfg"

# =================================

cfg_changed=0

if [[ ! -d "$cfg_dir" ]]; then
  echo "creating config dir"
  mkdir -p "$cfg_dir"
  cfg_changed=1
fi

if [[ ! -f "$cfg_file" ]]; then
  echo "creating config file"
  cp example_config.cfg "$cfg_file"
  echo "edit $cfg_file before running pinger"
  cfg_changed=1
fi


if [[ "$cfg_changed" -eq 0 ]]; then
  echo "already configured"
fi




