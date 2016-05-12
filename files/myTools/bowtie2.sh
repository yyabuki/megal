#!/bin/bash
INPUT=$1
OUTPUT=$2
OPTION=${@:3}

INPUT_FNAME="${INPUT##*/}"
DATA_DIR="${INPUT%/*}"
OUTPUT_FNAME="${OUTPUT##*/}"

IMG="genomicpariscentre/bowtie2:latest"
docker pull $IMG

docker run -v $DATA_DIR:/data -v /megapdata:/megapdata \
           $IMG bowtie2 $OPTION -q \
           -x /megapdata/phiX174.Human.fasta.index \
           -U /data/$INPUT_FNAME -S /data/$OUTPUT_FNAME \
           2> /data/bowtie.err
