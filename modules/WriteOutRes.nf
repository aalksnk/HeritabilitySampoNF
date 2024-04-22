#!/bin/bash nextflow 

process ConsolidateResults {
    container 'quay.io/cawarmerdam/ldsc:v0.3'
    errorStrategy = 'ignore'
    executor = 'local'

    input:
        path log_files 

    output:
        path "results/final_results_table.csv"

    script:
    """
    #!/bin/bash
    echo 'Phenotype,Heritability,OtherStats' > results/final_results_table.csv
    for log in \$(ls \${log_files})
    do
        # Assuming 'Heritability' and other stats are parseable in a specific line or format
        phenotype=\$(basename \${log} '_heritability.log')
        heritability=\$(grep 'Heritability estimate:' \${log} | cut -d ' ' -f3)
        other_stats=\$(grep 'Other stats:' \${log} | cut -d ' ' -f3)
        echo "\${phenotype},\${heritability},\${other_stats}" >> results/final_results_table.csv
    done
    """
}
