@echo off
echo ====================================================================
echo   Deploying RISC-V Processor Project to GitHub (MDASIFIQUBAL-0)
echo ====================================================================
echo.
echo Make sure you have created the empty repository on GitHub:
echo https://github.com/new -> Name: riscv_processor_project
echo.
pause
"%LOCALAPPDATA%\Programs\MinGit\cmd\git.exe" push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Project deployed successfully to https://github.com/MDASIFIQUBAL-0/riscv_processor_project
) else (
    echo [NOTE] If prompted for credentials, use your GitHub username and Personal Access Token (PAT).
)
pause
