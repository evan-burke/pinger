# pinger

cron entry should look something like:

`*/15 * * * * /bin/bash ${HOME}/pinglog.sh >> ${HOME}/logs_pings/cron.log 2>&1`
