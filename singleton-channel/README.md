# Exhausting single element channels

## Problem

Processes that accept more than one argument, will be executed as many times as the smaller number of elements in either channel, for example, if you have a channel with five elements and another with two elements, the process will be called twice. This can be surprising because nextflow in DSL2 copies channels as needed.

## Solution

Channels can be turned into [value channels](https://www.nextflow.io/docs/latest/channel.html#value-channel) which can never be exhausted and read an unlimited number of times. A simple way to do this is by applying the operator [`first`](https://www.nextflow.io/docs/latest/operator.html#first).

You can see the differences by running the [example](main.nf), please refer to that file to see the details.

```bash
NXF_VER=21.10.6 nextflow run main.nf
```

## Addendum

If you have multiple channels of different numbers of elements but more than one element such that a value channel is not an option, you can apply some transformations to achieve the correct outcome. That is the last [example](main.nf).
