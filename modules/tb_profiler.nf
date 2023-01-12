process TbProfiler {

  // TB Profiler to assign sub-lineage
  
  label 'slurm'

  publishDir "${projectDir}/results/${batch}/${sample_id}/stats", mode: "copy", pattern: "*_lineageSpo_${params.variant_caller}.{csv,json}"
  publishDir "${projectDir}/results/${batch}/${sample_id}/stats", mode: "copy", pattern: "*.errlog.txt"

  input:
  tuple val(sample_id), path(bam), val(batch), val(run)

  output:
  path "${sample_id}_lineageSpo_${params.variant_caller}.csv", optional: true
  path "*.errlog.txt", optional: true

  script:
    """
    # Rename Chromosome for compatibility with Tb-profiler
    samtools view -h -t \$SLURM_CPUS_ON_NODE ${bam} | sed 's/NC_000962.3/Chromosome/g' | sambamba view -t \$SLURM_CPUS_ON_NODE -S -f bam -o tmp_renamed.bam /dev/stdin

    # Running Tb-profiler
    tb-profiler profile --bam tmp_renamed.bam --prefix ${sample_id} --dir . --csv --spoligotype --threads \$SLURM_CPUS_ON_NODE --caller ${params.variant_caller}

    # Renaming outputs
    mv results/${sample_id}.results.csv ${sample_id}_lineageSpo_${params.variant_caller}.csv
    mv results/${sample_id}.results.json ${sample_id}_lineageSpo_${params.variant_caller}.json
    """

}