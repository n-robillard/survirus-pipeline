#!/bin/bash

DATADIR=$1
OUTPUT_DIR=$2
THREADS=$3
REF_DIR=/mnt/MDWorks4/Workdir_Nicolas/refs

#Unzipp .fastq.gz into fastq for the pipe and move it into tmp folder
cd $DATADIR
echo "Make a data directory for temporary files $DATADIR/tmp_nosave"
mkdir ./tmp_nosave
echo "Unzipp all fastq.gz files and move it into the $DATADIR/tmp_nosave"
gunzip -kr $DATADIR
mv *fastq ./tmp_nosave
cd ./tmp_nosave

## make folder for each samples
# take all name of sample into variable
echo "Generate UNIQ_FASTQ variable with all sample names"
UNIQ_FASTQ=$(find -maxdepth 1 -type f -name '*.fastq*' \
	| sed -r 's%\.(R[[:digit:]]|U)\.fastq.*%%' \
	| sed -r 's%\./%%' \
	| sort \
	| uniq)

# make a folder for output of SurVirus
echo "Generate separated output directory"
for sample in $UNIQ_FASTQ;
do
	echo "make directory for: $sample in $OUTPUT_DIR"
	mkdir $OUTPUT_DIR/$sample
done

# Command to execute the SurVirus pipeline
echo Processing SurVirus pipeline for samples
for sample in $UNIQ_FASTQ;
do
	echo "Start to process $sample"
	python /mnt/MDWorks4/Workdir_Nicolas/my_tools/SurVirus/surveyor.py \
		$DATADIR/tmp_nosave/$sample.R1.fastq,$DATADIR/tmp_nosave/$sample.R2.fastq \
		$OUTPUT_DIR/$sample \
		$REF_DIR/hg19/hg19.fa \
		$REF_DIR/all_HPV/HPVs.fa \
		$REF_DIR/hg19_HPVs/hg19+HPVs.fa \
		--fq \
		--threads $THREADS
	echo "Process completed for $sample"
done

#remove temporary folder 
#rm -r $DATADIR/tmp_nosave