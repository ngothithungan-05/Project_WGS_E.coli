#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate prokka_new

prokka --outdir Bioinfo_Project/03_Project_S.pne/2_results/prokka_result/ \
--prefix DRR189357 \
Bioinfo_Project/03_Project_S.pne/2_results/assembly_result/contigs.fasta