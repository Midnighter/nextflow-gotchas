# DataflowVariable can only be assigned once

## Issue

You get the following error, connected to a process

```output
Error executing process > 'PROCESS'

Caused by:
  A DataflowVariable can only be assigned once. Only re-assignments to an equal value are allowed.
```

## Possible source

You forgot the parentheses around a function like `flatten()`:

```groovy
PROCESS
    .out
    .vcfs
    .flatten
```

## Recommendation

Use [static typing](https://docs.seqera.io/nextflow/static-typing) with Nextflow 26.10 or later. [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) then reports the missing parentheses at the line where they are missing:

```output
Error main.nf:14:5: Unrecognized property `flatten` for type Channel<Set<Path>>
```
