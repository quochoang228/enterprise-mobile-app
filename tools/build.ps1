# Enterprise Mobile App Build Script
# Builds the app according to Architecture.md specifications

param(
    [string]$Environment = "development",
    [string]$Platform = "all",
    [switch]$Clean = $false,
    [switch]$Generate = $true,
    [switch]$Test = $false,
    [switch]$Analyze = $true
)

$ErrorActionPreference = "Stop"

Write-Host "🏗️  Enterprise Mobile App Build Script" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Platform: $Platform" -ForegroundColor Yellow

# Function to run build_runner in a package
function Build-Package {
    param([string]$PackagePath, [string]$PackageName)
    
    if (Test-Path "$PackagePath\pubspec.yaml") {
        Write-Host "📦 Building package: $PackageName" -ForegroundColor Green
        Set-Location $PackagePath
        flutter pub get
        
        if ($Generate) {
            Write-Host "🔧 Generating code for $PackageName..."
            dart run build_runner build --delete-conflicting-outputs
        }
        
        if ($Test) {
            Write-Host "🧪 Running tests for $PackageName..."
            flutter test
        }
        
        if ($Analyze) {
            Write-Host "🔍 Analyzing $PackageName..."
            dart analyze --fatal-infos
        }
        
        Set-Location $PSScriptRoot\..
    } else {
        Write-Host "⚠️  Skipping $PackageName (no pubspec.yaml found)" -ForegroundColor Yellow
    }
}

# Clean if requested
if ($Clean) {
    Write-Host "🧹 Cleaning workspace..." -ForegroundColor Yellow
    melos clean
}

# Get dependencies for all packages
Write-Host "📥 Getting dependencies..." -ForegroundColor Blue
melos get

# Build packages in dependency order
Write-Host "🔨 Building packages..." -ForegroundColor Blue

# Core package first
Build-Package "packages\core" "Core"

# Design system
Build-Package "packages\design_system" "Design System"

# Feature packages
Build-Package "packages\features\user_management" "User Management"

# Main app last
Build-Package "app" "Main App"

# Generate injection config
Write-Host "💉 Generating dependency injection..." -ForegroundColor Blue
Set-Location "app"
dart run injectable_generator:build
Set-Location $PSScriptRoot\..

# Build for specific platforms
if ($Platform -eq "android" -or $Platform -eq "all") {
    Write-Host "🤖 Building Android..." -ForegroundColor Green
    Set-Location "app"
    flutter build apk --release --dart-define=ENVIRONMENT=$Environment
    Set-Location $PSScriptRoot\..
}

if ($Platform -eq "ios" -or $Platform -eq "all") {
    Write-Host "🍎 Building iOS..." -ForegroundColor Green
    Set-Location "app"
    flutter build ios --release --no-codesign --dart-define=ENVIRONMENT=$Environment
    Set-Location $PSScriptRoot\..
}

if ($Platform -eq "web" -or $Platform -eq "all") {
    Write-Host "🌐 Building Web..." -ForegroundColor Green
    Set-Location "app"
    flutter build web --release --dart-define=ENVIRONMENT=$Environment
    Set-Location $PSScriptRoot\..
}

Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Platform: $Platform" -ForegroundColor Yellow
