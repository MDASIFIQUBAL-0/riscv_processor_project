# Design and Functional Verification of a Simplified 32-bit RISC-V Processor Using Verilog HDL

![RISC-V](https://img.shields.io/badge/ISA-RISC--V%20RV32I-blue.svg)
![Language](https://img.shields.io/badge/Language-Verilog--2001-green.svg)
![Simulation](https://img.shields.io/badge/Simulator-Icarus%20Verilog%20%2F%20GTKWave-orange.svg)
![Status](https://img.shields.io/badge/Functional%20Verification-100%25%20Passed-brightgreen.svg)

A modular, synthesizable, fully documented 32-bit single-cycle processor implementing the open-source **RISC-V RV32I** base integer instruction set architecture in Verilog HDL.

Designed specifically for undergraduate Electronics and Communication Engineering (ECE) capstone projects, academic evaluation, VLSI viva examinations, and technical interviews.

---

## 1. Project Highlights

- **Standard-Compliant ISA**: Implements official RISC-V RV32I encodings for R-type, I-type, S-type, and B-type instructions.
- **Pure Single-Cycle Microarchitecture**: Achieves determinism with Cycles Per Instruction ($CPI = 1$).
- **Modular RTL Hierarchy**:
  - `program_counter.v`: 32-bit PC with active-low asynchronous reset.
  - `instruction_memory.v`: Word-aligned 32-bit instruction store loaded via `$readmemh`.
  - `register_file.v`: 32 general-purpose 32-bit registers, dual asynchronous read ports, single synchronous write port, architectural `x0 = 0` hardwired.
  - `immediate_generator.v`: Bit-accurate sign extension for I, S, and B immediate layouts.
  - `alu.v`: 8-operation arithmetic/logic/shift unit (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL) with zero detection.
  - `control_unit.v`: Single-cycle decoder generating glitch-free datapath multiplexing signals.
  - `data_memory.v`: Word-aligned data RAM supporting LW and SW operations.
  - `riscv_processor.v`: Top-level datapath integration.
- **Automated Verification**: Self-checking testbench (`tb_riscv_processor.v`) with automated programmatic assertions.
- **Zero-Installation Option**: Included cycle-accurate reference simulator (`simulate_riscv.ps1`) runs out-of-the-box on Windows PowerShell.
- **Synthesis Ready**: Includes Yosys synthesis script (`synthesis.ys`) with hierarchy check and cell statistics.

---

## 2. Directory Structure

```
riscv_processor_project/
├── rtl/
│   ├── program_counter.v       # 32-bit Program Counter Register
│   ├── instruction_memory.v    # Read-Only Instruction Memory
│   ├── register_file.v         # 32x32 Architectural Register File (x0=0)
│   ├── alu.v                   # 32-bit Arithmetic Logic Unit
│   ├── immediate_generator.v   # Immediate Sign-Extension Engine
│   ├── control_unit.v          # Main & ALU Instruction Decoder
│   ├── data_memory.v           # Word-Aligned Data RAM (LW / SW)
│   └── riscv_processor.v       # Top-Level Processor Integration
├── testbench/
│   └── tb_riscv_processor.v    # Self-Checking Verilog Testbench
├── programs/
│   └── sample_program.mem      # 23-Instruction Machine Code Hex Program
├── simulation/
│   ├── README.md               # Simulation & GTKWave User Guide
│   └── simulate_riscv.ps1      # Cycle-Accurate Windows Reference Simulator
├── synthesis/
│   └── synthesis.ys            # Yosys RTL Synthesis Script
├── docs/
│   ├── project_report.md       # Comprehensive Academic Project Report
│   ├── architecture_explanation.md # Datapath Architecture & Stage Analysis
│   └── viva_questions.md       # 45 Viva Questions (English + Hinglish) + Presentation Pitch
└── README.md                   # Main Project Overview & Execution Guide
```

---

## 3. Supported Instruction Set

| Instruction | Type | Mnemonic Format | Description |
|---|---|---|---|
| `ADD`  | R | `add rd, rs1, rs2` | Add registers |
| `SUB`  | R | `sub rd, rs1, rs2` | Subtract registers |
| `AND`  | R | `and rd, rs1, rs2` | Bitwise logical AND |
| `OR`   | R | `or rd, rs1, rs2`  | Bitwise logical OR |
| `XOR`  | R | `xor rd, rs1, rs2` | Bitwise logical XOR |
| `SLT`  | R | `slt rd, rs1, rs2` | Set Less Than (signed) |
| `SLL`  | R | `sll rd, rs1, rs2` | Shift Left Logical |
| `SRL`  | R | `srl rd, rs1, rs2` | Shift Right Logical |
| `ADDI` | I | `addi rd, rs1, imm`| Add Immediate |
| `LW`   | I | `lw rd, imm(rs1)`  | Load Word from Data Memory |
| `SW`   | S | `sw rs2, imm(rs1)` | Store Word to Data Memory |
| `BEQ`  | B | `beq rs1, rs2, imm`| Branch if Equal |
| `BNE`  | B | `bne rs1, rs2, imm`| Branch if Not Equal |

---

## 4. How to Run the Simulation

### Option 1: Native Windows PowerShell Simulator (Runs Immediately!)
Open PowerShell in the project directory and execute:
```powershell
powershell -ExecutionPolicy Bypass -File simulation\simulate_riscv.ps1
```
This parses the machine code from `sample_program.mem`, simulates every clock cycle, and verifies all 17 hardware checks.

### Option 2: Icarus Verilog & GTKWave
1. Compile the RTL and testbench:
   ```bash
   iverilog -g2012 -o processor_sim rtl/*.v testbench/tb_riscv_processor.v
   ```
2. Run the simulation:
   ```bash
   vvp processor_sim
   ```
3. Open waveform in GTKWave:
   ```bash
   gtkwave processor.vcd
   ```

### Option 3: EDA Playground (Cloud Simulation)
1. Open [EDA Playground](https://www.edaplayground.com).
2. Set simulator to **Icarus Verilog 0.10.0**.
3. Place `tb_riscv_processor.v` in testbench and RTL files in design.
4. Enable **Open EPWave after run** and click **Run**.

---

## 5. Verification Summary

Execution of `programs/sample_program.mem` validates 17 distinct functional checks:

```
==================================================================
   FUNCTIONAL VERIFICATION: REGISTER & MEMORY CHECKS
==================================================================
[PASS] Test 1: ADDI x1, x0, 10           | Register x1  = 10
[PASS] Test 2: ADDI x2, x0, 20           | Register x2  = 20
[PASS] Test 3: ADD  x3, x1, x2           | Register x3  = 30
[PASS] Test 4: SW   x3, 0(x0)            | DataMem[0]   = 30
[PASS] Test 5: LW   x4, 0(x0)            | Register x4  = 30
[PASS] Test 6: SUB  x5, x3, x1           | Register x5  = 20
[PASS] Test 7: AND  x6, x1, x2           | Register x6  = 0
[PASS] Test 8: OR   x7, x1, x2           | Register x7  = 30
[PASS] Test 9: XOR  x8, x1, x2           | Register x8  = 30
[PASS] Test 10: SLT x9, x1, x2           | Register x9  = 1
[PASS] Test 11: SLL x10, x1, x9          | Register x10 = 20
[PASS] Test 12: SRL x11, x10, x9         | Register x11 = 10
[PASS] Test 13: ADDI Negative Imm (-5)   | Register x12 = -5 (0xFFFFFFFB)
[PASS] Test 14: Register x0 is Zero      | Register x0  = 0
[PASS] Test 15: BEQ Taken (Skip Trap)    | Register x13 = 1
[PASS] Test 16: BEQ Not Taken (Fallthru) | Register x14 = 2
[PASS] Test 17: BNE Taken (Skip Trap)    | Register x15 = 3
==================================================================
   >>> STATUS: ALL 17 TEST CASES PASSED SUCCESSFULLY! <<<
==================================================================
```

---

## 6. RTL Synthesis with Yosys

Execute synthesis via Yosys CLI:
```bash
yosys -s synthesis/synthesis.ys
```
The script elaborates hierarchy, extracts state machines and memories, maps logic to standard gates, reports structural statistics, and generates `synthesis/synthesized_netlist.v`.

---

## 7. Resume & Professional Profiles

### Resume Project Entry:
> **32-Bit RISC-V Single-Cycle Processor Design & Functional Verification** | *Verilog HDL, Icarus Verilog, GTKWave, Yosys*
> - Designed a synthesizable 32-bit single-cycle processor implementing the RISC-V RV32I base integer specification.
> - Engineered 8 modular blocks: PC, 32-entry dual-read Register File (hardwired `x0=0`), 8-operation ALU, sign-extending Immediate Generator, Control Unit, and word-aligned memories.
> - Implemented support for R, I, S, and B instruction formats including arithmetic, memory load/store (`LW`/`SW`), and conditional branch control flow (`BEQ`/`BNE`).
> - Developed a self-checking testbench and architectural reference simulator verifying 17 functional test assertions with 100% pass rate.
> - Prepared synthesis scripts for structural netlist generation and gate-level cell analysis using Yosys.

### LinkedIn Post Description:
> 🚀 Excited to share my latest digital VLSI design project: **Design & Functional Verification of a Simplified 32-bit RISC-V Processor using Verilog HDL!**
>
> 💻 **Key Highlights:**
> • Implemented the baseline RISC-V RV32I ISA in synthesizable Verilog-2001.
> • Developed a modular single-cycle microarchitecture incorporating a 32-register architectural file (`x0` hardwired to 0), 8-operation ALU, Immediate Generator, and unified Main & ALU Control Unit.
> • Supported R, I, S, and B instruction formats (arithmetic, logic, shifts, LW/SW memory operations, and BEQ/BNE branches).
> • Functionally verified against 17 automated test checks using self-checking testbenches, GTKWave waveform analysis, and reference simulation.
> • Configured RTL synthesis flows targeting gate-level mapping using Yosys.
>
> Open-source computer architecture is transforming the semiconductor industry, and building this core provided deep insights into datapath timing, instruction encoding, and hardware verification.
>
> #RISCV #VLSI #Verilog #HardwareDesign #ComputerArchitecture #Semiconductors #DigitalDesign #FPGA #ECE
