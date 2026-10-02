# Missing process or function with name mix

## Issue

You get the follow error when using `.mix()` on channels

```output
Missing process or function with name 'mix'
```

## Possible source

- You passed a multi-channel output variable to `.mix` that causes this error:

    ```groovy
    ch_scaffolds2bin_for_dastool
        .mix(DASTOOL_SCAFFOLDS2BIN_METABAT2.out.scaffolds2bin)
        .mix(DASTOOL_SCAFFOLDS2BIN_MAXBIN2)
    ```

    when you should've specified the particular `.out` channels

    ```groovy
    ch_scaffolds2bin_for_dastool
        .mix(DASTOOL_SCAFFOLDS2BIN_METABAT2.out.scaffolds2bin)
        .mix(DASTOOL_SCAFFOLDS2BIN_MAXBIN2.out.scaffolds2bin)
    ```

## Recommendation

Use [static typing](https://docs.seqera.io/nextflow/static-typing) with Nextflow 26.10 or later. A typed process call returns its output directly, so assign it to a variable and pass the variable to `mix`. [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) reports a process name used as a value:

```output
Error main.nf:16:25: Process `DASTOOL_SCAFFOLDS2BIN_MAXBIN2` cannot be used as a variable
```

It also reports a `mix` of channels with different element types.
