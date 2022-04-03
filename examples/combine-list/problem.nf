#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Define processes
 ******************************************************************************/

process CREATE {
    input:
    val filename

    output:
    path filename

    script:  // (1)
    """
    echo ${filename} > ${filename}
    """
}

process CAT {
    input:
    tuple val(number), path(files)

    output:
    tuple val(number), path('result.txt')

    script:  // (2)
    """
    cat ${files} > result.txt
    echo 'Parameter: ${number}' >> result.txt
    """
}

/*******************************************************************************
 * Define main workflow
 ******************************************************************************/

workflow {
    ch_param = Channel.of(1..5)
    ch_files = Channel.of('foo.txt', 'bar.txt', 'baz.txt')

    CREATE(ch_files)

    CREATE.out.map { it.name } .view()  // (3)

    ch_input = ch_param.combine( CREATE.out.collect() )  // (4)

    ch_input.map { row ->
            [row.head()] + row.tail().collect{ it.name }  // (5)
        }
        .view()

    CAT(ch_input)

    CAT.out.map { it[1].text }.view()  // (6)
}
