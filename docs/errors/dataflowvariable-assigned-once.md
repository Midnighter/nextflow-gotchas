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
