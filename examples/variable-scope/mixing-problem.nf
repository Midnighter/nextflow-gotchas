#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process ECHO {
    input:
    val(meta)

    output:
    tuple val(meta), path(result)


    script:
    result = "${meta.id}.txt"
    def choice = result.startsWith('snafu') ? 'yes' : 'no'
    """
    echo '${choice}' > '${result}'
    """
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    ECHO([id: 'snafu'])
}
