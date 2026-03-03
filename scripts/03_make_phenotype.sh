#!/usr/bin/env bash
set -euo pipefail

########## 0. Helper: logging ##########

log() {
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] $*"
}

########## 1. Paths & basic checks ##########

DATA_DIR="data"
SCRIPTS_DIR="scripts"

BFILE_PREFIX="${DATA_DIR}/chr22_CHB_qc"
PHENO_FILE="${DATA_DIR}/chr22_CHB_pheno.txt"
RAW_PREFIX="${DATA_DIR}/chr22_CHB_qc_subset"
RAW_SUBSET="${RAW_PREFIX}.raw"
SNPLIST_ALL="${DATA_DIR}/chr22_CHB_qc.snplist"
SNPLIST_SUBSET="${DATA_DIR}/chr22_CHB_qc_subset.snplist"

# 1.1 检查 QC 后的 plink 文件是否存在
for ext in bed bim fam; do
  if [ ! -f "${BFILE_PREFIX}.${ext}" ]; then
    echo "ERROR: ${BFILE_PREFIX}.${ext} not found. Did you run scripts/02_qc.sh?"
    exit 1
  fi
done

# 1.2 检查 Python 环境（要求有 numpy/pandas）
if ! command -v python >/dev/null 2>&1; then
  echo "ERROR: python not found in PATH. Please activate your conda/env with Python + numpy + pandas."
  exit 1
fi

# 1.3 定位 PLINK
if command -v plink >/dev/null 2>&1; then
  PLINK="$(command -v plink)"
else
  echo "ERROR: plink not found in PATH."
  exit 1
fi

log "Using PLINK: ${PLINK}"

########## 2. 生成 SNP 列表并选取前若干个 SNP ##########

# 只在第一次运行时创建 snplist
if [ ! -f "${SNPLIST_SUBSET}" ]; then
  log "Subset snplist not found. Generating SNP list and selecting subset..."

  # 2.1 写出所有 SNP 名称
  log "Writing full SNP list to: ${SNPLIST_ALL}"
  ${PLINK} \
    --bfile "${BFILE_PREFIX}" \
    --chr 22 \
    --write-snplist \
    --out "${DATA_DIR}/chr22_CHB_qc"

  # 2.2 从中取前 5000 个（如果总数不足 5000，就全用）
  N_SNP=5000
  TOTAL_SNP=$(wc -l < "${SNPLIST_ALL}")
  if [ "${TOTAL_SNP}" -lt "${N_SNP}" ]; then
    N_SNP="${TOTAL_SNP}"
  fi

  log "Selecting first ${N_SNP} SNPs out of ${TOTAL_SNP} into: ${SNPLIST_SUBSET}"
  head -n "${N_SNP}" "${SNPLIST_ALL}" > "${SNPLIST_SUBSET}"
else
  log "Found existing subset snplist: ${SNPLIST_SUBSET}"
fi

########## 3. 导出 SNP 子集为 .raw ##########

if [ ! -f "${RAW_SUBSET}" ]; then
  log "Subset .raw file not found. Exporting genotype subset with PLINK --recode A..."

  ${PLINK} \
    --bfile "${BFILE_PREFIX}" \
    --chr 22 \
    --extract "${SNPLIST_SUBSET}" \
    --recode A \
    --out "${RAW_PREFIX}"

  log "Subset genotype file generated: ${RAW_SUBSET}"
else
  log "Found existing subset genotype file: ${RAW_SUBSET}"
fi

########## 4. 调用 Python 脚本模拟 phenotype ##########

N_CAUSAL=20
SEED=42

log "Simulating quantitative phenotype..."
log "  Input FAM: ${BFILE_PREFIX}.fam"
log "  Input RAW: ${RAW_SUBSET}"
log "  Output phenotype: ${PHENO_FILE}"
log "  n_causal SNPs: ${N_CAUSAL}, seed: ${SEED}"

python "${SCRIPTS_DIR}/simulate_phenotype.py" \
  --fam "${BFILE_PREFIX}.fam" \
  --raw "${RAW_SUBSET}" \
  --out "${PHENO_FILE}" \
  --n_causal "${N_CAUSAL}" \
  --seed "${SEED}"

log "Phenotype file generated:"
log "  ${PHENO_FILE}"

log "Done."
