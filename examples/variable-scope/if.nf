#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    if (true) {
        def message = 'Hello... noone?'
    }
    def ch = Channel.of(message)
}
