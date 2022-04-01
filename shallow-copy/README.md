# Modifying mutable elements

## Problem

When working with [nf-core modules](https://nf-co.re/modules), a ubiquitous pattern is to pass around sample metadata as a hash map. Hash maps are mutable objects.
In nextflow DSL2, you can reuse a channel. This creates a shallow copy of the channel's elements which can lead to surprising behavior in combination with mutable objects.

To see this in action run the first example.

```bash
NXF_VER=21.10.6 nextflow run main.nf
```

The channel `ch_input` contains two elements which are both maps. The channel is passed to a process `ECHO_1_1` and then reused and modified before being passed to the process `ECHO_1_2`. Intuitively, we would expect the reuse to copy the channel and thus be independent of the first use. However, due to shallow copying we can see that both uses of the channel are modified.

## Solution

In order to achieve the desired outcome of the reused channel being independent of the first use, we need to clone the mutable element. This then creates a shallow of the mutable element itself which can be modified independently. To see the outcome, run the following:

```bash
NXF_VER=21.10.6 nextflow run main.nf --run_solution true
```

In some cases where you have nested mutable objects you may have to create a [deep copy](https://stackoverflow.com/a/13155429).
