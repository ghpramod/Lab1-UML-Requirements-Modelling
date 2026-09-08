# PowerShell script to easily push your repository to GitHub
param(
    [string]$RepoUrl
)

# 1. Locate Git executable
$gitPath = (Get-Command git -ErrorAction SilentlyContinue)?.Source
if (-not $gitPath) {
    $vsGit = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe"
    if (Test-Path $vsGit) {
        $gitPath = $vsGit
    } else {
        Write-Error "Git executable could not be found. Please ensure Git or Visual Studio is installed."
        exit 1
    }
}

Write-Host "Using Git at: $gitPath" -ForegroundColor Green

# 2. Check if RepoUrl was provided
if (-not $RepoUrl) {
    Write-Host "`n=== GitHub Upload Helper ===" -ForegroundColor Cyan
    Write-Host "Please create a new repository on GitHub (https://github.com/new) without initializing with a README."
    $RepoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/YOUR_USERNAME/Lab1-UML-Requirements.git)"
}

if (-not $RepoUrl) {
    Write-Warning "No repository URL provided. Aborting push."
    exit 0
}

# 3. Ensure branch is main
& $gitPath branch -M main

# 4. Configure remote
$existingRemote = & $gitPath remote get-url origin 2>$null
if ($existingRemote) {
    & $gitPath remote set-url origin $RepoUrl
    Write-Host "Updated remote origin to: $RepoUrl" -ForegroundColor Yellow
} else {
    & $gitPath remote add origin $RepoUrl
    Write-Host "Added remote origin: $RepoUrl" -ForegroundColor Green
}

# 5. Push to GitHub
Write-Host "Pushing to GitHub (main branch)..." -ForegroundColor Cyan
& $gitPath push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "Visit your repo at: $RepoUrl" -ForegroundColor Cyan
} else {
    Write-Warning "`nPush encountered an issue. If prompted for credentials, please provide your GitHub Personal Access Token (PAT) or log in."
}
