# pinger

Quick and dirty telemetry logging for my flaky internet connection, based on `ping`.


cron entry should look something like:

`*/15 * * * * /bin/bash ${HOME}/pinglog.sh >> ${HOME}/logs_pings/cron.log 2>&1`

### Parsing output:
```
# packet loss stats:
grep packet ~/logs_pings/pinglog_cron_2022-12-04_*

# packet rtt stats:
grep rtt ~/logs_pings/pinglog_cron_2022-12-04_*
```
