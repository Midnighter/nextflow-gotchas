#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Import processes
 ******************************************************************************/

include {
    ECHO as ECHO1;
    ECHO as ECHO2;
} from './echo'

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    def ch_input = Channel.of([id: 'test1', idx: 1], [id: 'test2', idx: 2])

    ECHO1(ch_input).view()

    ECHO2(
        ch_input.map { meta ->
            meta.id = 'foo'
            meta
        }
    ).view()
}
