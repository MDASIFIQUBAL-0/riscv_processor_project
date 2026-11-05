# Architectural Specification & Datapath Analysis
## Simplified 32-Bit Single-Cycle RISC-V Processor (RV32I)

---

## 1. Top-Level Datapath Architecture

The processor implements a **single-cycle architecture** where every instruction completes its fetch, decode, operand read, execution, data memory access, and write-back in exactly **one clock cycle**. The clock period is determined by the propagation delay through the longest combinational path (the **critical path**), which corresponds to the Load Word (`LW`) instruction.

### 1.1 Architecture Block Diagram

```mermaid
flowchart LR
    subgraph IF["Stage 1: Instruction Fetch"]
        PC["Program Counter\n(PC Register)"] -->|addr| IMEM["Instruction Memory\n(addr[31:2])"]
        PC -->|PC| ADD4["Add 4\n(PC + 4)"]
        IMEM -->|instruction[31:0]| INST_SPLIT["Instruction\nBus Splitter"]
    end

    subgraph ID["Stage 2: Instruction Decode & Register Read"]
        INST_SPLIT -->|opcode, funct3, funct7| CTRL["Control Unit\n(Main + ALU Decoder)"]
        INST_SPLIT -->|instruction[31:0]| IMMGEN["Immediate\nGenerator"]
        INST_SPLIT -->|rs1 [19:15]| RF["Register File\n(32 x 32-bit)\nx0 = 0"]
        INST_SPLIT -->|rs2 [24:20]| RF
        INST_SPLIT -->|rd  [11:7]| RF
    end

    subgraph EX["Stage 3: Execute (ALU)"]
        RF -->|rs1_data| ALU_A["ALU Input A"]
        RF -->|rs2_data| MUX_ALU["ALU Src Mux\n(0: rs2, 1: Imm)"]
        IMMGEN -->|imm_ext| MUX_ALU
        CTRL -->|alu_src| MUX_ALU
        ALU_A --> ALU["Arithmetic Logic Unit\n(ALU)"]
        MUX_ALU --> ALU
        CTRL -->|alu_control[3:0]| ALU
        ALU -->|zero| BRANCH_LOGIC["Branch Decision Logic\n(BEQ / BNE)"]
        CTRL -->|branch, branch_bne| BRANCH_LOGIC
        PC -->|PC| ADD_BR["Branch Adder\n(PC + imm_ext)"]
        IMMGEN -->|imm_ext| ADD_BR
    end

    subgraph MEM["Stage 4: Memory Access"]
        ALU -->|alu_result| DMEM["Data Memory\n(RAM 64 x 32)"]
        RF -->|rs2_data| DMEM
        CTRL -->|mem_write| DMEM
        CTRL -->|mem_read| DMEM
    end

    subgraph WB["Stage 5: Write-Back"]
        ALU -->|alu_result| MUX_WB["Write-Back Mux\n(0: ALU, 1: Mem)"]
        DMEM -->|read_data| MUX_WB
        CTRL -->|mem_to_reg| MUX_WB
        MUX_WB -->|wb_data| RF
        CTRL -->|reg_write| RF
    end

    subgraph PC_NEXT_SEL["Next-PC Logic"]
        ADD4 -->|PC + 4| MUX_PC["Next-PC Mux"]
        ADD_BR -->|PC + imm| MUX_PC
        BRANCH_LOGIC -->|pc_src| MUX_PC
        MUX_PC -->|pc_next| PC
    end
```

---

## 2. Six Logical Stages Within a Single Clock Cycle

Even though physically no pipeline registers exist between stages, logical execution progresses sequentially across combinational logic during each clock cycle:

```
[posedge clk] 
   |
   v
1. Instruction Fetch (IF):
   - Program Counter outputs current PC.
   - Instruction Memory reads instruction word at address PC.
   - In parallel, PC + 4 adder computes sequential next address.
   |
   v
2. Instruction Decode (ID):
   - Opcode, funct3, and funct7 are decoded by Control Unit.
   - Immediate Generator sign-extends the constant field based on format (I, S, B).
   |
   v
3. Register Fetch (RF):
   - Addresses rs1 and rs2 access register file asynchronously.
   - Operands rs1_data and rs2_data become valid on the bus.
   |
   v
4. Execute (EX):
   - ALU Mux selects between rs2_data and imm_ext based on `alu_src`.
   - ALU performs arithmetic/logic operation specified by `alu_control`.
   - ALU outputs `result` and asserts `zero` flag if result is zero.
   - Branch target address is computed: `pc_branch = PC + imm_ext`.
   - Branch decision logic evaluates if branch is taken (`pc_src`).
   |
   v
5. Data Memory Access (MEM):
   - If instruction is `SW`, data memory writes `rs2_data` to word address `alu_result[31:2]` on posedge clk.
   - If instruction is `LW`, data memory outputs word from address `alu_result[31:2]`.
   |
   v
6. Write-Back (WB):
   - Multiplexer selects between `alu_result` and `read_data` based on `mem_to_reg`.
   - On the next `posedge clk`, destination register `rd` is updated with `wb_data` if `reg_write` is active and `rd != 0`.
   - In parallel, PC is updated with `pc_next`.
```

---

## 3. Detailed Module Specifications

### 3.1 Program Counter (`program_counter.v`)
- **Function**: Holds the address of the instruction being fetched.
- **Bit Width**: 32 bits.
- **Reset Mechanism**: Asynchronous active-low (`rst_n == 0` forces `pc <= 0x00000000`).
  - *Engineering Justification*: Active-low asynchronous reset ensures immediate, deterministic chip reset upon power glitch or board reset button press without waiting for an active clock edge.

### 3.2 Instruction Memory (`instruction_memory.v`)
- **Function**: Read-only instruction store.
- **Addressing Mechanism**: RV32I uses byte addressing where instructions are 4 bytes wide (32 bits). Therefore, bits `[1:0]` of the PC are always `2'b00`. The internal array `mem[0:MEM_DEPTH-1]` is indexed by `addr[31:2]` (`addr >> 2`).
- **Initialization**: Loaded with compiled machine code hex file at startup using `$readmemh`.

### 3.3 Register File (`register_file.v`)
- **Function**: Contains 32 general-purpose registers (`x0` through `x31`), each 32 bits wide.
- **Ports**:
  - Two asynchronous read ports: `rs1_addr` $\to$ `rs1_data`, `rs2_addr` $\to$ `rs2_data`.
  - One synchronous write port: `rd_addr`, `rd_data`, controlled by `reg_write`.
- **Architectural Requirement (x0)**: Register `x0` is hardwired to zero (`32'h00000000`).
  - Reads from `x0` always yield 0.
  - Writes to `x0` are discarded by hardware (`if (reg_write && rd_addr != 5'd0)`).

### 3.4 Immediate Generator (`immediate_generator.v`)
Extracts and sign-extends the immediate field to 32 bits:
1. **I-Type** (`ADDI`, `LW`):
   $$\text{imm}[11:0] = \text{inst}[31:20]$$
   $$\text{imm\_ext} = \{\{20\{\text{inst}[31]\}\}, \text{inst}[31:20]\}$$
2. **S-Type** (`SW`):
   $$\text{imm}[11:0] = \{\text{inst}[31:25], \text{inst}[11:7]\}$$
   $$\text{imm\_ext} = \{\{20\{\text{inst}[31]\}\}, \text{inst}[31:25], \text{inst}[11:7]\}$$
3. **B-Type** (`BEQ`, `BNE`):
   $$\text{imm}[12:0] = \{\text{inst}[31], \text{inst}[7], \text{inst}[30:25], \text{inst}[11:8], 1'b0\}$$
   $$\text{imm\_ext} = \{\{19\{\text{inst}[31]\}\}, \text{inst}[31], \text{inst}[7], \text{inst}[30:25], \text{inst}[11:8], 1'b0\}$$

### 3.5 Control Unit (`control_unit.v`)
Truth Table for Control Signals:

| Instruction | Opcode | funct3 | funct7 | RegWrite | MemWrite | MemRead | MemtoReg | ALUSrc | Branch | BranchBNE | ALUControl |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **ADD** | `0110011` | `000` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0000 (ADD) |
| **SUB** | `0110011` | `000` | `0100000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0001 (SUB) |
| **AND** | `0110011` | `111` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0010 (AND) |
| **OR**  | `0110011` | `110` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0011 (OR)  |
| **XOR** | `0110011` | `100` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0100 (XOR) |
| **SLT** | `0110011` | `010` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0101 (SLT) |
| **SLL** | `0110011` | `001` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0110 (SLL) |
| **SRL** | `0110011` | `101` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 4'b0111 (SRL) |
| **ADDI**| `0010011` | `000` | Any       | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 4'b0000 (ADD) |
| **LW**  | `0000011` | `010` | Any       | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 4'b0000 (ADD) |
| **SW**  | `0100011` | `010` | Any       | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 4'b0000 (ADD) |
| **BEQ** | `1100011` | `000` | Any       | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 4'b0001 (SUB) |
| **BNE** | `1100011` | `001` | Any       | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 4'b0001 (SUB) |

### 3.6 Arithmetic Logic Unit (`alu.v`)
- Accepts two 32-bit operands `a` and `b`.
- Produces 32-bit `result` and single-bit `zero`.
- SLT uses signed comparison: `($signed(a) < $signed(b)) ? 32'd1 : 32'd0`.
- SLL/SRL uses lower 5 bits of operand B (`b[4:0]`).

### 3.7 Data Memory (`data_memory.v`)
- Synchronous write on positive clock edge when `mem_write` is active.
- Asynchronous combinational read when `mem_read` is active.
- Indexed by `addr[31:2]` (word alignment).

---

## 4. Critical Path Analysis

The critical path determines the maximum clock frequency ($f_{\max} = 1 / T_{\text{clk}}$):

$$T_{\text{clk}} \ge T_{\text{PC\_clk-to-q}} + T_{\text{IMEM\_access}} + T_{\text{RF\_read}} + T_{\text{ALU\_mux}} + T_{\text{ALU}} + T_{\text{DMEM\_access}} + T_{\text{WB\_mux}} + T_{\text{RF\_setup}}$$

In this single-cycle processor, **`LW` (Load Word)** exercises every single component in sequence, representing the worst-case propagation delay.
