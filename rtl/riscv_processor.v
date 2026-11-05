// ============================================================================
// Module Name:  riscv_processor
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Top-Level Single-Cycle RISC-V Processor Module.
//               Integrates the Program Counter, Instruction Memory,
//               Register File, Immediate Generator, Control Unit, ALU,
//               and Data Memory into a cohesive datapath.
//               Executes one instruction per clock cycle.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module riscv_processor #(
    parameter MEM_DEPTH = 64,                         // Instruction and Data Memory Depth
    parameter INIT_FILE = "programs/sample_program.mem" // Initial machine code hex
)(
    input  wire        clk,               // Master Clock
    input  wire        rst_n,             // Active-low Asynchronous Reset

    // External Probe / Monitoring Ports (ideal for verification & debugging)
    output wire [31:0] debug_pc,          // Current PC value
    output wire [31:0] debug_instruction, // Current Instruction word
    output wire [31:0] debug_alu_result,  // Current ALU computation output
    output wire [31:0] debug_wb_data,     // Current Write-Back data
    output wire        debug_reg_write,   // Register File Write Enable
    output wire        debug_mem_write,   // Data Memory Write Enable
    output wire        debug_branch_taken // Branch condition met
);

    // ========================================================================
    // Internal Wires and Buses
    // ========================================================================

    // Program Counter Signals
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_branch;
    wire        pc_src;

    // Instruction Signals
    wire [31:0] instruction;
    wire [6:0]  opcode = instruction[6:0];
    wire [4:0]  rd     = instruction[11:7];
    wire [2:0]  funct3 = instruction[14:12];
    wire [4:0]  rs1    = instruction[19:15];
    wire [4:0]  rs2    = instruction[24:20];
    wire [6:0]  funct7 = instruction[31:25];

    // Control Unit Signals
    wire        reg_write;
    wire        mem_write;
    wire        mem_read;
    wire        mem_to_reg;
    wire        alu_src;
    wire        branch;
    wire        branch_bne;
    wire [3:0]  alu_control;

    // Datapath Buses
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm_ext;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [31:0] mem_read_data;
    wire [31:0] wb_data;

    // ========================================================================
    // Instruction Fetch Stage
    // ========================================================================

    // Sequential PC register
    program_counter u_pc (
        .clk     (clk),
        .rst_n   (rst_n),
        .pc_next (pc_next),
        .pc      (pc_current)
    );

    // PC Arithmetic:
    // Standard sequential address is PC + 4
    assign pc_plus_4 = pc_current + 32'd4;

    // Branch target address is PC + SignExtendedImmediate
    assign pc_branch = pc_current + imm_ext;

    // Branch Condition Evaluation:
    // If BEQ (branch_bne == 0), branch is taken when alu_zero is 1.
    // If BNE (branch_bne == 1), branch is taken when alu_zero is 0.
    wire branch_condition = branch_bne ? (~alu_zero) : alu_zero;
    assign pc_src = branch & branch_condition;

    // Next PC Selection Multiplexer
    assign pc_next = pc_src ? pc_branch : pc_plus_4;

    // Instruction Memory (ROM)
    instruction_memory #(
        .MEM_DEPTH (MEM_DEPTH),
        .INIT_FILE (INIT_FILE)
    ) u_imem (
        .addr        (pc_current),
        .instruction (instruction)
    );

    // ========================================================================
    // Instruction Decode & Register Fetch Stage
    // ========================================================================

    // Control Unit (Main & ALU Decoder)
    control_unit u_control (
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .reg_write   (reg_write),
        .mem_write   (mem_write),
        .mem_read    (mem_read),
        .mem_to_reg  (mem_to_reg),
        .alu_src     (alu_src),
        .branch      (branch),
        .branch_bne  (branch_bne),
        .alu_control (alu_control)
    );

    // 32 x 32 Register File
    register_file u_regfile (
        .clk       (clk),
        .rst_n     (rst_n),
        .rs1_addr  (rs1),
        .rs2_addr  (rs2),
        .rd_addr   (rd),
        .rd_data   (wb_data),
        .reg_write (reg_write),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    // Sign-extending Immediate Generator
    immediate_generator u_imm_gen (
        .instruction (instruction),
        .imm_ext     (imm_ext)
    );

    // ========================================================================
    // Execution Stage (ALU)
    // ========================================================================

    // ALU Operand B Multiplexer: Select rs2_data or imm_ext
    assign alu_operand_b = alu_src ? imm_ext : rs2_data;

    // Arithmetic Logic Unit
    alu u_alu (
        .a           (rs1_data),
        .b           (alu_operand_b),
        .alu_control (alu_control),
        .result      (alu_result),
        .zero        (alu_zero)
    );

    // ========================================================================
    // Memory Stage (Data RAM)
    // ========================================================================

    data_memory #(
        .MEM_DEPTH (MEM_DEPTH)
    ) u_dmem (
        .clk        (clk),
        .rst_n      (rst_n),
        .addr       (alu_result),
        .write_data (rs2_data),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .read_data  (mem_read_data)
    );

    // ========================================================================
    // Write-Back Stage
    // ========================================================================

    // Multiplexer selecting ALU result or Data Memory read data
    assign wb_data = mem_to_reg ? mem_read_data : alu_result;

    // ========================================================================
    // Debug & Probing Port Assignments
    // ========================================================================
    assign debug_pc          = pc_current;
    assign debug_instruction = instruction;
    assign debug_alu_result  = alu_result;
    assign debug_wb_data     = wb_data;
    assign debug_reg_write   = reg_write;
    assign debug_mem_write   = mem_write;
    assign debug_branch_taken= pc_src;

endmodule
