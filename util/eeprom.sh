#!/bin/bash
# Code used to create a backup file from the EEPROM of the WS, 

echo "Starting updating DB in EEPROM ..."
cd /home/weather/vantage-publisher
URL="127.0.0.1:22222"

YEAR=$(date +"%Y")
MONTH=$(date +"%m")

BASE_PATH="/storage/eeprom"

mkdir -p "${BASE_PATH}/${YEAR}"

CSV_DB="${BASE_PATH}/${YEAR}/${YEAR}-${MONTH}.csv"

START_DATE="${YEAR}-${MONTH}-01 00:00"
LAST_DATE=$(date -d "$(date +'%Y-%m-01') +1 month -1 day" +'%Y-%m-%d')
END_DATE="${LAST_DATE} 23:59"
echo $START_DATE $END_DATE

docker compose down

python3 /home/weather/weather-inizialization/util/backup-eeprom.py tcp:${URL}\
    --start "${START_DATE}" \
    --output "${CSV_DB}"

echo "DB updated in EEPROM: ${CSV_DB}"

docker compose up -d
