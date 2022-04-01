#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define default parameters
 ******************************************************************************/

params.run_problem  = true
params.run_solution   = false

/*******************************************************************************
 * Import processes
 ******************************************************************************/

include {
    ECHO as ECHO_1_1;
    ECHO as ECHO_1_2;
    ECHO as ECHO_2_1;
    ECHO as ECHO_2_2;

} from './echo'

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    def ch_input = Channel.of([id: 'test1', idx: 1], [id: 'test2', idx: 2])

    if (params.run_problem && !params.run_solution) {
        ECHO_1_1(ch_input).view()
    
        ECHO_1_2(
            ch_input.map { meta ->
                meta.id = 'foo'
                meta
            }
        ).view()
    }

    if (params.run_solution) {
        ECHO_2_1(ch_input).view()
    
        ECHO_2_2(
            ch_input.map { meta ->
                def dup = meta.clone()
                dup.id = 'foo'
                dup
            }
        ).view()
    }
}
