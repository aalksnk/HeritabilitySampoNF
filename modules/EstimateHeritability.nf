#!/usr/bin/env nextflow

process EstimateHeritability {
    container 'quay.io/cawarmerdam/ldsc:v0.3'
    tag "${name}"
    
    // Define inputs
    input:
        tuple val(name), val(prevalence), path(sumstats), path(w_ld_chr) 

    // Define outputs
    output:

    // Script to execute
    script:
    """
    /ldsc/ldsc.py \
    --h2 ${sumstats} \
    --ref-ld-chr ${w_ld_chr}/ \
    --w-ld-chr ${w_ld_chr}/ \
    --chisq-max 10000 \
    --samp-prev ${prevalence} \
    --pop-prev ${prevalence} \
    --out ${name}_heritability
    """
}
