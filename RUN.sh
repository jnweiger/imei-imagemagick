#! /bin/bash

for rel in ubuntu-*; do
  docker build -t imei-build-$rel $rel

  # to copy out artefacts, we need a container. docker create creates us one.
  container=$(docker create imei-build-$rel)
  mkdir -p repo
  docker cp $container:/usr/local/src repo
  docker rm $container
  mv repo/src repo/$rel
done


