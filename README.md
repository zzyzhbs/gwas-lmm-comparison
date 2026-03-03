# GWAS: Linear vs LMM on 1000G CHB chr22

## Introduction / Overview

- Brief background: what scientific / methodological question this project is addressing.
- Data used: e.g., 1000 Genomes Project, chromosome 22, CHB population.
- Main outputs: shell scripts, intermediate data, final association results, plots.

---

## Repository Structure

Short description of the most important directories and files:

- `scripts/` – data download, preprocessing, and analysis scripts.
- `data/` – data directory (raw downloads, intermediate files, final processed data).
- `bin/` – external tools or helper executables (if any).
- `results/` – analysis outputs and plots.
- any other important directories or configuration files.

---

## Environment and Dependencies

Describe what is required to run the project:

- Recommended OS: Linux or macOS.
- Shell and basic tools: `bash`, `curl`, `awk`, `grep`, etc.
- Statistical / plotting environment: e.g., R version and required packages, or Python version and required packages.
- PLINK requirement:
  - Required PLINK version (e.g., PLINK ≥ 1.9).
  - How the scripts locate PLINK (e.g., using `command -v plink`).
  - macOS installation / PATH instructions.
  - Linux installation / PATH instructions.
  - Common PLINK errors (e.g., `unknown option "--vcf"`) and how to fix them.

This is where you should paste the detailed plain-text PLINK section you already prepared.



PLINK requirement
-----------------

This project assumes that a recent version of PLINK (>= 1.9) is available as "plink" on your PATH. The scripts locate it via:

PLINK = "$(command -v plink)"

If "plink" is not found, or if your PLINK version is too old (v1.07), the scripts will fail.

Please follow the instructions below to install or update PLINK.

macOS installation (without Homebrew formula)
---------------------------------------------

1. Download PLINK 1.9 for macOS from:

   https://www.cog-genomics.org/plink/1.9/

2. Unzip the archive and copy the "plink" binary into your personal bin directory, for example:

   cd ~/Downloads
   unzip plink_mac_*.zip -d plink_mac
   mkdir -p ~/bin
   cp plink_mac/plink ~/bin/plink
   chmod +x ~/bin/plink

3. Add "~/bin" to your PATH (for zsh, edit ~/.zshrc and add):

   export PATH="$HOME/bin:$PATH"

4. Reload your shell configuration or open a new terminal:

   source ~/.zshrc

5. Verify that PLINK is correctly installed and on PATH:

   which plink
   plink --version

The first command should print a path like:

   /Users/your-username/bin/plink

The second command should show a version number starting with 1.9 or 2.0. If it shows v1.07, you are still using an old PLINK and need to replace it.

Linux installation
------------------

1. Download PLINK 1.9 or 2.0 from:

   https://www.cog-genomics.org/plink/1.9/
   or
   https://www.cog-genomics.org/plink/2.0/

2. Place the "plink" binary somewhere on your PATH, for example:

   cd /path/to/downloads
   tar -xvf plink_xxx.tar.gz  (if it is a tarball)
   mkdir -p ~/bin
   mv plink ~/bin/plink
   chmod +x ~/bin/plink

3. Add "~/bin" to your PATH in your shell configuration (for example in ~/.bashrc or ~/.zshrc):

   export PATH="$HOME/bin:$PATH"

4. Reload the configuration:

   source ~/.bashrc
   or
   source ~/.zshrc

5. Verify:

   which plink
   plink --version

Again, you should see PLINK 1.9 or newer.

Common error and how to fix it
------------------------------

If you see an error like:

   plink: unknown option "--vcf"
   plink: unknown option "--keep"

then your PLINK version is too old (usually v1.07). It does not support the newer command line options used in this project.

To fix this, install PLINK 1.9 or 2.0 as described above, and make sure the new "plink" binary is the one found by "which plink".

Script behaviour
----------------

The scripts in this repository do not use a hard-coded path to PLINK. Instead, they search for "plink" on PATH using:

   command -v plink

If PLINK is not found, or if you want to use a specific PLINK binary, you can adjust your PATH so that "which plink" points to the desired executable.



---

## Quick Start

Provide the minimal set of steps for the TA to run the full pipeline once, end‑to‑end:

1. Clone this repository.
2. Set up the environment and dependencies:
   - Install PLINK as described in “Environment and Dependencies”.
   - Install R / Python packages if needed.
3. Prepare the data:
   - Example command: `bash scripts/01_prepare_data.sh`
4. Run the main analysis scripts:
   - Example: `bash scripts/02_gwas_linear.sh`
   - Example: `bash scripts/03_gwas_lmm.sh`
5. Inspect results:
   - Point to specific files in `results/` and/or `data/processed/`.

---

## Data Description

Explain what data is used and how it is organized in the repository:

- External data sources:
  - 1000 Genomes Project (with the official URL).
  - Which chromosome(s) and population(s) are used (e.g., chr22, CHB).
- Directory layout under `data/`:
  - `data/raw/` – original downloaded files (VCF, panels, etc.).
  - `data/intermediate/` – converted formats (e.g., PLINK bed/bim/fam).
  - `data/processed/` – cleaned / filtered data used as final analysis input.
- Any additional phenotype or covariate files:
  - Where they come from, and what columns/format they have.

---

## Scripts

Document the key scripts in `scripts/` and what they do.

For each major script, specify:

- Script name.
- Purpose.
- Inputs and outputs.
- How to run it (exact command).

Example layout:

- `scripts/01_prepare_data.sh`
  - Purpose: download 1000G chr22 VCF, subset CHB samples, convert to PLINK binary.
  - Inputs: public VCF URL, sample panel, PLINK executable.
  - Outputs: PLINK bed/bim/fam files under `data/`.
  - Usage: `bash scripts/01_prepare_data.sh`
- `scripts/02_qc.sh`
  - Purpose, inputs, outputs, usage.
- `scripts/03_gwas_linear.sh`
  - Purpose, inputs, outputs, usage.
- `scripts/04_gwas_lmm.sh`
  - Purpose, inputs, outputs, usage.

---

## Analysis Pipeline

Explain the logical sequence of steps at a higher level than individual scripts:

1. Data preparation:
   - Download raw data (VCF, panel).
   - Subset to the target population.
   - Convert to PLINK bed/bim/fam.
2. Quality control (if applicable):
   - Variant filters (MAF, missingness, HWE, etc.).
   - Sample filters (missingness, relatedness, etc.).
3. Association analysis:
   - Linear regression model (standard GWAS) and how it is implemented.
   - Linear mixed model (LMM) and how it is implemented.
   - Software / options used for each method.
4. Multiple testing correction:
   - Method (e.g., Bonferroni, FDR) and where it is applied.
5. Visualization and summarization:
   - Which scripts generate Manhattan / QQ plots.
   - Where those plots are stored.

---

## Results and Interpretation

Summarize what the TA should expect from running the pipeline and how to interpret it:

- Main comparison between methods:
  - e.g., difference in p‑value distributions between linear regression and LMM.
  - Genomic inflation factors (λGC), number of significant hits.
- Where to find key output files:
  - e.g., `results/gwas_linear.assoc`, `results/gwas_lmm.assoc`.
  - e.g., `results/manhattan_linear.png`, `results/qq_lmm.png`.
- Short narrative interpretation:
  - What the results suggest about population structure / relatedness.
  - How LMM performance compares to standard linear regression in this setting.

---

## Reproducibility

Explain how to fully reproduce your results from scratch:

- Any required manual steps (if any) before running the scripts.
- Exact sequence of commands to go from a fresh clone to final results, for example:

  1. `bash scripts/01_prepare_data.sh`
  2. `bash scripts/02_qc.sh`
  3. `bash scripts/03_gwas_linear.sh`
  4. `bash scripts/04_gwas_lmm.sh`

- Mention whether there is any randomness and how you control it (e.g., fixed seeds).

---

## FAQ / Troubleshooting

List common problems the TA might encounter and how to resolve them.

Examples:

- PLINK errors:
  - Error: `plink: unknown option "--vcf"`
    - Cause: PLINK version is too old (likely v1.07).
    - Fix: upgrade to PLINK 1.9+ as described in “Environment and Dependencies”.
- Download issues:
  - 1000 Genomes download is slow or interrupted.
  - Possible workarounds or manual download instructions.
- Resource issues:
  - What to do if memory or disk usage becomes a problem.
  - Options to downsample the data if necessary.

---

## License and Acknowledgements

- State how the code and documentation may be used (e.g., for CSE 284 course project only, or a standard open-source license if applicable).
- Acknowledge data sources:
  - e.g., The 1000 Genomes Project.
- Acknowledge software and libraries:
  - e.g., PLINK, R, specific R/Python packages used.







