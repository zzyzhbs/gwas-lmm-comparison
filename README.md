## Project Overview

This repository contains code and scripts for our UCSD CSE284 course project (Option 2: applying two or more methods to a task discussed in class and comparing results on real data). The goal is to perform a Genome-Wide Association Study (GWAS) on real genotype data from the 1000 Genomes Project (Phase 3, CHB, chromosome 22), simulate a quantitative trait under an additive genetic model, and compare two statistical approaches:

- A standard linear regression model using PLINK (baseline):
  Y = Xβ + ε
- A linear mixed model (LMM) using GCTA to incorporate a genetic relationship matrix (GRM):
  Y = Xβ + Zu + ε

The comparison will focus on genomic inflation factor (λ_GC), Manhattan plots, and Q–Q plots, to evaluate how each method handles population structure and related confounding factors.

## Dependencies & Installation

To reproduce this pipeline, the following tools and libraries are required:

* PLINK (v1.9+): Required for basic data processing and standard linear regression GWAS.
* GCTA (v1.9+): Required for generating the Genetic Relationship Matrix (GRM) and running the Linear Mixed Model (MLMA). 
* Python 3: Required for the master execution script and phenotype simulation.
  * Packages: `numpy`, `pandas`
* R / Python: Required for downstream analysis and generating visualization plots (Q-Q and Manhattan plots).

You can run this pipeline seamlessly on JupyterHub by activating a standard conda environment containing `numpy`/`pandas` and ensuring `plink` and `gcta64` are in your `$PATH` or specified via the `GCTA_BIN` environment variable.

## Repository Structure

```text
.
├── README.md                     # Main project documentation
├── run_pipeline_01_05.py         # Master interactive Python driver for steps 01-05
├── scripts/                      # Core bash and python scripts for data prep, QC, and GWAS
│   ├── 01_prepare_data.sh        # Prepares and converts 1000G CHB chr22 data
│   ├── 02_qc.sh                  # Performs basic genotype QC (MAF, missingness)
│   ├── 03_make_phenotype.sh      # Wrapper to call the simulation script
│   ├── simulate_phenotype.py     # Python logic for simulating quantitative traits
│   ├── 04_run_plink_linear.sh    # Runs baseline standard linear regression (PLINK)
│   └── 05_run_lmm.sh             # Runs Linear Mixed Model (GCTA/MLMA)
├── analysis/                     # Scripts for calculating lambda_GC and plotting
├── data/                         # Directory for genotype (.bed/.bim/.fam) and phenotype files
├── results/                      # Directory for PLINK/GCTA association outputs
│   └── plots/                    # Directory for generated Q-Q and Manhattan plots
└── doc/                          # Project report and presentation outlines
````


## Preliminary Results

We evaluated the performance of two different GWAS models—**Standard Linear Regression (PLINK)** and **Linear Mixed Model (LMM/GCTA)**—using simulated phenotypes on 1000 Genomes Phase 3 data (Chr 22, CHB population).

### 1. Statistical Models Compared
To identify genetic variants while controlling for confounding factors, we compared:
* **Linear Regression**: $Y = X\beta + \epsilon$ (Baseline approach)
* **Linear Mixed Model (LMM)**: $Y = X\beta + Zu + \epsilon$ (Accounting for population structure and relatedness)

### 2. Genomic Inflation ($\lambda_{GC}$)
We calculated the genomic inflation factor to assess how well each model controls for population stratification:
$$\lambda_{GC} = \frac{\text{median}(\chi^2_{\text{obs}})}{0.4549}$$

| Method | $\lambda_{GC}$ | Observation |
| :--- | :--- | :--- |
| **Linear (PLINK)** | **1.0125** | Slight inflation observed |
| **LMM (GCTA)** | **1.0004** | Near-perfect control of stratification |

### 3. Comparison Visualization
The following figure was automatically generated using the `analysis/compare_plink_lmm.py` script.

![GWAS Comparison](results/plots/qq_comparison.png)

### 4. Interpretation
* **Inflation Control**: The LMM showed better control of inflation compared to standard linear regression, with $\lambda_{GC}$ moving from 1.01 down to 1.00.
* **Q-Q Plot Stability**: As shown in the Q-Q plot, the LMM (blue points) follows the expected null distribution more closely than the linear model (grey points), effectively reducing potential false positives.
* **Manhattan Plot Consistency**: Both models identified consistent peaks, but LMM provided a more statistically rigorous assessment of significance.

## How to Run (Quick Start)

We have provided an interactive master script to run the entire pipeline from Step 01 to Step 05. 

1. Clone the repository and navigate to the root directory.
2. Ensure your environment is set up (activate your conda environment and export `GCTA_BIN` if necessary).
3. Execute the master driver:
```bash
python run_pipeline_01_05.py
```
## Remaining Work & Challenges for Peer Review

### Remaining Tasks (Last Week)
- Draft the final written report: Populate the `report_outline.md` with detailed explanations, methodology, and result interpretations.
- Prepare presentation slides: Convert `slides_outline.md` into the final slide deck for the class presentation.
- Polish visualizations: Ensure all axes, legends, and titles on the Q-Q and Manhattan plots are perfectly formatted for the final report.
- Final code review: Do a final walkthrough of the interactive Python driver to ensure it runs flawlessly for the TAs' grading process.

### Challenges & Topics for Peer Discussion
- Trait Simulation Realism: We simulated a quantitative trait under a basic additive genetic model. We'd like to discuss with peers if incorporating more complex architectures (e.g., dominant/recessive effects, or environmental covariates) would drastically alter the performance gap between standard linear regression and LMM.
- Scalability Bottlenecks: Our pipeline works efficiently for chromosome 22 of the CHB sub-population. However, calculating the Genetic Relationship Matrix (GRM) in GCTA is computationally expensive. We want to discuss the computational challenges of scaling this pipeline to whole-genome data or massive cohorts like the UK Biobank.
- Interpreting Mild Inflation: Our baseline PLINK lambda_GC was 1.0125, which represents relatively mild inflation (likely because the CHB dataset is an isolated, relatively homogeneous population). We'd love to hear how other groups handled populations with more extreme stratification (e.g., admixed populations) and how their LMM corrected it compared to our baseline.