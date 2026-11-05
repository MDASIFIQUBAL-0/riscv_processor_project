param(
    [Parameter(Mandatory=$false)]
    [string]$Token
)

$git = "$env:LOCALAPPDATA\Programs\MinGit\cmd\git.exe"

if (-not $Token) {
    Write-Host "`nTo push to GitHub, a Personal Access Token (PAT) is required." -ForegroundColor Yellow
    Write-Host "1. Create a token in 30 seconds at: https://github.com/settings/tokens/new" -ForegroundColor Cyan
    Write-Host "   - Name: 'RISCV-Deploy'"
    Write-Host "   - Check the 'repo' box"
    Write-Host "   - Click 'Generate token' and copy the token (starts with ghp_...)" -ForegroundColor Cyan
    Write-Host ""
    $Token = Read-Host "Paste your GitHub Personal Access Token here" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)
    $Token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

if (-not $Token) {
    Write-Host "[ERROR] No token provided. Aborting." -ForegroundColor Red
    exit 1
}

Write-Host "`nPushing to https://github.com/MDASIFIQUBAL-0/riscv_processor_project..." -ForegroundColor Green
$remoteUrl = "https://${Token}@github.com/MDASIFIQUBAL-0/riscv_processor_project.git"

& $git push -u $remoteUrl main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================================================" -ForegroundColor Green
    Write-Host " [SUCCESS] All files deployed successfully to:" -ForegroundColor Green
    Write-Host " https://github.com/MDASIFIQUBAL-0/riscv_processor_project" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Push failed. Please check that the token has 'repo' permissions." -ForegroundColor Red
}
