## Project Overview

This repository contains code and scripts for our UCSD CSE284 course project (Option 2: applying two or more methods to a task discussed in class and comparing results on real data). The goal is to perform a Genome-Wide Association Study (GWAS) on real genotype data from the 1000 Genomes Project (Phase 3, CHB, chromosome 22), simulate a quantitative trait under an additive genetic model, and compare two statistical approaches:

- A standard linear regression model using PLINK (baseline):
  Y = Xβ + ε
- A linear mixed model (LMM) using GCTA to incorporate a genetic relationship matrix (GRM):
  Y = Xβ + Zu + ε

The comparison will focus on genomic inflation factor (λ_GC), Manhattan plots, and Q–Q plots, to evaluate how each method handles population structure and related confounding factors.

## Current Progress (as of 2026-03-02)

The following components of the pipeline have been implemented and tested end-to-end.

+ `scripts/01_prepare_data.sh`: Check for a recent PLINK (>= 1.9) on PATH, download 1000 Genomes Phase 3 chr22 data and sample panel, extract the CHB subset, and convert the chr22 CHB VCF to PLINK binary format (.bed/.bim/.fam).

+ `scripts/02_qc.sh`: Perform basic genotype quality control on the chr22 CHB PLINK dataset (e.g., filters based on minor allele frequency and missingness) and produce a cleaned dataset with prefix like data/chr22_CHB_qc.

+ `scripts/03_make_phenotype.sh`: Based on the QC’ed PLINK dataset, call a Python script (simulate_phenotype.py) to simulate a quantitative trait under an additive genetic model and write phenotype files compatible with PLINK and GCTA.

+ `scripts/simulate_phenotype.py`: Implement the actual phenotype simulation logic on top of the real genotype matrix, controlling how SNP effects are generated and how the quantitative phenotype values are constructed.

+ `scripts/04_run_plink_linear.sh`: Run GWAS using PLINK linear regression (e.g., --linear) with the QC’ed genotypes and simulated phenotype, and output baseline association results such as results/chr22_CHB_plink_linear.assoc.linear.

+ `scripts/05_run_lmm.sh`: Locate the GCTA binary via the GCTA_BIN environment variable or gcta64 on PATH, construct a GRM from the QC’ed genotypes if needed, run LMM/MLMA association with GCTA, and produce results such as results/chr22_CHB_gcta_lmm.mlma.

+ `run_pipeline_01_05.py`: Provide an interactive Python driver that sequentially runs steps 01–05, prints a short description before each step, waits for user confirmation (press Enter) to proceed, handles errors by allowing retry or skip for each step, and summarizes the locations of the key PLINK and GCTA output files at the end.
