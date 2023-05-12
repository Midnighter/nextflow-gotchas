# Invalid method invocation with arguments

## Issue

You get an error such as:

```nextflow
ERROR ~ Invalid method invocation `call` with arguments: [i, am, a] (java.util.ArrayList) on _runScript_closure1 type

 -- Check '.nextflow-console.log' file for details
```

Note that `call` can sometimes be reported as `doCall`.

## Possible source

This normally means you are using a closure (e.g. `map`) on a channel somewhere in your workflow in which you define variables to each element of the input channel.

You will get the error if the input channel has additional or fewer elements that defined in the closure function.

```nextflow
ch_input = Channel.of(['foo', 'bar', 'baz'])

ch_input
    .map{
        one, two ->
        [one]
    }
```

or

```nextflow
ch_input = Channel.of(['foo'])

ch_input
    .map{
        one, two ->
        [one]
    }
```

## Possible Solution

To fix, ensure that whenever you define variables to elements there is a one to one ratio of variable names to elements

```nextflow
ch_input = Channel.of(['foo', 'bar', 'baz'])

ch_input
    .map{
        one, two, thjree ->
        [one]
    }
````

Note that the error message does not report where this happens, so you will have to look for all cases of a closure being applied to the channel with the channel contents as reported in the error, to find where this occurs.
