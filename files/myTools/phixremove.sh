#!/bin/bash
INPUT_FQ=$1
INPUT_SAM=$2
OUTPUT=$3

INPUT_FQ_FNAME="${INPUT_FQ##*/}"
INPUT_SAM_FNAME="${INPUT_SAM##*/}"
DATA_DIR="${INPUT_FQ%/*}"

OUTPUT_FNAME="${INPUT_FQ_FNAME}.rem"

IMG="perl:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data -v /scripts:/scripts \
           $IMG perl /scripts/PhixRemove \
           /data/$INPUT_FQ_FNAME /data/$INPUT_SAM_FNAME

mv ${DATA_DIR}/${OUTPUT_FNAME} $OUTPUT
