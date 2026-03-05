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

4. Toy Example (For Quick Testing)
----------------------------------

Running the full pipeline on the entire Chromosome 22 can take some time. If you (or the TAs) wish to quickly test the computational mechanics of the scripts without waiting, you can generate a minimal "toy" dataset.

Assuming you have already run Step 01 to generate the initial CHB dataset (`data/chr22_CHB.bed` etc.), you can use PLINK to extract a tiny subset (e.g., keeping only 5% of the SNPs) by running the following command from the project root:

    plink --bfile data/chr22_CHB \
          --thin 0.05 \
          --make-bed \
          --out data/toy_demo

- `--thin 0.05`: Keeps roughly 5% of the variants randomly, drastically reducing file size and computation time.
- Once `data/toy_demo.{bed,bim,fam}` is generated, you can temporarily modify the data prefix in the Step 03, 04, and 05 scripts to point to `data/toy_demo` to test the pipeline end-to-end in seconds.