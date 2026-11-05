# RISC-V RV32I Processor Viva & Interview Preparation Guide
### Comprehensive 45 Questions with Bilingual (English & Hinglish) Explanations + 2-Minute Faculty Pitch

---

## Part 1: Two-Minute Faculty Project Pitch

### English Script:
> "Good morning, respected professors. In this project, I have designed and functionally verified a simplified 32-bit single-cycle processor based on the open-source RISC-V RV32I instruction set architecture using synthesizable Verilog HDL.
>
> The core architecture integrates eight modular blocks: a Program Counter with active-low asynchronous reset, word-aligned Instruction and Data Memories, a 32-register architectural Register File where register x0 is hardwired to zero, a sign-extending Immediate Generator for I, S, and B formats, a 32-bit ALU supporting eight arithmetic and logic operations, and a unified Main and ALU Control Unit.
>
> In our single-cycle implementation, every instruction executes in exactly one clock cycle, achieving a CPI of 1. The design supports key RV32I instructions including ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, ADDI, LW, SW, and branch instructions BEQ and BNE.
>
> I verified the processor using a self-checking Verilog testbench in Icarus Verilog and GTKWave, as well as an architectural cycle-accurate reference simulator. We executed a comprehensive machine-code program verifying arithmetic computations, memory store and load sequences, negative immediate sign extension, register x0 immutability, and both taken and not-taken conditional branches. All 17 verification assertions passed with zero errors. Furthermore, the design is structured for gate-level synthesis using Yosys. This project served as an end-to-end practical exercise in computer architecture, RTL design, and hardware verification."

### Hinglish Translation:
> "Good morning professors. Is project me maine synthesizable Verilog HDL use karke open-source RISC-V RV32I ISA par based ek 32-bit single-cycle processor design aur functionally verify kiya hai.
>
> Is processor me 8 modular blocks hain: Program Counter with asynchronous reset, word-aligned Instruction aur Data Memory, 32 registers ka Register File jisme register x0 permanently zero par hardwired hai, sign-extending Immediate Generator, 8 operations perform karne wala 32-bit ALU, aur unified Control Unit.
>
> Kyunki ye single-cycle design hai, har instruction strictly 1 clock cycle me execute hoti hai ($CPI = 1$). Ye processor ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, ADDI, LW, SW, BEQ, aur BNE instructions ko support karta hai.
>
> Maine ise Icarus Verilog, GTKWave aur reference simulator se verify kiya hai ek 23-instruction machine code program run karke. Isme memory access, arithmetic logic, negative sign extension, x0 protection aur branching verify hui hai aur sabhi 17 verification test cases 100% pass hue hain. Code fully synthesizable hai aur Yosys ke liye ready hai."

---

## Part 2: 45 Core Viva Questions and Detailed Answers

### 1. What is Verilog HDL?
- **English**: Verilog is a Hardware Description Language (HDL) used to model, simulate, and synthesize digital electronic systems and integrated circuits at various abstraction levels (behavioral, dataflow, gate-level).
- **Hinglish**: Verilog ek hardware description language hai jisse hum digital circuits aur microprocessors ko code ke form me model, simulate aur silicon chips ke liye synthesize karte hain.

### 2. What is the difference between an HDL and a software programming language like C?
- **English**: C code executes sequentially on an existing processor thread. Verilog describes physical concurrent hardware circuits that operate in parallel and continuously react to signal changes.
- **Hinglish**: C language CPU par sequentially line-by-line chalta hai, jabki Verilog hardware circuits describe karta hai jo real physical gates ki tarah parallel me simultaneously execute hote hain.

### 3. What is a Processor?
- **English**: A digital processing engine that fetches machine instructions from memory, decodes them, executes arithmetic/logical operations, accesses data memory, and updates its architectural state.
- **Hinglish**: Processor ek digital circuit hai jo memory se instructions fetch karta hai, decode karta hai, mathematical/logical calculations karta hai, aur data update karta hai.

### 4. What is an Instruction Set Architecture (ISA)?
- **English**: The abstract interface and contract between hardware and software. It defines the supported instructions, data types, register set, addressing modes, and memory model.
- **Hinglish**: ISA hardware aur software ke beech ka rulebook ya contract hota hai, jo batata hai ki processor kaunse instructions, registers aur data formats support karega.

### 5. What is RISC-V?
- **English**: An open-source, royalty-free Reduced Instruction Set Computer (RISC) ISA developed at UC Berkeley in 2010. It is modular and managed by RISC-V International.
- **Hinglish**: RISC-V ek modern, open-source aur royalty-free processor ISA hai jo UC Berkeley me design kiya gaya tha. Iska use koi bhi company ya student bina licensing fees ke kar sakta hai.

### 6. What does "RV32I" signify?
- **English**: **RV** stands for RISC-V, **32** indicates 32-bit address and register width, and **I** denotes the base Integer instruction set with 40 fundamental instructions.
- **Hinglish**: RV matlab RISC-V, 32 ka matlab 32-bit registers aur memory address, aur I ka matlab base Integer instruction set.

### 7. What is a 32-bit Processor?
- **English**: A processor where the general-purpose registers, internal datapath buses, arithmetic logic unit (ALU), and memory address spaces are 32 bits wide.
- **Hinglish**: Ek aisa processor jiske registers, data buses, aur ALU operations 32 bits wide hote hain aur ek samay me 32-bit data process karte hain.

### 8. What is a Single-Cycle Processor?
- **English**: A processor microarchitecture in which every instruction executes in exactly one clock cycle ($CPI = 1$).
- **Hinglish**: Aisa processor jisme har instruction complete fetch se lekar write-back tak poora execution sirf ek single clock cycle me complete karti hai.

### 9. What is CPI and what is its value in our processor?
- **English**: Cycles Per Instruction. In our single-cycle processor, $CPI = 1.0$ because one instruction completes every clock cycle.
- **Hinglish**: CPI ka full form Cycles Per Instruction hota hai. Hamare single-cycle processor me CPI hamesha 1 hoti hai.

### 10. What is the Program Counter (PC)?
- **English**: A dedicated 32-bit register that holds the memory address of the instruction currently being executed.
- **Hinglish**: PC ek special 32-bit register hai jo currently execute ho rahi instruction ka memory address store karta hai.

### 11. Why does the PC normally increment by 4?
- **English**: In RV32I, every instruction is 32 bits (4 bytes) wide. Because memory is byte-addressed, moving to the next sequential instruction requires adding 4 bytes ($PC + 4$).
- **Hinglish**: RISC-V instructions 32 bits (4 bytes) ki hoti hain aur memory byte-addressed hoti hai, isliye next instruction par jaane ke liye PC me hamesha 4 add hota hai.

### 12. Why did you choose an active-low asynchronous reset for the PC?
- **English**: Active-low asynchronous reset (`rst_n`) is standard in commercial ASIC standard-cell libraries and enables deterministic initialization upon power-on without requiring a running clock.
- **Hinglish**: Asynchronous active-low reset industry standard hai aur power-on ke time bina clock edge ka wait kiye chip ko turant clean 0x00 address par reset kar deta hai.

### 13. What is the Register File?
- **English**: An array of general-purpose high-speed storage locations inside the CPU. In RV32I, it contains 32 registers (`x0` to `x31`), each 32 bits wide.
- **Hinglish**: Register File CPU ke andar fast internal memory hoti hai jisme 32 general purpose registers hote hain jo ALU calculations ke operands store karte hain.

### 14. Why does RISC-V have two read ports and one write port in the Register File?
- **English**: Most RISC-V instructions (e.g., `ADD rd, rs1, rs2`) require two source operands simultaneously and write back one destination result in the same cycle.
- **Hinglish**: Zyadatar instructions do source values (`rs1`, `rs2`) padhti hain aur ek destination (`rd`) me result write karti hain, isliye do read ports aur ek write port chahiye.

### 15. Why is register x0 hardwired to zero in RISC-V?
- **English**: Hardwiring `x0 = 0` provides an architectural constant zero, enabling simple pseudo-instructions (e.g., `MOV rd, rs1` is just `ADD rd, rs1, x0`; `NOP` is `ADDI x0, x0, 0`).
- **Hinglish**: `x0` ko 0 par fix karne se architecture bohot simple ho jata hai. Isse NOP (`ADDI x0, x0, 0`) aur register copy (`ADD rd, rs1, x0`) bina extra hardware instructions ke ban jaate hain.

### 16. What happens if software attempts to write to x0?
- **English**: The hardware explicitly ignores writes to `x0` (`if (reg_write && rd_addr != 5'd0)`), so `x0` remains permanently 0.
- **Hinglish**: Hardware code me check laga hai ki agar destination address 0 hai to write operation discard ho jaye, isliye `x0` hamesha 0 rehta hai.

### 17. What is the Arithmetic Logic Unit (ALU)?
- **English**: The central combinational execution block that performs binary arithmetic (ADD, SUB), bitwise logical (AND, OR, XOR), comparisons (SLT), and shift operations (SLL, SRL).
- **Hinglish**: ALU ek core combinational circuit hai jo math (addition, subtraction), logic (AND, OR, XOR), comparison (SLT), aur shifts (SLL, SRL) perform karta hai.

### 18. What is the purpose of the ALU Zero flag?
- **English**: It indicates whether the ALU result is zero. It is used by branch instructions like `BEQ` (branch if $rs1 - rs2 == 0$) and `BNE` (branch if $rs1 - rs2 \ne 0$).
- **Hinglish**: Zero flag batata hai ki ALU ka calculation result 0 aya ya nahi. Branch instructions (`BEQ`/`BNE`) is flag se faisla karti hain ki jump karna hai ya nahi.

### 19. What is the Immediate Generator?
- **English**: A dedicated decoder that extracts constant literal bits from instruction words and sign-extends them to 32 bits according to the instruction format.
- **Hinglish**: Immediate Generator instruction ke andar se constant number nikalta hai aur uske MSB sign-bit ko extend karke 32-bit signed number banata hai.

### 20. Why do different instruction formats place immediate bits in different positions?
- **English**: To keep source and destination register fields (`rs1`, `rs2`, `rd`) in identical bit locations across all instruction types, simplifying and speeding up register decode hardware.
- **Hinglish**: Taaki register fields (`rs1`, `rs2`, `rd`) har format me hamesha same position par rahein, jisse decoder circuit fast aur simple ho jaye.

### 21. What is an R-Type instruction?
- **English**: Register-Register instructions (e.g., `ADD`, `SUB`, `AND`, `OR`, `SLT`) where both source operands and the destination operand are registers.
- **Hinglish**: Aisi instructions jisme dono input values aur final result registers me hote hain (koi constant immediate nahi hota).

### 22. What is an I-Type instruction?
- **English**: Immediate or Load instructions (e.g., `ADDI`, `LW`) where one operand is a register and the second operand is a 12-bit signed constant immediate.
- **Hinglish**: Aisi instructions jisme ek input register hota hai aur dusra 12-bit ka constant immediate value hota hai, jaise `ADDI` ya `LW`.

### 23. What is an S-Type instruction?
- **English**: Store instructions (e.g., `SW`) that write register data to memory using a base register and a 12-bit immediate offset.
- **Hinglish**: Store instructions jo register ka data memory me write karti hain (`SW`), jisme address base register + 12-bit offset se banta hai.

### 24. What is a B-Type instruction?
- **English**: Conditional branch instructions (e.g., `BEQ`, `BNE`) that compare two registers and add a 13-bit signed offset to the PC if the condition is met.
- **Hinglish**: Branch instructions jo do registers compare karti hain aur condition true hone par PC me offset add karke jump karti hain.

### 25. Why is the least significant bit (bit 0) of branch immediates always zero?
- **English**: All RISC-V instructions are at least 2-byte (16-bit halfword) aligned, so branch target addresses are always multiples of 2, making bit 0 always 0.
- **Hinglish**: RISC-V instructions hamesha even byte address par hoti hain, isliye jump target ka aakhri bit hamesha 0 hota hai aur store karne ki zaroorat nahi hoti.

### 26. What does the Control Unit do?
- **English**: It decodes the instruction opcode, funct3, and funct7 fields and generates multiplexer and enable signals (`RegWrite`, `MemWrite`, `ALUSrc`, `ALUControl`, `MemtoReg`, `Branch`).
- **Hinglish**: Control Unit instruction ko dekh kar pure processor ke switch/multiplexer signals aur write enables control karta hai.

### 27. What is the difference between Instruction Memory and Data Memory?
- **English**: Instruction Memory holds executable code words fetched by the PC. Data Memory stores program variables, arrays, and data structures accessed via `LW` and `SW` (Harvard Architecture separation).
- **Hinglish**: Instruction Memory me program code rehta hai jise PC fetch karta hai, jabki Data Memory me variables aur data rehte hain jise `LW`/`SW` access karte hain.

### 28. What is word-aligned memory access?
- **English**: In 32-bit systems, a word is 4 bytes. Word-aligned addresses are multiples of 4 (i.e., address ending in `2'b00`, such as 0, 4, 8, 12).
- **Hinglish**: 32-bit me 1 word = 4 bytes. Word-aligned ka matlab address 4 ka multiple hota hai aur aakhri do bits `00` hote hain.

### 29. What is a Verilog Testbench?
- **English**: An un-synthesizable simulation wrapper module that generates clock, reset, and stimulus vectors, monitors responses from the Design Under Test (DUT), and verifies correctness.
- **Hinglish**: Testbench ek simulation environment hota hai jo clock, reset aur inputs generate karta hai aur check karta hai ki design sahi output de raha hai ya nahi.

### 30. What is a Self-Checking Testbench?
- **English**: A testbench containing automated programmatic assertions that compare actual DUT outputs against expected golden values and display clear PASS/FAIL messages.
- **Hinglish**: Ek aisa testbench jo automated check karta hai aur khud batata hai ki test PASS hua ya FAIL, human ko waveform dekh kar manually check nahi karna padta.

### 31. What is the difference between Simulation and Synthesis?
- **English**: Simulation models hardware behavior over time on a software computer. Synthesis converts abstract Verilog RTL code into a physical netlist of logic gates and flip-flops.
- **Hinglish**: Simulation software me timing aur logic verify karne ke liye hota hai, jabki Synthesis code ko actual physical AND, OR gates aur flip-flops me convert karta hai.

### 32. What is a VCD file?
- **English**: Value Change Dump. An industry-standard ASCII text file that records timestamped logic transitions of all probed simulation signals for visualization in GTKWave.
- **Hinglish**: VCD file simulation ke dauran badalne wale signals ka record rakhti hai jisse GTKWave me graph/waveform ke roop me dekha ja sakta hai.

### 33. What is GTKWave?
- **English**: An open-source digital waveform viewer used to inspect signal transitions, timing, bus values, and state changes over simulation time.
- **Hinglish**: GTKWave ek waveform viewing tool hai jisme hum clock pulses, bus values, aur digital signals ko graphical form me analyze karte hain.

### 34. What is Yosys?
- **English**: An open-source framework for Verilog RTL synthesis, behavioral elaboration, logic optimization, and formal verification.
- **Hinglish**: Yosys ek open-source synthesis tool hai jo Verilog RTL code ko gate-level netlist aur technology-mapped cells me translate karta hai.

### 35. What is an FPGA?
- **English**: Field Programmable Gate Array. A semiconductor IC containing an array of configurable logic blocks (CLBs) and programmable interconnects that can be reprogrammed post-manufacturing.
- **Hinglish**: FPGA ek aisi silicon chip hoti hai jise manufacture hone ke baad bhi computer se reprogram karke koi bhi digital circuit banaya ja sakta hai.

### 36. What is an ASIC?
- **English**: Application-Specific Integrated Circuit. A custom-fabricated silicon microchip permanently manufactured for a dedicated application, offering highest performance and lowest power.
- **Hinglish**: ASIC ek permanently manufactured dedicated silicon chip hoti hai, jaise Apple ya Qualcomm ke mobile processors.

### 37. What is the critical path in a digital circuit?
- **English**: The longest combinational propagation delay path between any two sequential storage elements (registers). It dictates the maximum operating clock frequency ($f_{\max} = 1 / T_{\text{crit}}$).
- **Hinglish**: Circuit ka wo sabse lamba rasta jisme signal ko travel karne me sabse zyada time lagta hai. Yahi processor ki maximum speed decide karta hai.

### 38. Which instruction defines the critical path in this single-cycle processor?
- **English**: The `LW` (Load Word) instruction, because it must sequentially execute: PC $\to$ Instruction Memory $\to$ Register File read $\to$ ALU address computation $\to$ Data Memory read $\to$ Write-back mux $\to$ Register File setup.
- **Hinglish**: `LW` (Load Word) instruction, kyunki ye Instruction Memory, Register File, ALU aur Data Memory charo bade blocks se hokar guzarti hai.

### 39. What is the major limitation of a Single-Cycle Processor?
- **English**: The clock period must be long enough to accommodate the slowest instruction (`LW`), forcing fast instructions (like `ADD` or `NOP`) to wait unnecessarily, resulting in low clock frequencies.
- **Hinglish**: Clock period sabse slow instruction ke hisaab se rakhna padta hai, jisse fast instructions ke time par processor idle rehta hai aur clock speed bohot kam aati hai.

### 40. How does a 5-Stage Pipelined Processor solve this limitation?
- **English**: Pipelining places registers between stages (IF, ID, EX, MEM, WB), allowing multiple instructions to be processed concurrently at different stages, shortening the clock period and drastically increasing instruction throughput.
- **Hinglish**: Pipelining me har stage ke beech flip-flops laga diye jaate hain, jisse har stage alag instruction par simultaneously kaam karti hai aur clock frequency bohot badh jaati hai.

### 41. What is the difference between blocking (`=`) and non-blocking (`<=`) assignments?
- **English**: Blocking (`=`) executes sequentially within the block, used for combinational logic. Non-blocking (`<=`) schedules updates concurrently at the end of the simulation step, mandatory for sequential registers.
- **Hinglish**: Blocking (`=`) combinational logic me use hota hai, aur non-blocking (`<=`) registers/flip-flops me use hota hai taaki race conditions na hon.

### 42. What is a transparent latch and why must unintentional latches be avoided?
- **English**: A level-sensitive storage element. If a combinational `always` block omits an assignment in any branch, synthesis infers a latch, which causes timing closure issues and glitches in synchronous designs.
- **Hinglish**: Unintentional latch tab banta hai jab code me koi condition miss ho jaye. Ye timing issues aur unexpected bugs create karta hai isliye default assignments dena zaroori hai.

### 43. How does the processor handle negative numbers?
- **English**: RV32I uses two's complement representation. The Immediate Generator sign-extends bit 31 across upper bits, and the ALU uses `$signed()` comparison for `SLT`.
- **Hinglish**: Two's complement use hota hai. Immediate Generator sign bit (bit 31) ko upper bits me duplicate karta hai aur ALU signed comparison karta hai.

### 44. What happens during a conditional branch if the condition is false?
- **English**: `pc_src` evaluates to 0, and the PC multiplexer selects `pc_plus_4`, seamlessly continuing sequential program execution.
- **Hinglish**: `pc_src` signal 0 ho jata hai aur PC simply next instruction (`PC + 4`) par aage badh jata hai.

### 45. Can this processor run C programs?
- **English**: Yes! A cross-compiler like `riscv32-unknown-elf-gcc` can compile standard C code into RV32I machine code, which can then be formatted into our `.mem` file and executed.
- **Hinglish**: Haan! RISC-V GCC cross-compiler se C code ko compile karke machine code generate kiya ja sakta hai aur use is processor par run kiya ja sakta hai.
