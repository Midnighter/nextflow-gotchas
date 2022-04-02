process ECHO {
    input:
    val meta

    output:
    val meta

    """
    echo '${meta.id}'
    """
}