open(LS,"$ARGV[0]");

$DATA_DIR=$ARGV[1];
$SCRIPT_DIR=$ARGV[2];
$CLAST_DIR=$ARGV[3];
$D16S_DIR=$ARGV[4];
$QUE_NAME='/que';

$count=0;
if(`wc -l $ARGV[0]`=~/^([0-9]+)/)
{
	$thre_count=$1/100;
}
$roop=1;
open(OUT,">${QUE_NAME}/que$roop.sh");
printf(OUT "#\$ -S /bin/sh
#\$ -cwd
#\$ -l s_vmem=128G -l mem_req=15G -l month -l gpu
sh ${SCRIPT_DIR}/16SAnalysis_node_farewell.sh ");
while(<LS>)
{
	if($thre_count>$count)
	{
		$line=$_;
		chomp $line;
		printf(OUT "${DATA_DIR} ${CLAST_DIR} ${SCRIPT_DIR} ${D16S_DIR}/%s ",$line);
		$count++;
	}
	else
	{
		close OUT;
		$roop++;
		open(OUT,">${QUE_NAME}/que$roop.sh");
		printf(OUT "#\$ -S /bin/sh
#\$ -cwd
#\$ -l s_vmem=128G -l mem_req=15G -l month -l gpu
sh ${SCRIPT_DIR}/16SAnalysis_node_farewell.sh ");
		
		$line=$_;
		chomp $line;
		printf(OUT "${DATA_DIR} ${CLAST_DIR} ${SCRIPT_DIR} ${D16S_DIR}/%s ",$line);
		$count=1;
	}
}
printf("%d",$roop);
close OUT;
close LS;
