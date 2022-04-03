# Global variables only in shell blocks

## Problem

A very common pattern when working with [nf-core modules](https://nf-co.re/modules) is to define local arguments for a command. This pattern allows for defining some process-local defaults, as well as the ability to override those defaults from a configuration file.

Take the [gunzip module](https://nf-co.re/modules/gunzip), for example, it defines empty default arguments.

```groovy title="gunzip/main.nf" linenums="1" hl_lines="21"
process GUNZIP {
    tag "$archive"
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://containers.biocontainers.pro/s3/SingImgsRepo/biocontainers/v1.2.0_cv1/biocontainers_v1.2.0_cv1.img' :
        'biocontainers/biocontainers:v1.2.0_cv1' }"

    input:
    tuple val(meta), path(archive)

    output:
    tuple val(meta), path("$gunzip"), emit: gunzip
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    gunzip = archive.toString() - '.gz'
    """
    gunzip \\
        -f \\
        $args \\
        $archive
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gunzip: \$(echo \$(gunzip --version 2>&1) | sed 's/^.*(gzip) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
```

I can then override the default arguments with additional options in a configuration file such as a pipeline's `conf/modules.config`.

```groovy title="conf/modules.config"
process {
    withName: GUNZIP {
        ext.args = '--keep'
    }
}
```

The other day, I needed to use a [shell block](https://www.nextflow.io/docs/latest/process.html#shell) instead of the normal [script block](https://www.nextflow.io/docs/latest/process.html#script) but I hit a snag; my `args` were being replaced with `[]`?! :face_with_raised_eyebrow: You can try this yourself by running the following workflow.

```groovy title="problem.nf" linenums="1" hl_lines="13"
--8<-- "shell-global-only/problem.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/shell-global-copy/problem.nf
```

When you do so, you should see output like:

```output
executor >  local (1)
[97/a1e136] process > ECHO [100%] 1 of 1 ✔

    ECHO: task.ext.args: null
    ECHO: args: bar

[]
```

As you will see from the output, `args` contains the correct value `bar` but the final output is `[]`.

## Exploration

That made me wonder, "Is the `args` variable special somehow?" :thinking: The name is easily changed to `foo` which you can try yourself.

```groovy title="exploration.nf" linenums="1" hl_lines="9 13 17"
--8<-- "shell-global-only/exploration.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/shell-global-copy/exploration.nf
```

And :boom: big, fat error.

```output
Error executing process > 'ECHO_LOCAL_FOO'

Caused by:
  No such variable: foo

Source block:
  def foo = task.ext.args ?: 'bar'
  log.info """
      ${task.process}: task.ext.args: ${task.ext.args}
      ${task.process}: foo: ${foo}
      """
  '''
      echo !{foo}
      '''
```

This was the clue I needed to find a solution.

## Solution

There are [a couple of gotchas in nextflow with locally scoped variables](/nextflow-gotchas/gotchas/variable-scope/) (variables defined with `def`). So why not try with a process global? Removing the `def` keyword finally made the process run as expected. You can see for yourself by running the following:

```groovy title="solution.nf" linenums="1" hl_lines="9"
--8<-- "shell-global-only/solution.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/shell-global-copy/solution.nf
```

```output
executor >  local (1)
[ba/0e5d39] process > ECHO [100%] 1 of 1 ✔

    ECHO: task.ext.args: null
    ECHO: args: bar

bar
```

Smooth :sunglasses:
