#!/bin/bash

# Catch signals
trap "/soe/scripts/monit_stop_all_wait.sh ; exit" EXIT

# Monit will start all apps
service monit start

# Stay up for container to stay alive
while [ 1 ] ; do
   sleep 1d
done
