## Submission parameters
#$ -l h_rt=10:0:0
#$ -q all.q
#$ -e ./VC.err
#$ -o ./VC.out
#$ -V
#$ -cwd
#$ -l h_vmem=30G
#$ -M your.mail@your.institution
#$ -m beas

VIRUSSEQ=/hpc/cog_bioinf/common_scripts/VirusSeq-CLI/sub/virusseq.sh

#INPUTS
FQ1=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_1.fq.gz
FQ2=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_2.fq.gz
OUT=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/test2




#### EXAMPLES ###### 

#PE/SE without skipping hg19 alignment

#sh ${VIRUSSEQ} -f $FQ1 -r $FQ2 -n 14 -o $OUT 
#sh ${VIRUSSEQ} -f $FQ1 -n 14 -o $OUT 

#PE/SE with skipping hg19 alignment

#sh ${VIRUSSEQ} -f $FQ1 -r $FQ2 -o $OUT -n 14 -s 
#sh ${VIRUSSEQ} -f $FQ1 -o $OUT -n 14 -s 
