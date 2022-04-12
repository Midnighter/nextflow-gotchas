# Cannot get property id on null object

## Issue

Console

```output
Execution aborted due to an unexpected error

 -- Check script '/home/jfellows/Documents/git/nf-core/taxprofiler/./workflows/../modules/nf-core/modules/kraken2/kraken2/main.nf' at line: 2 or see '.nextflow.log' file for more details
```

Log

```output
java.lang.NullPointerException: Cannot get property 'id' on null object
```

## Possible source

In most cases `meta.id` does exist, it is just not accessible by Nextflow in the way it expects to.

- Input channels not correctly passed to a module
  - `meta` tuple is incorrectly nested (e.g. `[[<meta>]]` vs. ``[<meta>]``)
  - Other parts of an input channel are incorrectly nested e.g. `[meta] [[reads1.fq, reads2.fq]]` when should be `[meta] [reads1.fq, reads2.fq]`
- Can also occur when `meta.id` tag is specified the `tag` block of a module, but `meta` is not supplied as input.
