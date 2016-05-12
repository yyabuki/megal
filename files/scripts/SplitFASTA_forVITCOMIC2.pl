#! /usr/local/bin/perl -w
#ラウンドロビン用入力配列分割コード。現状のVITCOMIC2のシェルでは時間計測のため、一応分割処理を空回ししている
use warnings;
use strict;
use File::Basename;

my ($number, $input, $seqnum, $div, $div2, $counter, $quecount, $output,$size) = 0;

my $dir = $ARGV[1];
die "$dir not found." if ! -d $dir;

$input = $dir . "/" . $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

my $name = basename $input;

$seqnum = `grep -c '>' $input`;#配列本数をshコマンドで調べて格納

if(`du -sS $input`=~/^([0-9]+)/)#fastaファイルのサイズをshコマンドで調べて格納
{
	$size=$1;
}
$number=int($size/10000)+1;#10MBごとに分割

$div = $seqnum / $number;#1分割ファイル10MBになるように分割ファイルあたりの配列本数を計算
$div2 = sprintf("%d", $div);#整数に丸める
$counter = 0;
$quecount = 1;
$output = "$dir/tmp_splitFasta/${name}_query$quecount";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";
#以降、ラベルかそうでないかを判定しつつ分割ファイル作成
while(<INPUT>){
        if(/^(>.+?)\s*$/){#ラベルの場合
                if($counter == $div2){#分割ファイルあたりの本数を満たしたらファイルを閉じて、次の分割ファイルに書き込む
                        close OUTPUT;
                        $quecount += 1;
                        $output = "$dir/tmp_splitFasta/${name}_query$quecount";
                        open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";
                        print OUTPUT "$1\n";
                        $counter = 0;
                }
                else{
                        print OUTPUT "$1\n";
                }
		$counter+=1;
        }
        else{#ラベルではなく配列の行の場合
                print OUTPUT "$_";
        }
}
print "$quecount";
close OUTPUT;
close INPUT;
exit

