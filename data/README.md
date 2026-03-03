# Data description

This project uses a subset of the 1000 Genomes Project Phase 3 data:

- Reference: GRCh37 (hg19)
- Release: 20130502 integrated variant call set
- Chromosome: 22
- Population: CHB (Han Chinese in Beijing)

We do not commit any large 1000G files to this repository. Instead, all
data needed for the analyses can be reproduced locally by running:

bash scripts/01_prepare_data.sh

1. Raw data source
------------------

We use the official 1000 Genomes Phase 3 integrated call set, release 20130502.

- URL (chr22 VCF, all samples):

  https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz

- URL (sample panel with population labels):

  https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel

The preparation script will:

1. Download the chr22 VCF into data/raw/
2. Download the sample panel into data/raw/
3. Extract CHB samples based on the panel file
4. Convert the CHB subset to PLINK binary format (.bed/.bim/.fam)

Output files (created in data/):

- chr22_CHB.bed
- chr22_CHB.bim
- chr22_CHB.fam

2. Local vs. server usage
-------------------------

- On a local machine (e.g. macOS):
  - Make sure ./bin/plink is available and executable.
  - Run: bash scripts/01_prepare_data.sh

- On a university platform (e.g. datahub):
  - The same script can be used as long as the platform has internet access
    and PLINK installed. You can either:
    - Place the PLINK binary at ./bin/plink, or
    - Edit scripts/01_prepare_data.sh to point to a system-wide PLINK.

3. Privacy and licensing
------------------------

The 1000 Genomes Project data are fully de-identified and publicly available
for research. For details about usage and citation, see:

- The International Genome Sample Resource (IGSR) website:
  https://www.internationalgenome.org
