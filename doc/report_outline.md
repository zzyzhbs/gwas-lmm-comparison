# Project Report Outline

## Title
- Comparative Analysis of Linear and Mixed Model Approaches in GWAS

## Team Members
- Shengqi Yuan
- Yumeng Guo
- Hongshuo Xie

## 1. Introduction
- Goal of the Tool/Pipeline: Briefly introduce the automated pipeline we built to compare standard linear regression and Linear Mixed Models (LMM).
- Applicable Problems: Explain the challenge of confounding factors in GWAS (population structure, cryptic relatedness) and how this pipeline evaluates LMM as a solution to prevent false positives.

## 2. Methods
- Dataset Source: 1000 Genomes Project Phase 3, Chromosome 22, Han Chinese in Beijing (CHB) population.
- Implementation Details: Describe the phenotype simulation under an additive genetic model (simulate_phenotype.py) and the assumed heritability (h2).
- Tools and Parameters:
  - PLINK (v1.9): Used for QC and baseline linear regression.
  - GCTA: Used for the Genetic Relationship Matrix (GRM) and LMM. 
  - Python / R: Versions and specific libraries used for the pipeline driver and visualization (e.g., pandas, matplotlib/ggplot2).

## 3. Results
- Benchmark & Analysis Summary:
  - Genomic Inflation Factor (lambda_GC): Compare the lambda_GC values (PLINK: 1.0125 vs GCTA: 1.0004) and explain the successful control of inflation.
  - Visualizations: Discuss the Q-Q Plot (adherence to the null distribution) and Manhattan Plot (peak signals and noise reduction).

## 4. Discussion
- Challenges: Detail technical hurdles encountered (e.g., formatting data between PLINK and GCTA, pipeline automation, simulating traits).
- Future Directions: Suggest improvements if the project were to continue (e.g., testing on larger, multi-ancestry cohorts, or comparing runtime performance with modern tools like REGENIE or fastGWA).

## 5. Code Availability
- GitHub Repository: https://github.com/zzyzhbs/gwas-lmm-comparison

## 6. References
- PLINK 1.9 original paper/URL.
- GCTA / MLMA paper.
- 1000 Genomes Project Phase 3 citation.