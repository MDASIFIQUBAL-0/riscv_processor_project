# Simulation & Waveform Verification Guide

This guide details how to compile, simulate, and verify the 32-bit RISC-V Single-Cycle Processor using **Icarus Verilog**, **GTKWave**, and **EDA Playground**.

---

## 1. Tool Installation on Windows

### Option A: Direct Windows Native Installer (Recommended for Windows 10/11)
1. Download the Icarus Verilog Windows installer from Bleifuss:
   - Website: [http://bleifuss.com/iverilog/](http://bleifuss.com/iverilog/) or [Icarus Verilog Windows](https://bleyer.org/icarus/)
   - Setup file: `iverilog-v12-20220611-x64_setup.exe` (or latest).
2. During installation:
   - Check the box **"Install GTKWave"**.
   - Check the box **"Add executable folder to system PATH"**.
3. Verify installation in PowerShell:
   ```powershell
   iverilog -v
   vvp -v
   gtkwave --version
   ```

### Option B: Windows Subsystem for Linux (WSL / Ubuntu)
If you prefer a Linux terminal environment inside Windows:
1. Open PowerShell as Administrator and run:
   ```powershell
   wsl --install -d Ubuntu
   ```
2. Inside Ubuntu terminal, install all tools via `apt`:
   ```bash
   sudo apt update
   sudo apt install -y iverilog gtkwave yosys
   ```

---

## 2. Compilation and Simulation with Icarus Verilog

Run these commands from the root project directory (`riscv_processor_project/`):

### Step 1: Compilation
```bash
iverilog -g2012 -o processor_sim rtl/*.v testbench/tb_riscv_processor.v
```
- `-g2012`: Enables modern Verilog / SystemVerilog syntax parsing.
- `-o processor_sim`: Sets the output simulation binary name to `processor_sim`.
- `rtl/*.v`: Compiles all RTL modules.
- `testbench/tb_riscv_processor.v`: Includes the self-checking testbench.

### Step 2: Simulation Execution
```bash
vvp processor_sim
```
- `vvp` is the Icarus Verilog simulation engine.
- It executes the compiled binary, evaluates all testbench asserts, displays cycle-by-cycle logs, and writes out `processor.vcd`.

---

## 3. Waveform Inspection with GTKWave

Open the generated Value Change Dump (VCD) file:
```bash
gtkwave processor.vcd
```

### Essential Signals to Inspect:
1. **Clock & Reset**:
   - `tb_riscv_processor.clk`
   - `tb_riscv_processor.rst_n`
2. **Program Counter & Instruction**:
   - `dut.pc_current[31:0]` (Verify it increments by 4: `0x00`, `0x04`, `0x08`, `0x0C`... or branches)
   - `dut.instruction[31:0]` (View in Hexadecimal to compare against `sample_program.mem`)
3. **Datapath & Execution**:
   - `dut.u_regfile.rs1_data[31:0]`
   - `dut.u_regfile.rs2_data[31:0]`
   - `dut.alu_operand_b[31:0]`
   - `dut.alu_result[31:0]`
   - `dut.wb_data[31:0]`
4. **Control Signals**:
   - `dut.reg_write`
   - `dut.mem_write`
   - `dut.alu_src`
   - `dut.mem_to_reg`
   - `dut.branch`
   - `dut.pc_src` (asserts high during taken branches)
5. **Registers to inspect in `dut.u_regfile.registers`**:
   - `x1`: 10
   - `x2`: 20
   - `x3`: 30
   - `x4`: 30 (LW from memory)
   - `x5`: 20 (SUB)
   - `x6`: 0  (AND)
   - `x7`: 30 (OR)
   - `x8`: 30 (XOR)
   - `x9`: 1  (SLT)
   - `x10`: 20 (SLL)
   - `x11`: 10 (SRL)
   - `x12`: -5 (`0xFFFFFFFB`)

---

## 4. Running on EDA Playground (Zero-Installation Cloud Simulation)

If you cannot install tools locally, EDA Playground runs the exact same code directly in your browser:

1. Open [https://www.edaplayground.com](https://www.edaplayground.com) and log in.
2. In the left configuration sidebar:
   - **Testbench + Design**: Choose `Verilog/SystemVerilog`.
   - **Simulator**: Select `Icarus Verilog 0.10.0` or `Synopsys VCS` / `Aldec Riviera Pro`.
   - Check the box **"Open EPWave after run"** to view waveforms in your browser.
3. In the right pane:
   - Paste the testbench code (`tb_riscv_processor.v`) into the **testbench.sv** pane.
   - Combine the RTL modules into the **design.sv** pane (or upload the individual `.v` files).
   - In the testbench, paste the memory content directly or include `sample_program.mem` in the files tab.
4. Click **Run**!
