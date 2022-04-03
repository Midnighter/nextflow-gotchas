#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process TOUCH {
    input:
    val(meta)

    output:
    tuple val(meta), path(result)


    script:
    result = "${meta.id}.txt"
    """
    touch '${result}'
    """
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    TOUCH([id: 'snafu'])
}
