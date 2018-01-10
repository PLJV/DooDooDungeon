#!/bin/bash

# expires 2023 : reclass all expired CRP to corn (val=1) and merge with CRP (val=233) and background 2016 NASS (A)
gdal_calc.py -A /gis_data/Landcover/NASS/Raster/2016_crp.tif -B crp_binary_2023.tif --calc="(A==1)+(B==1)" --outfile="2023_expiring.tif" --overwrite
gdal_calc.py -A 2023_expiring.tif -B /gis_data/Landcover/NASS/Raster/2016_30m_cdls.tif --calc="((A==2)*233) + ((A==1)*1) + ((A==0)*B)" --outfile="2023_worst_case_crp_nass.tif" --overwrite
rm -rf 2023_expiring.tif

# expires 2027 : reclass all expired CRP to corn (val=1) and merge with CRP (val=233) and background 2016 NASS (A)
gdal_calc.py -A /gis_data/Landcover/NASS/Raster/2016_crp.tif -B crp_binary_2023.tif -C crp_binary_2027.tif --calc="(A==1)+(B==1)+(C==1)" --outfile="2027_expiring.tif" --overwrite
gdal_calc.py -A 2027_expiring.tif -B /gis_data/Landcover/NASS/Raster/2016_30m_cdls.tif --calc="(((A==1)+(A==2))*1) + ((A==3)*233) + ((A==0)*B)" --outfile="2027_worst_case_crp_nass.tif" --overwrite
rm -rf 2027_expiring.tif
