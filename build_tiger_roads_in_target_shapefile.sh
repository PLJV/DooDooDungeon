#!/bin/bash

#
# this will download county-level TIGER 'all roads' data for the entire US
# and unpack/merge shapefiles into a single target shapefile, accounting for
# a user-specified boundary extent (hardcoded).
#

if [ $# -eq 0 ]; then
  exit "please specify a filename argument for our output"
fi
if [ ! -d "src" ]; then
  mkdir "src"
fi

cd "src"

shopt -s nullglob # for our files array

if [[ `find "$PWD" | grep ".zip$" | wc -l` -eq 0 ]]; then
  print " -- downloading:"
  wget -r --continue --no-parent -nH --cut-dirs=1 --reject\ 
    "index.html*" ftp://ftp2.census.gov/geo/tiger/TIGER2016/ROADS/
fi
if [[ `find "$PWD" | grep ".shp$" | wc -l` -eq 0 ]]; then
  print " -- unpacking"
  for f in `ls -1 *.zip`; do
    7za x $f
  done
  files=(*.shp)
else
  files=(*.shp)
fi

echo " -- merging and subsetting input data:"

ogr2ogr -f "ESRI Shapefile" $1 "${files[0]}"

for fn in "${files[@]:1}"; do # slice to end of array (skipping 0)
  ogr2ogr -f "ESRI Shapefile" -clipsrc\
    "/global_workspace/ebird_number_crunching/ebird_reference_dataset_erd/erd/central_flyway.shp"\
    -skipfailures -append -update $1 $fn
done

cd src;
mv "${1/.shp/.*}" "../"
rm -rf *.shp *.shx *.prj *.xml
cd ..

echo " -- done"
