// ============================================================================
// Module Name:  control_unit
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Main and ALU Control Unit
//               Decodes the 7-bit opcode, 3-bit funct3, and 7-bit funct7 fields
//               to generate unified control signals for datapath execution.
//               Supports R-type (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL),
//               I-type arithmetic (ADDI, etc.), I-type load (LW),
//               S-type store (SW), and B-type branch (BEQ, BNE).
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module control_unit (
    input  wire [6:0] opcode,      // Instruction Opcode [6:0]
    input  wire [2:0] funct3,      // Instruction funct3 field [14:12]
    input  wire [6:0] funct7,      // Instruction funct7 field [31:25]
    output reg        reg_write,   // Register File Write Enable
    output reg        mem_write,   // Data Memory Write Enable
    output reg        mem_read,    // Data Memory Read Enable
    output reg        mem_to_reg,  // Write-back Multiplexer (0: ALU, 1: Mem)
    output reg        alu_src,     // ALU Operand B Multiplexer (0: rs2, 1: Imm)
    output reg        branch,      // Conditional Branch Indicator
    output reg        branch_bne,  // 0: BEQ (Branch if Equal), 1: BNE (Branch if Not Equal)
    output reg  [3:0] alu_control  // ALU 4-bit Operation Control
);

    // ALU Operation Codes
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    // Supported RV32I Opcode Encodings
    localparam OPCODE_R_TYPE   = 7'b0110011;
    localparam OPCODE_I_ARITH  = 7'b0010011;
    localparam OPCODE_I_LOAD   = 7'b0000011;
    localparam OPCODE_S_STORE  = 7'b0100011;
    localparam OPCODE_B_BRANCH = 7'b1100011;

    always @(*) begin
        // Safe default values: all writes disabled to prevent corruption from invalid opcodes
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 1'b0;
        alu_src     = 1'b0;
        branch      = 1'b0;
        branch_bne  = 1'b0;
        alu_control = ALU_ADD;

        case (opcode)
            // ------------------------------------------------------------
            // R-Type Instructions (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL)
            // ------------------------------------------------------------
            OPCODE_R_TYPE: begin
                reg_write   = 1'b1;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_src     = 1'b0; // ALU Operand B is rs2_data
                branch      = 1'b0;

                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_control = ALU_SUB; // SUB
                        else
                            alu_control = ALU_ADD; // ADD
                    end
                    3'b001: alu_control = ALU_SLL; // SLL
                    3'b010: alu_control = ALU_SLT; // SLT
                    3'b100: alu_control = ALU_XOR; // XOR
                    3'b101: alu_control = ALU_SRL; // SRL
                    3'b110: alu_control = ALU_OR;  // OR
                    3'b111: alu_control = ALU_AND; // AND
                    default: alu_control = ALU_ADD;
                endcase
            end

            // ------------------------------------------------------------
            // I-Type Arithmetic Instructions (ADDI, SLTI, etc.)
            // ------------------------------------------------------------
            OPCODE_I_ARITH: begin
                reg_write   = 1'b1;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_src     = 1'b1; // ALU Operand B is imm_ext
                branch      = 1'b0;

                case (funct3)
                    3'b000:  alu_control = ALU_ADD; // ADDI
                    3'b001:  alu_control = ALU_SLL; // SLLI
                    3'b010:  alu_control = ALU_SLT; // SLTI
                    3'b100:  alu_control = ALU_XOR; // XORI
                    3'b101:  alu_control = ALU_SRL; // SRLI
                    3'b110:  alu_control = ALU_OR;  // ORI
                    3'b111:  alu_control = ALU_AND; // ANDI
                    default: alu_control = ALU_ADD;
                endcase
            end

            // ------------------------------------------------------------
            // I-Type Load Instructions (LW)
            // ------------------------------------------------------------
            OPCODE_I_LOAD: begin
                reg_write   = 1'b1;
                mem_write   = 1'b0;
                mem_read    = 1'b1;
                mem_to_reg  = 1'b1; // Load data from Memory to Register File
                alu_src     = 1'b1; // Effective Address = rs1 + imm
                branch      = 1'b0;
                alu_control = ALU_ADD;
            end

            // ------------------------------------------------------------
            // S-Type Store Instructions (SW)
            // ------------------------------------------------------------
            OPCODE_S_STORE: begin
                reg_write   = 1'b0;
                mem_write   = 1'b1;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_src     = 1'b1; // Effective Address = rs1 + imm
                branch      = 1'b0;
                alu_control = ALU_ADD;
            end

            // ------------------------------------------------------------
            // B-Type Conditional Branch Instructions (BEQ, BNE)
            // ------------------------------------------------------------
            OPCODE_B_BRANCH: begin
                reg_write   = 1'b0;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_src     = 1'b0; // Compare rs1 and rs2
                branch      = 1'b1;
                alu_control = ALU_SUB; // Perform (rs1 - rs2) to set Zero flag

                if (funct3 == 3'b001) begin
                    branch_bne = 1'b1; // BNE: Branch if Not Equal
                end else begin
                    branch_bne = 1'b0; // BEQ: Branch if Equal (funct3 == 3'b000)
                end
            end

            default: begin
                // Invalid or unsupported instruction
                reg_write   = 1'b0;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_src     = 1'b0;
                branch      = 1'b0;
                branch_bne  = 1'b0;
                alu_control = ALU_ADD;
            end
        endcase
    end

endmodule
