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
* Python 3: Required for the master execution script and phenotype simulation, downstream analysis, and generating visualization plots (Q-Q and Manhattan plots).
  * Packages: `numpy`, `pandas`

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

![GWAS Comparison](results/plots/qq_comparison.png?v=2)

### 4. Interpretation
* **Inflation Control**: The LMM showed better control of inflation compared to standard linear regression, with $\lambda_{GC}$ moving from 1.01 down to 1.00.
* **Q-Q Plot Stability**: As shown in the Q-Q plot, the LMM (blue points) follows the expected null distribution more closely than the linear model (grey points), effectively reducing potential false positives.
* **Manhattan Plot Consistency**: Both models identified consistent peaks, but LMM provided a more statistically rigorous assessment of significance.

## How to Run (Quick Start)

> **Platform note:** The following script is written for **Linux x86\_64** environments (e.g., UCSD DataHub / TSCC). If you are on macOS or another platform, you will need to download the corresponding GCTA binary from the [GCTA download page](https://yanglab.westlake.edu.cn/software/gcta/#Download) and adjust the download URL accordingly.

Copy the entire block below into your terminal. It will clone the repo, create an isolated conda environment, install all dependencies (including PLINK 1.9 and GCTA), run the full GWAS pipeline, and generate all summary plots.

```bash
# ============================================================
#  Platform: Linux x86_64
# ============================================================

# --------------------------------------------------
# 0. Clone the repository
# --------------------------------------------------
git clone https://github.com/zzyzhbs/gwas-lmm-comparison
cd gwas-lmm-comparison

# --------------------------------------------------
# 1. Create a clean conda environment (Python 3.11)
# --------------------------------------------------
ENV_NAME="cse284_final"

# Remove the env if it already exists, for a truly clean slate
conda deactivate 2>/dev/null
conda env remove -n "${ENV_NAME}" -y 2>/dev/null

conda create -n "${ENV_NAME}" python=3.11 -y
conda activate "${ENV_NAME}"

# --------------------------------------------------
# 2. Install Python dependencies
# --------------------------------------------------
pip install -r env/requirements.txt

# --------------------------------------------------
# 3. Install PLINK 1.9
#    If plink is already available in the current
#    environment, we skip the install.
# --------------------------------------------------
if command -v plink &>/dev/null; then
    echo "[INFO] PLINK 1.9 found: $(command -v plink)"
else
    echo "[INFO] PLINK not found — installing via conda-forge..."
    conda install -c bioconda plink=1.90b6.21 -y
    echo "[INFO] PLINK installed: $(command -v plink)"
fi

# --------------------------------------------------
# 4. Download & configure GCTA (Linux x86_64)
#
#    All platform builds are available at:
#    https://yanglab.westlake.edu.cn/software/gcta/#Download
#
#    Below we download the Linux x86_64 v1.95.1 binary,
#    unzip it into ./bin, and export GCTA_BIN so the
#    pipeline scripts can find it automatically.
# --------------------------------------------------
GCTA_URL="https://yanglab.westlake.edu.cn/software/gcta/bin/gcta-1.95.1-linux-x86_64.zip"
GCTA_DIR="./bin/gcta-1.95.1-linux-x86_64"

if [[ -n "${GCTA_BIN:-}" && -x "${GCTA_BIN}" ]]; then
    # User already configured GCTA_BIN — respect it
    echo "[INFO] Using existing GCTA_BIN: ${GCTA_BIN}"
elif command -v gcta64 &>/dev/null; then
    export GCTA_BIN="$(command -v gcta64)"
    echo "[INFO] Using GCTA from PATH: ${GCTA_BIN}"
else
    echo "[INFO] GCTA not found — downloading to ./bin ..."
    mkdir -p ./bin
    wget -q --show-progress -O ./bin/gcta.zip "${GCTA_URL}"
    unzip -o ./bin/gcta.zip -d ./bin
    rm -f ./bin/gcta.zip
    chmod +x "${GCTA_DIR}/gcta64"       # ← make sure it's executable
    export GCTA_BIN="${GCTA_DIR}/gcta64"
    echo "[INFO] GCTA installed at: ${GCTA_BIN}"
fi

# --------------------------------------------------
# 5. Run the full GWAS pipeline (Steps 01–05)
#    Data will be downloaded automatically.
# --------------------------------------------------
echo "=========================================="
echo "  Running GWAS pipeline (Steps 01–05)..."
echo "=========================================="
python run_pipeline_01_05.py

# --------------------------------------------------
# 6. Generate summary plots
#    (λGC, Manhattan plots, Q–Q plots)
# --------------------------------------------------
echo "=========================================="
echo "  Generating comparison plots..."
echo "=========================================="
python analysis/compare_plink_lmm.py \
  --plink results/chr22_CHB_plink_linear.assoc.linear \
  --lmm   results/chr22_CHB_gcta_lmm.mlma \
  --out   results/plots/

# --------------------------------------------------
# Done!
# --------------------------------------------------
echo ""
echo "All done! Results and plots are in:"
echo "    results/"
echo "    results/plots/"
```

> **Tip:** If `conda activate` does not work inside a non-interactive script, replace it with:
>
> ```bash
> source "$(conda info --base)/etc/profile.d/conda.sh"
> conda activate cse284_final
> ```

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
