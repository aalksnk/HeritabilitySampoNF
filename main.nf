#!/usr/bin/env nextflow
/* 
 * Enables Nextflow DSL 2
 */

nextflow.enable.dsl=2

// Define parameters for input and output directories
params.pthresh = 5e-8      // Default p-value threshold
params.eqtlwindow = 5000000 

// Include module files
include { PARSE_SUMSTATS } from './modules/ParseSumstats.nf'
include { ProcessGwas } from './modules/ProcessGwas.nf'
include { EstimateHeritability } from './modules/EstimateHeritability.nf'
include { ConsolidateResults } from './modules/WriteOutRes.nf'

// Create Channel for initial input data files
Channel
    .fromPath("${params.inputDir}/*.parquet.snappy", checkIfExists: true)
    .ifEmpty { exit 1, "Sumstats directory is empty!" }
    .set { input_files_ch }
Channel
    .fromPath("${params.refLdChr}/*", checkIfExists: true)
    .ifEmpty { exit 1, "Reference LD directory is empty or files are missing!" }
    .set { ref_ld_chr_ch }

Channel
    .fromPath("${params.wLdChr}/*", checkIfExists: true)
    .ifEmpty { exit 1, "Weighted LD directory is empty or files are missing!" }
    .set { w_ld_chr_ch }
/*Channel
    .fromPath(params.dataDir)
    .map { file -> tuple(file.baseName.replace(".parquet.snappy", ""), file) }
    .set { data_ch }
*/

// Define the workflow
workflow {
    // Run the parsing of sumstats
    PARSE_SUMSTATS(input_files_ch)
    
    // Combine parsed sumstats with reference LD files before passing to GWAS processing
    parsed_files_ch = PARSE_SUMSTATS.out
        .combine(ref_ld_chr_ch.collect())  // Collects all ref LD files into a list and combines each with parsed files
        .combine(w_ld_chr_ch.collect())    // Collects all weighted LD files into a list and combines each with the previous combination

    // Process GWAS data with both ref and weighted LD files available
    process_gwas_out = ProcessGwas(parsed_files_ch)

    // Estimate Heritability using combined LD references
    heritability_logs_ch = EstimateHeritability(process_gwas_out, ref_ld_chr_ch, w_ld_chr_ch)

    // Consolidate Results into a final table
    ConsolidateResults(heritability_logs_ch.collect())
}

