// ============================================================================
// Module Name:  alu
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Arithmetic Logic Unit (ALU)
//               Executes arithmetic, logical, and shift operations on two 32-bit operands.
//               Supports ADD, SUB, AND, OR, XOR, SLT, SLL, and SRL operations.
//               Outputs a 32-bit computation result and a zero flag.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module alu (
    input  wire [31:0] a,           // Operand A (typically rs1_data)
    input  wire [31:0] b,           // Operand B (rs2_data or immediate)
    input  wire [3:0]  alu_control, // Operation Selector
    output reg  [31:0] result,      // 32-bit Calculation Result
    output wire        zero         // Zero Flag (1 if result == 0)
);

    // ALU Operation Encodings
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    // Combinational evaluation
    always @(*) begin
        case (alu_control)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLL: result = a << b[4:0]; // Shift amount is lower 5 bits of operand B
            ALU_SRL: result = a >> b[4:0];
            default: result = 32'h0000_0000;
        endcase
    end

    // Zero Flag: Asserted high when the ALU result is completely zero
    // Used by conditional branch instructions (e.g., BEQ, BNE)
    assign zero = (result == 32'h0000_0000);

endmodule
