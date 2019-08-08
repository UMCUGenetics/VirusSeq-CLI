# VirusSeq CLI User Guide

## Introduction

This guide provides a short introduction to VirusSeq CLI, a wrapper tool for the VirusSeqPipeline. For more information on the pipeline itself, consider the [VirusSeq] (https://www.ncbi.nlm.nih.gov/pubmed/23162058) paper and [GitHub] (https://github.com/rosericazondekon/virusSeqPipeline) repository.   

## 1) Setup jumpDB resources and Mosaik (advanced).

Setup the reference and annotation files using the `jump_file_builder.sh` script in the Author's Github repository. Note that you have to adjust the working directory paths to your own configuration. We will use this resource directory later on.

Please <b>DO NOT</b> use any other Mosaik binaries, except the one provided in the GitHub repository by the Author (Mosaik_bin). The pipeline is likely to break with versions different from <b>0.9.891.</b>

## 2) Reference configuration

Navigate to the `virusseq.sh` file and set the correct paths in de ### CONFIG ### section.

`JUMPDB_PATH` - Directory containing your jumpDB/reference resources build in <b>1)</b>. <br>
`MOSAIK_PATH` - Path to the MOSAIK binary. <br>
`PERL_PATH` - Path to virusSeq Perl scripts folder (VirusSeq_Detection.pl, VirusSeq_Integration.pl).


This has to be done only once before using the script. Do not edit anything else.

## 3) Basic usage   

The VirusSeq CLI script support 4 different run modes depending on your submission parameters. 


`-f` Forward read <br>
`-r` Reverse read (optional) <br>
`-l` Reference library (optional, default gibVirus)  <br>
`-o` Path to output folder <br>
`-n` Number of CPU cores to use (the more the merrier) <br>
`-s` Indicates if hg19 alignment should be skipped. (optional)

Note that the Reference library argument (-l) should match exactly the basename of the virus reference/annotation files in  `JUMPDB_PATH` (i.e. <b>gibVirus</b>.fa) if provided. Make sure that the output directory (-o) you specified does not exist in the given path. VirusSeq CLI will attempt to create the folder you specified.

### Paired-end example (gibVirus) ###

In case you want to provide <b>paired-end</b> Illumina reads call the script as follows. 

`sh virusseq.sh -f L526401A_1.fq.gz -r L526401A_2.fq.gz -o /tmp/output_virseq -n 14`

You can provide unmapped reads directly (i.e RNASeq STAR's out.mate1/mate2) by appending the `-s` flag to the end of your command. This will <b>skip</b> Mosaik's internal hg19 alignment and map the reads directly to the virus reference genome.  
On a system with 14 CPU cores and 30GB RAM, it will take around 3h to process the L526401A sample dataset. Skipping hg19 alignment will likely reduce the runtime by half. 

### Single-end example (gibVirus)

For <b>single-end</b> reads, simply leave the `-r` parameter empty. If you want to skip hg19 alignment, use the `-s` flag in the same manner as in the paired end example.    

`sh virusseq.sh -f L526401A_1.fq.gz -o /tmp/output_virseq -n 14`

## 4) Logging
In addition to the output files generated by the pipeline itself, VirusSeq CLI writes all STDOUT and STDERR output to `{REF_LIB}.viseq_out.log` in the output directory. Have a look here in case anything went wrong after analysis submission.


## 5) Running VIrusSeq-CLI on the HPC

A pre-configured version of the scripts have been installed on the HPC under `/hpc/cog_bioinf/common_scripts/VirusSeq-CLI/` with all the necessary reference and annotation files in place. For the sake of simplicity, its advisable to use this version instead of configuring everything yourself. Use the `SGE_run_example.sh` as a template/inspiration to run VirusSeq-CLI on the HPC. 

## 6) Example

Download the L526401A paired-end testset using the `download_virusseq_resources.sh` script and run the pipeline in paired-end mode without skipping hg19 alignment as descriped in section <b>3)</b>.  


















 
