

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { CAT_FASTQ } from '../modules/cat/fastq'
include { FASTQC } from '../modules/fastqc/fastqc'
include { BBDUK_TRIM } from '../modules/bbmap/bbduk'
include { BISCUIT_ALIGN } from '../modules/biscuit/align'
include { BISCUIT_PILEUP } from '../modules/biscuit/pileup'
include { BISCUIT_VCF2BED_MET } from '../modules/biscuit/vcf2bed'
include { BISCUIT_VCF2BED_SNP } from '../modules/biscuit/vcf2bed'
include { MARK_DUPLICATES } from '../modules/gatk/markduplicates'
include { METHYLDACKEL } from '../modules/methyldackel/methyldackel'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow EMSEQ {
    Channel
        .fromPath(params.input)
        .splitCsv(skip: 1)
        .map {
            meta, fastq_1, fastq_2 ->
            if (!fastq_2) {
                return [ [id:meta, single_end:true ], [ fastq_1 ] ]
            } else {
                return [ [id:meta, single_end:false ], [ fastq_1, fastq_2 ] ]
            }
        }
        .groupTuple(by: [0])
        .branch {
            meta, fastq ->
            single: fastq.size() == 1
            return [ meta, fastq.flatten() ]
            multiple: fastq.size() > 1
            return [ meta, fastq.flatten() ]
        }
        .set { ch_fastq }

    // MODULE: Concatenate FastQ files from same sample if required
    CAT_FASTQ(ch_fastq.multiple)
        .mix(ch_fastq.single)
        .set { ch_cat_fastq }

    // MODULE: Run FastQC
    FASTQC(ch_cat_fastq)

    // MODULE: BBDUK_TRIM
    BBDUK_TRIM(ch_cat_fastq)
        .set{ ch_trimmed_fastq }

    // Alignment (biscuit) and mark duplicates (gatk)
    ch_trimmed_fastq | BISCUIT_ALIGN | MARK_DUPLICATES

    // Perform Methylation call
    METHYLDACKEL ( MARK_DUPLICATES.out.dup )

    // MODULE: BISCUIT_PILEUP
    BISCUIT_PILEUP( MARK_DUPLICATES.out.dup )

    // MODULE: METHYLATION AND MUTATION CALLS
    BISCUIT_VCF2BED_MET( BISCUIT_PILEUP.out.pileup )
    BISCUIT_VCF2BED_SNP( BISCUIT_PILEUP.out.pileup )
    
}

