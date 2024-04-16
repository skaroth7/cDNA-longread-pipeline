import os
import shutil
count = 0

configfile:
    "config.json"
	
	
SAMPLES, = glob_wildcards(config['data']+"/fastq_merged/barcode{id}.fastq")

rule all:
    input:
        expand(config['data']+"/salmon_quantification_output/barcode{id}/quant.sf", id=SAMPLES)
		
		
		
rule make_directories:
    output:
        bam = config['data'] + "/bam_files/",
        scripts = config['data'] + "/transcripts/",
        fastq_trimmed = config['data'] + "/fastq_trimmed/"
    shell:
        """
        mkdir -p {output.bam}
        mkdir -p {output.scripts}
        mkdir -p {output.fastq_trimmed}
        """

		
rule quantify_transcripts:
	output:
		config['data']+"/salmon_quantification_output/barcode{id}/quant.sf"
		
	params:
		output_directory = config['data']+"/salmon_quantification_output/barcode{id}",
		input_directory = config['data']+"/salmon_reference_folder/"
	
	input:
		salmon_reference_folder = config['data']+"/salmon_reference_folder/hash.bin",
		trimmed_fastq = config['data']+"/fastq_trimmed/barcode{id}.fastq"
		
	shell:
		"salmon quant -i {params.input_directory} -l  SF -r {input.trimmed_fastq} --validate mappings -o {params.output_directory} -p 1"
			
rule pychopper:
	output:
		config['data']+"/fastq_trimmed/barcode{id}.fastq"
		
	params:
		report = config['data']+"/fastq_trimmed/report{id}.pdf"
		
	input:
		config['data']+"/fastq_merged/barcode{id}.fastq"
	shell:
		"pychopper -r {params.report} {input} {output} -t 1"
		

rule alignement:
	output:
		config['data']+"/bam_files/barcode{id}.sam"
	input:
		config['data']+"/fastq_trimmed/barcode{id}.fastq"
	params:
		reference = config['genome_reference']
	shell:
		"minimap2 -ax splice {params.reference} {input} > {output} -t 1"

rule sort alignments:
	output:
		config['data']+"/bam_files/barcode{id}.bam"
	input:
		config['data']+"/bam_files/barcode{id}.sam"
	shell:
		"samtools sort -o {output} {input}"

rule assemble_transcripts:
    output:
        config['data']+"/transcripts/barcode{id}.gtf"
    input:
        config['data']+"/bam_files/barcode{id}.bam"
    params:
        reference = config['transcriptome_reference']
    shell:
        "stringtie -e -G {params.reference} {input} -L -o {output}"

rule generate_salmon_reference:
    output:
        config['data']+"/salmon_reference_folder/hash.bin"
    input:
        expand(config['data']+"/transcripts/barcode{id}.gtf", id=SAMPLES)
    params:
        transcripts_dir = config['data']+"/transcripts/",
        salmon_index_dir = config['data']+"/salmon_reference_folder/",
        hg38_path = config['genome_reference'],
        transcriptome_path = config['transcriptome_reference']
    shell:
        """
        bash salmon_reference.sh {params.transcripts_dir} {params.salmon_index_dir} {params.hg38_path} {params.transcriptome_path}
        """