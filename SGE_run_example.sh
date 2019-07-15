## Submission parameters
#$ -l h_rt=10:0:0
#$ -q all.q
#$ -e ./VC.err
#$ -o ./VC.out
#$ -V
#$ -cwd
#$ -l h_vmem=30G
#$ -M t.schafers@umcutrecht.nl
#$ -m beas

FQ1=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_1.fq.gz
FQ2=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_2.fq.gz
OUT=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/test2

#Example. PE/SE without skipping hg19 alignment
#sh sub/virusseq.sh -f $FQ1 -r $FQ2 -n 14 -o $OUT 
#sh sub/virusseq.sh -f $FQ1 -n 14 -o $OUT 

#Example. PE/SE with skipping hg19 alignment
#sh sub/virusseq.sh -f $FQ1 -r $FQ2 -o $OUT -n 14 -s 
#sh sub/virusseq.sh -f $FQ1 -o $OUT -n 14 -s 
