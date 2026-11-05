// ============================================================================
// Module Name:  immediate_generator
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Extracts immediate fields from the 32-bit instruction word
//               and performs sign extension to 32 bits according to the
//               official RISC-V RV32I ISA specification.
//               Supports:
//                 - I-type (ADDI, LW): imm[11:0]
//                 - S-type (SW):       imm[11:5], imm[4:0]
//                 - B-type (BEQ, BNE): imm[12|10:5|4:1|11], LSB is 0
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module immediate_generator (
    input  wire [31:0] instruction, // 32-bit Instruction Word
    output reg  [31:0] imm_ext      // 32-bit Sign-Extended Immediate
);

    wire [6:0] opcode = instruction[6:0];

    // RISC-V Standard Opcode Definitions
    localparam OPCODE_I_ARITH = 7'b0010011; // ADDI, SLTI, etc.
    localparam OPCODE_I_LOAD  = 7'b0000011; // LW, LH, LB
    localparam OPCODE_S_STORE = 7'b0100011; // SW, SH, SB
    localparam OPCODE_B_BRANCH= 7'b1100011; // BEQ, BNE, BLT, BGE

    always @(*) begin
        case (opcode)
            // I-type: ADDI, LW
            // Immediate is formed from instruction[31:20] and sign-extended by 20 bits
            OPCODE_I_ARITH,
            OPCODE_I_LOAD: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type: SW
            // Immediate split into instruction[31:25] and instruction[11:7]
            OPCODE_S_STORE: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type: BEQ, BNE
            // Immediate scrambled across instruction[31], [7], [30:25], [11:8], with bit 0 hardwired to 0
            OPCODE_B_BRANCH: begin
                imm_ext = {{19{instruction[31]}}, 
                            instruction[31], 
                            instruction[7], 
                            instruction[30:25], 
                            instruction[11:8], 
                            1'b0};
            end

            // Default for R-type or unsupported opcodes
            default: begin
                imm_ext = 32'h0000_0000;
            end
        endcase
    end

endmodule
