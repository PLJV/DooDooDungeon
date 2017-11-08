#!/bin/bash

rm -rf index.html;
rm -rf to_fetch.dat;

wget https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/dof/
cat index.html | grep zip | grep "a href" | awk '{ print $2 }' | cut -d '"' -f2 | awk '{ print "https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/dof/" $1 }' >> to_fetch.dat

R --no-save --vanilla --slave < fetch_and_process_faa_wind_digital_obstruction_data.R

rm -rf *DAT *EXE *exe
