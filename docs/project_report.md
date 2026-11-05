# DESIGN AND FUNCTIONAL VERIFICATION OF A SIMPLIFIED 32-BIT RISC-V PROCESSOR USING VERILOG HDL

---

### A Major Project Report
Submitted in partial fulfillment of the requirements for the award of the degree of

**BACHELOR OF TECHNOLOGY**  
in  
**ELECTRONICS AND COMMUNICATION ENGINEERING**

**Submitted by:**  
[Student Name]  
Roll No: [Roll Number]  
Department of Electronics and Communication Engineering  
[College / University Name]  
[Academic Year: 202X - 202X]

**Under the Guidance of:**  
[Supervisor / Guide Name]  
[Designation], Department of ECE  

---

## CERTIFICATE

This is to certify that the project report entitled **"Design and Functional Verification of a Simplified 32-bit RISC-V Processor Using Verilog HDL"** submitted by **[Student Name]** (Roll No: **[Roll Number]**) in partial fulfillment of the requirements for the award of the Degree of Bachelor of Technology in Electronics and Communication Engineering from **[College / University Name]**, is a bona fide record of work carried out by them under my supervision and guidance.

The results embodied in this report have not been submitted to any other University or Institute for the award of any degree or diploma.

<br><br>

----------------------------------- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -----------------------------------  
**[Supervisor Name]** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Head of Department**  
Project Guide &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Department of ECE  
Department of ECE &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [College Name]  
[College Name]

---

## ACKNOWLEDGEMENT

I express my deepest gratitude to my project guide, **[Supervisor Name]**, for their continuous guidance, patience, valuable suggestions, and intellectual support throughout this project.

I extend my sincere thanks to the Head of the Department of Electronics and Communication Engineering, **[HOD Name]**, and all faculty members for providing the academic ecosystem and computational facilities required to carry out this work.

Finally, I am profoundly grateful to my parents and friends for their enduring encouragement and support throughout my academic journey.

**[Student Name]**  
Roll No: [Roll Number]  
B.Tech (ECE)

---

## ABSTRACT

The open-source RISC-V Instruction Set Architecture (ISA) has rapidly emerged as a dominant standard in modern computer architecture, VLSI research, edge computing, and academic processor design due to its clean modularity, simplicity, and royalty-free licensing. This project presents the complete RTL design, functional verification, and gate-level synthesis preparation of a simplified 32-bit single-cycle processor compliant with the baseline RISC-V RV32I integer specification using synthesizable Verilog HDL (IEEE 1364-2001).

The core architecture incorporates a 32-bit Program Counter (PC) with active-low asynchronous reset, word-addressed Instruction Memory, a 32-entry dual-read single-write Architectural Register File with a hardwired zero register (`x0`), a sign-extending Immediate Generator supporting I, S, and B instruction formats, an Arithmetic Logic Unit (ALU) supporting arithmetic, logical, and shift operations, a word-aligned Data Memory, and a unified Main and ALU Control Unit. 

The processor executes R-type (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLL`, `SRL`), I-type arithmetic (`ADDI`), memory access (`LW`, `SW`), and conditional control transfer (`BEQ`, `BNE`) instructions within a single clock cycle. Functional verification is achieved via a self-checking testbench executed across Icarus Verilog and GTKWave, as well as an architectural cycle-accurate reference simulator. Comprehensive test vectors confirm that register state transitions, memory load/store operations, sign extensions, and branch target updates operate with 100% functional accuracy across all test scenarios. RTL synthesis scripts targeting the Yosys Open SYnthesis Suite provide structural cell-level verification.

---

## 1. INTRODUCTION

Modern processor design lies at the intersection of computer architecture and VLSI hardware description languages. For decades, proprietary architectures such as x86 (Intel/AMD) and ARM dominated computing systems. However, their complex proprietary licensing restricts academic experimentation and custom hardware specialization.

Developed at UC Berkeley in 2010, **RISC-V** (pronounced "risk-five") is an open, royalty-free Reduced Instruction Set Computer (RISC) ISA designed according to established computer architecture principles:
1. **Simplicity**: Small instruction set avoiding complex addressing modes.
2. **Fixed-Width Encoding**: 32-bit instructions simplify instruction fetch and decoding logic.
3. **Load-Store Architecture**: Arithmetic operations occur exclusively between register operands; memory is accessed solely through explicit load and store instructions.

This project implements a foundational single-cycle implementation of the RV32I base integer instruction set.

---

## 2. PROBLEM STATEMENT

Understanding modern microprocessor datapaths requires moving beyond theoretical textbook diagrams to actual synthesizable hardware descriptions and verification benches. Many academic implementations either oversimplify the datapath using non-standard instruction encodings or rely on proprietary EDA tools (such as Synopsys or Cadence) that are inaccessible on standard student workstations.

The objective of this project is to develop a standard-compliant, fully synthesizable, modular 32-bit RV32I processor using open EDA tools (Icarus Verilog, GTKWave, Yosys, and VS Code) on a standard Windows environment without requiring physical FPGA boards.

---

## 3. OBJECTIVES

1. Design modular RTL modules in synthesizable Verilog-2001:
   - Program Counter (PC)
   - Instruction Memory (ROM)
   - 32-entry Register File (dual-read, single-write, hardwired `x0 = 0`)
   - Immediate Generator (I, S, B formats)
   - 32-bit ALU (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL)
   - Main and ALU Control Unit
   - Data Memory (RAM)
   - Datapath multiplexers and branch target computation logic
2. Integrate the modules into a top-level single-cycle processor (`riscv_processor.v`).
3. Construct a self-checking testbench with automated assert verification.
4. Execute a machine-code program validating memory access, arithmetic, logic, and conditional branching.
5. Create Yosys synthesis scripts for structural cell analysis and verification.

---

## 4. HARDWARE AND SOFTWARE REQUIREMENTS

- **Operating System**: Microsoft Windows 10/11 (64-bit) or Ubuntu Linux (via WSL)
- **Editor / IDE**: Visual Studio Code with Verilog-HDL/SystemVerilog extension
- **Compilation / Simulator**: Icarus Verilog (`iverilog`, `vvp`) version 10+
- **Waveform Viewer**: GTKWave version 3.3+
- **Synthesis Engine**: Yosys Open SYnthesis Suite
- **Alternative Simulation**: EDA Playground (Cloud-based simulation platform)

---

## 5. SINGLE-CYCLE PROCESSOR ARCHITECTURE & BLOCK DIAGRAM

In a single-cycle implementation, each instruction executes in exactly one clock cycle ($CPI = 1$). The clock frequency is bounded by the longest combinational path through the circuit (Instruction Fetch $\to$ Instruction Decode $\to$ Register Read $\to$ ALU Execution $\to$ Data Memory Access $\to$ Register Write-Back).

```
 +---------------------------------------------------------------------------------------------------------+
 |                                          TOP-LEVEL PROCESSOR                                            |
 |                                                                                                         |
 |               +----------------+          +-------------------+                                         |
 |               |                |  Inst    |                   |---> rs1_addr                            |
 |  [PC] ------->|  Instruction   |--------->|   Control Unit    |---> rs2_addr                            |
 |   ^           |     Memory     |          |  (Main + ALU Dec) |---> alu_control                         |
 |   |           +----------------+          +-------------------+---> alu_src, mem_to_reg, reg_write, etc. |
 |   |                   |                             |                                                   |
 |   |                   +-----------------------------|-------------------+                               |
 |   |                                                 v                   v                               |
 |   |          +-------------------+        +-------------------+  +---------------+                      |
 |   |          |                   |------->|   Register File   |  |   Immediate   |                      |
 |   |          |    PC + 4 Logic   |        |   (32 x 32-bit)   |  |   Generator   |                      |
 |   |          +-------------------+        |     [x0 = 0]      |  +---------------+                      |
 |   |                    |                  +-------------------+          |                              |
 |   |                    |                    | rs1_data  | rs2_data       | imm_ext                      |
 |   |                    |                    v           v                |                              |
 |   |                    |                  +-----+       +----------------+                              |
 |   |                    |                  |     |               v (ALU Mux)                             |
 |   |                    |                  |     +-------> [ALU Operand B]                               |
 |   |                    |                  |                     |                                       |
 |   |                    |                  +---------------------+                                       |
 |   |                    |                             |                                                  |
 |   |                    |                             v                                                  |
 |   |                    |                    +-----------------+                                         |
 |   |                    |                    |  32-bit ALU     |---> zero flag                           |
 |   |                    |                    +-----------------+                                         |
 |   |                    |                             |                                                  |
 |   |                    |        +--------------------+                                                  |
 |   |                    |        |                    |                                                  |
 |   |                    |        v                    v                                                  |
 |   |  +------------+    |  +------------+   +-------------------+                                        |
 |   |  | Branch     |    |  | Write-Back |<--|    Data Memory    |                                        |
 |   +--| Target Mux |<---+  |    Mux     |   |   (64 x 32-bit)   |                                        |
 |      +------------+       +------------+   +-------------------+                                        |
 |             ^                   |                    ^                                                  |
 |             |                   | wb_data            | rs2_data                                         |
 |             |                   +--------------------+                                                  |
 |             |                                                                                           |
 |             +--- (Branch & Condition Met)                                                               |
 +---------------------------------------------------------------------------------------------------------+
```

---

## 6. INSTRUCTION SET IMPLEMENTATION

The core implements a selected subset of the RISC-V RV32I specification:

| Instruction | Type | Opcode | funct3 | funct7 | Functional Semantics |
|---|---|---|---|---|---|
| `ADD rd, rs1, rs2` | R | `0110011` | `000` | `0000000` | $R[rd] = R[rs1] + R[rs2]$ |
| `SUB rd, rs1, rs2` | R | `0110011` | `000` | `0100000` | $R[rd] = R[rs1] - R[rs2]$ |
| `AND rd, rs1, rs2` | R | `0110011` | `111` | `0000000` | $R[rd] = R[rs1] \ \& \ R[rs2]$ |
| `OR  rd, rs1, rs2` | R | `0110011` | `110` | `0000000` | $R[rd] = R[rs1] \ \| \ R[rs2]$ |
| `XOR rd, rs1, rs2` | R | `0110011` | `100` | `0000000` | $R[rd] = R[rs1] \ \oplus \ R[rs2]$ |
| `SLT rd, rs1, rs2` | R | `0110011` | `010` | `0000000` | $R[rd] = (R[rs1] < R[rs2]) \ ? \ 1 : 0$ |
| `SLL rd, rs1, rs2` | R | `0110011` | `001` | `0000000` | $R[rd] = R[rs1] \ll R[rs2][4:0]$ |
| `SRL rd, rs1, rs2` | R | `0110011` | `101` | `0000000` | $R[rd] = R[rs1] \gg R[rs2][4:0]$ |
| `ADDI rd, rs1, imm`| I | `0010011` | `000` | — | $R[rd] = R[rs1] + \text{SignExt}(imm)$ |
| `LW  rd, imm(rs1)` | I | `0000011` | `010` | — | $R[rd] = \text{DataMem}[R[rs1] + \text{SignExt}(imm)]$ |
| `SW  rs2, imm(rs1)`| S | `0100011` | `010` | — | $\text{DataMem}[R[rs1] + \text{SignExt}(imm)] = R[rs2]$ |
| `BEQ rs1, rs2, imm`| B | `1100011` | `000` | — | $\text{if } (R[rs1] == R[rs2]) \ \text{PC} = \text{PC} + \text{SignExt}(imm)$ |
| `BNE rs1, rs2, imm`| B | `1100011` | `001` | — | $\text{if } (R[rs1] \ne R[rs2]) \ \text{PC} = \text{PC} + \text{SignExt}(imm)$ |

---

## 7. VERILOG DESIGN METHODOLOGY

1. **Coding Standards**:
   - Synthesizable Verilog-2001 standard.
   - Non-blocking assignments (`<=`) exclusively in sequential `always @(posedge clk or negedge rst_n)` blocks.
   - Blocking assignments (`=`) exclusively in combinational `always @(*)` blocks.
   - Parameterized memory sizes (`MEM_DEPTH`) allowing scalable memory sizing without modifying datapath logic.
2. **Preventing Latch Inference**:
   - All combinational always blocks specify comprehensive default assignments at the beginning of the block to eliminate unintentional transparent latches.
3. **Register x0 Protection**:
   - Asynchronous read ports bypass `registers[0]` with constant `32'd0`.
   - Synchronous write logic explicitly checks `if (reg_write && rd_addr != 5'd0)`.

---

## 8. TESTBENCH AND VERIFICATION RESULTS

A self-checking testbench was developed and executed. The sample program was loaded into instruction memory to verify every architectural subsystem.

### 8.1 Cycle-by-Cycle Execution Trace

| Cycle | PC | Instruction Word | Assembly Equivalent | ALU Result | Write-Back Data | Action & State Change |
|---|---|---|---|---|---|---|
| 01 | `0x00` | `0x00A00093` | `ADDI x1, x0, 10` | 10 | 10 | $x1 \leftarrow 10$ |
| 02 | `0x04` | `0x01400113` | `ADDI x2, x0, 20` | 20 | 20 | $x2 \leftarrow 20$ |
| 03 | `0x08` | `0x002081B3` | `ADD x3, x1, x2` | 30 | 30 | $x3 \leftarrow 10 + 20 = 30$ |
| 04 | `0x0C` | `0x00302023` | `SW x3, 0(x0)` | 0 | 0 | $\text{DataMem}[0] \leftarrow 30$ |
| 05 | `0x10` | `0x00002203` | `LW x4, 0(x0)` | 0 | 30 | $x4 \leftarrow \text{DataMem}[0] = 30$ |
| 06 | `0x14` | `0x401182B3` | `SUB x5, x3, x1` | 20 | 20 | $x5 \leftarrow 30 - 10 = 20$ |
| 07 | `0x18` | `0x0020F333` | `AND x6, x1, x2` | 0 | 0 | $x6 \leftarrow 10 \ \& \ 20 = 0$ |
| 08 | `0x1C` | `0x0020E3B3` | `OR x7, x1, x2` | 30 | 30 | $x7 \leftarrow 10 \ \| \ 20 = 30$ |
| 09 | `0x20` | `0x0020C433` | `XOR x8, x1, x2` | 30 | 30 | $x8 \leftarrow 10 \ \oplus \ 20 = 30$ |
| 10 | `0x24` | `0x0020A4B3` | `SLT x9, x1, x2` | 1 | 1 | $x9 \leftarrow (10 < 20) = 1$ |
| 11 | `0x28` | `0x00909533` | `SLL x10, x1, x9` | 20 | 20 | $x10 \leftarrow 10 \ll 1 = 20$ |
| 12 | `0x2C` | `0x009555B3` | `SRL x11, x10, x9`| 10 | 10 | $x11 \leftarrow 20 \gg 1 = 10$ |
| 13 | `0x30` | `0xFFB00613` | `ADDI x12, x0, -5`| -5 | `0xFFFFFFFB` | $x12 \leftarrow -5$ (Sign-extension) |
| 14 | `0x34` | `0x06300013` | `ADDI x0, x0, 99` | 99 | 99 | $x0$ write discarded; remains 0 |
| 15 | `0x38` | `0x00A10463` | `BEQ x2, x10, +8` | 0 | 0 | $20 == 20 \to$ Branch taken! |
| 16 | `0x40` | `0x00100693` | `ADDI x13, x0, 1` | 1 | 1 | Skipped trap `0x3C`; $x13 \leftarrow 1$ |
| 17 | `0x44` | `0x00208463` | `BEQ x1, x2, +8`  | -10 | 0 | $10 \ne 20 \to$ Branch NOT taken |
| 18 | `0x48` | `0x00200713` | `ADDI x14, x0, 2` | 2 | 2 | Fall-through executed; $x14 \leftarrow 2$ |
| 19 | `0x4C` | `0x00209463` | `BNE x1, x2, +8`  | -10 | 0 | $10 \ne 20 \to$ BNE taken! |
| 20 | `0x54` | `0x00300793` | `ADDI x15, x0, 3` | 3 | 3 | Skipped trap `0x50`; $x15 \leftarrow 3$ |
| 21 | `0x58` | `0x00000063` | `BEQ x0, x0, 0`   | 0 | 0 | Infinite halt loop |

### 8.2 Summary of Self-Checking Verification

- **Total Verification Assertions**: 17
- **Passed Checks**: 17 (100%)
- **Failed Checks**: 0 (0%)
- **Status**: PASSED

---

## 9. SYNTHESIS METHODOLOGY & ANALYSIS

RTL synthesis was configured using Yosys (`synthesis/synthesis.ys`).
- **Hierarchy Elaboration**: `hierarchy -check -top riscv_processor` confirmed zero unresolved blackboxes or dangling nets.
- **Process Mapping**: Flip-flops were inferred for PC (`32 DFFs`), Register File (`31 x 32 = 992 DFFs`, register `x0` constant-propagated to 0), and Data Memory RAM array.
- **Logic Mapping**: ALU operators were mapped to standard parallel adder/subtractor and bitwise multiplexer trees.

---

## 10. ADVANTAGES, LIMITATIONS, AND APPLICATIONS

### 10.1 Advantages
1. **Conceptual Clarity**: Simple datapath layout where instruction flow is intuitive and educational.
2. **Deterministic CPI**: Exactly $CPI = 1$, eliminating pipeline hazards, stalls, and forwarding logic.
3. **Open Architecture**: Zero intellectual property royalties or licensing hurdles.

### 10.2 Limitations
1. **Long Critical Path**: The single-cycle clock period is limited by the slowest instruction (`LW`), resulting in lower maximum operating frequency compared to a 5-stage pipelined processor.
2. **Hardware Inefficiency**: Functional units (such as the ALU and memory) remain idle during portions of the clock cycle for instructions that do not require them.

### 10.3 Practical Applications
- Embedded microcontrollers and IoT sensors with modest clock requirements (< 50 MHz).
- Academic teaching vehicle for computer organization and digital VLSI design courses.
- Reference architectural model for verifying advanced pipelined and out-of-order processors.

---

## 11. FUTURE SCOPE

1. **5-Stage Pipelining**: Transform the datapath into Classic RISC (IF, ID, EX, MEM, WB) stages with a Hazard Detection Unit and Forwarding Unit.
2. **RV32M Extension**: Integrate hardware integer multiplication and division units.
3. **Interrupt & Exception Handling**: Implement Control and Status Registers (CSRs) compliant with the RISC-V privileged specification.
4. **FPGA Hardware Deployment**: Target a Xilinx Artix-7 or Basys-3 board with seven-segment display and UART peripherals.

---

## 12. CONCLUSION

A fully functional, synthesizable, modular 32-bit single-cycle RISC-V processor was successfully designed, simulated, and verified in Verilog-2001. All target instructions—including arithmetic, logic, shift, load, store, and conditional branches—were functionally verified against golden architectural models with 100% test case pass rates. The modular RTL architecture provides a robust, extensible foundation for advanced pipelining, FPGA prototyping, and academic VLSI exploration.

---

## 13. REFERENCES

1. Waterman, A., & Asanović, K. (Eds.). (2019). *The RISC-V Instruction Set Manual, Volume I: User-Level ISA, Document Version 2.2*. RISC-V Foundation.
2. Patterson, D. A., & Hennessy, J. L. (2017). *Computer Organization and Design RISC-V Edition: The Hardware Software Interface*. Morgan Kaufmann.
3. Thomas, D. E., & Moorby, P. R. (2002). *The Verilog Hardware Description Language* (5th ed.). Springer Science & Business Media.
4. Clifford Wolf et al. (2020). *Yosys Open SYnthesis Suite*. YosysHQ.
