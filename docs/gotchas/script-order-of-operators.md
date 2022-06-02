# Ordering of operators in a script

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Midnighter/nextflow-gotchas/blob/main/docs/gotchas/script-order-of-operators.md)

## Problem

In many cases, the order in which you define steps of a Nextflow script does not influence the order of execution. This is due to the nature of the process and channel dataflow paradigm used by Nextflow.

In contrast, where a Nextflow _operator_ is placed within a script _does_ influence when it is executed.

One such example is the `mix`ing of channels together prior passing it to a process. If a `.mix()` is specified _after_ the execution of a process that uses that channel, the contents of that particular `.mix()` will NOT be included in the execution of the process.

A good example of this is [nf-core](https://nf-co.re) version reporting. In nf-core pipelines, a 'commmon' channel (`ch_versions`) is created early in the pipeline script. When each process is executed, a versions file from that process is then `mix`ed into this common channel. Finally, this common channel containing all versions files is sent to a process (`CUSTOM_DUMPSOFTWAREVERSIONS`) that aggregates all versions into a single file.

In the example below, the `mix`ing of the `BAR` process' version file into `ch_versions` is defined to happen after `CUSTOM_DUMPSOFTWAREVERSIONS`. In this case, the version of `BAR` would **not** be included in the execution/output of the `CUSTOM_DUMPSOFTWAREVERSIONS` process.

```nextflow
ch_versions = Channel.empty()
FOO( input )
BAR( input )
ch_versions = ch_versions.mix( FOO.out.versions )
CUSTOM_DUMPSOFTWAREVERSIONS ( ch_versions )
ch_versions = ch_versions.mix( BAR.out.versions )
```

The output file of `CUSTOM_DUMPSOFTWAREVERSIONS` would look like

```text
FOO:
  foo: '1.0.0'
```

whereby the `BAR` version is not included in the file.

## Solution

Ensure that all `mix`ing invocations are defined in the script prior to the process the subsequent channel will be included in.

```nexflow
ch_versions = Channel.empty()
FOO( input )
BAR( input )
ch_versions = ch_versions.mix( FOO.out.versions )
ch_versions = ch_versions.mix( BAR.out.versions )
CUSTOM_DUMPSOFTWAREVERSIONS ( ch_versions )
```

In this case the versions of both FOO and BAR will be displayed

```text
FOO:
  foo: '1.0.0'
BAR:
  bar: '2.0.0'
```
