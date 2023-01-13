# *M. tuberculosis*  variant identification pipeline

Pipeline for *M. tuberculosis* variant identification from short-read data for epidemiology and phylogenetics. Briefly, this pipeline takes raw short-read Illumina data, pre-processes reads (read adapter trimming and taxonomic filtering), maps reads to a provided reference genome, calls variants, and outputs consensus FASTA sequences for downstream applications. The pipeline is written in Nextflow, so modules are adaptable. User options allow for tailoring of the pipeline such as setting custom filters and choosing a reference genome.

## Installation & set-up

1. Download Docker image. This is a containerized pipeline, so the Docker image contains the software and versions required for analysis.
```
docker pull YYY 
```

2. Run script to download references and resources (these, especially the Kraken2 database, are too large to include elsewhere). The Kraken2 database requires ~100G of space; users with more limited memory might consider a different database.
```
# Clone Github (includes scripts and small, pipeline-specific resources).
git clone https://github.com/ksw9/WalterPipeline.git

# Run download_refs.sh.
cd WalterPipeline (update w/name of pipeline)
./scripts/download_refs.sh
```
This should populate your resources directory with all required references and databases.

3. Modify the config file (nextflow.config).
  - update the path to the Docker image
  - update all paths to resources

## Usage
1. Run the pipeline on the test data (truncated FASTQ files) included in the test_data directory. Include any user options here. 
```
nextflow run main.nf
```

2. Run the pipeline on user data. 
  - Create a tab-delimited file with sample name, full path to FASTQ read 1, full path to FASTQ read 2, batch name, run name (format like data/reads_list.tsv). 
  - Update the nextflow.config so that the reads_list parameter is now defined by the new list. 
  - Run the pipeline.
```
nextflow run main.nf
```
 
