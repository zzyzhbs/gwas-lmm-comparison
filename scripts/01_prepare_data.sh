#!/usr/bin/env bash
set -euo pipefail

##############################################
# 01_prepare_data.sh
# Download 1000G chr22 VCF, extract CHB, convert to PLINK.
##############################################

########## 0. Locate PLINK ##########

if ! command -v plink >/dev/null 2>&1; then
  echo "ERROR: 'plink' not found in PATH."
  echo "Please install PLINK >= 1.9 and make sure 'plink' is on your PATH."
  echo "Example (macOS):"
  echo "  1) Download PLINK 1.9 from https://www.cog-genomics.org/plink/1.9/"
  echo "  2) Put the 'plink' binary into \$HOME/bin and add it to PATH."
  exit 1
fi

PLINK="$(command -v plink)"
echo "[`date +'%Y-%m-%d %H:%M:%S'`] Using PLINK: ${PLINK}"
"${PLINK}" --version || true  

########## Configuration ##########
RAW_VCF_URL="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
PANEL_URL="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel"
POP="CHB"
OUT_PREFIX="chr22_${POP}"
DATA_DIR="data"
RAW_DIR="${DATA_DIR}/raw"
OUT_DIR="${DATA_DIR}"


########## Helper ##########

log() {
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] $*"
}

########## 0. Check dependencies ##########

if [ ! -x "${PLINK}" ]; then
  echo "ERROR: ${PLINK} not found or not executable."
  echo "Please place PLINK binary at ./bin/plink or update PLINK path in this script."
  exit 1
fi

########## 1. Create directories ##########

log "Creating data directories..."
mkdir -p "${RAW_DIR}"
mkdir -p "${OUT_DIR}"

########## 2. Download chr22 VCF ##########

RAW_VCF="${RAW_DIR}/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"

if [ -f "${RAW_VCF}" ]; then
  log "Found existing VCF: ${RAW_VCF}"
else
  log "Downloading chr22 VCF from:"
  log "  ${RAW_VCF_URL}"
  curl -L "${RAW_VCF_URL}" -o "${RAW_VCF}"
  log "VCF downloaded to: ${RAW_VCF}"
fi

########## 2b. Download sample panel ##########

PANEL_FILE="${RAW_DIR}/integrated_call_samples_v3.20130502.ALL.panel"

if [ -f "${PANEL_FILE}" ]; then
  log "Found existing panel file: ${PANEL_FILE}"
else
  log "Downloading sample panel from:"
  log "  ${PANEL_URL}"
  curl -L "${PANEL_URL}" -o "${PANEL_FILE}"
  log "Panel file downloaded to: ${PANEL_FILE}"
fi

########## 3. Extract CHB sample IDs ##########

CHB_LIST="${RAW_DIR}/CHB_samples.txt"
CHB_KEEP="${RAW_DIR}/CHB_samples_fid_iid.txt"

if [ -f "${CHB_LIST}" ]; then
  log "Found existing CHB sample list (single-column IID): ${CHB_LIST}"
else
  log "Extracting CHB sample IDs from panel file..."
  # Typical columns: sampleID population sex super_population ...
  # We assume the 2nd column is the population code.
  awk '$2 == "CHB" {print $1}' "${PANEL_FILE}" > "${CHB_LIST}"

  N_CHB=$(wc -l < "${CHB_LIST}" | tr -d ' ')
  log "CHB sample IDs written to: ${CHB_LIST} (n=${N_CHB})"

  if [ "${N_CHB}" -eq 0 ]; then
    echo "ERROR: No CHB samples found in panel file. Please check PANEL_FILE format."
    exit 1
  fi
fi

# Ensure we always have a two-column FID/IID file for --keep
log "Creating two-column FID/IID keep file for CHB..."
awk 'NF > 0 {print $1, $1}' "${CHB_LIST}" > "${CHB_KEEP}"

N_CHB_KEEP=$(wc -l < "${CHB_KEEP}" | tr -d ' ')
log "CHB keep file written to: ${CHB_KEEP} (n=${N_CHB_KEEP})"

########## 4. Convert VCF to PLINK (CHB only) ##########

log "Converting VCF to PLINK and extracting CHB samples..."

${PLINK} \
  --vcf "${RAW_VCF}" \
  --keep "${CHB_KEEP}" \
  --make-bed \
  --out "${OUT_DIR}/${OUT_PREFIX}"

log "PLINK files generated:"
log "  ${OUT_DIR}/${OUT_PREFIX}.bed"
log "  ${OUT_DIR}/${OUT_PREFIX}.bim"
log "  ${OUT_DIR}/${OUT_PREFIX}.fam"

########## 5. Placeholder for QC ##########

log "Basic QC is not applied in this script."
log "You can later add options like:"
log "  --maf 0.01 --geno 0.05 --mind 0.05"

log "Done."
