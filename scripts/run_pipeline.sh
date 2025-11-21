#!/bin/bash

################################################################################
# Metabarcoding Pipeline - Mallorca 2025 Course
# This script runs the complete metabarcoding analysis pipeline
################################################################################

# Set strict error handling
set -euo pipefail

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_message "============================================" "$BLUE"
print_message "  Metabarcoding Pipeline - Starting" "$BLUE"
print_message "============================================" "$BLUE"
echo ""

# Define directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="${BASE_DIR}/data/raw_sequences"
OUTPUT_DIR="${BASE_DIR}/results"
TOOLS_DIR="${BASE_DIR}/tools"

# Create output directories
mkdir -p "${OUTPUT_DIR}"/{quality_control,filtered,merged,otu_table,taxonomy}

print_message "Configuration:" "$YELLOW"
echo "  Base directory: ${BASE_DIR}"
echo "  Data directory: ${DATA_DIR}"
echo "  Output directory: ${OUTPUT_DIR}"
echo "  Tools directory: ${TOOLS_DIR}"
echo ""

# Check if required tools are available
print_message "Checking required software..." "$YELLOW"
REQUIRED_TOOLS=("fastqc" "cutadapt" "vsearch")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command_exists "$tool"; then
        print_message "  ✓ $tool found" "$GREEN"
    else
        print_message "  ✗ $tool not found" "$RED"
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    print_message "Warning: Some tools are missing. The pipeline may not complete successfully." "$YELLOW"
    print_message "Please refer to README.md for installation instructions." "$YELLOW"
    echo ""
fi

# Step 1: Quality Control
print_message "Step 1: Quality Control Analysis" "$BLUE"
print_message "Running FastQC on raw sequences..." "$YELLOW"

if command_exists fastqc; then
    fastqc "${DATA_DIR}"/*.fastq -o "${OUTPUT_DIR}/quality_control" --quiet 2>/dev/null || true
    print_message "  ✓ Quality control completed" "$GREEN"
else
    print_message "  ⊘ Skipping - FastQC not installed" "$YELLOW"
fi
echo ""

# Step 2: Quality Filtering and Trimming
print_message "Step 2: Quality Filtering and Adapter Trimming" "$BLUE"
print_message "Filtering sequences with quality threshold..." "$YELLOW"

if command_exists cutadapt; then
    for R1_FILE in "${DATA_DIR}"/*_R1.fastq; do
        SAMPLE_NAME=$(basename "$R1_FILE" _R1.fastq)
        R2_FILE="${DATA_DIR}/${SAMPLE_NAME}_R2.fastq"
        
        if [ -f "$R2_FILE" ]; then
            print_message "  Processing ${SAMPLE_NAME}..." "$YELLOW"
            cutadapt \
                -q 20,20 \
                -m 100 \
                -o "${OUTPUT_DIR}/filtered/${SAMPLE_NAME}_R1_filtered.fastq" \
                -p "${OUTPUT_DIR}/filtered/${SAMPLE_NAME}_R2_filtered.fastq" \
                "$R1_FILE" "$R2_FILE" \
                > "${OUTPUT_DIR}/filtered/${SAMPLE_NAME}_cutadapt.log" 2>&1 || true
        fi
    done
    print_message "  ✓ Quality filtering completed" "$GREEN"
else
    print_message "  ⊘ Skipping - Cutadapt not installed" "$YELLOW"
fi
echo ""

# Step 3: Merging Paired-End Reads
print_message "Step 3: Merging Paired-End Reads" "$BLUE"
print_message "Merging forward and reverse reads..." "$YELLOW"

if command_exists vsearch; then
    for R1_FILE in "${OUTPUT_DIR}/filtered"/*_R1_filtered.fastq; do
        if [ -f "$R1_FILE" ]; then
            SAMPLE_NAME=$(basename "$R1_FILE" _R1_filtered.fastq)
            R2_FILE="${OUTPUT_DIR}/filtered/${SAMPLE_NAME}_R2_filtered.fastq"
            
            if [ -f "$R2_FILE" ]; then
                print_message "  Merging ${SAMPLE_NAME}..." "$YELLOW"
                vsearch --fastq_mergepairs "$R1_FILE" \
                    --reverse "$R2_FILE" \
                    --fastqout "${OUTPUT_DIR}/merged/${SAMPLE_NAME}_merged.fastq" \
                    --fastq_minovlen 20 \
                    --fastq_maxdiffs 10 \
                    > "${OUTPUT_DIR}/merged/${SAMPLE_NAME}_merge.log" 2>&1 || true
            fi
        fi
    done
    print_message "  ✓ Read merging completed" "$GREEN"
else
    print_message "  ⊘ Skipping - VSEARCH not installed" "$YELLOW"
fi
echo ""

# Step 4: Dereplication and Clustering
print_message "Step 4: Dereplication and OTU Clustering" "$BLUE"
print_message "Combining all samples and clustering into OTUs..." "$YELLOW"

if command_exists vsearch && [ -n "$(ls -A "${OUTPUT_DIR}/merged" 2>/dev/null)" ]; then
    # Combine all merged reads
    cat "${OUTPUT_DIR}/merged"/*_merged.fastq > "${OUTPUT_DIR}/all_merged.fastq" 2>/dev/null || true
    
    if [ -f "${OUTPUT_DIR}/all_merged.fastq" ] && [ -s "${OUTPUT_DIR}/all_merged.fastq" ]; then
        # Dereplicate
        print_message "  Dereplicating sequences..." "$YELLOW"
        vsearch --derep_fulllength "${OUTPUT_DIR}/all_merged.fastq" \
            --output "${OUTPUT_DIR}/dereplicated.fasta" \
            --sizeout \
            > "${OUTPUT_DIR}/dereplication.log" 2>&1 || true
        
        # Cluster at 97% identity
        print_message "  Clustering at 97% identity..." "$YELLOW"
        vsearch --cluster_size "${OUTPUT_DIR}/dereplicated.fasta" \
            --id 0.97 \
            --centroids "${OUTPUT_DIR}/otu_table/otus.fasta" \
            --uc "${OUTPUT_DIR}/otu_table/clusters.uc" \
            > "${OUTPUT_DIR}/clustering.log" 2>&1 || true
        
        print_message "  ✓ OTU clustering completed" "$GREEN"
    else
        print_message "  ⊘ No merged sequences found to process" "$YELLOW"
    fi
else
    print_message "  ⊘ Skipping - VSEARCH not installed or no data" "$YELLOW"
fi
echo ""

# Step 5: Summary
print_message "============================================" "$BLUE"
print_message "  Pipeline Execution Completed!" "$BLUE"
print_message "============================================" "$BLUE"
echo ""
print_message "Results are saved in: ${OUTPUT_DIR}" "$GREEN"
echo ""
print_message "Next steps:" "$YELLOW"
echo "  1. Review quality control reports in ${OUTPUT_DIR}/quality_control"
echo "  2. Check OTU sequences in ${OUTPUT_DIR}/otu_table/otus.fasta"
echo "  3. Perform taxonomic assignment (see PIPELINE.md for details)"
echo ""
print_message "For more information, see PIPELINE.md" "$BLUE"
