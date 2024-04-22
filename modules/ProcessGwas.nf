#!/bin/bash nextflow

process ProcessGwas {
    container 'quay.io/cawarmerdam/ldsc:v0.3'

    input:
        tuple val(name), path(sumstats), path(ref_ld_chr)  // Receives phenotype name and sumstats path from previous process

    output:
        path("${name.replaceAll("\\s","_")}.processed.sumstats.gz")

    script:
        """
        bin/munge_sumstats.py \
        --sumstats ${sumstats} \
        --N 211658 \  // Assuming fixed sample size; adjust if dynamic sample size needed
        --out ${name.replaceAll("\\s","_")}.processed \
        --snp variant_id \
        --merge-alleles ${ref_ld_chr} \
        --chunksize 500000
        """
}
