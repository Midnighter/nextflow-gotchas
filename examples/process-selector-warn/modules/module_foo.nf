process MODULE_FOO {


    script:
    def args = task.ext.args ?: ''
    """
    echo "bye!"
    """

}
