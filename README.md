# *M. tuberculosis*  variant identification pipeline

Pipeline for *M. tuberculosis* variant identification from short-read data for epidemiology and phylogenetics. Briefly, this pipeline takes raw short-read Illumina data, pre-processes reads (read adapter trimming and taxonomic filtering), maps reads to a provided reference genome, calls variants, and outputs consensus FASTA sequences for downstream applications. The pipeline is written in Nextflow, so modules are adaptable. User options allow for tailoring of the pipeline such as setting custom filters and choosing a reference genome.

## Installation & set-up

1. Clone Github repo.
```
git clone https://github.com/ksw9/WalterPipeline.git
```

2. Load your HPC's container tool (i.e. Docker or Singularity) and nextflow. (Some clusters may have these pre-loaded.)
```
module load singularity # or docker
module load java nextflow 
```

3. Run script to download references and resources, specify docker/sigularity (these, especially the Kraken2 database, are too large to include elsewhere). 
```
# Run download_refs.sh.
cd WalterPipeline 
./scripts/download_refs.sh singularity # or docker
```
This should populate your resources directory with required references and databases.

4. Download the most up-to-date Kraken2 [database](https://benlangmead.github.io/aws-indexes/k2) to `resources/kraken_db` for taxonomic filtering. The Standard kraken2 databse is 62Gb, if you have space constraints, use the Standard-8 or Standard-16. (If you are using a pre-built Kraken2 database, skip this step.)
```
cd resources/kraken_db
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20221209.tar.gz 
tar -xf k2_standard_20221209.tar.gz 
```

5. Modify the config file (nextflow.config):
  - update resources_dir (full path to directory resources)
  - update clusterOptions parameter to make arguments specific to cluster
    - Stanford SCG: clusterOptions = "-A jandr --partition batch -N 1 --time=4:00:00 --mem-per-cpu 64G"
  - update kraken_db with the path to a previously installed Kraken2 database
  - Note: the nextflow.config file cluster arguments take precedence over the SLURM submission script parameters.

## Usage
1. Run the pipeline on the test data (truncated FASTQ files) included in the test_data directory. Include any user options here. The Docker image will be pulled automatically by running the pipeline the first time.
```
nextflow run main.nf -profile singularity # or docker
```

2. Run the pipeline on user data. 
  - Create a tab-delimited file with sample name, full path to FASTQ read 1, full path to FASTQ read 2, batch name, run name (format like data/reads_list.tsv). 
  - Update the nextflow.config so that the reads_list parameter is now defined by the new list. 
  - Run the pipeline.
```
nextflow run main.nf -profile singularity # or docker
sbatch scripts/submit_mtb_pipeline.sh # submit via a SLURM job scheduler script
```

## Options

There are several user options which can be modified on the command line or in the nextflow.config file (command line options take precedence).
- mapper (bwa/bowtie2): defines mapping algorithm to be used (default = bwa).
- run_lofreq (true/false): In addition to calling variants with GATK, will call low frequency minority variants with LoFreq.
- depth_threshold: defines minimum site depth for calling an allele (either variant or reference) that will be applied to generate a consensus sequence (default = 5)
- qual_threshold: defines the minimum site quality score for calling an allele (either variant or reference) that will be applied to generate a consensus sequence (default = 20)
- ploidy: defines ploidy for GATK variant calling (currently, only tested for ploidy = 1)
- threads: defines available threads (default = 4)
- nextseq (true/false): Use of NextSeq sequencing platform? (default = false). Nextseq has been found to [overcall](https://github.com/FelixKrueger/TrimGalore/blob/master/Docs/Trim_Galore_User_Guide.md) G bases at the 3' end; if this option is turned on, TrimGalore will ignore quality scores of G bases in the trimming step. 
- nextseq_qual_threshold: If the above parameter is true, defines the quality threshold for trimming (default = 20).

## Outputs

All outputs are stored in the results directory, within the project directory. Directory structure mirrors the input reads file, with directories organized by sequencing run, then sample.
```
├── results
│   ├── test_data/test (example organized by sequencing batch, then sample) 
|   │   ├──trim
|   │   ├──kraken
|   │   ├──bams
|   │   ├──vars
|   │   ├──fasta
|   │   ├──stats
```
## Example data

- Truncated paired-end fastq files are in the test_data directory.
- An input sample .tsv file list is located at config/test_data.tsv.

## Troubleshooting

- Singularity uses the `$HOME` directory as the default cache. This may cause errors if there are space limitations in `$HOME`. Specify a cache dir, `$TMPDIR`, via: 
``` 
export WORKDIR=$(pwd)
export TMPDIR=[set to temp directory]
export NXF_SINGULARITY_CACHEDIR=$WORKDIR/images
export SINGULARITY_CACHEDIR=$WORKDIR/images
export SINGULARITY_TMPDIR=$TMPDIR

```
- If Nextflow cannot pull Singularity image on the fly, pull manually, then run pipeline. 

```singularity pull ksw9-mtb-call.img docker://ksw9/mtb-call ```
- If pipeline truncates after a few steps, confirm that all expected files have been downloaded and are in the resources directory. This may be caused by incomplete download (i.e. of refs/).

