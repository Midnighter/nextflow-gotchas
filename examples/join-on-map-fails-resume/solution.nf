#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process LEFT {
    input:
    val meta

    output:
    tuple val(meta), stdout

    script:
    """
    echo "${meta.id}"
    sleep 0.01
    """
}

process RIGHT {
    input:
    val meta

    output:
    tuple val(meta), path('*.txt')

    script:
    """
    echo "${meta.id}" > "${meta.prefix}.txt"
    echo "${meta.id} ${meta.id}" > "${meta.prefix}_${meta.prefix}.txt"
    sleep 0.01
    """
}

process COMPARE {
    input:
    tuple val(meta), val(id), path(files)

    output:
    tuple val(meta), val(id), path(files)

    script:
    """
    cat ${files}
    echo "${id}"
    sleep 0.2
    """
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    def ch_param = Channel.of(1..500)
        .map { [id: it, prefix: "${it}"] }

    LEFT(ch_param)
    RIGHT(ch_param)

    def ch_joined = CustomChannelOperators.joinOnKeys(LEFT.out, RIGHT.out, 'id', failOnMismatch: true)

    COMPARE(ch_joined)
}
