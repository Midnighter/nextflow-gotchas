include { SUBWORKFLOW_ONE } from '../subworkflows/subworkflow_one'
include { SUBWORKFLOW_TWO } from '../subworkflows/subworkflow_two'
include { MODULE_FOO      } from '../modules/module_foo'

workflow PROCESS_SELECTOR_WARN {

    SUBWORKFLOW_ONE()
    SUBWORKFLOW_TWO()

    MODULE_FOO()

}
