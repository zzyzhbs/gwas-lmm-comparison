# Python environment for GWAS project

We recommend using conda to create a lightweight environment for analysis scripts
(lambda_GC computation, QQ plots, Manhattan plots).

## Create the environment

```bash
conda create -n gwas_env python=3.11 -y
conda activate gwas_env
pip install -r env/requirements.txt
```

###Notes

- This Python environment is only needed for analysis scripts under analysis/.
- Core GWAS tools (PLINK, GCTA, GEMMA) are standalone binaries in bin/ and do not depend on this Python environment.
- On shared servers (e.g. university clusters), you can reuse an existing Python installation as long as you install the packages listed in env/requirements.txt. 

