#! /bin/bash

for rel in ubuntu-*; do
  docker rmi imei-build-$rel 
done
