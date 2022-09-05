include { MODULE } from '../modules/module'

workflow SUBWORKFLOW_TWO {

    main:

    if ( !params.skip_module ){
        MODULE ()
    }


}
