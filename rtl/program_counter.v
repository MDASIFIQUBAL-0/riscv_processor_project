// ============================================================================
// Module Name:  program_counter
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Program Counter (PC) Register
//               Holds the 32-bit address of the currently executing instruction.
//               Updates synchronously on the rising edge of the clock.
//               Provides asynchronous active-low reset initializing PC to 0x00000000.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module program_counter (
    input  wire        clk,        // System Clock
    input  wire        rst_n,      // Active-low Asynchronous Reset
    input  wire [31:0] pc_next,    // Next Program Counter Value (calculated by fetch logic)
    output reg  [31:0] pc          // Current Program Counter Value
);

    // Asynchronous active-low reset process
    // Selected because active-low reset is standard in industry ASIC standard-cell
    // libraries and ensures clean power-on initialization without requiring clock pulses.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
