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

#### Change these settings (RUN Specific) ######
FQ1=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_1.fq.gz 
FQ2=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/fastq/L526401A_2.fq.gz
OUT=/hpc/cog_bioinf/ubec/analyses/custom/HUB_virusseq/test3
### END ######


### Change these settings (static) ####
VIRUSSEQ=/hpc/cog_bioinf/common_scripts/VirusSeq-CLI/sub/virusseq.sh 
REF=/hpc/cog_bioinf/GENOMES/MOSAIK
### END ######


# 1) Example without skipping hg19 alignment (PE), positive control.
sh $VIRUSSEQ -f $FQ1 -r $FQ2 -n 14 -g ${REF} -o $OUT

# 2) Example without skipping hg10 alignment (SE), positive control.
#sh $VIRUSSEQ -f $FQ1 -n 14 -g ${REF} -o $OUT

# 3) Example with skipping hg19 (PE)
#sh $VIRUSSEQ -f /path/to/unmapped.mate.1 -r /path/to/unmapped.mate.2 g ${REF} -o $OUT -n 14 -s

# 4) Example with skipping hg19 (SE)
#sh $VIRUSSEQ -f /path/to/unmapped_R1_fq -g ${REF} -o $OUT -n 14 -s
 



