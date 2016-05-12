#!/bin/bash
INPUT=$1
OUTPUT=$2

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"

IMG="perl:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data -v /scripts:/scripts \
           $IMG perl /scripts/CalculateEntropyDiv \
           /data/$INPUT_FNAME > $OUTPUT

