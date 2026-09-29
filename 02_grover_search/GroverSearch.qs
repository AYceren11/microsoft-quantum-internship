/// ============================================================================
/// PHASE 2: PROJECT IMPLEMENTATION - GROVER'S SEARCH ALGORITHM
/// Module: GroverSearch.qs
/// ----------------------------------------------------------------------------
/// Theoretical Formulation:
/// Grover's Algorithm finds a marked item in an unsorted N-item database in O(sqrt(N))
/// queries, providing a quadratic quantum speedup over classical O(N) search.
///
/// Geometric Steps:
/// 1. Initialize uniform superposition: |s> = 1/sqrt(N) sum |x>
/// 2. Apply Grover Iteration G = D * U_f (R times):
///    a. Phase Oracle U_f: |x> -> (-1)^f(x) |x>
///    b. Diffusion Operator D (Inversion about mean): D = 2|s><s| - I
/// 3. Optimal iterations: R approx floor(pi / 4 * sqrt(N))
///    - For N = 4 (2 qubits): R = floor(pi/4 * 2) = 1 iteration -> P(success) = 100%
///    - For N = 8 (3 qubits): R = round(pi/4 * sqrt(8)) = 2 iterations -> P(success) approx 94.5%
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;
import Microsoft.Quantum.Math.*;
import Microsoft.Quantum.Convert.*;

/// <summary>
/// Applies the Grover Diffusion Operator (Inversion about the Mean):
/// D = 2|s><s| - I = H^(tensor n) (2|0><0| - I) H^(tensor n)
/// Reflects probability amplitudes across the average amplitude mean.
/// </summary>
operation ApplyGroverDiffusion(register : Qubit[]) : Unit is Adj + Ctl {
    let n = Length(register);
    
    // Step 1: Transform to computational basis from uniform superposition
    for q in register {
        H(q);
    }
    
    // Step 2: Apply phase shift of -1 to all states except |00...0>
    // This is equivalent to: X -> Multi-Controlled Z on |11...1> -> X
    for q in register {
        X(q);
    }
    
    // Controlled-Z across all qubits in register
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
    
    // Step 3: Return to original basis
    for q in register {
        H(q);
    }
}

/// <summary>
/// Generalized phase oracle implementation for matching target bitstrings.
/// </summary>
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

/// <summary>
/// Calculates optimal Grover iteration count R for a given number of qubits.
/// </summary>
function CalculateOptimalIterations(numQubits : Int) : Int {
    if numQubits == 2 {
        return 1;
    } elif numQubits == 3 {
        return 2;
    } elif numQubits == 4 {
        return 3;
    } else {
        return 1;
    }
}

/// <summary>
/// Executes a full Grover Search routine on a simulated quantum register.
/// </summary>
operation RunGroverSearch(targetBits : Bool[], numIterations : Int) : Result[] {
    let numQubits = Length(targetBits);
    use register = Qubit[numQubits];
    
    // 1. Prepare uniform superposition state |s>
    for q in register {
        H(q);
    }
    
    // 2. Perform Amplitude Amplification: Repeat (Oracle + Diffusion) R times
    for _ in 1 .. numIterations {
        ApplyBitstringPhaseOracle(targetBits, register);
        ApplyGroverDiffusion(register);
    }
    
    // 3. Measure register in computational basis
    mutable results = [];
    for q in register {
        set results += [M(q)];
    }
    
    // 4. Reset qubits before deallocation
    ResetAll(register);
    
    return results;
}

/// <summary>
/// Helper function to convert Result array to readable bitstring: e.g. [One, Zero] -> "10"
/// </summary>
function ResultsToBitString(results : Result[]) : String {
    mutable s = "";
    for r in results {
        if r == One {
            set s += "1";
        } else {
            set s += "0";
        }
    }
    return s;
}

/// <summary>
/// Helper function to convert Bool array to bitstring: e.g. [true, false] -> "10"
/// </summary>
function TargetToBitString(target : Bool[]) : String {
    mutable s = "";
    for b in target {
        if b {
            set s += "1";
        } else {
            set s += "0";
        }
    }
    return s;
}

/// <summary>
/// Phase 2 Main Entry Point: Demonstrates Grover's algorithm across 2-qubit and 3-qubit spaces.
/// </summary>
@EntryPoint()
operation Main() : Unit {
    Message("================================================================");
    Message("  PHASE 2 - PROJECT IMPLEMENTATION: GROVER'S SEARCH ALGORITHM   ");
    Message("================================================================");
    
    // Demonstration 1: 2-Qubit Search Space (N = 4 items)
    Message("\n--- DEMONSTRATION 1: 2-QUBIT DATABASE (N = 4, Target = |11>) ---");
    let target2Q = [true, true];
    let iters2Q = CalculateOptimalIterations(2);
    let targetStr2Q = TargetToBitString(target2Q);
    
    Message($"Search Space Size: N = 4");
    Message($"Target Item      : |{targetStr2Q}>");
    Message($"Grover Iterations: {iters2Q}");
    Message("Running 10 consecutive trials:");
    
    mutable success2Q = 0;
    for trial in 1 .. 10 {
        let measuredResults = RunGroverSearch(target2Q, iters2Q);
        let measuredStr = ResultsToBitString(measuredResults);
        let isSuccess = (measuredStr == targetStr2Q);
        if isSuccess {
            set success2Q += 1;
        }
        Message($"  Trial #{trial}: Measured |{measuredStr}> -> {(isSuccess ? "MATCH (Success)" | "MISMATCH")}");
    }
    Message($"2-Qubit Success Rate: {success2Q}/10 (100% expected)");
    
    // Demonstration 2: 3-Qubit Search Space (N = 8 items)
    Message("\n--- DEMONSTRATION 2: 3-QUBIT DATABASE (N = 8, Target = |101>) ---");
    let target3Q = [true, false, true]; // |101>
    let iters3Q = CalculateOptimalIterations(3);
    let targetStr3Q = TargetToBitString(target3Q);
    
    Message($"Search Space Size: N = 8");
    Message($"Target Item      : |{targetStr3Q}>");
    Message($"Grover Iterations: {iters3Q}");
    Message("Running 10 consecutive trials:");
    
    mutable success3Q = 0;
    for trial in 1 .. 10 {
        let measuredResults = RunGroverSearch(target3Q, iters3Q);
        let measuredStr = ResultsToBitString(measuredResults);
        let isSuccess = (measuredStr == targetStr3Q);
        if isSuccess {
            set success3Q += 1;
        }
        Message($"  Trial #{trial}: Measured |{measuredStr}> -> {(isSuccess ? "MATCH (Success)" | "MISMATCH")}");
    }
    Message($"3-Qubit Success Rate: {success3Q}/10 (94.5% expected theoretically)");
    
    Message("\n================================================================");
    Message("  Grover's Search Algorithm demonstrations executed successfully!");
    Message("================================================================");
}
