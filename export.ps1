param(
    [switch]$RenderPng = $false
)

# 1. FIND OPENSCAD INSTALLATION
$possiblePaths = @(
    "$env:LOCALAPPDATA\Programs\OpenSCAD",
    "$env:LOCALAPPDATA\OpenSCAD",
    "C:\Program Files\OpenSCAD",
    "C:\Program Files (x86)\OpenSCAD",
    "/usr/bin", # For Linux (GitHub Actions)
    "/usr/local/bin"
)

$osPath = ""
$exeName = if ($IsWindows -or $env:OS -like "*Windows*") { "openscad.com" } else { "openscad" }

foreach ($p in $possiblePaths) {
    if (Test-Path "$p/$exeName") {
        $osPath = "$p/$exeName"
        break
    }
}

if ($osPath -eq "") {
    $osPath = Get-Command $exeName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

if (!$osPath) {
    Write-Host "ERROR: OpenSCAD not found." -ForegroundColor Red
    return
}

# 2. SETUP DIRECTORIES
$stlDir = "./STLs"
$pngDir = "./PNGs"

if (!(Test-Path $stlDir)) { New-Item -ItemType Directory -Path $stlDir }
if ($RenderPng -and !(Test-Path $pngDir)) { New-Item -ItemType Directory -Path $pngDir }

Write-Host "--- Starting Render Loop ---" -ForegroundColor Cyan
Write-Host "Using OpenSCAD at: $osPath"

# Double-quote character for arguments
$dq = [char]34

# 3. RENDER STL PARTS
$parts = @(
    "funnel",
    "plunger_insert",
    "filter_insert"
)

foreach ($pName in $parts) {
    $stlFile = "$stlDir/$pName.stl"
    Write-Host "Rendering $pName -> $stlFile" -ForegroundColor Yellow
    
    if (Test-Path $stlFile) { Remove-Item $stlFile }
    
    $partArg = "part=${dq}$pName${dq}"
    $stlArgs = @(
        "-o", $stlFile,
        "-D", $partArg,
        "--enable", "manifold",
        "aeropress_cleaner.scad"
    )
    
    & $osPath $stlArgs

    if ((Test-Path $stlFile) -and (Get-Item $stlFile).Length -gt 0) {
        Write-Host "  [STL] Success" -ForegroundColor Green
    } else {
        Write-Host "  [STL] Failed" -ForegroundColor Red
    }
}

# 4. RENDER PNG PREVIEW
if ($RenderPng) {
    $pngFile = "$pngDir/preview.png"
    Write-Host "Rendering Preview PNG -> $pngFile" -ForegroundColor Yellow
    
    if (Test-Path $pngFile) { Remove-Item $pngFile }
    
    $partArg = "part=${dq}all${dq}"
    $pngArgs = @(
        "-o", $pngFile,
        "-D", $partArg,
        "--imgsize", "1280,720",
        "--camera", "0,0,30,55,0,45,300",
        "--colorscheme", "DeepOcean",
        "--enable", "manifold",
        "aeropress_cleaner.scad"
    )
    
    & $osPath $pngArgs

    if (Test-Path $pngFile) {
        Write-Host "  [PNG] Success" -ForegroundColor Green
    } else {
        Write-Host "  [PNG] Failed" -ForegroundColor Red
    }
}

Write-Host "--- All Processes Complete ---" -ForegroundColor Cyan
