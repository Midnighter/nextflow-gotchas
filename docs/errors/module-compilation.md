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
