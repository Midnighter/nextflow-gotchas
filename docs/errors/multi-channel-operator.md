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
