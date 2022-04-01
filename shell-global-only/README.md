# Global variables only in shell blocks

## Problem

A very common pattern when working with [nf-core modules](https://nf-co.re/modules) is to define local arguments for a command. This pattern allows for defining some process-local defaults, as well as the ability to override those defaults from a configuration file.

```groovy
def args = task.ext.args ?: '--option 1'
```

I can then override this in a configuration:

```groovy
process {
    withName: PROCESS_NAME {
        ext.args = '--option 2'
    }
}
```

The other day, I needed to use a [shell block](https://www.nextflow.io/docs/latest/process.html#shell) instead of the normal [script block](https://www.nextflow.io/docs/latest/process.html#script) but I hit a snag; my `args` were being replaced with `[]`?! You can try this yourself by running the accompanying [workflow](main.nf).

```bash
NXF_VER=21.10.6 nextflow run main.nf
```

As you will see from the output, `args` contains the correct value `bar` but the final output is `[]`.

## Exploration

That made me wonder, "Is the `args` variable special somehow?" The name is easily changed to `foo` which you can try out with the following command:

```bash
NXF_VER=21.10.6 nextflow run main.nf --run_local_foo true
```

That leads to an error caused by: `No such variable: foo`. This was the clue I needed to find a solution.

## Solution

There are a couple of gotchas in nextflow with locally scoped variables (variables defined with `def`). So why not try with a process global? Removing the `def` keyword finally made the process run as expected. You can see for yourself by running the following:

```bash
NXF_VER=21.10.6 nextflow run main.nf --run_global_args true
```

For the details, please look at the [workflow definition](main.nf) directly.
