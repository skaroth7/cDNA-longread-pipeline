#!/bin/bash

# Assign command-line arguments to variables
transcripts_dir=$1
salmon_index_dir=$2
hg38_ref=$3
hg38_transcriptome=$4

# Navigate to the directory containing the GTF files
cd $transcripts_dir

# Generate a list of GTF files to be merged
gtf_files=$(ls *.gtf | tr '\n' ' ')

# Merge GTF files using stringtie --merge
stringtie --merge -G $hg38_transcriptome -o merged_barcode.gtf $gtf_files

# Generate a FASTA file for the transcripts from the merged GTF file
gffread -g $hg38_ref -w combined_transcripts.fasta merged_barcode.gtf

# Move the FASTA file to the desired location (optional based on your structure)
mv combined_transcripts.fasta ../

# Create a Salmon index from the FASTA file
salmon index -t ../combined_transcripts.fasta -i $salmon_index_dir --type quasi -k 31
