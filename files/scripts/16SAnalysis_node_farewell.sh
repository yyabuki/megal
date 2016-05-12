DATA_DIR=$1
shift

CLAST_DIR=$1
shift

SCRIPT_DIR=$1
shift

for DIR in ${DATA_DIR} ${CLAST_DIR} ${SCRIPT_DIR}
do
  if [ ! -d ${DIR} ]; then
    echo "${DIR} not found."
    exit 1
  fi
done

for DIR in ${DATA_DIR}/tmp_splitFasta ${DATA_DIR}/result/identity
do
  if [ ! -d ${DIR} ];then
    mkdir -p ${DIR}
  fi
done

for arg in $@
do
  echo "${arg} start."

  FNAME=`basename ${arg}`
  FPATH="download_16Ssample/$FNAME"

  rm -f ${DATA_DIR}/result/identity/${FNAME}.clast
  number=`perl ${SCRIPT_DIR}/SplitFASTA_forVITCOMIC2.pl ${FPATH} ${DATA_DIR}`
  opt=`perl ${SCRIPT_DIR}/optimize_usingMemory.pl ${arg}`

  for i in `seq 1 $number`
  do 

    docker run -it --rm -v ${DATA_DIR}:/data -v ${CLAST_DIR}:/clast \
	--device /dev/nvidia0:/dev/nvidia0 \
	--device /dev/nvidiactl:/dev/nvidiactl \
	--device /dev/nvidia-uvm:/dev/nvidia-uvm kaixhin/cuda \
	/clast/clast_for_vitcomic2 \
	-d /data/database/taxonRef \
	-q /data/tmp_splitFasta/${FNAME}_query${i} \
	-r /data/result/identity/${FNAME}.clast \
	-mode false -one true -kMer 20 -qChunk $opt

    rm -f ${DATA_DIR}/tmp_splitFasta/${FNAME}_query${i}
  done

  docker run -it --rm -v ${DATA_DIR}:/data -v ${SCRIPT_DIR}:/script \
	perl:latest \
	perl /script/VITCOMIC_makeCluster_false_copyNormalize.pl \
	/data/SPlist/Refs_14_04_11.SPlist /data/result/identity/${FNAME}.clast \
	>> ${DATA_DIR}/seqcounts.txt

  echo "VITCOMIC core data(${arg}) created."
done

