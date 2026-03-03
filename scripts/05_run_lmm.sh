#!/usr/bin/env bash
set -euo pipefail

############################################################
# 05_run_lmm.sh
# 使用 LMM 跑 GWAS（默认用 GCTA，可通过 GCTA_BIN 环境变量调整路径）
############################################################

# --------- 1. 解析 GCTA 路径（可配置） ---------

if [[ -n "${GCTA_BIN:-}" ]]; then
    # 如果用户在命令行或环境里显式设置了 GCTA_BIN，就用它
    echo "[INFO] Using GCTA from GCTA_BIN: ${GCTA_BIN}"
elif command -v gcta64 &> /dev/null; then
    GCTA_BIN=$(command -v gcta64)
    echo "[INFO] Using GCTA from PATH: ${GCTA_BIN}"
else
    echo "[ERROR] GCTA not found. Please set GCTA_BIN or put gcta64 in PATH." >&2
    exit 1
fi

if [[ ! -x "${GCTA_BIN}" ]]; then
    echo "[ERROR] GCTA_BIN is set but not executable: ${GCTA_BIN}" >&2
    exit 1
fi

# --------- 2. 解析参数 & 文件路径 ---------

BFILE_PREFIX=${1:-data/chr22_CHB_qc}
PHENO_FILE=${2:-data/chr22_CHB_pheno.txt}
OUT_PREFIX=${3:-results/chr22_CHB_gcta_lmm}

OUT_DIR=$(dirname "${OUT_PREFIX}")
mkdir -p "${OUT_DIR}"

for ext in bed bim fam; do
    [[ -f "${BFILE_PREFIX}.${ext}" ]] || { echo "[ERROR] Missing ${BFILE_PREFIX}.${ext}"; exit 1; }
done
[[ -f "${PHENO_FILE}" ]] || { echo "[ERROR] Missing phenotype file: ${PHENO_FILE}"; exit 1; }

echo "[INFO] BFILE prefix : ${BFILE_PREFIX}"
echo "[INFO] Pheno file   : ${PHENO_FILE}"
echo "[INFO] Output prefix: ${OUT_PREFIX}"

# --------- 3. 构建 GRM（如果不存在） ---------

GRM_PREFIX="${OUT_PREFIX}_grm"

if [[ -f "${GRM_PREFIX}.grm.bin" ]]; then
    echo "[INFO] GRM already exists. Skipping --make-grm."
else
    echo "[INFO] Building GRM with GCTA..."
    "${GCTA_BIN}" \
      --bfile "${BFILE_PREFIX}" \
      --make-grm \
      --out "${GRM_PREFIX}"
fi

# --------- 4. 运行 LMM GWAS（MLMA） ---------

echo "[INFO] Running GCTA MLMA..."

"${GCTA_BIN}" \
  --bfile "${BFILE_PREFIX}" \
  --grm "${GRM_PREFIX}" \
  --pheno "${PHENO_FILE}" \
  --mlma \
  --out "${OUT_PREFIX}"

echo "[INFO] Done. Main output:"
echo "       ${OUT_PREFIX}.mlma"
