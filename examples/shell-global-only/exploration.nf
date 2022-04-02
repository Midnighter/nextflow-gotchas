#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process ECHO {
    echo true

    shell:
    def foo = task.ext.args ?: 'bar'

    log.info """
    ${task.process}: task.ext.args: ${task.ext.args}
    ${task.process}: foo: ${args}
    """

    '''
    echo !{foo}
    '''
}

workflow {
    ECHO()
}
