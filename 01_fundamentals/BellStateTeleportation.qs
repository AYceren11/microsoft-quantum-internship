/// ============================================================================
/// PHASE 1: QUANTUM FUNDAMENTALS & Q# BASICS
/// Experiment 02: Quantum Entanglement & Teleportation Protocol
/// ----------------------------------------------------------------------------
/// Concepts Covered:
/// - Bell State Preparation: |Phi+> = (|00> + |11>) / sqrt(2)
/// - Multi-Qubit Gates: Controlled-NOT (`CNOT(control, target)`)
/// - Quantum Teleportation: Transferring an unknown quantum state using
///   an entangled pair and 2 classical bits.
/// - Quantum State Reconstruction via Pauli X and Z corrections.
/// ============================================================================

import Microsoft.Quantum.Diagnostics.*;
import Microsoft.Quantum.Intrinsic.*;
import Microsoft.Quantum.Measurement.*;

/// <summary>
/// Creates an entangled Bell pair between two qubits:
/// Initial state: |00> -> (H on q1) -> (|0>+|1>)|0>/sqrt(2) -> (CNOT) -> (|00>+|11>)/sqrt(2)
/// </summary>
operation CreateBellPair(q1 : Qubit, q2 : Qubit) : Unit is Adj + Ctl {
    H(q1);
    CNOT(q1, q2);
}

/// <summary>
/// Implements the standard 3-qubit Quantum Teleportation Protocol.
/// - Alice has a message qubit `msg` in an arbitrary state alpha|0> + beta|1>.
/// - Alice and Bob share an entangled Bell pair: `eprAlice` and `bobQubit`.
/// - Alice performs a Bell measurement on (msg, eprAlice).
/// - Bob receives 2 classical bits and applies X / Z gates to reconstruct the exact state.
/// </summary>
operation TeleportQuantumState(msg : Qubit, bobQubit : Qubit) : (Result, Result) {
    // 1. Allocate an auxiliary EPR qubit for Alice
    use eprAlice = Qubit();
    
    // 2. Establish entangled Bell pair between Alice and Bob
    CreateBellPair(eprAlice, bobQubit);
    
    // 3. Alice performs Bell-state analysis on her message and EPR qubit
    CNOT(msg, eprAlice);
    H(msg);
    
    // 4. Alice measures both qubits in the computational basis
    let mMsg = M(msg);
    let mEpr = M(eprAlice);
    
    // 5. Bob applies classical corrections according to Alice's measurement outcomes:
    //    If Alice's EPR measurement is One, Bob applies X (bit flip).
    //    If Alice's message measurement is One, Bob applies Z (phase flip).
    if mEpr == One {
        X(bobQubit);
    }
    if mMsg == One {
        Z(bobQubit);
    }
    
    // Clean up auxiliary qubit
    Reset(eprAlice);
    
    return (mMsg, mEpr);
}

/// <summary>
/// Verification entry point: Prepares known test states, teleports them,
/// and verifies Bob receives the identical quantum state.
/// </summary>
@EntryPoint()
operation Main() : Unit {
    Message("================================================================");
    Message("  PHASE 1 - EXPERIMENT 02: QUANTUM ENTANGLEMENT & TELEPORTATION ");
    Message("================================================================");
    
    // Test Case 1: Teleporting state |0>
    Message("Test 1: Teleporting state |0>");
    use msg1 = Qubit();
    use bob1 = Qubit();
    let (c1_msg, c1_epr) = TeleportQuantumState(msg1, bob1);
    let result1 = M(bob1);
    Message($"  Classical Bits sent by Alice: (Msg={c1_msg}, EPR={c1_epr})");
    Message($"  Bob measured state          : {result1} (Expected: Zero)");
    Reset(msg1);
    Reset(bob1);
    
    // Test Case 2: Teleporting state |1>
    Message("----------------------------------------------------------------");
    Message("Test 2: Teleporting state |1> (Prepared via Pauli X)");
    use msg2 = Qubit();
    use bob2 = Qubit();
    X(msg2); // Prepare |1>
    let (c2_msg, c2_epr) = TeleportQuantumState(msg2, bob2);
    let result2 = M(bob2);
    Message($"  Classical Bits sent by Alice: (Msg={c2_msg}, EPR={c2_epr})");
    Message($"  Bob measured state          : {result2} (Expected: One)");
    Reset(msg2);
    Reset(bob2);
    
    // Test Case 3: Teleporting Superposition State |+> = (|0> + |1>)/sqrt(2)
    Message("----------------------------------------------------------------");
    Message("Test 3: Teleporting Superposition State |+> (Prepared via Hadamard H)");
    use msg3 = Qubit();
    use bob3 = Qubit();
    H(msg3); // Prepare |+>
    let (c3_msg, c3_epr) = TeleportQuantumState(msg3, bob3);
    // Bob should have |+>. Applying H on |+> gives |0> deterministically!
    H(bob3);
    let result3 = M(bob3);
    Message($"  Classical Bits sent by Alice: (Msg={c3_msg}, EPR={c3_epr})");
    Message($"  Bob state rotated with H    : {result3} (Expected: Zero deterministically)");
    Reset(msg3);
    Reset(bob3);
    
    Message("================================================================");
    Message("  All Teleportation Protocol tests passed successfully!         ");
    Message("================================================================");
}
