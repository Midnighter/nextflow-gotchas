# No process matching config selector warnings

## Problem

You have used a module twice in a pipeline, but are placed in two different subworkflows.

In this case, both are optional to run, so you wrap them in `if` statements.

```nextflow
if ( params.run_module ) {
    MODULE ()
}
```

You may need to provide each of them different `publishDir` options, so to disambiguate between the two in a config file, you differentiate them with a `withName:` selector and give them the fully resolved path name (`PIPELINE:WORKFLOW:SUBWORKFLOW:MODULE`).

```nextflow
process {
    withName: 'PIPELINE:WORKFLOW:SUBWORKFLOW:MODULE' {
         publishDir = [
            path: { "${params.outdir}/MODULE_ONE" },
        ]
    }
}
```

This should be sufficient right to distinguish between the two, right?

But then when you run your pipeline, with the `if` statement around the module set to `false`

```console
$ nextflow run main.nf --run_module false
```

You suddenly get the following warnings:

```console
WARN: There's no process matching config selector: <PIPELINE>:<WORKFLOW>:<SUBWORKFLOW>:<MODULE>
WARN: There's no process matching config selector: <PIPELINE>:<WORKFLOW>:<SUBWORKFLOW>:<MODULE>
```

...huh?

## Solution

Apparently, the different ways of specifying a module with the `withName:` selector have different behaviours.

Only a explicit module name can copy with 'optional' execution and have a selector still picked up, even if it's 'turned off'.

Fully resolved paths or wildcarded `withName` selectors cannot be evaluated by Nextflow in this manner, and thus give you the `WARN`ings.

Here, your solutions are:

1. Give each of the two modules a unique name with `as` in the include statement in the pipeline code, and use that in the config file

    ```nextflow
    include { MODULE as MODULE_FIRST } from 'modules/<module>'
    ```

2. Wrap the `withName:` selector for the module ALSO in the config file

    ```
    if ( param.run_module ) {
        withName: '<PIPELINE>:<WORKFLOW>:<SUBWORKFLOW>:<MODULE>' {
            publishDir = [ <...options...>]
        }
    }
    ```
