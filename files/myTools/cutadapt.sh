#!/bin/bash
INPUT=$1
OUTPUT=$2
OPTION=${@:3}

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"
OUTPUT_FNAME="${OUTPUT##*/}"

IMG="emihat/cutadapt:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data $IMG cutadapt $OPTION \
           -f fastq -o /data/$OUTPUT_FNAME /data/$INPUT_FNAME
