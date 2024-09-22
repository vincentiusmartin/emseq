/**
 * Perform biscuit pileup
 * See reference: https://huishenlab.github.io/biscuit/docs/pileup.html
 */
process BISCUIT_PILEUP {
    tag "$meta.id"
    label 'process_high'
    errorStrategy 'ignore'

    module 'mamba'
    conda '/research/groups/northcgrp/home/common/Vincentius/envs/biscuit'

    publishDir "${params.outdir}/biscuit/pileup", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_pileup.vcf.gz"), emit: pileup
    tuple val(meta), path("*meth_average.tsv"), emit: methavg

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools index ${prefix}_dup.bam
    biscuit pileup -@ ${task.cpus} -o ${prefix}_pileup.vcf ${params.genome_ref} ${prefix}_dup.bam
    bgzip -@ ${task.cpus} ${prefix}_pileup.vcf
    tabix -p vcf ${prefix}_pileup.vcf.gz
    """

}