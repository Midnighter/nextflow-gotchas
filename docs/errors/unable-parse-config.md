# Unable to parse config file

## Issue

```output
Unable to parse config file: 'nextflow.config'

Compile failed for sources FixedSetSources[name='/groovy/script/Script7452FB2E4729BDF4899A4D4633CAE72A']. Cause: org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
/groovy/script/Script7452FB2E4729BDF4899A4D4633CAE72A: 432: Unexpected input: '{' @ line 432, column 8.
    process{
           ^
```

## Possible source

Syntax error in `modules.config`, such as:

1. Missing comma in `publishDir`
2. Additional `=` after `ext.<>` directive
3. Missing `{` or `}` somewhere

Mentioned line numbers OR mentioned sign are not indicative of where to search for the error, i.e., in the above example the actual problem was a duplicated `=`.

## Recommendation

Run [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) on your config files with Nextflow 26.10 or later. It reports a missing comma or a duplicated `=` at the line where it happens. A missing `}` is reported at the end of the file, with a hint:

```output
Error nextflow.config:9:1: Unexpected end of file -- check for an unclosed brace, bracket, parenthesis, or string
```
