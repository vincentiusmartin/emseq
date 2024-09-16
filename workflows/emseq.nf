

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { CAT_FASTQ } from '../modules/cat/fastq/main'
include { FASTQC } from '../modules/fastqc/main'
include { BBDUK_TRIM } from '../modules/bbmap/main'

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

    //
    // MODULE: Concatenate FastQ files from same sample if required
    //
    CAT_FASTQ(ch_fastq.multiple)
        .mix(ch_fastq.single)
        .set { ch_cat_fastq }

    //
    // MODULE: Run FastQC
    //
    FASTQC(ch_cat_fastq)

    //
    // MODULE: BBDUK_TRIM
    //
    BBDUK_TRIM(ch_cat_fastq)
    

}

