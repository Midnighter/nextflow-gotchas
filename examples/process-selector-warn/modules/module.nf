process MODULE {


    script:
    def args = task.ext.args ?: ''
    """
    echo "hello ${args}"
    """

}
