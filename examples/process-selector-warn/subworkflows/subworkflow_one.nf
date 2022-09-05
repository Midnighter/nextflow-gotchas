include { MODULE } from '../modules/module'

workflow SUBWORKFLOW_ONE {

    main:

    if ( params.skip_module ){
        MODULE ()
    }

}
