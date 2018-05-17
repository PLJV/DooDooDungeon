#!/bin/bash

if [ `ls -1 *.log | wc -l` -gt 0 ]; then
  7za a run.log.7z *.log
  rm -rf *.log;
fi

if [ `ps aux | grep jupyter | grep -v "launch-jupyter.sh" | grep -v "grep" | wc -l` -gt 0 ]; then
  kill -9 `ps aux | grep jupyter | grep -v "grep" | grep -v "launch-jupyter.sh" | awk '{ print $2 }'`
  sleep 1;
fi

nohup jupyter notebook --certfile=~/.jupyter/mycert.pem --keyfile ~/.jupyter/mykey.key >> `date | awk '{ print $2"_"$3"_"$4 }'`.log &
