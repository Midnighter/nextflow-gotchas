# Exhausting single element channels

## Problem

Processes that accept more than one argument, will be executed as many times as the smaller number of elements in either channel, for example, if you have a channel with five elements and another with two elements, the process will be called twice. If you have a channel with a single element, it is not reused automatically but the process is executed just once. This can be surprising because [nextflow in DSL2 copies channels as needed](https://www.nextflow.io/docs/latest/dsl2.html#channel-forking).

```groovy title="problem.nf" linenums="1" hl_lines="27"
--8<-- "singleton-channel/problem.nf"
```

Run the above workflow with:

```bash
NXF_VER='21.10.6' nextflow run examples/singleton-channel/problem.nf
```

which gives the following output, the process is just called once.

```output
executor >  local (1)
[b5/7c55cf] process > ECHO (1) [100%] 1 of 1 ✔
```

## Solution

Channels can be turned into [value channels](https://www.nextflow.io/docs/latest/channel.html#value-channel) which can never be exhausted and read an unlimited number of times. A simple way to do this is by applying the operator [`first`](https://www.nextflow.io/docs/latest/operator.html#first).

```groovy title="solution.nf" linenums="1" hl_lines="27"
--8<-- "singleton-channel/solution.nf"
```

You can see the difference by running the workflow.

```bash
NXF_VER='21.10.6' nextflow run examples/singleton-channel/solution.nf
```

```output
executor >  local (20)
[02/fa180f] process > ECHO (20) [100%] 20 of 20 ✔
```

Please note the following admonition from the nextflow documentation:

!!! note

    A value channel is implicitly created by a process when an input specifies a simple value in the `from` clause. Moreover, a value channel is also implicitly created as output for a process whose inputs are only value channels.

This means that a process that gets passed a value and, for example, downloads a file, implicitly has a value channel created for that file and it can be reused indefinitely.
## Combinations

If you have multiple channels of different numbers of elements but more than one element such that a value channel is not an option, you can apply some transformations to achieve the correct outcome.

```groovy title="combinations.nf" linenums="1" hl_lines="27-32 34"
--8<-- "singleton-channel/combinations.nf"
```

In this workflow, [`combine`](https://www.nextflow.io/docs/latest/operator.html#combine) does most of the work, as it _combines_ each element from one channel with every element of the other channel. Afterwards, we use [`multiMap`](https://www.nextflow.io/docs/latest/operator.html#multimap) to split the pairs into two separate channels that we can pass to the process which expects two arguments.

You can see the difference by running the workflow.

```bash
NXF_VER='21.10.6' nextflow run examples/singleton-channel/combinations.nf
```

Combinatorics, wheee

```output
executor >  local (60)
[09/71172f] process > ECHO (60) [100%] 60 of 60 ✔
```
