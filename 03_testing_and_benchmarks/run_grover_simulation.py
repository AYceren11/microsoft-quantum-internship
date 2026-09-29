"""
================================================================================
PHASE 3: STATISTICAL SIMULATION & MONTE CARLO BENCHMARK RUNNER
Module: run_grover_simulation.py
--------------------------------------------------------------------------------
Performs systematic statistical analysis of Grover's Search Algorithm:
- 1,000 Monte Carlo simulation shots per configuration (Native Q# batch runner)
- Measures empirical probability distributions
- Compares against exact theoretical quantum probabilities
- Computes 95% Confidence Intervals (Wilson score interval)
- Demonstrates optimal vs non-optimal iteration counts (over-rotation effect)
================================================================================
"""

import sys
import math
import json
from collections import Counter
from tabulate import tabulate

# Ensure UTF-8 output on Windows consoles
sys.stdout.reconfigure(encoding='utf-8')

try:
    import qsharp
except ImportError:
    print("Error: 'qsharp' package not found. Install via 'pip install qsharp'.")
    sys.exit(1)

# Initialize Q# interpreter
qsharp.init(target_profile=qsharp.TargetProfile.Unrestricted)

# Load Q# Grover Implementation with high-performance batch simulator
QSHARP_CODE = """
import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;
import Microsoft.Quantum.Math.*;

operation ApplyBitstringPhaseOracle(targetBits : Bool[], register : Qubit[]) : Unit is Adj + Ctl {
    let n = Length(register);
    for i in 0 .. n - 1 {
        if not targetBits[i] {
            X(register[i]);
        }
    }
    if n == 1 {
        Z(register[0]);
    } elif n == 2 {
        CZ(register[0], register[1]);
    } elif n == 3 {
        Controlled Z([register[0], register[1]], register[2]);
    } else {
        Controlled Z(register[0 .. n - 2], register[n - 1]);
    }
    for i in 0 .. n - 1 {
        if not targetBits[i] {
            X(register[i]);
        }
    }
}

operation ApplyGroverDiffusion(register : Qubit[]) : Unit is Adj + Ctl {
    let n = Length(register);
    for q in register {
        H(q);
    }
    for q in register {
        X(q);
    }
    if n == 1 {
        Z(register[0]);
    } elif n == 2 {
        CZ(register[0], register[1]);
    } elif n == 3 {
        Controlled Z([register[0], register[1]], register[2]);
    } else {
        Controlled Z(register[0 .. n - 2], register[n - 1]);
    }
    for q in register {
        X(q);
    }
    for q in register {
        H(q);
    }
}

operation RunGroverBatch(targetBits : Bool[], numIterations : Int, shots : Int) : Int[] {
    let numQubits = Length(targetBits);
    mutable outcomes = [];
    
    for _ in 1 .. shots {
        use register = Qubit[numQubits];
        for q in register {
            H(q);
        }
        for _ in 1 .. numIterations {
            ApplyBitstringPhaseOracle(targetBits, register);
            ApplyGroverDiffusion(register);
        }
        mutable intVal = 0;
        for i in 0 .. numQubits - 1 {
            let res = M(register[i]);
            if res == One {
                set intVal = intVal + (1 <<< i);
            }
        }
        ResetAll(register);
        set outcomes += [intVal];
    }
    return outcomes;
}
"""

qsharp.eval(QSHARP_CODE)

def theoretical_grover_prob(n_qubits: int, num_iterations: int, m_targets: int = 1) -> float:
    """
    Computes exact theoretical success probability of Grover's search:
    theta = arcsin(sqrt(M / N))
    P(success) = sin^2((2*R + 1) * theta)
    """
    N = 2 ** n_qubits
    theta = math.asin(math.sqrt(m_targets / N))
    prob = math.sin((2 * num_iterations + 1) * theta) ** 2
    return prob

def calculate_confidence_interval(k: int, n: int, confidence: float = 0.95):
    """
    Computes Wilson score 95% confidence interval for binomial proportion.
    """
    if n == 0:
        return (0.0, 0.0)
    z = 1.95996  # 95% confidence z-score
    p_hat = k / n
    denominator = 1 + (z**2) / n
    centre_adjusted_probability = p_hat + (z**2) / (2 * n)
    adjusted_standard_deviation = math.sqrt((p_hat * (1 - p_hat) + (z**2) / (4 * n)) / n)
    lower_bound = (centre_adjusted_probability - z * adjusted_standard_deviation) / denominator
    upper_bound = (centre_adjusted_probability + z * adjusted_standard_deviation) / denominator
    return (max(0.0, lower_bound), min(1.0, upper_bound))

def target_bits_to_int(target_bits: list[bool]) -> int:
    val = 0
    for idx, b in enumerate(target_bits):
        if b:
            val += (1 << idx)
    return val

def int_to_bitstring(val: int, n_qubits: int) -> str:
    res = []
    for i in range(n_qubits):
        res.append("1" if (val & (1 << i)) else "0")
    return "".join(res)

def run_experiment_batch(target_bits: list[bool], num_iterations: int, total_shots: int = 1000):
    """
    Executes a batch of total_shots for a given target and iteration count in a single native Q# call.
    """
    n_qubits = len(target_bits)
    target_int = target_bits_to_int(target_bits)
    target_str = int_to_bitstring(target_int, n_qubits)
    target_qsharp_arg = "[" + ", ".join("true" if b else "false" for b in target_bits) + "]"
    
    qsharp_call = f"RunGroverBatch({target_qsharp_arg}, {num_iterations}, {total_shots})"
    raw_outcomes = qsharp.eval(qsharp_call)
    
    measured_counts = Counter(raw_outcomes)
    success_count = measured_counts.get(target_int, 0)
    empirical_prob = success_count / total_shots
    theo_prob = theoretical_grover_prob(n_qubits, num_iterations)
    ci_lower, ci_upper = calculate_confidence_interval(success_count, total_shots)
    
    # Format distribution as bitstring keys
    distribution_str = {int_to_bitstring(k, n_qubits): v for k, v in measured_counts.items()}
    
    return {
        "n_qubits": n_qubits,
        "database_size": 2 ** n_qubits,
        "target_str": target_str,
        "target_int": target_int,
        "iterations": num_iterations,
        "total_shots": total_shots,
        "success_count": success_count,
        "empirical_prob": empirical_prob,
        "theoretical_prob": theo_prob,
        "ci_95": (ci_lower, ci_upper),
        "distribution": distribution_str
    }

def main():
    print("=" * 80)
    print("      MICROSOFT Q# ONBOARDING: GROVER'S ALGORITHM STATISTICAL BENCHMARK")
    print("=" * 80)
    print("Executing 1,000 Monte Carlo simulator trials per configuration...\n")
    
    benchmark_configs = [
        # 2-Qubit Configurations (N = 4)
        {"target": [True, True], "iters": 1, "desc": "2-Qubit Target |11> (Optimal: R=1)"},
        {"target": [False, True], "iters": 1, "desc": "2-Qubit Target |01> (Optimal: R=1)"},
        {"target": [True, False], "iters": 1, "desc": "2-Qubit Target |10> (Optimal: R=1)"},
        {"target": [False, False], "iters": 1, "desc": "2-Qubit Target |00> (Optimal: R=1)"},
        
        # 2-Qubit Over-rotation Test (R=2 on N=4 causes destructive interference!)
        {"target": [True, True], "iters": 2, "desc": "2-Qubit Target |11> (Over-rotated: R=2)"},
        
        # 3-Qubit Configurations (N = 8)
        {"target": [True, False, True], "iters": 2, "desc": "3-Qubit Target |101> (Optimal: R=2)"},
        {"target": [True, True, True], "iters": 2, "desc": "3-Qubit Target |111> (Optimal: R=2)"},
        {"target": [True, False, True], "iters": 1, "desc": "3-Qubit Target |101> (Sub-optimal: R=1)"},
        {"target": [True, False, True], "iters": 3, "desc": "3-Qubit Target |101> (Over-rotated: R=3)"},
    ]
    
    results = []
    table_rows = []
    
    for cfg in benchmark_configs:
        print(f"Running benchmark: {cfg['desc']} ...")
        res = run_experiment_batch(cfg["target"], cfg["iters"], total_shots=1000)
        res["description"] = cfg["desc"]
        results.append(res)
        
        ci_str = f"[{res['ci_95'][0]:.3f}, {res['ci_95'][1]:.3f}]"
        table_rows.append([
            cfg["desc"],
            f"|{res['target_str']}>",
            res["iterations"],
            f"{res['success_count']}/1000",
            f"{res['empirical_prob'] * 100:.2f}%",
            f"{res['theoretical_prob'] * 100:.2f}%",
            f"{abs(res['empirical_prob'] - res['theoretical_prob']) * 100:.2f}%",
            ci_str
        ])
    
    headers = [
        "Experiment Configuration",
        "Target",
        "Iters (R)",
        "Hits",
        "Empirical P",
        "Theory P",
        "Error",
        "95% CI"
    ]
    
    print("\n" + "=" * 80)
    print("                     STATISTICAL BENCHMARK RESULTS TABLE")
    print("=" * 80)
    print(tabulate(table_rows, headers=headers, tablefmt="fancy_grid"))
    
    # Save results to JSON file for charting and reporting
    json_path = "03_testing_and_benchmarks/simulation_results.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"\n[+] Raw simulation metrics successfully saved to: {json_path}")
    print("=" * 80)

if __name__ == "__main__":
    main()
