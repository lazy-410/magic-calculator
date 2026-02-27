#!/usr/bin/env pwsh

# Git Push Select Script
# This script searches for Git repositories and allows you to select one to push

# 1. Set Git SSH command (specify key + auto trust host)
$env:GIT_SSH_COMMAND = "ssh -i /d/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

Write-Host "=== Git Push Select Script ===" -ForegroundColor Green

# 2. Check current directory
$repos = @()
$counter = 1

# Check current directory
if (Test-Path ".git") {
    $repos += [PSCustomObject]@{ 
        Index = $counter
        Path = Get-Location
    }
    $counter++
}

# 3. Search for Git repositories in subdirectories
Write-Host "`nSearching for Git repositories..." -ForegroundColor Cyan
Get-ChildItem -Directory | ForEach-Object {
    if (Test-Path "$($_.FullName)\.git") {
        $repos += [PSCustomObject]@{ 
            Index = $counter
            Path = $_.FullName
        }
        $counter++
    }
}

# 4. Add option to enter custom path
$repos += [PSCustomObject]@{ 
    Index = $counter
    Path = "[Enter custom path]"
}

# 5. Display repositories
Write-Host "`nAvailable options:" -ForegroundColor Green
$repos | ForEach-Object {
    Write-Host "$($_.Index). $($_.Path)" -ForegroundColor White
}

# 6. Get user selection
Write-Host "`nPlease select an option (enter number):" -ForegroundColor Cyan
$selection = Read-Host

# 7. Process selection
$selectedRepo = $repos | Where-Object { $_.Index -eq $selection }
if (-not $selectedRepo) {
    Write-Host "`n❌ Invalid selection!" -ForegroundColor Red
    exit 1
}

# 8. Handle custom path
$repoPath = $selectedRepo.Path
if ($repoPath -eq "[Enter custom path]") {
    Write-Host "`nPlease enter the Git repository path:" -ForegroundColor Cyan
    $customPath = Read-Host
    if (-not (Test-Path "$customPath\.git")) {
        Write-Host "`n❌ Invalid Git repository path!" -ForegroundColor Red
        exit 1
    }
    $repoPath = $customPath
}

# 9. Navigate to selected repository
Write-Host "`nNavigating to: $repoPath" -ForegroundColor Green
Set-Location $repoPath

# 10. Get repository information
$currentBranch = git branch --show-current
if (-not $currentBranch) {
    Write-Host "`n❌ Error: Cannot determine current branch!" -ForegroundColor Red
    exit 1
}

Write-Host "`nRepository: $repoPath" -ForegroundColor White
Write-Host "Current branch: $currentBranch" -ForegroundColor White

# 11. Execute Git operations
Write-Host "`n=== Executing git status ===" -ForegroundColor Cyan
git status

Write-Host "`n=== Executing git log --oneline ===" -ForegroundColor Cyan
git log --oneline -5

# 12. Execute git push
Write-Host "`n=== Executing git push ===" -ForegroundColor Cyan
try {
    # First try to push to origin with current branch
    git push origin $currentBranch
} catch {
    # If that fails, try to set upstream and push
    Write-Host "`n⚠️  Setting upstream branch and pushing..." -ForegroundColor Yellow
    git push --set-upstream origin $currentBranch
}

# 13. Output execution result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Push successful!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Push failed, please check key or network!" -ForegroundColor Red
}

Write-Host "`n=== Script completed ===" -ForegroundColor Green
