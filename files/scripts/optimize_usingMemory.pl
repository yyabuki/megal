$input=$ARGV[0];

$seqnum= `grep -c '>' $input`;#配列本数を調べる
if(`du -sS $input`=~/^([0-9]+)/)#入力ファイルのサイズを調べる
{
        $size=$1;
}

$opt=4000/($size/$seqnum);#-qChunk用のパラメータを計算。入力ファイルのサイズ/配列本数で配列一本あたりの塩基長を近似的に表現している
						  #長い配列ほど一度にGPUに格納する本数を減らし、短い配列ほど格納する本数が増えるように調整している
printf("%d",$opt);
