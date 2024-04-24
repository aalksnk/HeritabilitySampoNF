#!/bin/bash nextflow 

process ConsolidateResults {
    container 'quay.io/cawarmerdam/ldsc:v0.3'

    input:
        path(log_files) 

    output:
        path("final_results_table.csv")

    script:
    """
    #!/bin/bash
    echo 'Phenotype,h2,se_h2,intercept,se_intercept,ratio,mean_chi2,lambda_gc,nr_snps,nr_snps_removed_chi2_filter' > final_results_table.csv
    
    for log in \$(ls \${log_files} | grep "log")
    do
        # Assuming 'Heritability' and other stats are parseable in a specific line or format
        phenotype=\$(basename \${log} '_heritability.log')
        h2=\$(grep 'Total Liability scale h2:' \${log} | cut -d ' ' -f5)
        se_h2=\$(grep 'Total Liability scale h2:' \${log} | cut -d ' ' -f6 | sed 's/[()]//g')
        intercept=\$(grep 'Intercept:' \${log} | cut -d ' ' -f2)
        se_intercept=\$(grep 'Intercept:' \${log} | cut -d ' ' -f3 | sed 's/[()]//g')
        ratio=\$(grep 'Ratio:' \${log} | cut -d ' ' -f2)
        mean_chi2=\$(grep 'Mean Chi' \${log} | cut -d ' ' -f3)
        lambda_gc=\$(grep 'Lambda GC:' \${log} | cut -d ' ' -f3)
        nr_snps=\$(grep 'After merging with regression SNP LD' \${log} | cut -d ' ' -f7)
        nr_snps_removed_chi2_filter=\$(grep ' SNPs with chi' \${log} | cut -d ' ' -f2)
        echo "\${phenotype},\${h2},\${se_h2},\${intercept},\${se_intercept},\${ratio},\${mean_chi2},\${lambda_gc},\${nr_snps},\${nr_snps_removed_chi2_filter}" >> final_results_table.csv
    done
    """
}
