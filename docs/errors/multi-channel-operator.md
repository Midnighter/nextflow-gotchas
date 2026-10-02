# Multi-channel output cannot be applied to operator for which argument is already provided

## Issue

You get an error such as

```output
Multi-channel output cannot be applied to operator mix for which argument is already provided
```

## Possible source

You likely forgot to specify the output channel of a multi-channel output module or subworkflow, i.e.,

```groovy
ch_output = MODULE_A ( input )

MODULE_B ( ch_output )
```

should be

```groovy
ch_output = MODULE_A ( input ).reads

MODULE_B ( ch_output )
```

## Recommendation

Use [static typing](https://docs.seqera.io/nextflow/static-typing) with Nextflow 26.10 or later. [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) reports a multi-output result passed to an operator or process, and lists its output channels. Better yet, give each typed process a single [record output](https://docs.seqera.io/nextflow/process-typed#structured-outputs), so that the result is one channel and there is nothing to pick from.
