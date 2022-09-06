include { HELLO } from '../modules/hello'

workflow SUBWORKFLOW_ONE {
    main:
    if ( !params.skip_hello ) {
        HELLO()
    }
}
