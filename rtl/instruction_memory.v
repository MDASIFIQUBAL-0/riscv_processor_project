// ============================================================================
// Module Name:  instruction_memory
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Read-only memory storing 32-bit instructions.
//               In RV32I, instructions are 32 bits (4 bytes) wide and word-aligned.
//               The address input is a 32-bit byte address; the internal memory
//               array is word-addressed using addr[31:2] (equivalent to addr >> 2).
//               Initialized from an external hex file via $readmemh.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_DEPTH = 64,                         // Number of 32-bit words
    parameter INIT_FILE = "programs/sample_program.mem" // Memory init file
)(
    input  wire [31:0] addr,        // 32-bit Byte Address from Program Counter
    output wire [31:0] instruction  // 32-bit Fetched Instruction
);

    // Memory array storing 32-bit instruction words
    reg [31:0] mem [0:MEM_DEPTH-1];

    // Word address calculation:
    // Discard the lower 2 bits (addr[1:0]) because all RV32I instructions are word-aligned (multiples of 4).
    wire [29:0] word_addr = addr[31:2];

    // Combinational read: instruction is available immediately once PC stabilizes
    assign instruction = (word_addr < MEM_DEPTH) ? mem[word_addr] : 32'h0000_0013; // default NOP (addi x0, x0, 0)

    // Memory initialization from file
    integer i;
    initial begin
        // Clear memory to NOP instructions (0x00000013)
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'h0000_0013;
        end
        // Load machine code hex file if specified
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

endmodule
