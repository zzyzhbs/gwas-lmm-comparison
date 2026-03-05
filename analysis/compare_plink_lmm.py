# Usage:
# python analysis/compare_plink_lmm.py \
#   --plink results/chr22_CHB_plink_linear.assoc.linear \
#   --lmm results/chr22_CHB_gcta_lmm.mlma \
#   --out results/plots/

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as stats
import os
import argparse

def calculate_lambda(p_values):
    # calculate Genomic Inflation Factor (lambda GC)
    chi2 = stats.chi2.ppf(1 - p_values, 1)
    return np.median(chi2) / 0.4549

def get_qq_coords(p_values):
    p_sorted = np.sort(p_values[p_values > 0])
    n = len(p_sorted)
    expected = -np.log10(np.arange(1, n + 1) / (n + 1))
    observed = -np.log10(p_sorted)
    return expected[::-1], observed

def run_analysis(plink_path, lmm_path, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    
    # 1. read data 
    df_lin = pd.read_csv(plink_path, sep='\s+').dropna(subset=['P'])
    df_lmm = pd.read_csv(lmm_path, sep='\s+').dropna(subset=['p'])
    
    # 2. calculate Lambda
    lam_lin = calculate_lambda(df_lin['P'])
    lam_lmm = calculate_lambda(df_lmm['p'])
    
    summary_text = (
        f"GWAS Comparison Summary\n"
        f"-----------------------\n"
        f"Linear (PLINK) lambda_GC: {lam_lin:.4f}\n"
        f"LMM (GCTA) lambda_GC:    {lam_lmm:.4f}\n"
    )
    print(summary_text)
    with open(os.path.join(out_dir, "summary.txt"), "w") as f:
        f.write(summary_text)

    # 3. plot (2x1 layout: top Manhattan, bottom QQ)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 12))

    # Manhattan Plot
    ax1.scatter(df_lin['BP'], -np.log10(df_lin['P']), c='lightgrey', s=10, label=f'Linear (λ={lam_lin:.2f})')
    ax1.scatter(df_lmm['bp'], -np.log10(df_lmm['p']), c='royalblue', s=10, alpha=0.7, label=f'LMM (λ={lam_lmm:.2f})')
    ax1.axhline(-np.log10(5e-8), color='red', linestyle='--', label='Genome-wide Significance')
    ax1.set_title('Manhattan Plot: Linear vs LMM')
    ax1.set_ylabel('-log10(P)')
    ax1.legend()

    # Q-Q Plot
    ex_lin, ob_lin = get_qq_coords(df_lin['P'])
    ex_lmm, ob_lmm = get_qq_coords(df_lmm['p'])
    ax2.scatter(ex_lin, ob_lin, c='lightgrey', s=10, label='Linear')
    ax2.scatter(ex_lmm, ob_lmm, c='royalblue', s=10, label='LMM')
    max_val = max(max(ex_lin), max(ex_lmm))
    ax2.plot([0, max_val], [0, max_val], 'k--')
    ax2.set_title('Q-Q Plot: Inflation Control')
    ax2.set_xlabel('Expected -log10(P)')
    ax2.set_ylabel('Observed -log10(P)')
    ax2.legend()

    plt.tight_layout()
    plt.savefig(os.path.join(out_dir, "qq_comparison.png"), dpi=300)
    print(f"Results saved to {out_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--plink", required=True)
    parser.add_argument("--lmm", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    run_analysis(args.plink, args.lmm, args.out)