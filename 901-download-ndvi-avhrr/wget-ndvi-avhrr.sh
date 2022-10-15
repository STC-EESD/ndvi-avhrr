#!/bin/bash

wget --no-check-certificate https://ftp.maps.canada.ca/pub/statcan_statcan/avhrr/Bands_Weeks_AVHRR_Semaines_Bandes.xlsx

# for YEAR in {1987..2022..1}
for YEAR in {1987..1991..1}
do
    tempfile=https://ftp.maps.canada.ca/pub/statcan_statcan/avhrr/AVHRR1KM_${YEAR}.zip
    echo
    echo downloading: ${tempfile}
    wget --no-check-certificate ${tempfile}
done
echo
