#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate rgi_env


mkdir -p Bioinfo_Project/03_Project_S.pne/2_results/analysis_result/rgi/

echo "Bước 1: Đang tải database CARD mới nhất..."
wget https://card.mcmaster.ca/latest/data -O card_data.tar.bz2
tar -jxvf card_data.tar.bz2

echo "Bước 2: Đang nạp database vào hệ thống RGI..."
rgi load --card_json card.json

echo "Bước 3: Đang phân tích gen kháng thuốc (RGI Main)..."
rgi main \
    -i Bioinfo_Project/03_Project_S.pne/2_results/prokka_result/DRR189357.faa \
    -o Bioinfo_Project/03_Project_S.pne/2_results/analysis_result/rgi/DRR189357_rgi \
    -t protein \
    --include_loose \
    --clean

echo "Bước 4: Đang dọn dẹp file tạm..."
rm -f card_data.tar.bz2 card.json card_variants.json protein_fasta* *.fasta *.txt *.tsv

echo "HOÀN TẤT! Kiểm tra kết quả tại thư mục rgi/"
