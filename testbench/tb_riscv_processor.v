// ============================================================================
// Module Name:  tb_riscv_processor
// Project:      Simplified 32-bit RISC-V Processor (RV32I)
// Description:  Comprehensive Self-Checking Testbench.
//               - Generates 100MHz Clock and Asynchronous Reset
//               - Dumps VCD waveform file ("processor.vcd") for GTKWave
//               - Monitors execution cycle-by-cycle (PC, Inst, ALU, WB)
//               - Verifies register values against golden architectural models
//               - Verifies data memory contents
//               - Reports explicit PASS / FAIL status for each test case
// Standard:     Verilog-2001
// ============================================================================

`timescale 1ns / 1ps

module tb_riscv_processor;

    // Clock and Reset Signals
    reg clk;
    reg rst_n;

    // Diagnostic Signals monitored from DUT
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_wb_data;
    wire        debug_reg_write;
    wire        debug_mem_write;
    wire        debug_branch_taken;

    // Verification statistics
    integer test_pass_count;
    integer test_fail_count;
    integer cycle_count;

    // Instantiate Design Under Test (DUT)
    riscv_processor #(
        .MEM_DEPTH (64),
        .INIT_FILE ("programs/sample_program.mem")
    ) dut (
        .clk                (clk),
        .rst_n              (rst_n),
        .debug_pc           (debug_pc),
        .debug_instruction  (debug_instruction),
        .debug_alu_result   (debug_alu_result),
        .debug_wb_data      (debug_wb_data),
        .debug_reg_write    (debug_reg_write),
        .debug_mem_write    (debug_mem_write),
        .debug_branch_taken (debug_branch_taken)
    );

    // 100MHz Clock Generation (Period = 10ns, 5ns High / 5ns Low)
    always #5 clk = ~clk;

    // Cycle Counter & Execution Monitor
    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count = cycle_count + 1;
            $display("[Cycle %02d | Time %0t ps] PC=0x%08h | Inst=0x%08h | ALU=0x%08h (%0d) | WB=0x%08h | RegWr=%b | MemWr=%b | BranchTaken=%b",
                     cycle_count, $time, debug_pc, debug_instruction, debug_alu_result, $signed(debug_alu_result),
                     debug_wb_data, debug_reg_write, debug_mem_write, debug_branch_taken);
        end
    end

    // Verification Task to check register values
    task check_reg;
        input [4:0]  reg_idx;
        input [31:0] expected_val;
        input [127:0] test_name;
        reg   [31:0] actual_val;
        begin
            actual_val = dut.u_regfile.registers[reg_idx];
            if (actual_val === expected_val) begin
                $display("[PASS] %0s | Register x%0d = %0d (0x%08h)", test_name, reg_idx, $signed(actual_val), actual_val);
                test_pass_count = test_pass_count + 1;
            end else begin
                $display("[FAIL] %0s | Register x%0d : Expected %0d (0x%08h), Found %0d (0x%08h)",
                         test_name, reg_idx, $signed(expected_val), expected_val, $signed(actual_val), actual_val);
                test_fail_count = test_fail_count + 1;
            end
        end
    endtask

    // Verification Task to check data memory values
    task check_mem;
        input [31:0] word_idx;
        input [31:0] expected_val;
        input [127:0] test_name;
        reg   [31:0] actual_val;
        begin
            actual_val = dut.u_dmem.mem[word_idx];
            if (actual_val === expected_val) begin
                $display("[PASS] %0s | DataMem[%0d] = %0d (0x%08h)", test_name, word_idx, $signed(actual_val), actual_val);
                test_pass_count = test_pass_count + 1;
            end else begin
                $display("[FAIL] %0s | DataMem[%0d] : Expected %0d (0x%08h), Found %0d (0x%08h)",
                         test_name, word_idx, $signed(expected_val), expected_val, $signed(actual_val), actual_val);
                test_fail_count = test_fail_count + 1;
            end
        end
    endtask

    // Simulation Sequence
    initial begin
        // Setup GTKWave VCD dump
        $dumpfile("processor.vcd");
        $dumpvars(0, tb_riscv_processor);

        // Initialize variables
        clk             = 0;
        rst_n           = 0;
        test_pass_count = 0;
        test_fail_count = 0;
        cycle_count     = 0;

        $display("==================================================================");
        $display("   STARTING RISC-V RV32I SINGLE-CYCLE PROCESSOR SIMULATION");
        $display("==================================================================");

        // Apply Reset for 25ns
        #25;
        @(negedge clk);
        rst_n = 1;
        $display("[INFO] Processor Reset released at %0t ps. Beginning program execution...", $time);

        // Execute program: 30 cycles are plenty to finish all instructions and reach halt loop
        repeat (30) @(posedge clk);

        $display("\n==================================================================");
        $display("   FUNCTIONAL VERIFICATION: REGISTER & MEMORY CHECKS");
        $display("==================================================================");

        // 1. Basic Sample Program Checks
        check_reg(1, 32'd10, "Test 1: ADDI x1, x0, 10");
        check_reg(2, 32'd20, "Test 2: ADDI x2, x0, 20");
        check_reg(3, 32'd30, "Test 3: ADD  x3, x1, x2");
        check_mem(0, 32'd30, "Test 4: SW   x3, 0(x0) ");
        check_reg(4, 32'd30, "Test 5: LW   x4, 0(x0) ");

        // 2. Arithmetic & Logic Operations
        check_reg(5, 32'd20, "Test 6: SUB  x5, x3, x1");
        check_reg(6, 32'd0,  "Test 7: AND  x6, x1, x2");
        check_reg(7, 32'd30, "Test 8: OR   x7, x1, x2");
        check_reg(8, 32'd30, "Test 9: XOR  x8, x1, x2");

        // 3. Comparison and Shift Operations
        check_reg(9,  32'd1,  "Test 10: SLT x9, x1, x2");
        check_reg(10, 32'd20, "Test 11: SLL x10, x1, x9");
        check_reg(11, 32'd10, "Test 12: SRL x11, x10, x9");

        // 4. Sign-extension of negative immediate
        check_reg(12, 32'hFFFF_FFFB, "Test 13: ADDI Negative Imm (-5)");

        // 5. Register x0 immutability
        check_reg(0, 32'd0, "Test 14: Register x0 is Zero");

        // 6. Branch Execution Checks
        check_reg(13, 32'd1, "Test 15: BEQ Taken (Skip Trap)");
        check_reg(14, 32'd2, "Test 16: BEQ Not Taken (Fallthrough)");
        check_reg(15, 32'd3, "Test 17: BNE Taken (Skip Trap)");

        $display("\n==================================================================");
        $display("   VERIFICATION SUMMARY");
        $display("   Total Passed Checks: %0d", test_pass_count);
        $display("   Total Failed Checks: %0d", test_fail_count);
        $display("==================================================================");

        if (test_fail_count == 0) begin
            $display("   >>> STATUS: ALL TEST CASES PASSED SUCCESSFULLY! <<<");
            $display("   The RV32I Processor architecture is functionally verified.");
        end else begin
            $display("   >>> STATUS: SIMULATION FAILED WITH %0d ERRORS! <<<", test_fail_count);
        end
        $display("==================================================================\n");

        $finish;
    end

endmodule
