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
