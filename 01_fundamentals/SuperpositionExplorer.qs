/// ============================================================================
/// PHASE 1: QUANTUM FUNDAMENTALS & Q# BASICS
/// Experiment 03: Multi-Qubit Superposition & State Diagnostics
/// ----------------------------------------------------------------------------
/// Concepts Covered:
/// - Multi-Qubit Register Allocation (`use register = Qubit[n]`)
/// - Tensor Product States & Uniform Superposition: H^(tensor n) |0...0> = 1/sqrt(2^n) sum |x>
/// - Phase Shifts (Z, S, T gates) & Phase Inversions
/// - Simulator Diagnostics with `DumpMachine()` for inspecting amplitudes & phases
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;

@EntryPoint()
operation Main() : Unit {
    Message("================================================================");
    Message("  PHASE 1 - EXPERIMENT 03: SUPERPOSITION & STATE VECTOR EXPLORER ");
    Message("================================================================");
    
    // Allocate a 3-qubit register (2^3 = 8 dimensional Hilbert space)
    use register = Qubit[3];
    
    Message("1. Initial Ground State |000> (Probability = 1.0 at index 0):");
    DumpMachine();
    
    // Transform all qubits to |+> using Hadamard gates
    Message("----------------------------------------------------------------");
    Message("2. Applying Hadamard H^(tensor 3) -> Uniform Superposition of 8 Basis States:");
    for q in register {
        H(q);
    }
    // Each state |000> .. |111> now has amplitude 1/sqrt(8) approx 0.35355 and probability 1/8 = 12.5%
    DumpMachine();
    
    // Apply a phase inversion (Z gate) to the first qubit:
    // Flips phase of any basis state where qubit 0 is |1>
    Message("----------------------------------------------------------------");
    Message("3. Applying Pauli Z gate to Qubit 0 (Phase Inversion):");
    Z(register[0]);
    DumpMachine();
    
    // Clean up register
    ResetAll(register);
    Message("================================================================");
    Message("  Register successfully reset and deallocated.                  ");
    Message("================================================================");
}
