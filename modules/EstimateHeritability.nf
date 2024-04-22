#!/usr/bin/env nextflow

process EstimateHeritability {
    container 'quay.io/cawarmerdam/ldsc:v0.3'
    tag "${name}"
    
    // Define inputs
    input:
        tuple val(name), path(sumstats) 
        path ref_ld_chr 
        path w_ld_chr 

    // Define outputs
    output:
        path("${name}_heritability.log")

    // Script to execute
    script:
    """
    /ldsc/ldsc.py \
    --h2 ${sumstats} \
    --ref-ld-chr ${ref_ld_chr}/ \
    --w-ld-chr ${w_ld_chr}/ \
    --chisq-max 10000 \
    --out ${name}_heritability
    """
}
