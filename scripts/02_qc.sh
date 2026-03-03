#!/usr/bin/env bash
set -euo pipefail

########## 0. Helper: logging ##########

log() {
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] $*"
}

########## 1. Locate PLINK ##########

if command -v plink >/dev/null 2>&1; then
  PLINK="$(command -v plink)"
else
  echo "ERROR: plink not found in PATH. Please install PLINK 1.9+ and ensure it's on your PATH."
  exit 1
fi

log "Using PLINK: ${PLINK}"
${PLINK} --version || true

########## 2. Input / output paths ##########

DATA_DIR="data"
IN_PREFIX="${DATA_DIR}/chr22_CHB"
OUT_PREFIX="${DATA_DIR}/chr22_CHB_qc"

# Check input files
for ext in bed bim fam; do
  if [ ! -f "${IN_PREFIX}.${ext}" ]; then
    echo "ERROR: Input file ${IN_PREFIX}.${ext} not found. Did you run 01_prepare_data.sh?"
    exit 1
  fi
done

########## 3. Run basic QC ##########

log "Running basic QC with PLINK..."
log "Input prefix:  ${IN_PREFIX}"
log "Output prefix: ${OUT_PREFIX}"

${PLINK} \
  --bfile "${IN_PREFIX}" \
  --maf 0.01 \
  --geno 0.05 \
  --mind 0.05 \
  --make-bed \
  --out "${OUT_PREFIX}"

log "QCed PLINK files generated:"
log "  ${OUT_PREFIX}.bed"
log "  ${OUT_PREFIX}.bim"
log "  ${OUT_PREFIX}.fam"

log "Done."
