/// ============================================================================
/// PHASE 2: PROJECT IMPLEMENTATION - GROVER'S SEARCH ALGORITHM
/// Module: StateDiagnostics.qs
/// ----------------------------------------------------------------------------
/// Description:
/// Diagnostic routines for observing the internal quantum state vector at each
/// intermediate stage of Grover's Search Algorithm:
///   1. Initial uniform superposition |s>
///   2. After Phase Oracle (Target phase flipped from +alpha to -alpha)
///   3. After Diffusion Operator (Target amplitude amplified, others suppressed)
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;

/// <summary>
/// Executes a single Grover iteration on 2 qubits while dumping the internal state vector
/// at each stage for pedagogical inspection and design review.
/// Target state: |11>
/// </summary>
operation InspectGroverStepByStep() : Unit {
    Message("=== STEP-BY-STEP GROVER STATE INSPECTION (2 Qubits, Target = |11>) ===");
    
    use register = Qubit[2];
    
    // Step 1: Uniform Superposition
    Message("\n[Stage 1] Initializing Uniform Superposition H^(tensor 2) |00>:");
    Message("All 4 states (|00>, |01>, |10>, |11>) should have equal amplitude: 1/2 = 0.5");
    H(register[0]);
    H(register[1]);
    DumpMachine();
    
    // Step 2: Apply Phase Oracle for |11>
    Message("\n[Stage 2] Applying Phase Oracle for |11> (CZ Gate):");
    Message("Only state |11> should have its phase inverted (amplitude = -0.5):");
    CZ(register[0], register[1]);
    DumpMachine();
    
    // Step 3: Apply Grover Diffusion Operator
    Message("\n[Stage 3] Applying Diffusion Operator (Inversion About the Mean):");
    Message("Mean amplitude is (0.5 + 0.5 + 0.5 - 0.5) / 4 = 0.25");
    Message("New amplitude for |11>: 2*(0.25) - (-0.5) = +1.0 (100% Probability!)");
    Message("New amplitude for other states: 2*(0.25) - (0.5) = 0.0 (0% Probability)");
    
    // Diffusion implementation:
    H(register[0]);
    H(register[1]);
    X(register[0]);
    X(register[1]);
    CZ(register[0], register[1]);
    X(register[0]);
    X(register[1]);
    H(register[0]);
    H(register[1]);
    
    DumpMachine();
    
    // Reset qubits
    ResetAll(register);
    Message("\nState diagnostics completed.");
}

@EntryPoint()
operation Main() : Unit {
    InspectGroverStepByStep();
}
