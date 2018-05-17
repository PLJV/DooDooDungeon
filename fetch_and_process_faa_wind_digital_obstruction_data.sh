#!/bin/bash

BASH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf index.html;
rm -rf to_fetch.dat;

echo "-- scraping FAA website"
curl --silent --output index.html\
  https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/dof/\
  >> index.html >/dev/null 2>&1

cat index.html | grep zip | grep "a href" | awk '{ print $2 }' | cut -d '"'\
  -f2 >> to_fetch.dat

Rscript $BASH_DIR"/fetch_and_process_faa_wind_digital_obstruction_data.R"

echo "-- cleaning-up, compressing, and committing"
rm -rf *DAT *EXE *exe index.html *.dat DOF*.zip *.txt;

7za a `ls -1 wind_turbines_*.shp | \
  awk '{ gsub(".shp",".zip"); print }'` wind_turbines_* >/dev/null 2>&1

rm -rf `ls -1 wind_turbines_* | grep -v "zip"`;

if [ -d /gis_data/Wind/Deliverables/ ]; then
  mv wind_turbines_*.zip /gis_data/Wind/Deliverables/
fi
