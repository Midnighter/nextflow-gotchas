# Combine a list element

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Midnighter/nextflow-gotchas)

## Problem

Say that you have a tool which takes a parameter and a bunch of files and does something with those. This is exemplified by the process `CAT` below. My first approach was to [`collect`](https://www.nextflow.io/docs/latest/operator.html#collect) the files before [combining](https://www.nextflow.io/docs/latest/operator.html#combine) them with the parameter. See the following workflow as an example.

```groovy title="problem.nf" linenums="1" hl_lines="48"
--8<-- "combine-list/problem.nf"
```

1. Create a file with distinct content.
2. Concatenate all files into one and use the parameter value.
3. For better display, I'm only showing the [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) here and not the whole paths.
4. The [`collect`](https://www.nextflow.io/docs/latest/operator.html#collect) operator should turn this into a list.
5. Don't worry too much about this, I'm again transforming the output to only display [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) and not the entire paths.
6. Here, I want to show the [content of the resulting file](https://www.nextflow.io/docs/latest/script.html#basic-read-write) which is the second of the pair in the output.

Run the above workflow with:

```bash
NXF_VER='21.10.6' nextflow run examples/combine-list/problem.nf
```

which gives the following output. It looks like the [`combine`](https://www.nextflow.io/docs/latest/operator.html#combine) operator, when combining a single list of elements treats that just like a channel and forms the cartesian product with every element. There is also a warning about the input cardinality not matching the defined one in `CAT` and indeed we can see in the output that only one file is written to the result while the others are ignored.

```output hl_lines="27"
executor >  local (8)
[32/a72ef8] process > CREATE (1) [100%] 3 of 3 ✔
[0a/dfd2e7] process > CAT (4)    [100%] 5 of 5 ✔
baz.txt
bar.txt
foo.txt
[1, baz.txt, bar.txt, foo.txt]
[2, baz.txt, bar.txt, foo.txt]
[3, baz.txt, bar.txt, foo.txt]
[4, baz.txt, bar.txt, foo.txt]
[5, baz.txt, bar.txt, foo.txt]
baz.txt
Parameter: 1

baz.txt
Parameter: 5

baz.txt
Parameter: 2

baz.txt
Parameter: 3

baz.txt
Parameter: 4

WARN: Input tuple does not match input set cardinality declared by process `CAT`
```

## Solution

Well, if a single list gets treated just like a channel, maybe we can nest that list such that we have a list with a single element that is also a list. I tried quite a few different ways:

1. Can we collect twice?

    ```groovy
    ch_input = ch_param.combine( CREATE.out.collect().collect() )
    ```

    This does not work correctly. Just like in the problem, we get a flat list.

2. What if we place it into a list manually?

    ```groovy
    ch_input = ch_param.combine( [ CREATE.out.collect() ] )
    ```

    This yields an error

    ```output
    Not a valid path value type: groovyx.gpars.dataflow.DataflowVariable
    ```

    which makes sense since we place the collected variable (of type `DataflowVariable`) inside the literal list and thus it gets passed to our `CAT` process directly.

3. Instead of [`collect`](https://www.nextflow.io/docs/latest/operator.html#collect) there is also [`toList`](https://www.nextflow.io/docs/latest/operator.html#tolist)...

    ```groovy
    ch_input = ch_param.combine( [ CREATE.out.toList() ] )
    ```

    Same error :disappointed:

    ```output
    Not a valid path value type: groovyx.gpars.dataflow.DataflowVariable
    ```

4. Then I got the correct advice:

    ```groovy
    ch_input = ch_param.combine( CREATE.out.toList().toList() )
    ```

    The corresponding comment on Slack was:

    > **Harshil Patel**
    >
    > Don't ask me why.

    :see_no_evil: :speak_no_evil:

5. Turns out that the following combination also works.

    ```groovy
    ch_input = ch_param.combine( CREATE.out.collect().toList() )
    ```

So in full the solution looks as follows.

```groovy title="solution.nf" linenums="1" hl_lines="48"
--8<-- "combine-list/solution.nf"
```

1. Create a file with distinct content.
2. Concatenate all files into one and use the parameter value.
3. For better display, I'm only showing the [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) here and not the whole paths.
4. Use the winning solution from above. The [`toList`](https://www.nextflow.io/docs/latest/operator.html#tolist) operator applied twice creates the nested list.
5. Don't worry too much about this, I'm again transforming the output to only display [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) and not the entire paths.
6. Again, I want to show the [content of the resulting file](https://www.nextflow.io/docs/latest/script.html#basic-read-write) which is the second of the pair in the output.

Run the above workflow with:

```bash
NXF_VER='21.10.6' nextflow run examples/combine-list/solution.nf
```

This time, both the shape of the input for `CAT`, as well as the content of the resulting files are as expected. :v:

```output
executor >  local (8)
[0c/731285] process > CREATE (3) [100%] 3 of 3 ✔
[e0/670c78] process > CAT (5)    [100%] 5 of 5 ✔
bar.txt
foo.txt
baz.txt
[1, [bar.txt, foo.txt, baz.txt]]
[2, [bar.txt, foo.txt, baz.txt]]
[3, [bar.txt, foo.txt, baz.txt]]
[4, [bar.txt, foo.txt, baz.txt]]
[5, [bar.txt, foo.txt, baz.txt]]
bar.txt
foo.txt
baz.txt
Parameter: 3

bar.txt
foo.txt
baz.txt
Parameter: 1

bar.txt
foo.txt
baz.txt
Parameter: 4

bar.txt
foo.txt
baz.txt
Parameter: 2

bar.txt
foo.txt
baz.txt
Parameter: 5
```

## Alternative solutions

### DataflowVariable value

We saw above that the following code caused an error because we are passing a `groovyx.gpars.dataflow.DataflowVariable` to the process.

```groovy
ch_input = ch_param.combine( [ CREATE.out.collect() ] )
```

It is possible, _though highly discouraged_, to access a `DataflowVariable`'s inner value.

```groovy
ch_input = ch_param.combine( [ CREATE.out.collect() ] )  // (1)
    .map { first, second -> [first, second.val] }
```

1. This combination generates pairs where the first element is the `val` and the second the `DataflowVariable` containing the list.

### Creating a list through transformation

In our problem statement we saw:

```groovy
ch_input = ch_param.combine( CREATE.out.collect() )
```

which created lists of four elements each. The parameter and the three files. We can transform this shape ourselves.

```groovy
ch_input = ch_param.combine( CREATE.out.collect() )
    .map { [it.head(), it.tail()] }
```

Done :slight_smile:

### Using combine and groupTuple

A very different approach is to first combine every parameter value with every file. This generates pairs of one value and one file. We can then [group the pairs together as tuples](https://www.nextflow.io/docs/latest/operator.html#grouptuple).

```groovy title="group-tuple.nf" linenums="1" hl_lines="48-49"
--8<-- "combine-list/group-tuple.nf"
```

1. Create a file with distinct content.
2. Concatenate all files into one and use the parameter value.
3. For better display, I'm only showing the [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) here and not the whole paths.
4. Use [`combine`](https://www.nextflow.io/docs/latest/operator.html#combine) on the flat channels to generate pairs. Then collect tuples of files by grouping the pairs by their first element, the numeric value, with [`groupTuple`](https://www.nextflow.io/docs/latest/operator.html#grouptuple).
5. Don't worry too much about this, I'm again transforming the output to only display [filenames](https://www.nextflow.io/docs/latest/script.html#check-file-attributes) and not the entire paths.
6. Again, I want to show the [content of the resulting file](https://www.nextflow.io/docs/latest/script.html#basic-read-write) which is the second of the pair in the output.

Run it

```bash
NXF_VER='21.10.6' nextflow run examples/combine-list/group-tuple.nf
```

This generates the exact same solution. However, if you have a lot of elements in your channels this might perform slightly worse since you generate a lot more pairs first that you then have to group again.

```output
executor >  local (8)
[e9/c7a72b] process > CREATE (2) [100%] 3 of 3 ✔
[cb/44c510] process > CAT (5)    [100%] 5 of 5 ✔
baz.txt
foo.txt
bar.txt
[1, [baz.txt, foo.txt, bar.txt]]
[2, [baz.txt, foo.txt, bar.txt]]
[3, [baz.txt, foo.txt, bar.txt]]
[4, [baz.txt, foo.txt, bar.txt]]
[5, [baz.txt, foo.txt, bar.txt]]
baz.txt
foo.txt
bar.txt
Parameter: 4

baz.txt
foo.txt
bar.txt
Parameter: 2

baz.txt
foo.txt
bar.txt
Parameter: 3

baz.txt
foo.txt
bar.txt
Parameter: 1

baz.txt
foo.txt
bar.txt
Parameter: 5
```
