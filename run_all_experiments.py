"""
================================================================================
MICROSOFT Q# & AZURE QUANTUM ONBOARDING: MASTER EXPERIMENT RUNNER
Script: run_all_experiments.py
--------------------------------------------------------------------------------
Executes the complete onboarding pipeline:
- Phase 1: Fundamentals (QRNG, Bell Teleportation, Superposition Explorer)
- Phase 2: Grover's Search Algorithm (2-Qubit & 3-Qubit Demos)
- Phase 3: Unit Tests, Monte Carlo Simulation Benchmarks & Chart Generation
================================================================================
"""

import sys
import os
import subprocess

# Ensure UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

def print_header(title):
    print("\n" + "=" * 80)
    print(f"  {title.center(76)}")
    print("=" * 80)

def main():
    print_header("QUANTUM KICKSTART: MICROSOFT Q# & AZURE QUANTUM ONBOARDING")
    
    try:
        import qsharp
    except ImportError:
        print("[!] Error: 'qsharp' is not installed. Run: pip install -r requirements.txt")
        sys.exit(1)
        
    qsharp.init(target_profile=qsharp.TargetProfile.Unrestricted)
    
    # -------------------------------------------------------------------------
    # PHASE 1: FUNDAMENTALS
    # -------------------------------------------------------------------------
    print_header("PHASE 1: QUANTUM FUNDAMENTALS & Q# BASICS")
    phase1_files = [
        ("01_fundamentals/RandomNumberGenerator.qs", "1. Quantum Random Number Generator"),
        ("01_fundamentals/BellStateTeleportation.qs", "2. Quantum Entanglement & Teleportation"),
        ("01_fundamentals/SuperpositionExplorer.qs", "3. Superposition & State Diagnostics")
    ]
    
    for qs_file, name in phase1_files:
        print(f"\n>>> Running {name} ({qs_file})")
        with open(qs_file, "r", encoding="utf-8") as f:
            code = f.read()
        qsharp.eval(code)
        qsharp.eval("Main()")
        print(f"--- Completed: {name} ---")

    # -------------------------------------------------------------------------
    # PHASE 2: GROVER'S SEARCH IMPLEMENTATION
    # -------------------------------------------------------------------------
    print_header("PHASE 2: GROVER'S SEARCH ALGORITHM PROJECT")
    grover_file = "02_grover_search/GroverSearch.qs"
    print(f"\n>>> Running Grover's Search Entry Point ({grover_file})")
    with open(grover_file, "r", encoding="utf-8") as f:
        code = f.read()
    qsharp.eval(code)
    qsharp.eval("Main()")
    print("--- Completed: Grover Search Demos ---")

    # -------------------------------------------------------------------------
    # PHASE 3: TESTS & BENCHMARKS
    # -------------------------------------------------------------------------
    print_header("PHASE 3: AUTOMATED UNIT TESTS & MONTE CARLO SIMULATIONS")
    
    # 1. Run Q# Unit Tests
    print("\n>>> Running Q# Automated Unit Tests:")
    tests_file = "03_testing_and_benchmarks/GroverTests.qs"
    with open(tests_file, "r", encoding="utf-8") as f:
        code = f.read()
    qsharp.eval(code)
    qsharp.eval("Main()")
    
    # 2. Run Monte Carlo Simulation
    print("\n>>> Running 1,000-shot Statistical Simulation Benchmark:")
    subprocess.run([sys.executable, "03_testing_and_benchmarks/run_grover_simulation.py"], check=True)
    
    # 3. Generate Charts
    print("\n>>> Generating Final Visualization Charts:")
    subprocess.run([sys.executable, "03_testing_and_benchmarks/generate_charts.py"], check=True)
    
    print_header("ALL PHASES EXECUTED SUCCESSFULLY (100% COMPLETE)")
    print("Project report available at : 04_documentation/PROJECT_REPORT.md (and .pdf)")
    print("Q# Cheatsheet available at  : 04_documentation/CHEATSHEET_QSHARP.md (and .pdf)")
    print("Visual assets generated at  : 04_documentation/assets/")
    print("=" * 80 + "\n")

if __name__ == "__main__":
    main()
