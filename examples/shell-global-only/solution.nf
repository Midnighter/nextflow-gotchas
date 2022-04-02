#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process ECHO {
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

workflow {
    ECHO()
}
