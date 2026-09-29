/// ============================================================================
/// PHASE 2: PROJECT IMPLEMENTATION - GROVER'S SEARCH ALGORITHM
/// Module: OracleDefinitions.qs
/// ----------------------------------------------------------------------------
/// Description:
/// In Grover's search algorithm, the quantum oracle f(x) marks target solutions
/// by flipping their phase in Hilbert space:
///     U_f |x> = (-1)^(f(x)) |x>
/// For marked target states (where f(x) = 1), amplitude becomes -alpha.
/// For non-target states (where f(x) = 0), amplitude remains +alpha.
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;
import Microsoft.Quantum.Convert.*;

/// <summary>
/// Specialized 2-Qubit Oracle marking target state |11> (x = 3).
/// In 2 qubits, state |11> is marked directly with a Controlled-Z (CZ) gate.
/// </summary>
operation ApplyOracle11(register : Qubit[]) : Unit is Adj + Ctl {
    CZ(register[0], register[1]);
}

/// <summary>
/// Specialized 2-Qubit Oracle marking target state |01> (x = 1).
/// Inverts qubit 1 (X), applies CZ, then restores qubit 1 (X).
/// </summary>
operation ApplyOracle01(register : Qubit[]) : Unit is Adj + Ctl {
    X(register[1]);
    CZ(register[0], register[1]);
    X(register[1]);
}

/// <summary>
/// Specialized 2-Qubit Oracle marking target state |10> (x = 2).
/// Inverts qubit 0 (X), applies CZ, then restores qubit 0 (X).
/// </summary>
operation ApplyOracle10(register : Qubit[]) : Unit is Adj + Ctl {
    X(register[0]);
    CZ(register[0], register[1]);
    X(register[0]);
}

/// <summary>
/// Specialized 2-Qubit Oracle marking target state |00> (x = 0).
/// Inverts both qubits (X), applies CZ, then restores both qubits (X).
/// </summary>
operation ApplyOracle00(register : Qubit[]) : Unit is Adj + Ctl {
    X(register[0]);
    X(register[1]);
    CZ(register[0], register[1]);
    X(register[0]);
    X(register[1]);
}

/// <summary>
/// Generalized Phase Oracle for arbitrary n-qubit target bitstrings.
/// Given a target boolean array (e.g. [true, false, true] for |101>),
/// it flips the phase of that basis state: |target> -> -|target>.
/// </summary>
operation ApplyBitstringPhaseOracle(targetBits : Bool[], register : Qubit[]) : Unit is Adj + Ctl {
    let n = Length(register);
    
    // 1. Invert qubits where target bit is false (0)
    // This maps the target state to the all-ones state |11...1>
    for i in 0 .. n - 1 {
        if not targetBits[i] {
            X(register[i]);
        }
    }
    
    // 2. Apply Multi-Controlled Z to flip phase of |11...1>
    if n == 1 {
        Z(register[0]);
    } elif n == 2 {
        CZ(register[0], register[1]);
    } elif n == 3 {
        Controlled Z([register[0], register[1]], register[2]);
    } else {
        Controlled Z(register[0 .. n - 2], register[n - 1]);
    }
    
    // 3. Uncompute initial bit flips
    for i in 0 .. n - 1 {
        if not targetBits[i] {
            X(register[i]);
        }
    }
}
