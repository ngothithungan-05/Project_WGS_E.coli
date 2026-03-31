#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate assembly_env

spades.py --12 Bioinfo_Project/03_Project_S.pne/3_data/DRR189357.fastq.gz -o Bioinfo_Project/03_Project_S.pne/2_results/assembly_result/