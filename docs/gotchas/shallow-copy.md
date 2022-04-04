# Modifying mutable elements

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Midnighter/nextflow-gotchas/blob/main/docs/gotchas/shallow-copy.md)

## Problem

When working with [nf-core modules](https://nf-co.re/modules), a ubiquitous pattern is to pass around sample metadata as a [maps](https://groovy-lang.org/groovy-dev-kit.html#Collections-Maps). Maps are mutable objects.
In [nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html), you can reuse a channel. This creates a shallow copy of the channel's elements which can lead to surprising behavior in combination with mutable objects.

To see this in action run the first example.

```groovy title="echo.nf" linenums="1"
--8<-- "shallow-copy/echo.nf"
```

```groovy title="problem.nf" linenums="1" hl_lines="19 25"
--8<-- "shallow-copy/problem.nf"
```

Notice that we are modifying the `id` attribute of the maps.

```bash
NXF_VER='21.10.6' nextflow run examples/shallow-copy/problem.nf
```

```console
executor >  local (4)
[10/bbc389] process > ECHO1 (2) [100%] 2 of 2 ✔
[fa/3f7585] process > ECHO2 (2) [100%] 2 of 2 ✔
[id:foo, idx:1]
[id:foo, idx:1]
[id:foo, idx:2]
[id:foo, idx:2]
```

The channel `ch_input` contains two elements which are both maps. The channel is passed to a process `ECHO1` and then reused and modified before being passed to the process `ECHO2`. Intuitively, we would expect the reuse to copy the channel and thus be independent of the first use. However, due to nextflow being asynchronous and shallow copying the channels, we can see that all maps are modified.

## Solution

In order to achieve the desired outcome of the reused channel being independent of the first use, we need to clone the mutable element. This then creates a shallow of the mutable element itself which can be modified independently.

```groovy title="problem.nf" linenums="1" hl_lines="25"
--8<-- "shallow-copy/solution.nf"
```

To see the outcome, run the following:

```bash
NXF_VER='21.10.6' nextflow run examples/shallow-copy/solution.nf
```

```console
executor >  local (4)
[0e/0b1e55] process > ECHO1 (1) [100%] 2 of 2 ✔
[f6/4e9656] process > ECHO2 (2) [100%] 2 of 2 ✔
[id:foo, idx:1]
[id:test2, idx:2]
[id:test1, idx:1]
[id:foo, idx:2]
```

In some cases where you have nested mutable objects you may have to create a [deep copy](https://stackoverflow.com/a/13155429).
