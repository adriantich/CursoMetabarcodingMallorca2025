# Metabarcoding Pipeline Description

## Overview

This document describes the metabarcoding bioinformatics pipeline used in the Mallorca 2025 course. The pipeline processes raw paired-end Illumina sequencing data from 16S rRNA amplicon sequencing to generate Operational Taxonomic Units (OTUs) and their taxonomic assignments.

## Pipeline Workflow

### 1. Quality Control (QC)

**Tool:** FastQC

**Purpose:** Assess the quality of raw sequencing reads before processing.

**Process:**
- Analyzes base quality scores across all sequences
- Identifies adapter contamination
- Checks for sequence duplication levels
- Evaluates GC content distribution

**Output:**
- HTML reports for each FASTQ file
- Quality metrics for decision-making on filtering parameters

### 2. Quality Filtering and Adapter Trimming

**Tool:** Cutadapt

**Purpose:** Remove low-quality bases and adapter sequences.

**Parameters:**
- Quality threshold: Q20 (99% base call accuracy)
- Minimum length: 100 bp
- Trim both 5' and 3' ends based on quality

**Process:**
- Removes adapter sequences if present
- Trims low-quality bases from read ends
- Discards reads shorter than the minimum length threshold
- Maintains pairing between R1 and R2 reads

**Output:**
- Filtered FASTQ files for forward (R1) and reverse (R2) reads
- Log files with filtering statistics

### 3. Paired-End Read Merging

**Tool:** VSEARCH

**Purpose:** Combine forward and reverse reads into full-length amplicon sequences.

**Parameters:**
- Minimum overlap length: 20 bp
- Maximum number of mismatches: 10
- Quality-aware merging algorithm

**Process:**
- Aligns overlapping regions of paired reads
- Merges reads where overlap meets quality criteria
- Uses quality scores to resolve disagreements
- Discards pairs that cannot be reliably merged

**Output:**
- Merged FASTQ files containing full amplicon sequences
- Merge statistics and logs

### 4. Dereplication

**Tool:** VSEARCH

**Purpose:** Collapse identical sequences and track their abundance.

**Process:**
- Identifies unique sequences across all samples
- Counts occurrence of each unique sequence
- Adds abundance information to sequence headers
- Reduces computational requirements for downstream steps

**Output:**
- FASTA file with dereplicated sequences
- Size annotations indicating sequence abundance

### 5. OTU Clustering

**Tool:** VSEARCH

**Purpose:** Group similar sequences into Operational Taxonomic Units (OTUs).

**Parameters:**
- Similarity threshold: 97% (species-level approximation)
- Clustering algorithm: size-based (most abundant sequences first)

**Process:**
- Sorts sequences by abundance
- Clusters sequences at 97% similarity
- Selects centroid sequence for each cluster
- Assigns remaining sequences to nearest cluster

**Output:**
- `otus.fasta`: Representative sequences for each OTU
- `clusters.uc`: Cluster membership information

### 6. Taxonomic Assignment (Manual Step)

**Recommended Tools:** 
- BLAST against NCBI 16S database
- RDP Classifier
- QIIME 2 with silva/greengenes database
- DADA2 assignTaxonomy function

**Purpose:** Assign taxonomic labels to OTU representative sequences.

**Process:**
- Compare OTU sequences against reference database
- Assign taxonomy based on best matches
- Generate confidence scores for assignments
- Create OTU table with taxonomic annotations

**Databases:**
- SILVA (comprehensive, curated)
- Greengenes (widely used, standardized)
- RDP (Ribosomal Database Project)
- NCBI 16S RefSeq

## Pipeline Execution

### Running the Complete Pipeline

```bash
cd scripts
./run_pipeline.sh
```

The script will:
1. Check for required software dependencies
2. Create necessary output directories
3. Run each analysis step sequentially
4. Generate comprehensive log files
5. Provide progress updates and completion status

### Output Directory Structure

```
results/
├── quality_control/        # FastQC reports
├── filtered/              # Quality-filtered reads
├── merged/                # Merged paired-end reads
├── otu_table/            # OTU sequences and clustering results
│   ├── otus.fasta
│   └── clusters.uc
└── taxonomy/             # Taxonomic assignments (manual step)
```

## Quality Metrics and Checkpoints

### Expected Read Retention Rates

- **After quality filtering:** 80-95% of reads
- **After merging:** 60-90% of filtered reads
- **After clustering:** Variable, depends on diversity

### Quality Indicators

**Good Quality Run:**
- Phred scores > 30 for majority of read length
- Low adapter content (< 5%)
- Even GC distribution
- High percentage of successfully merged reads

**Warning Signs:**
- Mean quality scores dropping below Q20
- High adapter content (> 10%)
- Very low merge rate (< 50%)
- Unusually high or low sequence diversity

## Troubleshooting

### Common Issues

1. **Low merge rates:**
   - Check read quality at 3' ends
   - Verify amplicon length matches expected overlap
   - Adjust merging parameters (minimum overlap, max differences)

2. **Excessive sequence loss:**
   - Review quality filtering parameters
   - Check for adapter contamination
   - Verify correct sequencing primers were used

3. **Biased taxonomic composition:**
   - Ensure appropriate reference database
   - Check for PCR bias or contamination
   - Verify extraction and library prep controls

## Advanced Options

### Chimera Detection

Chimeric sequences can be detected and removed using:

```bash
vsearch --uchime_denovo otus.fasta \
    --nonchimeras otus_nonchimeras.fasta
```

### Alpha and Beta Diversity Analysis

After taxonomic assignment, perform diversity analyses:
- Alpha diversity: richness and evenness within samples
- Beta diversity: compositional differences between samples
- Statistical testing: PERMANOVA, ANOSIM

**Recommended tools:**
- QIIME 2
- phyloseq (R package)
- vegan (R package)

## References and Further Reading

1. **Callahan, B. J., et al.** (2016). DADA2: High-resolution sample inference from Illumina amplicon data. *Nature Methods*, 13(7), 581-583.

2. **Rognes, T., et al.** (2016). VSEARCH: a versatile open source tool for metagenomics. *PeerJ*, 4, e2584.

3. **Schloss, P. D., et al.** (2009). Introducing mothur: open-source, platform-independent software for microbial ecology. *Applied and Environmental Microbiology*, 75(23), 7537-7541.

4. **Quast, C., et al.** (2013). The SILVA ribosomal RNA gene database project. *Nucleic Acids Research*, 41(D1), D590-D596.

## Course Information

For questions, additional resources, and course updates, please refer to the main README.md file or contact the course instructors.
