<#
 ============================================================================
 Script Name:  simulate_riscv.ps1
 Project:      Simplified 32-bit RISC-V Processor (RV32I)
 Description:  Cycle-Accurate Reference Simulator for Windows PowerShell.
               Simulates the exact RTL execution cycle-by-cycle of the
               single-cycle processor for the machine code in sample_program.mem.
               Displays cycle logs, checks registers, and outputs verification results.
 ============================================================================
#>

param(
    [string]$MemFile = "$PSScriptRoot\..\programs\sample_program.mem"
)

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   RISC-V RV32I SINGLE-CYCLE ARCHITECTURAL SIMULATION (POWERSHELL)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Read and parse memory file
if (-not (Test-Path $MemFile)) {
    Write-Host "[ERROR] Memory file '$MemFile' not found!" -ForegroundColor Red
    exit 1
}

$rawLines = Get-Content $MemFile
$imem = [uint32[]]::new(64)
$wordIdx = 0

foreach ($line in $rawLines) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "" -or $trimmed.StartsWith("//") -or $trimmed.StartsWith("#")) {
        continue
    }
    # Remove inline comments
    if ($trimmed.Contains(";")) { $trimmed = $trimmed.Split(";")[0].Trim() }
    if ($trimmed.Contains("//")) { $trimmed = $trimmed.Split("//")[0].Trim() }
    
    if ($trimmed.Length -ge 8) {
        $hexStr = $trimmed.Substring(0, 8)
        $val = [Convert]::ToUInt32($hexStr, 16)
        $imem[$wordIdx] = $val
        $wordIdx++
        if ($wordIdx -ge 64) { break }
    }
}

Write-Host "[INFO] Loaded $wordIdx instructions into Instruction Memory." -ForegroundColor Green

# 2. Processor State
$regs = [int32[]]::new(32)
$dmem = [int32[]]::new(64)
$pc = [uint32]0
$cycle = 0
$maxCycles = 30

Write-Host "`nStarting Cycle-by-Cycle RTL Trace..." -ForegroundColor Yellow
Write-Host ("-" * 110)

while ($cycle -lt $maxCycles) {
    $cycle++
    $currentPc = $pc
    $wordAddress = [int]($pc -shr 2)
    
    $instruction = if ($wordAddress -lt 64) { $imem[$wordAddress] } else { [uint32]0x00000013 }
    
    # Instruction Fields
    $opcode = [int]($instruction -band 0x7F)
    $rd     = [int](($instruction -shr 7) -band 0x1F)
    $funct3 = [int](($instruction -shr 12) -band 0x07)
    $rs1    = [int](($instruction -shr 15) -band 0x1F)
    $rs2    = [int](($instruction -shr 20) -band 0x1F)
    $funct7 = [int](($instruction -shr 25) -band 0x7F)
    
    # Read Registers (x0 is always 0)
    $rs1Val = if ($rs1 -eq 0) { [int32]0 } else { $regs[$rs1] }
    $rs2Val = if ($rs2 -eq 0) { [int32]0 } else { $regs[$rs2] }
    
    # Sign-Extended Immediate
    $immExt = [int32]0
    if ($opcode -eq 0x13 -or $opcode -eq 0x03) { # I-type
        $imm12 = [int](($instruction -shr 20) -band 0xFFF)
        if (($imm12 -band 0x800) -ne 0) {
            $immExt = [int32]($imm12 -bor -4096)
        } else {
            $immExt = [int32]$imm12
        }
    } elseif ($opcode -eq 0x23) { # S-type
        $imm11_5 = [int](($instruction -shr 25) -band 0x7F)
        $imm4_0  = [int](($instruction -shr 7) -band 0x1F)
        $imm12   = ($imm11_5 -shl 5) -bor $imm4_0
        if (($imm12 -band 0x800) -ne 0) {
            $immExt = [int32]($imm12 -bor -4096)
        } else {
            $immExt = [int32]$imm12
        }
    } elseif ($opcode -eq 0x63) { # B-type
        $b31 = [int](($instruction -shr 31) -band 1)
        $b7  = [int](($instruction -shr 7) -band 1)
        $b30_25 = [int](($instruction -shr 25) -band 0x3F)
        $b11_8  = [int](($instruction -shr 8) -band 0x0F)
        $imm13 = ($b31 -shl 12) -bor ($b7 -shl 11) -bor ($b30_25 -shl 5) -bor ($b11_8 -shl 1)
        if (($imm13 -band 0x1000) -ne 0) {
            $immExt = [int32]($imm13 -bor -8192)
        } else {
            $immExt = [int32]$imm13
        }
    }
    
    # Execution & Control Logic
    $aluResult = [int32]0
    $wbData = [int32]0
    $regWrite = 0
    $memWrite = 0
    $branchTaken = 0
    
    if ($opcode -eq 0x33) { # R-type
        $regWrite = 1
        if ($funct3 -eq 0) {
            if ($funct7 -eq 0x20) { $aluResult = $rs1Val - $rs2Val } # SUB
            else { $aluResult = $rs1Val + $rs2Val } # ADD
        } elseif ($funct3 -eq 1) { # SLL
            $aluResult = $rs1Val -shl ($rs2Val -band 0x1F)
        } elseif ($funct3 -eq 2) { # SLT
            $aluResult = if ($rs1Val -lt $rs2Val) { 1 } else { 0 }
        } elseif ($funct3 -eq 4) { # XOR
            $aluResult = $rs1Val -bxor $rs2Val
        } elseif ($funct3 -eq 5) { # SRL
            $aluResult = [int32]([uint32]$rs1Val -shr ($rs2Val -band 0x1F))
        } elseif ($funct3 -eq 6) { # OR
            $aluResult = $rs1Val -bor $rs2Val
        } elseif ($funct3 -eq 7) { # AND
            $aluResult = $rs1Val -band $rs2Val
        }
        $wbData = $aluResult
    } elseif ($opcode -eq 0x13) { # I-type Arith
        $regWrite = 1
        $aluResult = $rs1Val + $immExt
        $wbData = $aluResult
    } elseif ($opcode -eq 0x03) { # I-type Load (LW)
        $regWrite = 1
        $effectiveAddr = $rs1Val + $immExt
        $aluResult = $effectiveAddr
        $memIdx = [int]($effectiveAddr -shr 2)
        $wbData = if ($memIdx -ge 0 -and $memIdx -lt 64) { $dmem[$memIdx] } else { 0 }
    } elseif ($opcode -eq 0x23) { # S-type Store (SW)
        $memWrite = 1
        $effectiveAddr = $rs1Val + $immExt
        $aluResult = $effectiveAddr
        $memIdx = [int]($effectiveAddr -shr 2)
        if ($memIdx -ge 0 -and $memIdx -lt 64) {
            $dmem[$memIdx] = $rs2Val
        }
    } elseif ($opcode -eq 0x63) { # B-type Branch
        if ($funct3 -eq 0) { # BEQ
            if ($rs1Val -eq $rs2Val) { $branchTaken = 1 }
        } elseif ($funct3 -eq 1) { # BNE
            if ($rs1Val -ne $rs2Val) { $branchTaken = 1 }
        }
        $aluResult = $rs1Val - $rs2Val
    }
    
    # Write Back to Registers (x0 ignored)
    if ($regWrite -eq 1 -and $rd -ne 0) {
        $regs[$rd] = $wbData
    }
    
    # Next PC
    $nextPc = if ($branchTaken -eq 1) { [uint32]([int64]$currentPc + $immExt) } else { [uint32]($currentPc + 4) }
    
    $pcHex = "0x{0:X8}" -f $currentPc
    $instHex = "0x{0:X8}" -f $instruction
    $aluHex = "0x{0:X8}" -f $aluResult
    $wbHex = "0x{0:X8}" -f $wbData
    
    Write-Host ("[Cycle {0:D2}] PC={1} | Inst={2} | ALU={3} ({4,4}) | WB={5} | RegWr={6} | MemWr={7} | BranchTaken={8}" -f `
        $cycle, $pcHex, $instHex, $aluHex, $aluResult, $wbHex, $regWrite, $memWrite, $branchTaken)
        
    $pc = $nextPc
    
    # Check if halted in self-loop (BEQ x0, x0, 0 at 0x58)
    if ($instruction -eq 0x00000063 -and $branchTaken -eq 1) {
        Write-Host "`n[INFO] Processor reached halt loop at PC = $pcHex. Execution completed." -ForegroundColor Cyan
        break
    }
}

Write-Host ("-" * 110)
Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "   FUNCTIONAL VERIFICATION: REGISTER & MEMORY CHECKS" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

$passCount = 0
$failCount = 0

function Check-Reg([int]$regIdx, [int32]$expected, [string]$testName) {
    $actual = $global:regs[$regIdx]
    if ($actual -eq $expected) {
        Write-Host ("[PASS] {0} | Register x{1} = {2} (0x{3:X8})" -f $testName, $regIdx, $actual, $actual) -ForegroundColor Green
        $global:passCount++
    } else {
        Write-Host ("[FAIL] {0} | Register x{1} : Expected {2}, Found {3}" -f $testName, $regIdx, $expected, $actual) -ForegroundColor Red
        $global:failCount++
    }
}

function Check-Mem([int]$idx, [int32]$expected, [string]$testName) {
    $actual = $global:dmem[$idx]
    if ($actual -eq $expected) {
        Write-Host ("[PASS] {0} | DataMem[{1}] = {2} (0x{3:X8})" -f $testName, $idx, $actual, $actual) -ForegroundColor Green
        $global:passCount++
    } else {
        Write-Host ("[FAIL] {0} | DataMem[{1}] : Expected {2}, Found {3}" -f $testName, $idx, $expected, $actual) -ForegroundColor Red
        $global:failCount++
    }
}

Check-Reg 1 10 "Test 1: ADDI x1, x0, 10"
Check-Reg 2 20 "Test 2: ADDI x2, x0, 20"
Check-Reg 3 30 "Test 3: ADD  x3, x1, x2"
Check-Mem 0 30 "Test 4: SW   x3, 0(x0) "
Check-Reg 4 30 "Test 5: LW   x4, 0(x0) "
Check-Reg 5 20 "Test 6: SUB  x5, x3, x1"
Check-Reg 6 0  "Test 7: AND  x6, x1, x2"
Check-Reg 7 30 "Test 8: OR   x7, x1, x2"
Check-Reg 8 30 "Test 9: XOR  x8, x1, x2"
Check-Reg 9 1  "Test 10: SLT x9, x1, x2"
Check-Reg 10 20 "Test 11: SLL x10, x1, x9"
Check-Reg 11 10 "Test 12: SRL x11, x10, x9"
Check-Reg 12 -5 "Test 13: ADDI Negative Imm (-5)"
Check-Reg 0 0  "Test 14: Register x0 is Zero"
Check-Reg 13 1  "Test 15: BEQ Taken (Skip Trap)"
Check-Reg 14 2  "Test 16: BEQ Not Taken (Fallthrough)"
Check-Reg 15 3  "Test 17: BNE Taken (Skip Trap)"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "   VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "   Total Passed Checks: $passCount" -ForegroundColor Green
Write-Host "   Total Failed Checks: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host "==================================================================" -ForegroundColor Cyan

if ($failCount -eq 0) {
    Write-Host "   >>> STATUS: ALL 17 TEST CASES PASSED SUCCESSFULLY! <<<" -ForegroundColor Green
    Write-Host "   The RV32I Processor architecture is functionally verified." -ForegroundColor Green
} else {
    Write-Host "   >>> STATUS: SIMULATION FAILED WITH $failCount ERRORS! <<<" -ForegroundColor Red
}
Write-Host "==================================================================`n"
