#!/usr/bin/env pwsh

# Git Cloud Repositories Script
# This script allows you to manage your GitHub repositories

Write-Host "=== Git Cloud Repositories Script ===" -ForegroundColor Green

# 1. Set Git SSH command (specify key + auto trust host)
$env:GIT_SSH_COMMAND = "ssh -i /d/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

# 2. Get GitHub username
Write-Host "`nPlease enter your GitHub username:" -ForegroundColor Cyan
$username = Read-Host

if (-not $username) {
    Write-Host "`n❌ Username cannot be empty!" -ForegroundColor Red
    exit 1
}

# 3. Try to get repositories from GitHub API
Write-Host "`nFetching repositories for user: $username" -ForegroundColor Cyan
try {
    $reposUrl = "https://api.github.com/users/$username/repos"
    $repos = Invoke-RestMethod -Uri $reposUrl -Method Get
    
    if ($repos.Count -eq 0) {
        Write-Host "`n❌ No repositories found for user: $username" -ForegroundColor Red
        exit 1
    }
    
    # 4. Display repositories
    Write-Host "`nFound $($repos.Count) repositories:" -ForegroundColor Green
    $repoList = @()
    $counter = 1
    
    $repos | ForEach-Object {
        $repoList += [PSCustomObject]@{ 
            Index = $counter
            Name = $_.name
            Url = $_.ssh_url
            Description = $_.description
        }
        Write-Host "$($counter). $($_.name)" -ForegroundColor White
        if ($_.description) {
            Write-Host "   Description: $($_.description)" -ForegroundColor Gray
        }
        $counter++
    }
    
    # 5. Get user selection
    Write-Host "`nPlease select a repository (enter number):" -ForegroundColor Cyan
    $selection = Read-Host
    
    # Validate selection
    $selectedRepo = $repoList | Where-Object { $_.Index -eq $selection }
    if (-not $selectedRepo) {
        Write-Host "`n❌ Invalid selection!" -ForegroundColor Red
        exit 1
    }
    
    # 6. Ask for operation
    Write-Host "`nSelected repository: $($selectedRepo.Name)" -ForegroundColor Green
    Write-Host "SSH URL: $($selectedRepo.Url)" -ForegroundColor White
    
    Write-Host "`nPlease select an operation:" -ForegroundColor Cyan
    Write-Host "1. Clone repository to local"
    Write-Host "2. Push to repository (if already cloned)"
    $operation = Read-Host
    
    # 7. Execute operation
    switch ($operation) {
        "1" {
            # Clone repository
            Write-Host "`nEnter directory to clone into (leave empty for current directory):" -ForegroundColor Cyan
            $cloneDir = Read-Host
            if (-not $cloneDir) {
                $cloneDir = Get-Location
            }
            
            Write-Host "`nCloning repository..." -ForegroundColor Green
            git clone $selectedRepo.Url $cloneDir
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Repository cloned successfully!" -ForegroundColor Green
            } else {
                Write-Host "`n❌ Failed to clone repository!" -ForegroundColor Red
            }
        }
        "2" {
            # Push to repository
            Write-Host "`nEnter path to local repository (leave empty for current directory):" -ForegroundColor Cyan
            $repoPath = Read-Host
            if (-not $repoPath) {
                $repoPath = Get-Location
            }
            
            if (-not (Test-Path "$repoPath\.git")) {
                Write-Host "`n❌ Not a Git repository!" -ForegroundColor Red
                exit 1
            }
            
            Write-Host "`nNavigating to repository..." -ForegroundColor Green
            Set-Location $repoPath
            
            # Check remote
            $remote = git remote -v | Select-String $selectedRepo.Name
            if (-not $remote) {
                Write-Host "`n⚠️  Remote not found, adding remote..." -ForegroundColor Yellow
                git remote add origin $selectedRepo.Url
            }
            
            # Push
            Write-Host "`nPushing to repository..." -ForegroundColor Green
            git push origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Push successful!" -ForegroundColor Green
            } else {
                Write-Host "`n❌ Push failed!" -ForegroundColor Red
            }
        }
        default {
            Write-Host "`n❌ Invalid operation!" -ForegroundColor Red
            exit 1
        }
    }
    
} catch {
    Write-Host "`n❌ Error fetching repositories: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nYou can still manually enter repository URL:" -ForegroundColor Cyan
    
    # 8. Manual repository URL entry
    Write-Host "`nEnter GitHub repository SSH URL (e.g., git@github.com:username/repo.git):" -ForegroundColor Cyan
    $repoUrl = Read-Host
    
    if (-not $repoUrl) {
        Write-Host "`n❌ URL cannot be empty!" -ForegroundColor Red
        exit 1
    }
    
    # 9. Ask for operation
    Write-Host "`nPlease select an operation:" -ForegroundColor Cyan
    Write-Host "1. Clone repository to local"
    Write-Host "2. Push to repository (if already cloned)"
    $operation = Read-Host
    
    # 10. Execute operation
    switch ($operation) {
        "1" {
            # Clone repository
            Write-Host "`nEnter directory to clone into (leave empty for current directory):" -ForegroundColor Cyan
            $cloneDir = Read-Host
            if (-not $cloneDir) {
                $cloneDir = Get-Location
            }
            
            Write-Host "`nCloning repository..." -ForegroundColor Green
            git clone $repoUrl $cloneDir
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Repository cloned successfully!" -ForegroundColor Green
            } else {
                Write-Host "`n❌ Failed to clone repository!" -ForegroundColor Red
            }
        }
        "2" {
            # Push to repository
            Write-Host "`nEnter path to local repository (leave empty for current directory):" -ForegroundColor Cyan
            $repoPath = Read-Host
            if (-not $repoPath) {
                $repoPath = Get-Location
            }
            
            if (-not (Test-Path "$repoPath\.git")) {
                Write-Host "`n❌ Not a Git repository!" -ForegroundColor Red
                exit 1
            }
            
            Write-Host "`nNavigating to repository..." -ForegroundColor Green
            Set-Location $repoPath
            
            # Check remote
            $remote = git remote -v | Select-String "origin"
            if (-not $remote) {
                Write-Host "`n⚠️  Remote not found, adding remote..." -ForegroundColor Yellow
                git remote add origin $repoUrl
            }
            
            # Push
            Write-Host "`nPushing to repository..." -ForegroundColor Green
            git push origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Push successful!" -ForegroundColor Green
            } else {
                Write-Host "`n❌ Push failed!" -ForegroundColor Red
            }
        }
        default {
            Write-Host "`n❌ Invalid operation!" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "`n=== Script completed ===" -ForegroundColor Green
