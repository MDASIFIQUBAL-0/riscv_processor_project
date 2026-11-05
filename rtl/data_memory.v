// ============================================================================
// Module Name:  data_memory
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Read/Write Data RAM for Load (LW) and Store (SW) instructions.
//               Addresses from the ALU are 32-bit byte addresses.
//               This implementation operates on 32-bit word-aligned addresses,
//               using addr[31:2] to index into a 32-bit wide memory array.
//               Synchronous write on clock positive edge, combinational read.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module data_memory #(
    parameter MEM_DEPTH = 64 // Number of 32-bit words (256 bytes)
)(
    input  wire        clk,        // System Clock
    input  wire        rst_n,      // Active-low Reset
    input  wire [31:0] addr,       // Memory Byte Address from ALU Result
    input  wire [31:0] write_data, // Data to write (from rs2_data)
    input  wire        mem_write,  // Write Enable
    input  wire        mem_read,   // Read Enable
    output wire [31:0] read_data   // Data read from memory (to Write-back Mux)
);

    // Memory array holding 32-bit data words
    reg [31:0] mem [0:MEM_DEPTH-1];

    // Word address: RV32I word access ignores the lower 2 bits
    wire [29:0] word_addr = addr[31:2];

    // Combinational Read Port
    assign read_data = (mem_read && (word_addr < MEM_DEPTH)) ? mem[word_addr] : 32'h0000_0000;

    // Synchronous Write Port
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem[i] <= 32'h0000_0000;
            end
        end else if (mem_write && (word_addr < MEM_DEPTH)) begin
            mem[word_addr] <= write_data;
        end
    end

endmodule
