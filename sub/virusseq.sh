#### CONFIG #####

JUMPDB_PATH=/hpc/cog_bioinf/GENOMES/MOSAIK/jumpDB
MOSAIK_path=/hpc/cog_bioinf/GENOMES/MOSAIK/Mosaik
PERL_path=/hpc/cog_bioinf/GENOMES/MOSAIK/scripts

### END CONFIG #####


#### USER DEFINED INPUTS ####
echo "Usage : virusseq -f fw_read  -r reverse_read (optional) -l Reference library (optional, default gibVirus) -o Output dir -n number of CPU cores (optional, default 1) -s skip hg19 alignment"

REF_LIB=gibVirus #Default option
OUT_DIR=.
R1_fq=""
R2_fq=""
NCORES=1
SKIP=0

# Display user options
while getopts ":f:r:l:o:n:s" options; do
    case "${options}" in
        f)
            R1_fq=${OPTARG}
            ;;
        r)
            R2_fq=${OPTARG}
            ;;
        
	l)
           REF_LIB=${OPTARG}
           ;;

	o)
	   OUT_DIR=${OPTARG}
           ;;
        n)	
           NCORES=${OPTARG}
           ;;
        
        s)
           SKIP=${OPTARG}
	   SKIP=1
           ;;  
    esac
done

##### REASSIGN ######

##### Check #####
if [ -d ${OUT_DIR} ]
then
    echo "Output directory $OUT_DIR exits. Aborting!!!"
    exit 1
fi


if [ -z ${R1_fq} ]
then
    echo "No Forward read given. Aborting!!!"
    exit 1	
fi

### #############

#Extract basename from R1.fastq
SAMPLE=$(basename "$R1_fq" | cut -d. -f1)


#Make temp dir
mkdir -p ${OUT_DIR}
mkdir -p $OUT_DIR/tmp
mkdir -p $OUT_DIR/ace

export MOSAIK_TMP=$OUT_DIR/tmp

echo "Running virusseq pipeline for sample: "${SAMPLE} 

##### #######
## Redirect all output to logfile
touch $OUT_DIR/$SAMPLE_viseq.out.log
#Define run modes for single-end
if [ -z "$R2_fq" ] && [ ! -z "$R1_fq" ]
then
   if [ "$SKIP" == 1 ]
   then
       echo "Single-end mode (skipping hg19 alignment)"
       #Logging
       exec >> $OUT_DIR/${SAMPLE}.${REF_LIB}.viseq_out.log
       exec 2>&1
       ######	
       #DO STUFFF
       ${MOSAIK_path}/MosaikBuild -q ${R1_fq} -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina
       #Align
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.15 -act 25 -mhp 100 -m all -j ${JUMPDB_PATH}/${REF_LIB}.JumpDb -p ${NCORES} -km -pm
       #SORT
       ${MOSAIK_path}/MosaikSort -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted
       #assembles aligned reads per species
       ${MOSAIK_path}/MosaikAssembler -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted.assembled -f ace > ${OUT_DIR}/${SAMPLE}_VirusLog.txt
       #parses output log, and reports virus when present over ARGV1 reads
       perl ${PERL_path}/VirusSeq_Detection.pl ${OUT_DIR}/${SAMPLE}_VirusLog.txt 1000 ${OUT_DIR}/${SAMPLE}_VirusName.txt	
   else
       echo "Single-end mode (non-skip)"
       #Logging
       exec >> $OUT_DIR/${SAMPLE}.${REF_LIB}.viseq_out.log
       exec 2>&1
       #####
       #DO STUFFF
       ${MOSAIK_path}/MosaikBuild -q ${R1_fq} -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina
       ##align reads (takes long) to human reference first.
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/hg19.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.1 -mmal -minp 0.5 -act 25 -mhp 100 -m unique -j ${JUMPDB_PATH}/hg19.JumpDb -p $NCORES -km -pm -rur ${OUT_DIR}/${SAMPLE}_Unalg.fq

       ##Virus profiling
       ##build masaic format reads of unaligned selection
       ${MOSAIK_path}/MosaikBuild -q ${OUT_DIR}/${SAMPLE}_Unalg.fq -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina

       #aligns to virusref database
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.15 -act 25 -mhp 100 -m all -j ${JUMPDB_PATH}/${REF_LIB}.JumpDb -p ${NCORES} -km -pm

       #sorts
       ${MOSAIK_path}/MosaikSort -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted

       #assembles aligned reads per species
       ${MOSAIK_path}/MosaikAssembler -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted.assembled -f ace > ${OUT_DIR}/${SAMPLE}_VirusLog.txt

       #parses output log, and reports virus when present over ARGV1 reads
       perl ${PERL_path}/VirusSeq_Detection.pl ${OUT_DIR}/${SAMPLE}_VirusLog.txt 1000 ${OUT_DIR}/${SAMPLE}_VirusName.txt
   fi
fi		
#Define run modes for paired-end
if [ ! -z "$R1_fq" ] && [ ! -z "$R2_fq" ]
then
   if [ "$SKIP" == 1 ]
   then
       echo "Paired-end mode (skipping hg19 alignment)"
       ####Logging##
       exec >> $OUT_DIR/${SAMPLE}.${REF_LIB}.viseq_out.log
       exec 2>&1
       ######
       #DO STUFFF
       ${MOSAIK_path}/MosaikBuild -q ${R1_fq} -q2 ${R2_fq} -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina
       #Align
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.15 -act 25 -mhp 100 -m all -j ${JUMPDB_PATH}/${REF_LIB}.JumpDb -p ${NCORES} -km -pm

       #sorts
       ${MOSAIK_path}/MosaikSort -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted

       #assembles aligned reads per species
       ${MOSAIK_path}/MosaikAssembler -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted.assembled -f ace > ${OUT_DIR}/${SAMPLE}_VirusLog.txt

       #parses output log, and reports virus when present over ARGV1 reads
       perl ${PERL_path}/VirusSeq_Detection.pl ${OUT_DIR}/${SAMPLE}_VirusLog.txt 1000 ${OUT_DIR}/${SAMPLE}_VirusName.txt
   else
       echo "Paired-end mode (non-skip)"
       ##Logging###
       exec >> $OUT_DIR/${SAMPLE}.${REF_LIB}.viseq_out.log
       exec 2>&1
       ####
       ${MOSAIK_path}/MosaikBuild -q ${R1_fq} -q2 ${R2_fq} -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina
       ##align reads (takes long) to human reference first.
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/hg19.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.1 -mmal -minp 0.5 -act 25 -mhp 100 -m unique -j ${JUMPDB_PATH}/hg19.JumpDb -p ${NCORES} -km -pm -rur ${OUT_DIR}/${SAMPLE}_Unalg.fq
       ##Virus profiling
       ##build masaic format reads of unaligned selection
       ${MOSAIK_path}/MosaikBuild -q ${OUT_DIR}/${SAMPLE}_Unalg.fq -out ${OUT_DIR}/${SAMPLE}_Virus.bin -st illumina

       #aligns to virusref database
       ${MOSAIK_path}/MosaikAligner -in ${OUT_DIR}/${SAMPLE}_Virus.bin -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -hs 15 -mmp 0.15 -act 25 -mhp 100 -m all -j ${JUMPDB_PATH}/${REF_LIB}.JumpDb -p ${NCORES} -km -pm

       #SORTS
       ${MOSAIK_path}/MosaikSort -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted

       #assembles aligned reads per species
       ${MOSAIK_path}/MosaikAssembler -in ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted -ia ${JUMPDB_PATH}/${REF_LIB}.fa.bin -out ${OUT_DIR}/${SAMPLE}_Virus.bin.aligned.sorted.assembled -f ace > ${OUT_DIR}/${SAMPLE}_VirusLog.txt

      #parses output log, and reports virus when present over ARGV1 reads
      perl ${PERL_path}/VirusSeq_Detection.pl ${OUT_DIR}/${SAMPLE}_VirusLog.txt 1000 ${OUT_DIR}/${SAMPLE}_VirusName.txt
   fi
fi

#Clean-up ace files
mv ${OUT_DIR}/*.ace ${OUT_DIR}/ace









