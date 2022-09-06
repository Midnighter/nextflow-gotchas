include { SUBWORKFLOW_ONE } from '../subworkflows/subworkflow_one'
include { SUBWORKFLOW_TWO } from '../subworkflows/subworkflow_two'
include { BYE             } from '../modules/bye'

workflow PROCESS_SELECTOR_WARN {

    SUBWORKFLOW_ONE()
    SUBWORKFLOW_TWO()

    BYE()

}
