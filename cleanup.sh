#!/bin/bash

LOG_DIRS="server/logs bungee/logs"

while true; do
    for DIR in $LOG_DIRS; do
        if [ ! -d "$DIR" ]; then
            continue
        fi

        find "$DIR" -maxdepth 1 -type f \( -name "*.log" -o -name "*.log.gz" \) \
            ! -name "latest.log" \
            ! -iname "*warn*" ! -iname "*error*" \
            -mmin +2 -delete

        find "$DIR" -maxdepth 1 -type f \( -name "*.log" -o -name "*.log.gz" \) \
            ! -name "latest.log" \
            \( -iname "*warn*" -o -iname "*error*" \) \
            -mmin +10 -delete
    done

    sleep 120
done
