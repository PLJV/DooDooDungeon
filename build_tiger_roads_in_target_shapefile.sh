#!/bin/bash

if [ $# -eq 0 ]; then
  exit "please specify a filename argument for our output"
fi

old_dir=$PWD
shopt -s nullglob # for our files array

if [[ `find src/ | grep ".zip$" | wc -l` -eq 0 ]]; then
  print " -- downloading:"
  wget -r --no-parent --reject "index.html*" ftp://ftp2.census.gov/geo/tiger/TIGER2016/ROADS/
elif [[ `find src/ | grep ".shp$" | wc -l` -eq 0 ]]; then
  cd src/ftp2.census.gov/geo/tiger/TIGER2016/ROADS/
  print " -- unpacking"
  for f in `ls -1 *.zip`; do
    7za x $f
  done
  files=(*.shp)
else
  cd src/ftp2.census.gov/geo/tiger/TIGER2016/ROADS/
  files=(*.shp)
fi

echo " -- merging and subsetting input data:"

ogr2ogr -f "ESRI Shapefile" $1 "${files[0]}"

for i in "${files[@]:1}"; do # slice to end of array (skipping 0)
  ogr2ogr -f "ESRI Shapefile" -clipsrc /global_workspace/ebird_number_crunching/ebird_reference_dataset_erd/erd/central_flyway.shp -append -update $1 "${files[$i]}"
done

mv "${1/.shp/.*}" "$old_dir/"
