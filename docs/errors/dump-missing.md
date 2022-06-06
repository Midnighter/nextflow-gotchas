# Missing process or function with name dump

## Issue

When using the `.dump()` function you get an error to console

```output
Missing process or function with name 'dump'
```

## Possible source

In many cases, the function is not _missing_, just incorrectly applied.

- Missing `tag:` before the actual tag name (e.g. `.dump('my tag') vs .dump(tag: 'my_tag')`)
- Placed on a channel-type that does not support the `.dump` function (e.g. channels with branches)
- `.dump()` was applied on a multi-channel output object without specifying which channel
- `.dump()` was applied on a single-channel, unnamed output directly. Usually, when a process
defines a single output, unnamed channel, `PROCESS_NAME.out` (without specifying `[0]`) works
well with various nextflow operators, but, surprisingly, this way does not work well the `dump` operator. 
Quick workarounds could be i) using `[0]` to specify the channel explicitly, e.g. `PROCESS_NAME.out[0]`,
ii) using named output, or iii) use a `map` operator before the `dump` operator. Examples can be 
found in issue [#3](https://github.com/Midnighter/nextflow-gotchas/issues/3)
