#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate assembly_env

quast.py Bioinfo_Project/03_Project_S.pne/2_results/assembly_result/contigs.fasta \
-o Bioinfo_Project/03_Project_S.pne/2_results/quast_result/