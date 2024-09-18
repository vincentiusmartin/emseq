/**
 * Perform Picard Mark Duplicates
 * note that ValidateSamFile is not used as it results in warning written to stderr
 * causing the pipeline to fail
 */

process MARK_DUPLICATES {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/gatk", mode: 'copy'

    module 'gatk'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_dup.bam"), emit: dup
    tuple val(meta), path("*.metric.txt"), emit: metric


    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk MarkDuplicates -I ${prefix}.bam -O ${prefix}_dup.bam -M ${prefix}.metric.txt
    """
    
}