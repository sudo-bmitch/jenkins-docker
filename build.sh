#!/bin/sh

cd $(dirname $0)
build_date=$(date +%Y%m%d-%H%M%S)
docker build -t localhost:5000/jenkins-docker --build-arg "BUILD_DATE=$build_date" .

