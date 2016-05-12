#!/bin/bash
INPUT=$1
OUTPUT=$2

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"

OUTPUT_FNAME="${INPUT_FNAME}.N"

IMG="perl:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data -v /scripts:/scripts \
           $IMG perl /scripts/Exclude_N_Fastq2 \
           /data/$INPUT_FNAME

mv ${DATA_DIR}/${OUTPUT_FNAME} $OUTPUT
