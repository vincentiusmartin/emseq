/**
 * Perform biscuit aligner and convertion to sorted bam file
 */
process BISCUIT_ALIGN {
    tag "$meta.id"
    label 'process_high'

    module 'mamba'
    conda '/research/groups/northcgrp/home/common/Vincentius/envs/biscuit'

    publishDir "${params.outdir}/biscuit/align", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.bam")

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    biscuit align -@ ${task.cpus} -R "@RG\\tID:${prefix}\\tSM:${prefix}\\tPL:ILLUMINA\\tLB:LIB" \
        ${params.genome_ref} \
        ${prefix}_1.trimmed.fastq.gz ${prefix}_2.trimmed.fastq.gz | \
    samtools view -@ ${task.cpus} -S -b |
    samtools sort -@ ${task.cpus} -o ${prefix}.bam 
    """

}