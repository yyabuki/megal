#!/bin/bash
INPUT=$1
OUTPUT=$2

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"

touch $OUTPUT
chmod 777 $OUTPUT

IMG="biodckrdev/jellyfish:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data $IMG \
           jellyfish dump /data/$INPUT_FNAME > $OUTPUT

