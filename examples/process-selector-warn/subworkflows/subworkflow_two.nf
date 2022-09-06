include { HELLO } from '../modules/hello'

workflow SUBWORKFLOW_TWO {
    main:
    if ( !params.skip_hello ) {
        HELLO()
    }
}
