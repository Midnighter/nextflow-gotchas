#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process ECHO {
    input:
    val(number)
    val(data)

    """
    echo ${number}-${data}
    """
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    ch_variadic = Channel.of(1..20)
    ch_singleton = Channel.of('arg')

    ECHO(ch_variadic, ch_singleton.first())
}

