#!/bin/bash
INPUT=$1
OUTPUT=$2
OPTION=${@:3}

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"
OUTPUT_FNAME="${OUTPUT##*/}"

touch $OUTPUT
chmod 777 $OUTPUT

IMG="biodckrdev/jellyfish:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data $IMG \
           jellyfish count $OPTION \
           -C /data/$INPUT_FNAME -o /data/$OUTPUT_FNAME

