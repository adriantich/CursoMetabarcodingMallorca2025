# Tools Directory

This directory is designated for storing bioinformatics tools and software used in the metabarcoding pipeline.

## Purpose

Store standalone tools, scripts, or databases that are not available through standard package managers or that require specific versions for the course.

## Usage

You can place the following types of files here:

- **Standalone executables**: Pre-compiled binaries for tools like VSEARCH, BLAST, etc.
- **Custom scripts**: Additional analysis or utility scripts
- **Reference databases**: SILVA, Greengenes, or other taxonomic reference databases
- **Configuration files**: Pipeline configuration or parameter files

## Note

Most required tools for this course can be installed via conda/mamba (recommended) or other package managers. See the main README.md for installation instructions.

## Example Structure

```
tools/
├── databases/
│   ├── silva_138_99_16S.fasta
│   └── taxonomy_mapping.txt
├── scripts/
│   └── custom_analysis.py
└── README.md
```

## Adding Large Files

For large files (databases > 100MB), consider:
- Using Git LFS (Large File Storage)
- Providing download scripts instead of committing the files
- Documenting download locations in this README
