module load sambamcram/samtools/1.7

# Display user options
while getopts ":i:o:p" options; do
    case "${options}" in
        i)
            i=${OPTARG}
            ;;

        p)
           p=${OPTARG}
	   p=1	
           ;;

	o)
           o=${OPTARG}
           ;;	
    esac
done



PICARD=/hpc/cog_bioinf/common_scripts/picard-tools-1.62/SamToFastq.jar

echo "Usage: um2fq -i BAM -p (PE) -o OUTPUT_DIR"

SAMPLE=$(basename "$i" | cut -d. -f1)


if [[ $p == 1 ]];
then
	echo "Paired-end mode"
        samtools view -@ 4 -m 4G -uf 4 ${i} | java -Xmx4g -jar ${PICARD} I=/dev/stdin F=${o}/${SAMPLE}.R1.fastq.gz F2=${o}/${SAMPLE}.R2.fastq.gz
	
else 
       	echo "Single-end mode"
        samtools view -@ 4 -m 4G -uf 4 ${i} | java -Xmx4g -jar ${PICARD} I=/dev/stdin F=${o}/${SAMPLE}.R1.fastq.gz

fi

