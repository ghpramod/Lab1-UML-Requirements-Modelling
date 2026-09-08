# PowerShell script to easily push your repository to GitHub
param(
    [string]$RepoName = "Lab1-UML-Requirements-Modelling",
    [string]$RepoUrl
)

# 1. Locate Git and GH
$gitPath = (Get-Command git -ErrorAction SilentlyContinue)?.Source
if (-not $gitPath) {
    $vsGit = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe"
    if (Test-Path $vsGit) { $gitPath = $vsGit }
}

$ghPath = (Get-Command gh -ErrorAction SilentlyContinue)?.Source
if (-not $ghPath) {
    $defGh = "C:\Program Files\GitHub CLI\gh.exe"
    if (Test-Path $defGh) { $ghPath = $defGh }
}

Write-Host "=== GitHub Upload Helper ===" -ForegroundColor Cyan

# If GitHub CLI is available and authenticated
if ($ghPath) {
    $authStatus = & $ghPath auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "GitHub CLI is authenticated!" -ForegroundColor Green
        Write-Host "Creating and pushing repository '$RepoName' under your account..." -ForegroundColor Cyan
        & $ghPath repo create $RepoName --public --source=. --remote=origin --push
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n Successfully published to GitHub!" -ForegroundColor Green
            exit 0
        }
    }
}

# If not authenticated via gh, prompt for URL or auth
if (-not $RepoUrl) {
    Write-Host "`nGitHub CLI is not yet logged in." -ForegroundColor Yellow
    Write-Host "Option 1: Run 'gh auth login' to authenticate via browser." -ForegroundColor White
    Write-Host "Option 2: Create a repo manually on https://github.com/new and enter the URL below:" -ForegroundColor White
    $RepoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/ghpramod/Lab1-UML-Requirements-Modelling.git)"
}

if (-not $RepoUrl) {
    Write-Warning "No repository URL provided. Aborting push."
    exit 0
}

# Ensure branch is main and push via git
& $gitPath branch -M main
$existingRemote = & $gitPath remote get-url origin 2>$null
if ($existingRemote) {
    & $gitPath remote set-url origin $RepoUrl
} else {
    & $gitPath remote add origin $RepoUrl
}

Write-Host "Pushing to $RepoUrl..." -ForegroundColor Cyan
& $gitPath push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Warning "`nPush encountered an issue. Check your credentials or permissions."
}
