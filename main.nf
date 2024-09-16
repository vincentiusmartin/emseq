#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { EMSEQ } from './workflows/emseq'

workflow {
    EMSEQ()
}