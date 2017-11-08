#!/bin/bash

BASH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf index.html;
rm -rf to_fetch.dat;

echo " "
wget –quiet https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/dof/ >/dev/null 2>&1

cat index.html | grep zip | grep "a href" | awk '{ print $2 }' | cut -d '"' -f2 | awk '{ print "https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/dof/" $1 }' >> to_fetch.dat

Rscript $BASH_DIR"/fetch_and_process_faa_wind_digital_obstruction_data.R"

rm -rf *DAT *EXE *exe

7za a `ls -1 wind_turbines_*.shp | awk '{ gsub(".shp",".zip"); print }'` wind_turbines_*
#rm -rf `ls -1 wind_turbines_* | grep -v "zip"`
