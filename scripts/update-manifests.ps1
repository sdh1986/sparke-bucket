#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update Scoop bucket manifests automatically
    
.DESCRIPTION
    This script checks for updates to all manifests in the bucket directory
    and updates them if newer versions are available.
    
.PARAMETER DryRun
    Only check for updates without actually updating the files
    
.PARAMETER App
    Specific app to update (optional)
    
.EXAMPLE
    .\update-manifests.ps1
    .\update-manifests.ps1 -DryRun
    .\update-manifests.ps1 -App pixpin
#>

param(
    [switch]$DryRun,
    [string]$App
)

# 设置错误处理
$ErrorActionPreference = "Continue"

# 颜色函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# 获取脚本目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bucketDir = Join-Path $scriptDir "..\bucket"

# 检查 bucket 目录是否存在
if (-not (Test-Path $bucketDir)) {
    Write-ColorOutput Red "Error: bucket directory not found at $bucketDir"
    exit 1
}

# 安装 Scoop（如果未安装）
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Yellow "Scoop not found, installing..."
    try {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    } catch {
        Write-ColorOutput Red "Failed to install Scoop: $($_.Exception.Message)"
        exit 1
    }
}

# 克隆 Scoop 仓库以获取 checkver 脚本
$tempDir = Join-Path $env:TEMP "scoop-core"
if (-not (Test-Path $tempDir)) {
    Write-ColorOutput Yellow "Cloning Scoop repository..."
    git clone https://github.com/ScoopInstaller/Scoop.git $tempDir
}

$checkver = Join-Path $tempDir "bin\checkver.ps1"

# 获取要更新的应用列表
if ($App) {
    $manifests = @($App)
    Write-ColorOutput Blue "Updating specific app: $App"
} else {
    $manifests = Get-ChildItem "$bucketDir\*.json" | Select-Object -ExpandProperty BaseName
    Write-ColorOutput Blue "Found $($manifests.Count) manifests to check"
}

$updatedApps = @()
$failedApps = @()
$noUpdateApps = @()

foreach ($app in $manifests) {
    $manifestPath = Join-Path $bucketDir "$app.json"
    
    if (-not (Test-Path $manifestPath)) {
        Write-ColorOutput Red "Manifest not found: $manifestPath"
        $failedApps += $app
        continue
    }
    
    Write-ColorOutput Green "Checking $app for updates..."
    
    try {
        $beforeContent = Get-Content $manifestPath -Raw
        $beforeVersion = ($beforeContent | ConvertFrom-Json).version
        
        if ($DryRun) {
            Write-ColorOutput Yellow "  Dry run mode - would check for updates"
        } else {
            & $checkver -App $app -Dir $bucketDir -Update
        }
        
        $afterContent = Get-Content $manifestPath -Raw
        $afterVersion = ($afterContent | ConvertFrom-Json).version
        
        if ($beforeContent -ne $afterContent) {
            $updatedApps += $app
            Write-ColorOutput Green "  ✓ Updated from $beforeVersion to $afterVersion"
        } else {
            $noUpdateApps += $app
            Write-ColorOutput Yellow "  - Already at latest version ($beforeVersion)"
        }
        
    } catch {
        $failedApps += $app
        Write-ColorOutput Red "  ✗ Error: $($_.Exception.Message)"
    }
}

# 输出总结
Write-Host "`n" -NoNewline
Write-ColorOutput Blue "=== Update Summary ==="

if ($updatedApps) {
    Write-ColorOutput Green "✅ Updated Apps ($($updatedApps.Count)):"
    foreach ($app in $updatedApps) {
        Write-Host "  - $app"
    }
}

if ($noUpdateApps) {
    Write-ColorOutput Yellow "📋 No Updates ($($noUpdateApps.Count)):"
    foreach ($app in $noUpdateApps) {
        Write-Host "  - $app"
    }
}

if ($failedApps) {
    Write-ColorOutput Red "❌ Failed Apps ($($failedApps.Count)):"
    foreach ($app in $failedApps) {
        Write-Host "  - $app"
    }
}

Write-Host ""

# 如果有更新且不是干运行模式，询问是否提交
if ($updatedApps -and -not $DryRun) {
    $response = Read-Host "Do you want to commit these changes? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        try {
            Set-Location (Split-Path -Parent $bucketDir)
            git add bucket/*.json
            $date = Get-Date -Format "yyyy-MM-dd HH:mm"
            git commit -m "Update: $($updatedApps -join ', ') - $date"
            Write-ColorOutput Green "Changes committed successfully!"
        } catch {
            Write-ColorOutput Red "Failed to commit changes: $($_.Exception.Message)"
        }
    }
}
