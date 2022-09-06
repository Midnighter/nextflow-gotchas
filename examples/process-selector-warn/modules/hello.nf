process HELLO {
    script:
    def args = task.ext.args ?: ''
    """
    echo "hello ${args}"
    """
}
