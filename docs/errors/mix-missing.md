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
