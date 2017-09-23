#!/bin/bash

#
# Raster space saver, because I never set precision when working with raster::
# writeRaster in 'R', and it default saves everything I make with Float64
# precision, resulting in huge rasters. This will bulk process all rasters in
# the CWD. P.s., never run this on rasters where you need significant figures.
# It will ALWAYS drop the precision of your rasters, sometimes dramatically.
#

for f in `ls -1 *_30m.tif`; do
  MAX=`gdalinfo -stats $f | grep _MAX | awk '{ gsub("    STATISTICS_MAXIMUM=",""); print }'`
  MIN=`gdalinfo -stats $f | grep _MIN | awk '{ gsub("    STATISTICS_MINIMUM=",""); print }'`

  rm -rf output.tif

  if [[ $MIN > 0 && $MAX < 256 ]]; then
    echo "-- using byte precision"
    gdal_translate -ot Byte -a_nodata 0 $f output.tif;
    mv output.tif $f
  elif [[ $MIN < 0 && $MAX < 32768 ]]; then
    echo "-- using traditional Int16 precision"
    gdal_translate -ot Int16 $f output.tif;
    mv output.tif $f
  elif [[ $MIN > 0 && $MAX < 65536 ]]; then
    echo "-- using UInt16 precision"
    gdal_translate -ot UInt16 -a_nodata 0 $f output.tif;
    mv output.tif $f
  elif [[ $MIN > 0 && $MAX < 4294967296 ]]; then
    echo "-- using Uint32 precision"
    gdal_translate -ot UInt32 -a_nodata 0 $f output.tif;
    mv output.tif $f
  elif [[ $MIN < 0 && $MAX < 2147483648 ]]; then
    echo "-- using traditional Int32 precision"
    gdal_translate -ot Int32 $f output.tif;
    mv output.tif $f
  else
    echo "-- assuming precision at Float32"
    gdal_translate -ot Float32 $f output.tif;
    mv output.tif $f
  fi
done
