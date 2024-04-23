#!/usr/bin/env nextflow
/* 
 * Enables Nextflow DSL 2
 */

nextflow.enable.dsl=2

def helpMessage() {
    log.info"""
    =======================================================
     HeritabilitySampoNF v${workflow.manifest.version}
    =======================================================
    Usage:
    The typical command for running the pipeline is as follows:
        nextflow run main.nf \
        --InputDir \
        --wLdChr \
        -profile singularity,slurm\
        -resume

    Mandatory arguments:
    --InputDir              Directory with parquet files.
    --SnpRefFile            SNP reference file with alleles information.
    --wLdChr                LDSC LD-score folder.
    --CaseControlFile       File with case and control counts per phenotype.
    --LdscDir               Folder with LDSC software.

    Optional arguments:
    --OutputDir             Output directory.
    """.stripIndent()
}

// Define parameters for input and output directories

=======
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
    .fromPath("${params.SnpRefFile}/*", checkIfExists: true)
    .ifEmpty { exit 1, "SNP reference file is missing!" }
    .set { snp_ref_ch }
Channel
    .fromPath("${params.wLdChr}/*", checkIfExists: true)
    .ifEmpty { exit 1, "Weighted LD directory is empty or files are missing!" }
    .set { w_ld_chr_ch }
Channel
    .fromPath(params.LdscDir, checkIfExists: true))
    .ifEmpty { exit 1, "LDSC directory is empty or files are missing!" }
    .set { ldsc_ch }
Channel
    .fromPath(params.dataDir)
    .map { file -> tuple(file.baseName.replace(".parquet.snappy", ""), file) }
    .set { case_control_ch }


log.info """=======================================================
HeritabilitySampoNF v${workflow.manifest.version}"
======================================================="""
def summary = [:]
summary['Pipeline Name']            = 'HeritabilitySampoNF'
summary['Pipeline Version']         = workflow.manifest.version
summary['Working dir']              = workflow.workDir
summary['Container Engine']         = workflow.containerEngine
if(workflow.containerEngine) summary['Container'] = workflow.container
summary['Current home']             = "$HOME"
summary['Current user']             = "$USER"
summary['Current path']             = "$PWD"
summary['Working dir']              = workflow.workDir
summary['Script dir']               = workflow.projectDir
summary['Config Profile']           = workflow.profile
summary['Sumstats folder']          = params.inputDir
summary['Output folder']            = params.outputDir
summary['LD folder']                = params.refLdChr
summary['Weighted LD folder']       = params.wLdChr
log.info summary.collect { k,v -> "${k.padRight(21)}: $v" }.join("\n")
log.info "========================================="


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

