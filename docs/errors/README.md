# Introduction

Error messages and stack traces are probably the most intimidating whenever you start a new programming language. However, with nextflow there is an extra level of grief associated with coding errors. Nextflow is a domain specific language (DSL) for defining workflows built in Groovy/Java. That means that all the files actually are parsed and executed as Java code under the hood.

In my experience, error messages and stack traces only vaguely point you in the direction of your mistakes and just as often confuse you more than they help you. As an example, I was working on a pipeline and forgot a comma in a configuration file.

```sh
pipeline
├── conf
│   └── modules.config  # (1)
└── nextflow.config  # (2)
```

1. Here, I had forgotten a comma when configuring a process.

    ```groovy
    process {
        withName: PROCESS {
            publishDir = [
                mode: 'copy'
                pattern: '*.txt'
            ]
        }
    }
    ```

2. The `nextflow.config` includes the `conf/modules.config`:

    ```groovy
    includeConfig 'conf/modules.config'
    ```

The error message that I got looked something like:

```output
Unable to parse config file: 'pipeline/nextflow.config'

  Compile failed for sources FixedSetSources[name='/groovy/script/Script804F3A5DC10BC08232AE23542F1477EC']. Cause: org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
  /groovy/script/Script804F3A5DC10BC08232AE23542F1477EC: 1: Unexpected input: '{' @ line 1, column 9.
     process {
             ^

  1 error
```

So I knew it had to be a mistake inside of the [`process` scope](https://www.nextflow.io/docs/latest/config.html#scope-process) somewhere but that's not very helpful when I have several nested configuration files that each modify the `process` scope and I don't know what kind of error.

Hopefully, the examples provided in the errors section can help you make sense of your own cryptic messages. :pray: Most of them are contributions from [nf-core hackathon documentation](https://hackmd.io/vWjpftScRju7IJXXlW57Xw).
