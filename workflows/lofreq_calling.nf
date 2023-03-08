
// ----------------Workflow---------------- //

include { VariantsLoFreq } from '../modules/variants_lofreq.nf'
include { AnnotateVCF } from '../modules/annotate_vcf.nf'

workflow LOFREQ {

  take:
  bam_files
	
  main:
  // GATK VARIANT CALLER ------------------ //

  // Channel for genome reference fasta (absolute path from params won't do since the fasta index has to be in same dir for GATK)
  reference_fasta = Channel.fromPath("${params.resources_dir}/${params.reference_fasta_path}")

  // Channel for genome reference fasta index
  reference_fasta_index = Channel.fromPath("${params.resources_dir}/${params.reference_fasta_index_path}")

  // Variant calling
  VariantsLoFreq(reference_fasta, reference_fasta_index, bam_files)

  // ANNOTATE GATK VCF -------------------- //

  AnnotateVCF("lofreq", reference_fasta, VariantsLoFreq.out.lofreq_filt_vcf)

}
