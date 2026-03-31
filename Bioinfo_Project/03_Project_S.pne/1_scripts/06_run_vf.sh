#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate vf_env

mkdir -p Bioinfo_Project/03_Project_S.pne/2_results/analysis_result/vf/

echo "Đang quét yếu tố độc lực bằng Abricate (Database: VFDB)..."

abricate --db vfdb Bioinfo_Project/03_Project_S.pne/2_results/assembly_result/contigs.fasta > Bioinfo_Project/03_Project_S.pne/2_results/analysis_result/vf/DRR189357_vf.txt

echo "HOÀN TẤT! Kết quả tại: 2_results/analysis_result/vf/DRR189357_vf.txt"