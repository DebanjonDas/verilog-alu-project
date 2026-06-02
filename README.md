# Parametric N-Bit Arithmetic Logic Unit (ALU)

A highly modular and parametric $N$-bit Arithmetic Logic Unit (ALU) designed and implemented in Verilog HDL. The architecture separates arithmetic operations, logical bitwise operations, shift registries, and comparative circuits into distinct structural submodules, tied together by a top-level multiplexing ALU controller with comprehensive flag generation.

## 🛠️ Architecture & Features

- **Parametric Data Width:** Scalable data paths using Verilog parameters (Default: `WIDTH = 8`).
- **Structural Modularity:** The design avoids monolithic code blocks by isolating distinct execution units into discrete submodules:
  - `adder` & `full_adder`: Ripple Carry Adder implementation.
  - `subtractor`: Handles 2's complement subtraction using the parametric adder module.
  - `increment` & `decrement`: Handled via specialized hardware adder instantiations.
  - `lshift`, `rshift`, & `arshift`: Dedicated logical and arithmetic shifting arrays with lost-bit carry tracking.
  - `equal`, `greater`, & `less`: Combinational magnitude comparators.
- **Status Flags Generation:** Real-time updates for condition codes after every execution cycle:
  - **Carry Flag (`C`)**: Tracks unsigned overflow/borrow or shifted bits.
  - **Zero Flag (`Z`)**: Asserts high if the resulting vector evaluates to zero.
  - **Overflow Flag (`V`)**: Detects signed 2's complement overflow conditions.
  - **Negative Flag (`N`)**: Mirrors the Most Significant Bit (MSB) of the result to track sign state.

---

## 📋 Opcode Mapping Table

The ALU determines execution behavior based on a 4-bit `opcode` input:

| Opcode | Operation | Hardware Module | Status Flags Affected | Description |
| :---: | :--- | :--- | :---: | :--- |
| **`0000`** | ADD | `adder` | `C`, `Z`, `V`, `N` | $A + B$ (Addition) |
| **`0001`** | SUB | `subtractor` | `C`, `Z`, `V`, `N` | $A - B$ via 2's Complement |
| **`0010`** | AND | `and_op` | `Z`, `N` | Bitwise AND (`A & B`) |
| **`0011`** | OR | `or_op` | `Z`, `N` | Bitwise OR ($A \ \| \ B$) |
| **`0100`** | XOR | `xor_op` | `Z`, `N` | Bitwise XOR ($A \ \wedge \ B$) |
| **`0101`** | NOT | `not_op` | `Z`, `N` | Bitwise Inversion ($\sim A$) |
| **`0110`** | LSHIFT | `lshift` | `C`, `Z`, `N` | Logical Left Shift ($A \ll 1$) |
| **`0111`** | RSHIFT | `rshift` | `C`, `Z`, `N` | Logical Right Shift ($A \gg 1$) |
| **`1000`** | ARSHIFT| `arshift` | `C`, `Z`, `N` | Arithmetic Right Shift (Preserves Sign) |
| **`1001`** | INC | `increment` | `C`, `Z`, `V`, `N` | Increment ($A + 1$) |
| **`1010`** | DEC | `decrement` | `C`, `Z`, `V`, `N` | Decrement ($A - 1$) |
| **`1011`** | EQ | `equal` | `Z`, `N` | Equality Comparison ($A == B$) |
| **`1100`** | GT | `greater` | `Z`, `N` | Greater Than Comparison ($A > B$) |
| **`1101`** | LT | `less` | `Z`, `N` | Less Than Comparison ($A < B$) |

---

## 🚀 Simulation and Testing

A comprehensive behavioral testbench (`tb.v`) is provided to validate design integrity across multiple testing vectors, specifically monitoring arithmetic sign limits, zero flags, and overflow boundary scenarios.

### Prerequisites
Ensure you have an HDL simulator installed, such as **Icarus Verilog** (`iverilog`), along with a waveform viewer like **GTKWave**.

### Running the Simulation
Execute the following commands in your terminal interface:

```bash
# Compile the design and testbench together
iverilog -o alu_simulation alu.v tb.v

# Run the simulation runtime to generate output logs and VCD dumps
vvp alu_simulation
# Open GTKWave to view the timing waveforms
gtkwave dump.vcd

---

## 📊 Simulation Results & Waveforms

### 1. GTKWave Timing Diagram
Below is the behavioral simulation waveform capturing the execution of various arithmetic, logical, and shifting sequences. Note how the status flags (`C`, `Z`, `V`, `N`) instantly update based on the operations and operands.

![GTKWave Simulation Waveforms](assets/gtkwave_screenshot.png)

### 2. Testbench Console Log Output
The self-checking testbench validates execution boundaries (including overflow and sign changes) and prints the following diagnostic output to the terminal:

```text
==================================================
        STARTING PARAMETRIC ALU SIMULATION       
==================================================
[TIME: 10ns] OP: ADD    | A: 05 | B: 03 | OUT: 08 | Flags: C=0 Z=0 V=0 N=0 -> PASSED
[TIME: 20ns] OP: SUB    | A: 02 | B: 05 | OUT: FD | Flags: C=0 Z=0 V=0 N=1 -> PASSED
[TIME: 30ns] OP: ADD    | A: 7F | B: 01 | OUT: 80 | Flags: C=0 Z=0 V=1 N=1 -> PASSED (Signed Overflow)
[TIME: 40ns] OP: AND    | A: F0 | B: 0F | OUT: 00 | Flags: C=0 Z=1 V=0 N=0 -> PASSED (Zero Detected)
[TIME: 50ns] OP: LSHIFT | A: 81 | B: 00 | OUT: 02 | Flags: C=1 Z=0 V=0 N=0 -> PASSED (Carry Out Tracked)
==================================================
        SIMULATION COMPLETE: ALL TESTS PASSED     
==================================================
