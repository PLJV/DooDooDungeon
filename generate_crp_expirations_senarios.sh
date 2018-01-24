#!/bin/bash

# expires 2023 : reclass all expired CRP to corn (val=1) and merge with CRP (val=233) and background 2016 NASS (A)
echo " -- ensuring consistent CRS between 2016 & 2023 CRP rasters"

gdalwarp\
 -t_srs "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"\
 -tr 29.99982 30.00031\
 -multi\
 -q\
 -overwrite\
 crp_binary_2023.tif\
 b_2023.tif

echo " -- calculating composite CRP raster for 2016 & 2023"

gdal_calc.py -A /gis_data/Landcover/NASS/Raster/2016_crp.tif -B b_2023.tif\
 --calc="A+B"\
 --outfile="2023_expiring.tif"\
 --quiet\
 --overwrite

echo " -- ensuring consistent CRS between 2016 NASS & CRP composite"

gdalwarp\
 -t_srs "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"\
 -tr 29.99982 30.00031\
 -multi\
 -q\
 -overwrite\
 /gis_data/Landcover/NASS/Raster/2016_30m_cdls.tif\
 b_2016_nass.tif

echo " -- burning CRP expiration into 2016 NASS"

gdal_calc.py -A 2023_expiring.tif\
 -B b_2016_nass.tif\
 --calc="((A==2)*233) + ((A==1)*1) + ((A==0)*B)"\
 --outfile="2023_worst_case_crp_nass.tif"\
 --overwrite\
 --quiet

echo " -- cleaning up"

rm -rf 2023_expiring.tif

#
# 2027 : reclass all expired CRP to corn (val=1) and merge with CRP (val=233) and background 2016 NASS
#

gdalwarp\
 -t_srs "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"\
 -tr 29.99982 30.00031\
 -multi\
 -q\
 -overwrite\
 crp_binary_2027.tif\
 b_2027.tif


gdal_calc.py -A /gis_data/Landcover/NASS/Raster/2016_crp.tif -B b_2023.tif\
 -C b_2027.tif\
 --calc="A+B+C"\
 --outfile="2027_expiring.tif"\
 --overwrite

gdal_calc.py -A 2027_expiring.tif\
 -B b_2016_nass.tif\
 --calc="((A==3)*233) + ((A==1)*1) + ((A==2)*1) + ((A==0)*B)"\
 --outfile="2027_worst_case_crp_nass.tif"\
 --overwrite\
 --quiet

echo " -- cleaning up"

rm -rf 2027_expiring.tif b_2023.tif b_2027.tif b_2016_nass.tif
