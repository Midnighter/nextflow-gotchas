# Joining channels using a map as key

## Problem

You want to [`join`](https://www.nextflow.io/docs/latest/operator.html#join) two channels using identical [maps](https://www.nextflow.io/docs/latest/script.html#maps) as the key to join by.

```groovy
left  // tuple val(meta), val(count)
right  // tuple val(meta), path(read_pairs)

left.join(right)  // tuple val(meta), val(count), path(read_pairs)
```

This will work perfectly fine when you execute your workflow from the beginning. However, when you [resume](https://www.nextflow.io/docs/latest/getstarted.html?highlight=resume#modify-and-resume) your workflow, you will likely see that from the point of such a join statement, many samples are dropped from further processing since the maps no longer evaluate as being equal and thus the tuples are discarded as being incomplete. You can avoid elements being silently discarded by using the `failOnMismatch` option.

```groovy
left  // tuple val(meta), val(count)
right  // tuple val(meta), path(read_pairs)

left.join(right, failOnMismatch: true)  // tuple val(meta), val(count), path(read_pairs)
```

## Solution

Since maps, as mutable objects, may fail to evaluate as being equal after resuming, we can pull out an immutable value from the maps and join on them. Your map likely contains an `id` key which is a unique string or integer that is equal in both channels to be joined. This requires a couple of channel transformations such that we end up with the resulting channel containing the desired map as first element, followed by the remaining elements from both joined channels.

```groovy
left.map { [it[0].id, it[0], it[1]] }
  .join(
    right.map { [it[0].id, it[0], it[1]] }
  )
  .map { [it[1], it[2], it[4]] }
```
