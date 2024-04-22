#!/usr/bin/env nextflow

process ParseSumstats {
    // conda 'environment.yml'
    container 'quay.io/urmovosa/ld_overlap_image:v0.2'
    tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    input:
        path(file)

    output:
        tuple env(phenoname), path("processed_files/*_processed.txt")

    script:
    """
    mkdir -p processed_files
    Rscript --vanilla ${baseDir}/bin/parse.R ${file} > processed_files/\$(basename ${file} .parquet.snappy)_processed.txt

    # Parse phenotype name
    phenoname=\$(ls processed_files/*_processed* | cut -d '_' -f 1)
    """
}


workflow PARSE_SUMSTATS {
    take:
        data_ch  // Channel of .parquet.snappy files

    main:
        ParseSumstats(data_ch)

    emit:
        processed_files_ch = ParseSumstats.out
}
