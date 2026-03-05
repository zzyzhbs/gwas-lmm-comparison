# Presentation Slides Outline (5-6 Slides)

## Slide 1: Title & Team
- Title: GWAS Comparison - Linear Model vs Linear Mixed Model (LMM)
- Team Members: Shengqi Yuan, Yumeng Guo, Hongshuo Xie
- Tool Goal: Briefly introduce the automated pipeline we built.

## Slide 2: Introduction & Objective
- Applicable Problems: The challenge of confounding factors (population structure, cryptic relatedness) in GWAS.
- Objective: Compare standard linear regression (PLINK) with LMM (GCTA) to see which better prevents false positives.

## Slide 3: Methods (Data & Implementation)
- Dataset: 1000 Genomes Phase 3 (CHB, Chr 22).
- Implementation: How we simulated the phenotype (simulate_phenotype.py) under an additive model.
- Tools & Parameters:
  - PLINK (Baseline): Mention specific QC parameters (e.g., MAF, missingness) and linear regression.
  - GCTA (Advanced): Mention GRM creation and MLMA.

## Slide 4: Results (Benchmark & Visualizations)
- Genomic Inflation: lambda_GC of PLINK (1.0125) vs GCTA (1.0004).
- Visuals: Insert the Q-Q plot and Manhattan plot here.
- Analysis: Explain how LMM effectively adhered to the null distribution and reduced false positives.

## Slide 5: Discussion (Challenges & Future)
- Challenges: Pipeline automation, formatting data between different software.
- Future Directions: Testing on larger datasets or using newer tools.

## Slide 6: Code & References
- Code Availability: Link to our GitHub repository.
- References: PLINK, GCTA, and 1000 Genomes Project citations.