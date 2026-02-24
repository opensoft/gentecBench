# gentecBench - Genetics & Genomics
# Built on biobench-base (Layer 1) which provides:
#   - Everything from Layer 0 (Ubuntu 24.04, git, gh CLI, zsh, etc.)
#   - Miniconda with bioconda + conda-forge channels
#   - User setup matching host user

ARG USERNAME=brett

FROM biobench-base:${USERNAME}

LABEL layer.name="gentec-bench"
LABEL layer.version="0.6.0"
LABEL layer.description="Genetics and genomics workbench"

# Install Illumina BaseSpace CLI
USER root
RUN wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O /usr/local/bin/bs \
    && chmod +x /usr/local/bin/bs

# ========================================
# CONDA ENVIRONMENTS
# ========================================

# Create bfx environment - bioinformatics tools
RUN conda create -n bfx -y \
    -c conda-forge -c bioconda \
    art bcftools bedtools bwa fastqc minimap2 \
    mosdepth multiqc picard samtools seqtk snpeff \
    && conda clean -afy

# Create nf environment - Nextflow pipeline engine
RUN conda create -n nf -y \
    -c conda-forge -c bioconda \
    nextflow nf-core \
    && conda clean -afy

# Ensure conda dirs are owned by the user
RUN chown -R ${USERNAME}:${USERNAME} ${CONDA_DIR}

USER ${USERNAME}

CMD ["sleep", "infinity"]
