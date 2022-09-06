# Joining channels using a map as key

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Midnighter/nextflow-gotchas/blob/main/docs/gotchas/join-on-map-fails-resume.md)

## Problem

You want to [`join`](https://www.nextflow.io/docs/latest/operator.html#join) two channels using identical [maps](https://www.nextflow.io/docs/latest/script.html#maps) as the key to join by.

```groovy title="examples/join-on-map-fails-resume/problem.nf" linenums="61"
left = LEFT(ch_param)  // (1)
right = RIGHT(ch_param)  // (2)

ch_joined = left.join(right)  // (3)
```

1. A channel that contains a pair of a map with sample meta information and a number.
    ```groovy
    tuple val(meta), val(count)
    ```
2. A channel that contains a pair of a map with sample meta information and a list of file paths.
    ```groovy
    tuple val(meta), path(reads)
    ```
3. The desired joined channel should contain the map, the number, and the file paths.
    ```groovy
    tuple val(meta), val(count), path(read_pairs)
    ```

This will work perfectly fine when you execute your workflow from the beginning. However, when you [resume](https://www.nextflow.io/docs/latest/getstarted.html?highlight=resume#modify-and-resume) your workflow, you will likely see that from the point of such a join statement, many samples are dropped from further processing since the maps no longer evaluate as being equal and thus the tuples are discarded as being incomplete. You can avoid elements being silently discarded by using the `failOnMismatch` option.

```groovy title="examples/join-on-map-fails-resume/problem.nf" linenums="61"
left = LEFT(ch_param)
right = RIGHT(ch_param)

ch_joined = left.join(right, failOnMismatch: true)
```

## Solution

Since maps, as mutable objects, may fail to evaluate as being equal after resuming[^1], we can pull out an immutable value from the maps and join on them. Your map likely contains an `id` key which is a unique string or integer that is equal in both channels to be joined. This requires a couple of channel transformations such that we end up with the resulting channel containing the desired map as first element, followed by the remaining elements from both joined channels.

[^1]: My current hypothesis is that when you start a new pipeline, the different channels point to the same map object, whereas when you _resume_, different instances of the map with the same content are created. Then, I guess the comparison carried out by nextflow to join channels, is based on the object identity rather than comparing all key, value pairs.

```groovy title="examples/join-on-map-fails-resume/solution.nf" linenums="61"
def left = LEFT(ch_param).map { [it[0].id, it[0], it[1]] }  // (1)
def right = RIGHT(ch_param).map { [it[0].id, it[0], it[1]] }  // (2)

def ch_joined = left.join(right).map { [it[1], it[2], it[4]] }  // (3)
```

1. We prepend the `id` key which contains an immutable value.
    ```groovy
    tuple val(id), val(meta), val(count)
    ```
2. We prepend the `id` key which contains an immutable value.
    ```groovy
    tuple val(id), val(meta), path(reads)
    ```
3. After the join that occurred on the `id` value, we remove that element and also drop one of the otherwise identical maps.
    ```groovy
    tuple val(meta), val(count), path(read_pairs)
    ```

In order to generally, safely join two channels on a map key, I therefore propose you use the following function which was developed together with :magic_wand: [Mahesh Binzer-Panchal](https://github.com/mahesh-panchal)

```groovy title="lib/CustomChannelOperators.groovy" linenums="1"
--8<-- "join-on-map-fails-resume/lib/CustomChannelOperators.groovy"
```
