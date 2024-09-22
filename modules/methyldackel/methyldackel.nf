
process METHYLDACKEL {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/methyldackel", mode: 'copy'

    module 'mamba'
    conda '/research/groups/northcgrp/home/common/Vincentius/envs/biscuit'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.bedGraph")


    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools index ${prefix}_dup.bam
    MethylDackel extract -o "${prefix}" --mergeContext --minDepth 4 --OT 10,140,10,140 --OB 10,140,10,140 --maxVariantFrac 0.01 ${params.genome_ref} ${prefix}_dup.bam
    MethylDackel extract -o "${prefix}_low" --mergeContext --minDepth 1 --OT 10,140,10,140 --OB 10,140,10,140 ${params.genome_ref} ${prefix}_dup.bam
    """
    
}