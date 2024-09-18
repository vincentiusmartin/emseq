

process BISCUIT_VCF2BED_MET {
    tag "$meta.id"
    label 'process_high'

    module 'mamba'
    conda '/research/groups/northcgrp/home/common/Vincentius/envs/biscuit'

    publishDir "${params.outdir}/biscuit/methyl", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_met.bed")

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    biscuit vcf2bed -t cg -k ${params.met_coverage} -c ${prefix}_pileup.vcf.gz > ${prefix}_met.bed
    biscuit mergecg ${params.genome_ref} ${prefix}_met.bed
    """
}

process BISCUIT_VCF2BED_SNP {
    tag "$meta.id"
    label 'process_high'

    module 'mamba'
    conda '/research/groups/northcgrp/home/common/Vincentius/envs/biscuit'

    publishDir "${params.outdir}/biscuit/snp", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_snp.bed")

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    biscuit vcf2bed -t snp -k ${params.snp_coverage} -c ${prefix}_pileup.vcf.gz > ${prefix}_snp.bed
    """
}