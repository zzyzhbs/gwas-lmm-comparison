#!/usr/bin/env python
import argparse
import numpy as np
import pandas as pd


def main():
    parser = argparse.ArgumentParser(
        description="Simulate a polygenic quantitative phenotype from QCed chr22 CHB genotype."
    )
    parser.add_argument("--fam", required=True, help="Input FAM file (e.g. chr22_CHB_qc.fam)")
    parser.add_argument("--raw", required=True, help="PLINK --recode A .raw file (e.g. chr22_CHB_qc_subset.raw)")
    parser.add_argument("--out", required=True, help="Output phenotype file (FID IID PHENO)")
    parser.add_argument("--n_causal", type=int, default=20, help="Number of causal SNPs")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    args = parser.parse_args()

    np.random.seed(args.seed)

    # 1) Read FAM
    fam = pd.read_csv(args.fam, sep=r"\s+", header=None)
    fam.columns = ["FID", "IID", "PID", "MID", "SEX", "PHENO_PLINK"]

    # 2) Read RAW as pure matrix (skip header), construct our own column names
    with open(args.raw, "r") as f:
        _ = f.readline()          # skip original header
        second_line = f.readline()

    n_cols = len(second_line.split())
    meta_cols = ["FID", "IID", "PAT", "MAT", "SEX", "PHENOTYPE"]
    if n_cols < len(meta_cols):
        raise RuntimeError(f"Data row has only {n_cols} columns, less than 6 meta columns.")

    n_snps = n_cols - len(meta_cols)
    snp_cols = [f"SNP_{i}" for i in range(n_snps)]
    all_cols = meta_cols + snp_cols

    raw = pd.read_csv(
        args.raw,
        sep=r"\s+",
        header=None,
        skiprows=1,
        names=all_cols,
        engine="python",
    )

    # 3) Merge FAM and RAW to ensure sample alignment
    merged = pd.merge(
        fam[["FID", "IID"]],
        raw,
        on=["FID", "IID"],
        how="inner",
        sort=False,
    )

    snp_cols = [c for c in merged.columns if c not in meta_cols]
    if len(snp_cols) == 0:
        raise RuntimeError("No SNP columns found after merge.")
    if len(snp_cols) < args.n_causal:
        raise RuntimeError(f"Not enough SNPs ({len(snp_cols)}) for n_causal={args.n_causal}")

    # 4) Sample causal SNPs and simulate phenotype
    causal_snps = np.random.choice(snp_cols, size=args.n_causal, replace=False)
    beta = np.random.normal(loc=0.0, scale=0.2, size=args.n_causal)

    X = merged[causal_snps].to_numpy(dtype=float)
    g = X @ beta
    noise = np.random.normal(loc=0.0, scale=1.0, size=g.shape[0])
    pheno = g + noise

    out_df = merged[["FID", "IID"]].copy()
    out_df["PHENO"] = pheno

    out_df.to_csv(args.out, sep="\t", index=False)


if __name__ == "__main__":
    main()
