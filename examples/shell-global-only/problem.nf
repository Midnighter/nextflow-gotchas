#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process ECHO {
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

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    ECHO()
}
