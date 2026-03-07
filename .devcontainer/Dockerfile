# Layer 2: gentecBench - Genetics & Genomics
# USER-AGNOSTIC: No user creation — Layer 3 handles user setup
#
# Built on biobench-base:latest (Layer 1c) which provides:
#   - Everything from Layer 0 (Ubuntu 24.04, git, gh CLI, zsh, etc.)
#   - Miniconda with bioconda + conda-forge channels
#
# Usage:
#   docker build -t gentec-bench:latest .

FROM biobench-base:latest

# Container version labels
LABEL layer="2"
LABEL layer.name="gentec-bench"
LABEL layer.version="0.7.0"
LABEL layer.description="Genetics and genomics workbench (user-agnostic)"

USER root

# ========================================
# TOOLS
# ========================================

# Install Illumina BaseSpace CLI
RUN wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O /usr/local/bin/bs \
    && chmod +x /usr/local/bin/bs

# ========================================
# CONDA ENVIRONMENTS
# ========================================

# Create bfx environment - bioinformatics tools
# Split into smaller groups to avoid solver issues
# Note: art, picard, snpeff removed due to dependency conflicts - install separately if needed
RUN conda create -n bfx -y python=3.11 \
    && conda install -n bfx -y -c conda-forge -c bioconda \
    bcftools bedtools bwa fastqc samtools \
    && conda install -n bfx -y -c conda-forge -c bioconda \
    minimap2 mosdepth multiqc seqtk \
    && conda clean -afy

# Create nf environment - Nextflow pipeline engine
RUN conda create -n nf -y \
    -c conda-forge -c bioconda \
    nextflow nf-core \
    && conda clean -afy

# Default command
CMD ["sleep", "infinity"]
