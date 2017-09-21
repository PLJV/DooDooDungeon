#!/bin/bash
gdal_proximity.py -distunits PIXEL -ot Int16 -nodata 0 -use_input_nodata NO 2016_active_wind_installs.tif 2016_distance_to_active_wind_installs.tif
gdal_proximity.py -distunits PIXEL -ot Int16 -nodata 0 -use_input_nodata NO 2012-16_active_wind_installs.tif 2012-16_distance_to_active_wind_installs.tif
