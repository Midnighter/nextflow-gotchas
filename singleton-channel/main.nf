#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process ECHO_ONCE {
    input:
    val(number)
    val(data)

    """
    echo ${number}-${data}
    """
}

process ECHO_EVERY {
    input:
    val(number)
    val(data)

    """
    echo ${number}-${data}
    """
}

process ECHO_COMBINATIONS {
    input:
    val(number)
    val(data)

    """
    echo ${number}-${data}
    """
}

workflow {
    ch_variadic = Channel.of(1..20)
    ch_singleton = Channel.of('arg')
    ch_short = Channel.of(31..33)

    // Single element channel is exhausted after first combination.
    ECHO_ONCE(ch_variadic, ch_singleton)

    // Turning the channel into a value channel means it cannot be exhausted.
    // https://www.nextflow.io/docs/latest/channel.html?#value-channel
    ECHO_EVERY(ch_variadic, ch_singleton.first())
    
    ch_combined = ch_variadic
        .combine(ch_short)
        .multiMap {
            left: it[0]
            right: it[1]
        }

    ECHO_COMBINATIONS(ch_combined.left, ch_combined.right)
}
