#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


include { PROCESS_SELECTOR_WARN } from './workflows/process_selector_warn'

workflow {
    PROCESS_SELECTOR_WARN()
}
