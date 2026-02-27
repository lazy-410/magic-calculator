#!/usr/bin/env pwsh

# Universal Git Push Script
# This script can be used in any Git repository

# 1. Set Git SSH command (specify key + auto trust host)
$env:GIT_SSH_COMMAND = "ssh -i /d/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

# 2. Check if current directory is a Git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Current directory is not a Git repository!"
    exit 1
}

# 3. Get repository information
$repoPath = Get-Location
Write-Host "=== Git Push Script ==="
Write-Host "Repository: $repoPath"

# 4. Get current branch
$currentBranch = git branch --show-current
if (-not $currentBranch) {
    Write-Host "❌ Error: Cannot determine current branch!"
    exit 1
}
Write-Host "Current branch: $currentBranch"

# 5. Execute Git operations
Write-Host "`n=== Executing git status ==="
git status

Write-Host "`n=== Executing git log --oneline ==="
git log --oneline -5

# 6. Execute git push
Write-Host "`n=== Executing git push ==="
try {
    # First try to push to origin with current branch
    git push origin $currentBranch
} catch {
    # If that fails, try to set upstream and push
    Write-Host "`n⚠️  Setting upstream branch and pushing..."
    git push --set-upstream origin $currentBranch
}

# 7. Output execution result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Push successful!"
} else {
    Write-Host "`n❌ Push failed, please check key or network!"
}

Write-Host "`n=== Script completed ==="
