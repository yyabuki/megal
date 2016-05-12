#! /usr/local/bin/perl -w
use warnings;
use strict;
my($unknown,$seqID,$flag,$tempID,$highScore_ID,$memoID,$newick,$errorCount,$copyInput,$blastCounter,$otu_hit,$otu,$int_similarity,$i,$highScore,$counter,$highScore_name,$key,$input,$counterblast,$query_name,$pre_query_name,$first,$organism_name,$similarity,$match_length,$score)=0;
my(@save_query_name,@bac_name,@bac_similarity)=();
my(%bac_phylo_number,%otu_Hash,%counterblast_Hash,%idscore_Hash,%idsimi_Hash,%idsimi_Count)=();

$pre_query_name = "";

$newick = $ARGV[0]; #"VITCOMIC_program/SPlist/*.SPlist";
open(NEWICK, "$newick") or die "No Species_List.txt in current directory";
while(<NEWICK>){#VITCOMICから使っているコードの流用。別にNEWICKではなく、SPlist(DB配列の系統情報)を読み込むための処理
	if(/^(S[0-9]{9})\t([^\t]+)\t([^\t]+)\t([^\t]+)$/)
	{
		$bac_phylo_number{$1} = $2; #DB配列の門を保存
		$memoID=$1;
		if($bac_phylo_number{$memoID}=~/"([^\"]+)"$/)#作成の過程でダブルクォーテーションに囲まれた門があったので、これらのダブルクォーテーションを除く作業
		{
			$bac_phylo_number{$memoID}=$1;
		}
    }
}
close NEWICK;
$input = $ARGV[1];
open(INPUT, "$input") or die "Can't open \"$input\"\n";
$first=0;
$highScore=0;
$counter=0;
$unknown = "$input"."_strain_unknownSeq.txt";
open(UNKNOWN, ">$unknown") or die;
$seqID="$input"."_usedSeq.txt";
open(USED, ">$seqID") or die;
while(<INPUT>)
{
    if(/^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t[0-9]+\(([^%]+)\%\)\t([^\t]+)\t([^\t]+)$/)
	{#系統組成解析用CLASTの結果を解析する部分
		$query_name = $1;
		$organism_name = $5;
		$similarity = $8;
		$match_length = $3;
		$score = $9;
		if($match_length < 50)
		{
			#50bp未満のヒット長を持った結果は使用しない
			next;
		}
		else
		{
			if($first == 0)
			{#入力はじめの一行目は「前の行と違うquery_nameか」の分岐から逃がす必要がある
				$first = 1;
				$idscore_Hash{$organism_name}=$score;
				$idsimi_Hash{$organism_name}=$similarity;
				$idsimi_Count{$organism_name}=1;
				$pre_query_name = $query_name;
				next;
			}
			else
			{
				if($query_name ne $pre_query_name)
				{#前の行と違うquery_nameが始まった時点で、前の行までのquery_nameのトップヒット配列を選出する
					foreach $key(keys %idscore_Hash)
					{
						if($idscore_Hash{$key}>$highScore)
						{#最も高いスコアを出したDB配列名を保存
							$highScore_name=$key;
							if($key=~/(S[0-9]{9})/)
							{
								$highScore_ID=$1;
							}
							$highScore=$idscore_Hash{$key};
							$flag=1;
						}
						elsif($idscore_Hash{$key}==$highScore)
						{#同率トップヒットに関する処理。もし同率トップヒットが複数の門に跨がっていた場合、その配列の系統は不明瞭として解析に使用しない。
							if($key=~/(S[0-9]{9})/)
							{
								$tempID=$1;
							}
							if($bac_phylo_number{$highScore_ID} ne $bac_phylo_number{$tempID})
							{
                            	if($bac_phylo_number{$highScore_ID}=~/proteobacteria/)
                                {#proteobacteria内の綱間の跨ぎは許容する
                                	if($bac_phylo_number{$tempID}=~/proteobacteria/)
                                    {
                                    	$flag=1;
                                    }
								}
                                else
                                {
                                	$flag=0;
                                }
                            }
                            elsif($bac_phylo_number{$highScore_ID} eq "Tenericutes")
                            {#Tenericutes門とFirmicutes門間の跨ぎは許容する
                            	if($bac_phylo_number{$tempID} eq "Firmicutes")
                                {
                                	$flag=1;
                                }
                                else
                                {
                                	$flag=0;
                                }
                           	}
                            elsif($bac_phylo_number{$highScore_ID} eq "Firmicutes")
                            {#Tenericutes門とFirmicutes門間の跨ぎは許容する
                            	if($bac_phylo_number{$tempID} eq "Tenericutes")
                                {
                                	$flag=1;
                                }
                                else
                                {
                                	$flag=0;
                                }
                            }
                            else
                            {
                            	$flag=0;
                            }
						}
					}
					if($flag)#同率トップヒットの門の跨ぎが無かった場合、クエリ配列ごとのトップヒットを保存
					{
						$bac_name[$counter]=$highScore_name;
						$save_query_name[$counter]=$pre_query_name;
						#飛び地アライメントがあった場合、相同性は飛び地の相同性を平均する
						$bac_similarity[$counter]=$idsimi_Hash{$highScore_name}/$idsimi_Count{$highScore_name};
						$counter++;
						printf(USED "%s\n",$pre_query_name);
					}
					else
					{
						printf(UNKNOWN "%s\n",$pre_query_name);
					}
					foreach $key (keys %idscore_Hash)
					{#リフレッシュ処理
						delete $idscore_Hash{$key};
						delete $idsimi_Count{$key};
						delete $idsimi_Hash{$key};
						$highScore=0;
					}
					$pre_query_name = $query_name;
					$idscore_Hash{$organism_name}=$score;
					$idsimi_Hash{$organism_name}=$similarity;
					$idsimi_Count{$organism_name}=1;
				}
				else#前の行と同じquery_nameなら
				{
					if(exists($idscore_Hash{$organism_name}))
					{#飛び地でアライメントされていた場合、スコアを足し合わせる
						$idscore_Hash{$organism_name}=$idscore_Hash{$organism_name}+$score;
						$idsimi_Hash{$organism_name}=$idsimi_Hash{$organism_name}+$similarity;
						$idsimi_Count{$organism_name}=$idsimi_Count{$organism_name}+1;
					}
					else
					{#飛び地アライメントでない場合の処理。ターゲット配列との相同性とスコアを保存
						$idscore_Hash{$organism_name}=$score;
						$idsimi_Hash{$organism_name}=$similarity;
						$idsimi_Count{$organism_name}=1;
					}
				}
			}
		}
	}
}
foreach $key(keys %idscore_Hash)#最後のquery_nameに関する処理はループ内で処理されないため、ループ外に付け足している
{
	if($idscore_Hash{$key}>$highScore)
	{
		$highScore_name=$key;
		if($key=~/(S[0-9]{9})/)
		{
			$highScore_ID=$1;
		}
		$highScore=$idscore_Hash{$key};
		$flag=1;
	}
	elsif($idscore_Hash{$key}==$highScore)
	{
		if($key=~/(S[0-9]{9})/)
		{
			$tempID=$1;
		}
		if($bac_phylo_number{$highScore_ID} ne $bac_phylo_number{$tempID})
		{
            if($bac_phylo_number{$highScore_ID}=~/proteobacteria/)
            {
            	if($bac_phylo_number{$tempID}=~/proteobacteria/)
               	{
             	  	$flag=1;
              	}
				else
				{
					$flag=0;
				}
             }
             elsif($bac_phylo_number{$highScore_ID} eq "Tenericutes")
             {
             	if($bac_phylo_number{$tempID} eq "Firmicutes")
            	 {
            	 	$flag=1;
          	   	 }
			 	 else
			 	 {
			 	 	$flag=0;
			  	 }
             }
             elsif($bac_phylo_number{$highScore_ID} eq "Firmicutes")
             {
             	if($bac_phylo_number{$tempID} eq "Tenericutes")
                {
                	$flag=1;
                }
				else
				{
					$flag=0;
				}
             }
             else
             {
       			   $flag=0;
             }
		}
	}
}
if($flag)
{
	$bac_name[$counter]=$highScore_name;
	$save_query_name[$counter]=$pre_query_name;
	$bac_similarity[$counter]=$idsimi_Hash{$highScore_name}/$idsimi_Count{$highScore_name};
	$counter++;
	printf(USED "%s\n",$pre_query_name);
}
else
{
	printf(UNKNOWN "%s\n",$pre_query_name);
}
close INPUT;
close UNKNOWN;
close USED;
$blastCounter=0;
$errorCount=0;
#以下、系統組成解析のための配列相同性結果からclusterファイルを生成する作業
for($i=0;$i<$counter;$i++)
{
	$int_similarity=int($bac_similarity[$i]);
	if($int_similarity>=80)
	{#相同性80%未満の結果は保存しない
		$otu="$bac_name[$i]\t$int_similarity";
		if(exists($otu_Hash{$otu}))
		{#既にDB配列と相同性のセットが存在した場合、そのセットに本数を足す
			++$otu_Hash{$otu};
		}
		else
		{#DB配列と相同性のセットを新しく登録する場合
			$otu_Hash{$otu} = 1;
		}
		++$blastCounter;#全入力配列数を算出
	}
	else
	{#配列相同性が80%に満たなかった配列の本数をカウント
		++$errorCount;
	}
}
$otu_hit = "$input"."_nocopy.cluster";
open(OTU_HIT, ">$otu_hit") or die;#clusterファイルをまとめて書き込み
print OTU_HIT "$blastCounter\n";
foreach $key (keys %otu_Hash){
	printf(OTU_HIT "%s\t%f\n",$key,$otu_Hash{$key});
}
printf("%s seq counts=%d\n",$ARGV[1],$counter-$errorCount);#解析に用いることが出来た配列の本数を標準出力
close OTU_HIT;
