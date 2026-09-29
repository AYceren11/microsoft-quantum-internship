/// ============================================================================
/// PHASE 1: QUANTUM FUNDAMENTALS & Q# BASICS
/// Experiment 01: Quantum Random Number Generator (QRNG)
/// ----------------------------------------------------------------------------
/// Concepts Covered:
/// - Qubit Allocation (`use q = Qubit()`)
/// - Quantum Superposition via Hadamard Gate (`H(q)`)
/// - Quantum Measurement (`M(q)`) and Wavefunction Collapse
/// - Safe Qubit Deallocation & Reset (`Reset(q)`)
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Math.*;
import Microsoft.Quantum.Convert.*;

/// <summary>
/// Generates a truly random quantum bit (0 or 1).
/// The qubit starts in |0>, is transformed into (|0> + |1>)/sqrt(2) via Hadamard (H),
/// and upon measurement collapses to 0 or 1 with exactly 50% probability.
/// </summary>
operation GenerateRandomBit() : Result {
    // 1. Allocate a single qubit initialized to |0>
    use q = Qubit();
    
    // 2. Put qubit into equal superposition state |+> = 1/sqrt(2) (|0> + |1>)
    H(q);
    
    // 3. Measure qubit in standard computational (Z) basis
    let measuredBit = M(q);
    
    // 4. In Q#, all allocated qubits must be reset to |0> before being released
    Reset(q);
    
    return measuredBit;
}

/// <summary>
/// Generates an n-bit random integer by querying the quantum simulator for n independent random bits.
/// </summary>
operation GenerateRandomInteger(numBits : Int) : Int {
    mutable accumulator = 0;
    
    for bitIndex in 0 .. numBits - 1 {
        let bit = GenerateRandomBit();
        if bit == One {
            // Shift bit into position: 2^bitIndex
            set accumulator = accumulator + (1 <<< bitIndex);
        }
    }
    
    return accumulator;
}

/// <summary>
/// Entry point for running the QRNG experiment.
/// </summary>
@EntryPoint()
operation Main() : Unit {
    Message("================================================================");
    Message("  PHASE 1 - EXPERIMENT 01: QUANTUM RANDOM NUMBER GENERATOR      ");
    Message("================================================================");
    Message("Demonstrating quantum superposition and non-deterministic collapse:");
    
    // 1. Generate and display 10 individual quantum bits
    Message("--- 10 Single Quantum Bit Measurements ---");
    mutable countZeros = 0;
    mutable countOnes = 0;
    
    for i in 1 .. 10 {
        let bit = GenerateRandomBit();
        if bit == Zero {
            set countZeros = countZeros + 1;
        } else {
            set countOnes = countOnes + 1;
        }
        Message($"  Trial #{i}: Measured outcome = {bit}");
    }
    
    Message($"Results Summary: Zeros = {countZeros}, Ones = {countOnes}");
    
    // 2. Generate multi-bit quantum random integers
    Message("--- Generating Multi-Bit Quantum Integers ---");
    let random8Bit = GenerateRandomInteger(8);
    let random16Bit = GenerateRandomInteger(16);
    
    Message($"  8-Bit Quantum Integer (Range 0-255)   : {random8Bit}");
    Message($"  16-Bit Quantum Integer (Range 0-65535): {random16Bit}");
    Message("================================================================");
}
