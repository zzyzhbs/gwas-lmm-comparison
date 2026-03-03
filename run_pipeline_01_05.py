#!/usr/bin/env python3
import subprocess
import sys
import os
from datetime import datetime
from textwrap import dedent

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))


def timestamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(msg: str) -> None:
    print(f"[{timestamp()}] {msg}")


def section(title: str) -> None:
    print()
    print("=" * 60)
    print(title)
    print("=" * 60)


def wait_for_enter(prompt: str = "Press Enter to continue, or Ctrl+C to abort...") -> None:
    try:
        input(prompt + "\n")
    except KeyboardInterrupt:
        print("\nAborted by user.")
        sys.exit(1)


def run_shell_script(script_rel_path: str, description: str) -> None:
    """
    Run a shell script with:
      - Pre-step explanation + Enter to continue
      - Retry loop if it fails
    """
    script_path = os.path.join(PROJECT_ROOT, script_rel_path)

    if not os.path.isfile(script_path):
        print(f"[ERROR] Script not found: {script_path}")
        sys.exit(1)

    # Make sure script is executable
    if not os.access(script_path, os.X_OK):
        log(f"Making script executable: {script_path}")
        try:
            os.chmod(script_path, os.stat(script_path).st_mode | 0o111)
        except Exception as e:
            print(f"[ERROR] Failed to make script executable: {e}")
            sys.exit(1)

    while True:
        section(f"[STEP] {description}")

        # Explain what this step will do
        print(f"This step will run: {script_rel_path}")
        print()
        # You can customize per-step explanations here if needed.
        wait_for_enter("Press Enter to run this step, or Ctrl+C to abort...")

        log(f"Starting step: {description}")
        log(f"Running script: {script_path}")
        print()

        try:
            # Run the script, stream stdout/stderr directly
            subprocess.run(
                [script_path],
                cwd=PROJECT_ROOT,
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print()
            print("=" * 60)
            print("[ERROR] This step failed.")
            print(f"Step     : {description}")
            print(f"Script   : {script_path}")
            print(f"Exit code: {e.returncode}")
            print("=" * 60)
            print("Please check the error messages above, fix the issue,")
            print("and then choose one of the following options:")
            print("  - Press Enter to retry this step.")
            print("  - Type 's' and press Enter to skip this step and continue.")
            print()

            try:
                choice = input("[ACTION] Retry or skip? (Enter = retry, 's' + Enter = skip): ").strip().lower()
            except KeyboardInterrupt:
                print("\nAborted by user.")
                sys.exit(1)

            if choice == "s":
                log(f"User chose to SKIP step: {description}")
                return
            else:
                log(f"Retrying step: {description}")
                continue
        else:
            print()
            log(f"[OK] Step completed successfully: {description}")
            return


def check_basic_tools() -> None:
    """Check PLINK, Python, and optionally GCTA before running steps."""
    section("[CHECK] Environment and tools")

    # Check PLINK
    try:
        result = subprocess.run(
            ["plink", "--version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            raise FileNotFoundError
        log("[OK] PLINK is available.")
        print(result.stdout.strip())
    except FileNotFoundError:
        print("[ERROR] 'plink' not found in PATH.")
        print("        Please install PLINK >= 1.9 and ensure it is on your PATH.")
        sys.exit(1)

    # Check Python
    log("[INFO] Checking Python...")
    log(f"[OK] Using Python: {sys.executable}")

    # Check GCTA (optional)
    gcta_bin = os.environ.get("GCTA_BIN")
    if gcta_bin:
        log(f"[INFO] GCTA_BIN is set: {gcta_bin}")
        if not (os.path.isfile(gcta_bin) and os.access(gcta_bin, os.X_OK)):
            print(f"[ERROR] GCTA_BIN is set but not executable: {gcta_bin}")
            sys.exit(1)
    else:
        # Try to find gcta64 in PATH (non-fatal if missing; step 05 will error)
        try:
            result = subprocess.run(
                ["which", "gcta64"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False,
            )
            if result.returncode == 0 and result.stdout.strip():
                log(f"[INFO] Found gcta64 in PATH: {result.stdout.strip()}")
            else:
                print("[WARN] GCTA not detected (neither GCTA_BIN nor gcta64 in PATH).")
                print("       Step 05 (LMM with GCTA) will fail unless you configure GCTA.")
                print("       You can set it later via:")
                print("         export GCTA_BIN=/path/to/gcta64")
        except Exception:
            # Not critical; just warn.
            print("[WARN] Could not check gcta64 presence automatically.")

    # Check basic directories
    for d in ("scripts", "data"):
        path = os.path.join(PROJECT_ROOT, d)
        if not os.path.isdir(path):
            print(f"[ERROR] Required directory '{d}/' not found under project root: {PROJECT_ROOT}")
            sys.exit(1)

    log("[OK] Basic environment checks passed.")


def main():
    section("GWAS Pipeline Runner (Steps 01–05)")

    print(dedent(
        """
        This Python driver will run the GWAS pipeline in five steps:

          01) Prepare data (download 1000G chr22, extract CHB, convert to PLINK)
          02) Basic QC with PLINK
          03) Make/simulate quantitative phenotype
          04) PLINK linear regression GWAS
          05) GCTA LMM (MLMA) GWAS

        Before each step:
          - You will see a short description.
          - You must press Enter to proceed.

        If a step fails:
          - The error message will be shown.
          - You can press Enter to retry, or type 's' + Enter to skip.
        """
    ).strip())
    print()

    wait_for_enter("Press Enter to start environment checks, or Ctrl+C to abort...")

    check_basic_tools()

    # Step 01
    run_shell_script(
        "scripts/01_prepare_data.sh",
        "Step 01 – Prepare data (download + CHB extraction + PLINK conversion)",
    )

    # Step 02
    run_shell_script(
        "scripts/02_qc.sh",
        "Step 02 – Basic QC with PLINK",
    )

    # Step 03
    run_shell_script(
        "scripts/03_make_phenotype.sh",
        "Step 03 – Make/simulate quantitative phenotype",
    )

    # Step 04
    run_shell_script(
        "scripts/04_run_plink_linear.sh",
        "Step 04 – PLINK linear regression GWAS",
    )

    # Step 05
    run_shell_script(
        "scripts/05_run_lmm.sh",
        "Step 05 – GCTA LMM (MLMA) GWAS",
    )

    section("[SUMMARY] All requested steps processed")

    print("[INFO] The pipeline driver has finished running all steps (01–05).")
    print()
    print("If all steps above were marked as [OK], you should now have:")
    print("  - PLINK linear GWAS results at:")
    print("      results/chr22_CHB_plink_linear.assoc.linear")
    print("  - GCTA LMM GWAS results at:")
    print("      results/chr22_CHB_gcta_lmm.mlma")
    print()
    print("These files can be used for:")
    print("  - B: Manhattan and QQ plots (linear vs LMM).")
    print("  - C: Statistical comparison between linear and LMM GWAS.")
    print()
    print("End of pipeline driver.")
    print("=" * 60)


if __name__ == "__main__":
    main()
