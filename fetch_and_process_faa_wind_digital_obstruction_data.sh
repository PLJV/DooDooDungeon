#!/bin/bash
# when run from cron, these shell built-ins are sometimes neglected
export PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin"
export TERM=linux
# default runtime arguments
PROJECT_DIR="/tmp"
DELIVERABLES_DIR="/gis_data/Wind/Deliverables/"
# make sure we are using the latest version of our detector
echo " -- BUILDING Latest Detector from Github"
cd /home/ktaylora/Projects/PlayaWind*; git pull
cd /home/ktaylora/Projects/Beatbox; git pull
/opt/anaconda/anaconda2/bin/pip install --upgrade /home/ktaylora/Projects/Beatbox
/opt/anaconda/anaconda2/bin/pip install --upgrade /home/ktaylora/Projects/PlayaWind*
# drop-in to our project dir and make a mess of things
echo " -- Setting-up Project Workspace"
cp -r /home/ktaylora/Projects/PlayaWind*/geometries $PROJECT_DIR;
cd $PROJECT_DIR;
echo " -- RUNNING"
# here is the actual script-runner call for the knockout app
if ! /opt/anaconda/anaconda2/bin/python /home/ktaylora/Projects/PlayaWind*/runner.py; then
  echo " -- ERROR : SCRIPT RUN FAILURE (EXIT)"
  exit
fi
# move deliverables to their final home on gis_data
echo " -- Moving Deliverbales to Products Directory"
if [ -d $DELIVERABLES_DIR ]; then
  mv exports/*.zip $DELIVERABLES_DIR
fi

