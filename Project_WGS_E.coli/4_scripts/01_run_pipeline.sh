#!/bin/bash
# ==============================================================================
# MASTER SCRIPT: FROM ENVIRONMENT SETUP TO PIPELINE EXECUTION
# Usage: bash 4_scripts/00_master_pipeline.sh
# ==============================================================================

echo "================================================================="
echo " PART 1: INSTALL CONDA AND REQUIRED BIOINFORMATICS ENVIRONMENTS  "
echo "================================================================="

# 1. Install Miniconda (if not already installed)
if ! command -v conda &> /dev/null; then
    echo "Conda not found. Installing Miniconda3..."
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh
    ~/miniconda3/bin/conda init bash
    source ~/.bashrc
else
    echo "Conda is already installed. Skipping this step."
fi

# Set path so the script recognizes conda commands
source $(conda info --base)/etc/profile.d/conda.sh

# 2. Create environments (Use -y to automatically accept installation)
echo "Checking and installing qc_env environment (fastqc, fastp)..."
conda create -n qc_env -c bioconda -c conda-forge fastqc fastp -y

echo "Checking and installing assembly_env environment (spades, quast, busco)..."
conda create -n assembly_env -c bioconda -c conda-forge spades quast busco -y

echo "Checking and installing annotation_env environment (prokka, abricate)..."
conda create -n annotation_env -c bioconda -c conda-forge prokka abricate -y

# Note: rgi_env might require a more complex setup, but this is the basic command to create it
echo "Checking and installing rgi_env environment (rgi)..."
conda create -n rgi_env -c bioconda -c conda-forge rgi -y


echo "================================================================="
echo " PART 2: RUN DATA ANALYSIS PIPELINE                              "
echo "================================================================="

echo "=== STEP 1: ACTIVATE qc_env & DOWNLOAD DATA ==="
conda activate qc_env

cd ./1_raw_data
wget -nc https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR258/003/SRR2584863/SRR2584863_1.fastq.gz
wget -nc https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR258/003/SRR2584863/SRR2584863_2.fastq.gz
cd .. 

echo "=== STEP 2: RAW DATA QUALITY CONTROL ==="
fastqc ./1_raw_data/SRR2584863_1.fastq.gz ./1_raw_data/SRR2584863_2.fastq.gz -o ./3_results/01_QC/

echo "=== STEP 3: TRIM AND FILTER DATA WITH FASTP ==="
fastp -i ./1_raw_data/SRR2584863_1.fastq.gz \
      -I ./1_raw_data/SRR2584863_2.fastq.gz \
      -o ./2_clean_data/clean_R1.fastq.gz \
      -O ./2_clean_data/clean_R2.fastq.gz \
      -h ./3_results/01_QC/fastp_report.html \
      -j ./3_results/01_QC/fastp.json

echo "=== STEP 4: CLEAN DATA QUALITY CONTROL ==="
fastqc ./2_clean_data/clean_R1.fastq.gz ./2_clean_data/clean_R2.fastq.gz -o ./3_results/01_QC/


echo "=== STEP 5: SWITCH TO ASSEMBLY ENVIRONMENT (assembly_env) ==="
conda deactivate
conda activate assembly_env

echo "=== STEP 6: RUN SPADES (Genome Assembly) ==="
spades.py -1 ./2_clean_data/clean_R1.fastq.gz \
          -2 ./2_clean_data/clean_R2.fastq.gz \
          -o ./3_results/02_Assembly/SPAdes_Final \
          -t 2 -m 2

echo "=== STEP 7: RUN QUAST (Evaluate contigs) ==="
quast ./3_results/02_Assembly/SPAdes_Final/contigs.fasta \
      -o ./3_results/02_Assembly/quast_out

echo "=== STEP 8: RUN BUSCO (Evaluate completeness) ==="
busco -i ./3_results/02_Assembly/SPAdes_Final/contigs.fasta \
      -o busco_out \
      --out_path ./3_results/02_Assembly/ \
      -m genome \
      --auto-lineage-prok


echo "=== STEP 9: SWITCH TO ANNOTATION ENVIRONMENT (annotation_env) ==="
conda deactivate
conda activate annotation_env 

echo "=== STEP 10: RUN PROKKA (Genome Annotation) ==="
prokka ./3_results/02_Assembly/SPAdes_Final/contigs.fasta \
       --outdir ./3_results/03_Annotation/prokka_out \
       --prefix sample_1 \
       --force

echo "=== STEP 11: RUN ABRICATE (Find virulence genes via VFDB) ==="
abricate --db vfdb ./3_results/02_Assembly/SPAdes_Final