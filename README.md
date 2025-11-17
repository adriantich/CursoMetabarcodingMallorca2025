# Curso de Metabarcoding - Mallorca 2025

## Course Description

Welcome to the Metabarcoding Course repository! This course provides hands-on training in metabarcoding bioinformatics, focusing on the analysis of 16S rRNA gene amplicon sequencing data for microbial community characterization.

Metabarcoding is a powerful molecular technique that combines DNA barcoding with high-throughput sequencing to identify and quantify organisms in complex environmental samples. This course covers the complete bioinformatics workflow from raw sequencing reads to taxonomic identification and diversity analysis.

### Learning Objectives

By the end of this course, participants will be able to:

- Understand the principles and applications of metabarcoding
- Perform quality control and preprocessing of Illumina sequencing data
- Execute a complete metabarcoding analysis pipeline
- Interpret OTU clustering results and taxonomic assignments
- Troubleshoot common issues in metabarcoding workflows
- Apply best practices for reproducible bioinformatics analyses

### Target Audience

This course is designed for:
- Researchers working with microbial ecology
- Graduate students in bioinformatics or molecular biology
- Laboratory technicians processing amplicon sequencing data
- Anyone interested in learning metabarcoding analysis techniques

### Course Structure

- **Duration:** Hands-on workshop format
- **Level:** Intermediate (basic command-line knowledge required)
- **Platform:** Linux/Unix-based systems

## Repository Structure

```
CursoMetabarcodingMallorca2025/
├── data/                          # Sample datasets
│   ├── raw_sequences/            # Raw FASTQ files (paired-end)
│   └── README.md
├── scripts/                       # Analysis scripts
│   └── run_pipeline.sh           # Main pipeline execution script
├── tools/                         # Additional tools and databases
│   └── README.md
├── PIPELINE.md                    # Detailed pipeline description
├── README.md                      # This file
└── LICENSE                        # GPL-3.0 License
```

## Software Requirements

### Core Tools

The metabarcoding pipeline requires the following software:

1. **FastQC** (≥ 0.11.9) - Quality control for sequencing data
2. **Cutadapt** (≥ 3.4) - Adapter trimming and quality filtering
3. **VSEARCH** (≥ 2.18.0) - Sequence analysis and clustering

### Optional Tools (for advanced analysis)

- **BLAST+** - For taxonomic assignment
- **QIIME 2** - Comprehensive microbiome analysis platform
- **R** with phyloseq, vegan, ggplot2 - Statistical analysis and visualization
- **Python 3** with BioPython - Custom scripting

## Installation Instructions

### Option 1: Using Conda/Mamba (Recommended)

Conda provides an easy way to install all required tools in an isolated environment.

#### Step 1: Install Miniconda or Mambaforge

**Download and install Miniconda:**
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

**Or install Mambaforge (faster alternative):**
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
bash Mambaforge-Linux-x86_64.sh
```

#### Step 2: Create a Conda Environment

```bash
# Create environment with all required tools
conda create -n metabarcoding -c bioconda -c conda-forge \
    fastqc=0.11.9 \
    cutadapt=3.5 \
    vsearch=2.22.1

# Activate the environment
conda activate metabarcoding

# Verify installations
fastqc --version
cutadapt --version
vsearch --version
```

#### Step 3: (Optional) Install Additional Tools

```bash
# For taxonomic assignment and advanced analysis
conda install -c bioconda -c conda-forge \
    blast \
    qiime2 \
    r-base \
    r-phyloseq \
    r-vegan \
    r-ggplot2
```

### Option 2: Using APT (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install FastQC
sudo apt install -y fastqc

# Install Cutadapt (requires Python)
sudo apt install -y python3-pip
pip3 install cutadapt

# Install VSEARCH
sudo apt install -y vsearch
```

### Option 3: Manual Installation

#### FastQC
```bash
cd ~/software
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc_v0.11.9.zip
chmod +x FastQC/fastqc
export PATH=$PATH:~/software/FastQC
```

#### Cutadapt
```bash
pip3 install --user cutadapt
export PATH=$PATH:~/.local/bin
```

#### VSEARCH
```bash
cd ~/software
wget https://github.com/torognes/vsearch/releases/download/v2.22.1/vsearch-2.22.1-linux-x86_64.tar.gz
tar xzf vsearch-2.22.1-linux-x86_64.tar.gz
export PATH=$PATH:~/software/vsearch-2.22.1-linux-x86_64/bin
```

### Verification

Test that all tools are properly installed:

```bash
# Check FastQC
fastqc --version
# Expected output: FastQC v0.11.9 (or higher)

# Check Cutadapt
cutadapt --version
# Expected output: 3.5 (or higher)

# Check VSEARCH
vsearch --version
# Expected output: vsearch v2.22.1 (or higher)
```

## Quick Start Guide

### 1. Clone the Repository

```bash
git clone https://github.com/adriantich/CursoMetabarcodingMallorca2025.git
cd CursoMetabarcodingMallorca2025
```

### 2. Activate Your Environment (if using Conda)

```bash
conda activate metabarcoding
```

### 3. Run the Pipeline

```bash
cd scripts
./run_pipeline.sh
```

The pipeline will:
- Perform quality control on raw sequences
- Filter and trim reads based on quality
- Merge paired-end reads
- Dereplicate and cluster sequences into OTUs
- Generate results in the `results/` directory

### 4. Examine Results

```bash
# View quality control reports
firefox ../results/quality_control/*.html

# Check OTU sequences
head ../results/otu_table/otus.fasta

# Review pipeline logs
cat ../results/*.log
```

## Detailed Documentation

For comprehensive information about each step of the pipeline, including:
- Detailed methodology
- Parameter explanations
- Quality metrics
- Troubleshooting tips
- Advanced analysis options

Please refer to **[PIPELINE.md](PIPELINE.md)**.

## Dataset Information

The `data/` directory contains small demonstration datasets:
- **Sample format:** Paired-end FASTQ files (Illumina)
- **Target region:** 16S rRNA V4 hypervariable region
- **Sequencing platform:** Illumina MiSeq (2x250 bp)
- **Purpose:** Educational demonstration only

For working with your own data, replace the files in `data/raw_sequences/` with your samples following the same naming convention: `samplename_R1.fastq` and `samplename_R2.fastq`.

## Troubleshooting

### Common Issues

**Issue 1: "Command not found" errors**
- Solution: Ensure your conda environment is activated or tools are in your PATH
- Verify installation with `which toolname`

**Issue 2: Pipeline fails during quality filtering**
- Solution: Check that input files are valid FASTQ format
- Verify sufficient disk space is available
- Review cutadapt log files for specific errors

**Issue 3: Low number of merged reads**
- Solution: Check read quality at 3' ends in FastQC reports
- Adjust merging parameters in the pipeline script
- Verify correct amplicon length and sequencing strategy

**Issue 4: Memory errors during clustering**
- Solution: Reduce dataset size or increase available RAM
- Use more stringent quality filtering to reduce data volume

For additional help, please refer to PIPELINE.md or contact course instructors.

## Course Materials

- **Slides and presentations:** Available during the course
- **Hands-on exercises:** Follow along with the pipeline
- **Reference materials:** See PIPELINE.md for citations

## Support and Contact

For questions about the course:
- Open an issue in this repository
- Contact course instructors during sessions
- Email: [course contact information will be provided]

## Contributing

Contributions to improve the course materials are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear descriptions

## Citation

If you use these materials in your research or teaching, please cite:

```
Metabarcoding Course Materials - Mallorca 2025
https://github.com/adriantich/CursoMetabarcodingMallorca2025
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Course instructors and teaching assistants
- Open-source bioinformatics community
- Tool developers: FastQC, Cutadapt, VSEARCH teams
- All course participants

---

**Last updated:** January 2025  
**Course website:** [To be announced]