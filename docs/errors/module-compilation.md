# Module compilation error

## Issue

You get the following error, connected to the whole workflow

```output
 - file : [PATH]
 -  cause: Unexpected input: '{' @ line N, column N.
 -  workflow [WORKFLOW] {
```

## Possible source

- You put two `.` next to each other, such as at the end of the first line and the start of the second:

    ```groovy
    PROCESS.
        .out
        .bam
        .set{ch_bams}
    ```

## Recommendation

Run [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) with Nextflow 26.10 or later. It reports the error on the line after the stray `.`, instead of at the workflow definition:

```output
Error main.nf:8:10: Unexpected input: 'out'
```
