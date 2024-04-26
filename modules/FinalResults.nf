#!/bin/bash nextflow 

process FinaliseResults {
    container 'quay.io/urmovosa/ld_overlap_image:v0.2'
    publishDir "${params.outputDir}", mode: 'copy', overwrite: true

    input:
        tuple path(final_results_table), path(case_control_ch)

    output:
        path ("final_results.tsv")

    script:
    """
    Rscript --vanilla ${baseDir}/bin/process_results.R ${final_results_table} ${case_control_ch}
    """
}
