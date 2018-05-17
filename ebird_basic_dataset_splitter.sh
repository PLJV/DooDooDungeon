#!/bin/bash

#
# Basic BASH script that will accept a ebd .txt file as a 
# commandline argument and then split the file
# into 500,000 line CSV chunks. The output can then
# be processed piecewise in R
#
# Author : Kyle Taylor (kyle.taylor@pljv.org) [2017]
#
# edits : Initial build 8/10/2017
#

# find our split files
split_files=(`ls -1 x* | grep -v "x[.][.]"`)

if [[ ${#split_files[@]} > 1 ]]; then
  echo "-- using previous split files found in CWD"
else
  echo " -- generating split files"
  split $1 -l 500000
fi

# record the header and purge from first split
header=`head -n1 $1`

function header_is_present {
  if [[ `head -n1 $1` == $header ]]; then 
    if [[ $2 == "chop" ]]; then
      echo " -- chopping header from first split file"
      rm -rf out1234
      tail -n +2 $1 >> out1234
      mv out1234 $1
    fi
    return 1
  else
    return 0
  fi
}

function add_header_to_split_files {
echo -n " -- processing:"
  for f in ${1[@]} ; do
    rm -rf $f"1"
    echo $2 >> $f"1"
    cat $f >> $f"1"
    mv $f"1" $f
    mv $f $f".csv"
    echo -n "."
  done
  echo "\n"
}

# process our chunks by adding a header to each split file

# the first split should have a lurking header at line n=1
header_is_present ${split_files[0]} "chop"
add_header_to_split_files $split_files $header

# compress everything for the user
rm -rf echo $1 | awk '{ gsub(".txt",""); print }'`"_processed.zip"
7za a `echo $1 | awk '{ gsub(".txt",""); print }'`"_processed.zip" ${split_files[@]}

rm -rf ${split_files[@]}
