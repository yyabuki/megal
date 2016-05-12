#!/bin/bash
INPUT=$1
OUTPUT=$2

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"

OUTPUT_FNAME="${INPUT_FNAME}.fasta"

IMG="perl:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data -v /scripts:/scripts \
           -v /megapdata:/megapdata \
           $IMG perl /scripts/Qual_Filter_FASTQFASTA \
           /data/$INPUT_FNAME /megapdata/ascii

mv ${DATA_DIR}/${OUTPUT_FNAME} $OUTPUT

