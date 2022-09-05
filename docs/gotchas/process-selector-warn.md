# No process matching config selector warnings

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Midnighter/nextflow-gotchas/blob/main/docs/gotchas/process-selector-warn.md)

## Problem

You are using a process twice in a pipeline in two different subworkflows. Additionally, both are optional to run, so you wrap them in `if` statements.

```groovy
if ( params.run_module ) {
    PROCESS ()
}
```

You may need to provide each of them different [`publishDir`](https://www.nextflow.io/docs/latest/process.html#publishdir) options so to disambiguate between the two in a [configuration file](https://www.nextflow.io/docs/latest/config.html#configuration-file), you differentiate them using a [`withName` selector](https://www.nextflow.io/docs/latest/config.html#process-selectors) and give them the fully resolved path name `PIPELINE:WORKFLOW:SUBWORKFLOW:PROCESS`.

```groovy
process {
    withName: 'PIPELINE:WORKFLOW:SUBWORKFLOW_ONE:PROCESS' {
         publishDir = [
            path: { "${params.outdir}/PROCESS_ONE" },
        ]
    }
    withName: 'PIPELINE:WORKFLOW:SUBWORKFLOW_TWO:PROCESS' {
         publishDir = [
            path: { "${params.outdir}/PROCESS_TWO" },
        ]
    }
}
```

This should be sufficient to distinguish between the two, right?

But then when you run your pipeline, with the `if` statement around the module set to `false`

```bash
nextflow run main.nf --run_module false
```

You suddenly get the following warnings:

```output
WARN: There's no process matching config selector: <PIPELINE>:<WORKFLOW>:<SUBWORKFLOW_ONE>:<PROCESS>
WARN: There's no process matching config selector: <PIPELINE>:<WORKFLOW>:<SUBWORKFLOW_TWO>:<PROCESS>
```

...huh? :thinking:

## Solution

Apparently, the different ways of specifying a module using the [`withName` selector](https://www.nextflow.io/docs/latest/config.html#process-selectors) have different behaviours.

-   Only an explicit module name can cope with 'optional' execution and have a selector still picked up, even if it's 'turned off'.
-   Fully resolved paths or [wildcarded `withName` selectors](https://www.nextflow.io/docs/latest/config.html#selector-expressions) cannot be evaluated by Nextflow in this manner, and thus give you warnings like above.

Here, your solutions are:

1. Give each of the two processes a unique name via an [alias](https://www.nextflow.io/docs/latest/dsl2.html#module-aliases) and use that in the configuration file.

    `subworkflows/subworkflow_one.nf`:

    ```groovy
    include { PROCESS as PROCESS_ONE } from 'modules/process_module'
    ```

    `subworkflows/subworkflow_two.nf`:

    ```groovy
    include { PROCESS as PROCESS_TWO } from 'modules/process_module'
    ```

    Configuration:

    ```groovy
    process {
        withName: 'PROCESS_ONE' {
            publishDir = [
                path: { "${params.outdir}/PROCESS_ONE" },
            ]
        }
        withName: 'PROCESS_TWO' {
            publishDir = [
                path: { "${params.outdir}/PROCESS_TWO" },
            ]
        }
    }
    ```

2. Wrap the `withName` selector for the module **also** in the configuration file:

    ```groovy
    process {
        if ( param.run_module ) {
            withName: 'PIPELINE:WORKFLOW:SUBWORKFLOW_ONE:PROCESS' {
                publishDir = [
                    path: { "${params.outdir}/PROCESS_ONE" },
                ]
            }
            withName: 'PIPELINE:WORKFLOW:SUBWORKFLOW_TWO:PROCESS' {
                publishDir = [
                    path: { "${params.outdir}/PROCESS_TWO" },
                ]
            }
        }
    }
    ```
