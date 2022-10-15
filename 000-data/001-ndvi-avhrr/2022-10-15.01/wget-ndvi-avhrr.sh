#!/bin/bash

server_url=https://ftp.maps.canada.ca/pub/statcan_statcan/avhrr

wget --no-check-certificate ${server_url}/Bands_Weeks_AVHRR_Semaines_Bandes.xlsx

echo
echo downloading starts: `date`
echo

for YEAR in {1987..2022}
do
    tempfile=${server_url}/AVHRR1KM_${YEAR}.zip
    echo
    echo downloading: ${tempfile}
    wget --no-check-certificate ${tempfile}
done

echo
echo
echo downloading complete: `date`
echo

echo
echo unzipping starts: `date`
echo

for YEAR in {1987..2022}
do
    tempfile=AVHRR1KM_${YEAR}.zip
    echo
    echo unzipping: ${tempfile}
    unzip ${tempfile}
done
echo

echo
echo unzipping complete: `date`
echo
