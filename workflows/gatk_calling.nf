
// ----------------Workflow---------------- //

include { VariantsGATK } from '../modules/variants_gatk.nf'
include { ConvertVCF } from '../modules/vcf2fasta.nf'
include { AnnotateVCF } from '../modules/annotate_vcf.nf'

workflow GATK {

  take:
  bam_files
	
  main:
  // GATK VARIANT CALLER ------------------ //

  // Channel for genome reference fasta (absolute path from params won't do since the fasta index has to be in same dir for GATK)
  reference_fasta = Channel.fromPath("${params.resources_dir}/${params.reference_fasta_path}")

  // Channel for genome reference fasta index
  reference_fasta_index = Channel.fromPath("${params.resources_dir}/${params.reference_fasta_index_path}")

  // Channel for GATK dictionary (absolute path from params won't do since it has to be present in the dir where GATK is launched)
  gatk_dictionary = Channel.fromPath("${params.resources_dir}/${params.gatk_dictionary_path}")

  // Channel for masking bed file required by "gatk VariantFiltration" in VariantsGATK
  bed_file = Channel.fromPath("${params.resources_dir}/${params.bed_path}")

  // Channel for masking bed file index required by "gatk VariantFiltration" in VariantsGATK
  bed_file_index = Channel.fromPath("${params.resources_dir}/${params.bed_index_path}")

  // Variant calling
  VariantsGATK(reference_fasta, reference_fasta_index, gatk_dictionary, bed_file, bed_file_index, bam_files)

  // CONVERTING VCF TO FASTA -------------- //

  ConvertVCF("GATK", reference_fasta, VariantsGATK.out.gatk_vcf_filt)

  // ANNOTATE GATK VCF -------------------- //

  AnnotateVCF("GATK", reference_fasta, VariantsGATK.out.gatk_vcf_filt)

}