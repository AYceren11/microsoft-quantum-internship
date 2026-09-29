# Microsoft Q# & Azure Quantum Quick Cheatsheet

A concise reference guide for modern Microsoft Q# (QDK 1.0+) syntax, quantum gates, data structures, and Azure Quantum CLI commands.

---

## 1. Q# Core Syntax & Declarations

### Functions vs. Operations
- **`function`**: Pure classical computation with no quantum side effects (deterministic, cannot allocate or modify qubits).
- **`operation`**: Quantum computation (can allocate qubits, apply gates, perform measurements).

```qsharp
// Pure Classical Function
function AddNumbers(a : Int, b : Int) : Int {
    return a + b;
}

// Quantum Operation
operation PrepareSuperposition(q : Qubit) : Unit is Adj + Ctl {
    H(q);
}
```

### Qubit Allocation & Release
```qsharp
// Single Qubit
use q = Qubit();
H(q);
let result = M(q);
Reset(q); // MUST reset to |0⟩ before release!

// Multi-Qubit Register
use register = Qubit[4];
for q in register {
    H(q);
}
ResetAll(register);
```

---

## 2. Standard Quantum Gates

| Gate | Q# Code | Matrix Transformation | Description |
| :--- | :--- | :--- | :--- |
| **Pauli X** | `X(q)` | $\begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$ | Bit-flip ($|0\rangle \leftrightarrow |1\rangle$, Quantum NOT) |
| **Pauli Y** | `Y(q)` | $\begin{pmatrix} 0 & -i \\ i & 0 \end{pmatrix}$ | Combined bit-flip & phase-flip |
| **Pauli Z** | `Z(q)` | $\begin{pmatrix} 1 & 0 \\ 0 & -1 \end{pmatrix}$ | Phase-flip ($|1\rangle \to -|1\rangle$) |
| **Hadamard** | `H(q)` | $\frac{1}{\sqrt{2}}\begin{pmatrix} 1 & 1 \\ 1 & -1 \end{pmatrix}$ | Creates equal superposition ($|0\rangle \to |+\rangle$) |
| **CNOT** | `CNOT(c, t)` | $4 \times 4$ Unitary | Flips target $t$ iff control $c = |1\rangle$ |
| **Controlled-Z** | `CZ(c, t)` | $4 \times 4$ Unitary | Applies $Z$ on $t$ iff $c = |1\rangle$ |
| **Multi-Controlled**| `Controlled Z([c1, c2], t)` | Multi-qubit | Applies gate iff all control qubits are $|1\rangle$ |

---

## 3. Measurement & Diagnostics

```qsharp
// Standard Z-basis measurement (returns Result.Zero or Result.One)
let m = M(q);

// Multi-qubit register measurement
mutable results = [];
for q in register {
    set results += [M(q)];
}

// State Vector Diagnostics (Simulator only)
import Microsoft.Quantum.Diagnostics.*;
DumpMachine();
```

---

## 4. Control Flow & Classical Integration

```qsharp
// Immutable binding
let n = 4;

// Mutable variable
mutable counter = 0;
set counter = counter + 1;

// Conditionals
if m == One {
    X(target);
} elif m == Zero {
    Z(target);
} else {
    // default
}

// Loops
for idx in 0 .. n - 1 {
    Message($"Index: {idx}");
}
```

---

## 5. Azure Quantum CLI Quick Reference

```bash
# Connect to Azure Quantum Workspace
az quantum workspace set -g <resource-group> -w <workspace-name> -l <location>

# List available quantum hardware targets (IonQ, Quantinuum, Rigetti)
az quantum target list -o table

# Submit Q# job to Azure Quantum simulator
az quantum job submit --target-id "microsoft.simulator.fullstate"

# Estimate physical resources (Qubits, T-Gates, runtime)
az quantum job submit --target-id "microsoft.estimator"
```
