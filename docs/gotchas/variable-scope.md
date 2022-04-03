
# Variable scope

Under most circumstances it is recommended to use local variable scope. In Groovy and thus nextflow, you do this with the `def` keyword. However, there are some situations where this can be awkward or even surprising.

## Conditionals

In the following workflow, the variable `message` is declared local to the `if` statement and cannot be accessed outside it. :confused:

```groovy title="if.nf" linenums="1" hl_lines="11"
--8<-- "variable-scope/if.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/variable-scope/if.nf
```

```output
No such variable: message

 -- Check script 'examples/variable-scope/problem.nf' at line: 13 or see '.nextflow.log' file for more details
```

## Process blocks

### Problem

In my mental model, a [nextflow process](https://www.nextflow.io/docs/latest/process.html) is very much a logical unit. However, a process consists of up to five blocks and variables local to one block, cannot be used in another. As an example:

```groovy title="process-problem.nf" linenums="1" hl_lines="18"
--8<-- "variable-scope/process-problem.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/variable-scope/process-problem.nf
```

```output
executor >  local (1)
[28/98c503] process > TOUCH [100%] 1 of 1, failed: 1 ✘
Error executing process > 'TOUCH'

Caused by:
  Missing output file(s) `result` expected by process `TOUCH`

Command executed:

  touch 'snafu.txt'

Command exit status:
  0

Command output:
  (empty)
```

### Solution

It is an error to use the `result` variable which was declared local to the `script` block, in any other block. One may want to use a variable defined in the `script` block in the `output` block. In that case, you have to remove the `def` keyword to make it global.

```groovy title="process-solution.nf" linenums="1" hl_lines="18"
--8<-- "variable-scope/process-solution.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/variable-scope/process-solution.nf
```

```output
executor >  local (1)
[f4/263762] process > TOUCH [100%] 1 of 1 ✔
```

## Mixing variables

Additionally, if you use a variable with global scope in the assignment of a variable with local scope, this is also an error.

```groovy title="mixing-problem.nf" linenums="1" hl_lines="19"
--8<-- "variable-scope/mixing-problem.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/variable-scope/mixing-problem.nf
```

```output
Script compilation error
- cause: Variable `result` already defined in the process scope @ line 19, column 18.
       def choice = result.startsWith('snafu') ? 'yes' : 'no'
                    ^
```

That means, any variable that uses a global in its assignment, has to be global also.

```groovy title="mixing-solution.nf" linenums="1" hl_lines="19"
--8<-- "variable-scope/mixing-solution.nf"
```

```bash
NXF_VER='21.10.6' nextflow run examples/variable-scope/mixing-solution.nf
```

```output
executor >  local (1)
[c2/70f706] process > ECHO [100%] 1 of 1 ✔
```

Hope this helps, it can be quite baffling.
