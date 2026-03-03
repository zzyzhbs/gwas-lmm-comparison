#!/usr/bin/env bash
set -euo pipefail

############################################################
# 04_run_plink_linear.sh
#
# Run baseline PLINK linear association on QC'ed genotype
# and a simulated continuous phenotype.
#
# Usage:
#   bash scripts/04_run_plink_linear.sh \
#       [BFILE_PREFIX] [PHENO_FILE] [OUT_PREFIX]
#
# Examples:
#   # Use defaults (chr22_CHB_qc + chr22_CHB_pheno.txt)
#   bash scripts/04_run_plink_linear.sh
#
#   # Custom bfile and output prefix
#   bash scripts/04_run_plink_linear.sh \
#       data/chr22_CHB_qc data/chr22_CHB_pheno.txt \
#       results/chr22_CHB_plink_linear
############################################################

# --------- 1. Parse arguments & set defaults ---------

BFILE_PREFIX=${1:-data/chr22_CHB_qc}
PHENO_FILE=${2:-data/chr22_CHB_pheno.txt}
OUT_PREFIX=${3:-results/chr22_CHB_plink_linear}

# --------- 2. Basic checks ---------

if ! command -v plink &> /dev/null; then
    echo "[ERROR] plink not found in PATH. Activate your gwas_env or install PLINK first." >&2
    exit 1
fi

if [[ ! -f "${BFILE_PREFIX}.bed" ]]; then
    echo "[ERROR] Cannot find ${BFILE_PREFIX}.bed" >&2
    exit 1
fi

if [[ ! -f "${BFILE_PREFIX}.bim" ]]; then
    echo "[ERROR] Cannot find ${BFILE_PREFIX}.bim" >&2
    exit 1
fi

if [[ ! -f "${BFILE_PREFIX}.fam" ]]; then
    echo "[ERROR] Cannot find ${BFILE_PREFIX}.fam" >&2
    exit 1
fi

if [[ ! -f "${PHENO_FILE}" ]]; then
    echo "[ERROR] Phenotype file not found: ${PHENO_FILE}" >&2
    exit 1
fi

# --------- 3. Prepare output directory ---------

OUT_DIR=$(dirname "${OUT_PREFIX}")
mkdir -p "${OUT_DIR}"

echo "[INFO] BFILE prefix  : ${BFILE_PREFIX}"
echo "[INFO] Phenotype file: ${PHENO_FILE}"
echo "[INFO] Output prefix : ${OUT_PREFIX}"
echo "[INFO] Running PLINK linear association..."

# --------- 4. Run PLINK linear association ---------

plink \
  --bfile "${BFILE_PREFIX}" \
  --pheno "${PHENO_FILE}" \
  --pheno-name PHENO \
  --linear \
  --allow-no-sex \
  --out "${OUT_PREFIX}"

echo "[INFO] PLINK finished. Key output:"
echo "       ${OUT_PREFIX}.assoc.linear"
