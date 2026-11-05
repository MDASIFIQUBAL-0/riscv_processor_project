// ============================================================================
// Module Name:  register_file
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Architectural Register File containing 32 general-purpose
//               32-bit registers (x0 to x31).
//               - Dual asynchronous read ports (rs1_data, rs2_data).
//               - Single synchronous write port (rd_data, enabled by reg_write).
//               - Register x0 is hardwired to 0x00000000 per the RISC-V specification;
//                 writes to x0 are ignored and reads always return 0.
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module register_file (
    input  wire        clk,        // System Clock
    input  wire        rst_n,      // Active-low Asynchronous Reset
    input  wire [4:0]  rs1_addr,   // Source Register 1 Address (0 to 31)
    input  wire [4:0]  rs2_addr,   // Source Register 2 Address (0 to 31)
    input  wire [4:0]  rd_addr,    // Destination Register Address (0 to 31)
    input  wire [31:0] rd_data,    // Write Data for Destination Register
    input  wire        reg_write,  // Write Enable Control Signal
    output wire [31:0] rs1_data,   // Source Register 1 Read Data
    output wire [31:0] rs2_data    // Source Register 2 Read Data
);

    // 32 registers of 32-bit width
    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous Read Ports:
    // Register x0 is strictly hardwired to constant 0.
    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : registers[rs2_addr];

    // Synchronous Write Port with Asynchronous Reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all 32 registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            // Write only if enabled and destination is not x0
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
