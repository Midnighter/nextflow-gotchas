# Invalid method invocation with arguments

## Issue

You get an error such as:

```sh
ERROR ~ Invalid method invocation `call` with arguments: [i, am, a] (java.util.ArrayList) on _runScript_closure1 type  # (1)!

 -- Check '.nextflow-console.log' file for details
```

1. Note that `call` can sometimes be reported as `doCall`.

## Possible source

This normally means you are using a closure (e.g., within a
[map](https://www.nextflow.io/docs/latest/operator.html#map) call) on a channel
somewhere in your workflow in which you define variables for each element of the
input channel.

You will get the error if the input channel has additional or fewer elements
than defined in the closure function.

```nextflow
ch_input = Channel.of(['foo', 'bar', 'baz'])

ch_input.map{ one, two -> [one] }
```

or

```nextflow
ch_input = Channel.of(['foo'])

ch_input.map{ one, two -> [one] }
```

## Solution

To fix, ensure that whenever you define variables to elements there is a one to
one ratio of variable names to elements

```nextflow
ch_input = Channel.of(['foo', 'bar', 'baz'])

ch_input.map{ one, two, three -> [one] }
```

Note that the error message does not report where this happens, so you will have
to look for all cases of a closure being applied to the channel with the channel
contents as reported in the error, to find where this occurs. Liberal use of the
[dump](https://www.nextflow.io/docs/latest/operator.html#dump) channel operator
can help you spot a mismatch between expected and actual channel content.

## Recommendation

Use [static typing](https://docs.seqera.io/nextflow/static-typing) with Nextflow 26.10 or later. [`nextflow lint`](https://docs.seqera.io/nextflow/reference/cli/lint) reports a closure whose parameters don't match the channel item, at the line where it happens:

```nextflow
ch_input = channel.of(tuple('foo', 'bar', 'baz'))
ch_input.map { one, two -> one }
```

```output
Error main.nf:5:18: Closure with signature (?, ?) -> ? is not compatible with expected signature: (String, String, String) -> R
```

Only tuples can be destructured in typed code, so create channel items with `tuple()`, or use [records](https://docs.seqera.io/nextflow/script#records-and-tuples) and access fields by name.
