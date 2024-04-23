

set -f

nextflow_path=/Users/urmovosa/Documents/temp_tools/

inputDir=/Users/urmovosa/Documents/projects/2023/sampo_pipelines/ldoverlapnf/tests/data/sumstats/
outputDir=/Users/urmovosa/Documents/projects/2023/sampo_pipelines/HeritabilitySampoNF/tests/output/

#module load nextflow/23.09.3-edge
#module load singularity/3.8.5
echo "Input Directory: ${inputDir}"
#echo "Output Folder: ${outp_folder}"
#cho "Reference: ${ref}"
#echo "Extract: ${extract}"

NXF_VER=21.10.6 ${nextflow_path}/nextflow run main.nf  \
--inputDir ${inputDir} \
-- \
-profile docker \
-resume 