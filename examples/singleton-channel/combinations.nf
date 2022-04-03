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
    ch_long = Channel.of(1..20)
    ch_short = Channel.of(31..33)

    ch_combined = ch_long
        .combine(ch_short)
        .multiMap {
            first: it[0]
            second: it[1]
        }

    ECHO(ch_combined.first, ch_combined.second)
}
