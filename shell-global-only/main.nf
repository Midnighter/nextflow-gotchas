#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define default parameters
 ******************************************************************************/

params.run_local_args  = true
params.run_local_foo   = false
params.run_global_args = false

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process ECHO_LOCAL_ARGS {
    echo true

    shell:
    def args = task.ext.args ?: 'bar'

    log.info """
    ${task.process}: task.ext.args: ${task.ext.args}
    ${task.process}: args: ${args}
    """

    '''
    echo !{args}
    '''
}


process ECHO_LOCAL_FOO {
    echo true

    shell:
    def foo = task.ext.args ?: 'bar'

    log.info """
    ${task.process}: task.ext.args: ${task.ext.args}
    ${task.process}: foo: ${foo}
    """

    '''
    echo !{foo}
    '''
}


process ECHO_GLOBAL_ARGS {
    echo true

    shell:
    args = task.ext.args ?: 'bar'

    log.info """
    ${task.process}: task.ext.args: ${task.ext.args}
    ${task.process}: args: ${args}
    """

    '''
    echo !{args}
    '''
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    if (params.run_local_args) {
        ECHO_LOCAL_ARGS()
    }

    if (params.run_local_foo) {
        ECHO_LOCAL_FOO()
    }

    if (params.run_global_args) {
        ECHO_GLOBAL_ARGS()
    }
}
