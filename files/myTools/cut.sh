#!/bin/bash
INPUT=$1
OUTPUT=$2
OPTION=${@:3}

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"

IMG="busybox:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data $IMG \
           cut $OPTION /data/$INPUT_FNAME > $OUTPUT

chmod 777 $OUTPUT

