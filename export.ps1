param(
    [switch]$RenderPng = $false,
    [switch]$RenderGif = $false
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
$gifDir = "./Animation"
$tempFrameDir = "./temp_frames"

if (!(Test-Path $stlDir)) { New-Item -ItemType Directory -Path $stlDir }
if ($RenderPng -and !(Test-Path $pngDir)) { New-Item -ItemType Directory -Path $pngDir }
if ($RenderGif -and !(Test-Path $gifDir)) { New-Item -ItemType Directory -Path $gifDir }

Write-Host "--- Starting Render Loop ---" -ForegroundColor Cyan
Write-Host "Using OpenSCAD at: $osPath"

# Double-quote character for arguments
$dq = [char]34

# 3. RENDER STL PARTS
$parts = @(
    "funnel",
    "scraper"
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

# 5. RENDER GIF ANIMATION
if ($RenderGif) {
    $gifFile = "$gifDir/aeropress_cleaner.gif"
    Write-Host "Rendering Animation GIF -> $gifFile" -ForegroundColor Yellow
    
    if (Test-Path $tempFrameDir) { Remove-Item -Recurse -Force $tempFrameDir }
    New-Item -ItemType Directory -Path $tempFrameDir | Out-Null
    
    $frameCount = 40
    Write-Host "  Rendering $frameCount frames..." -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $frameCount; $i++) {
        $t_val = $i / $frameCount
        $frameName = "frame_$(($i).ToString('0000')).png"
        $pngFile = "$tempFrameDir/$frameName"
        
        $partArg = "part=${dq}all${dq}"
        $animateArg = "animate=true"
        $tArg = "time_t=$t_val"
        
        # Spin the camera 360 degrees around Z axis over the animation course
        $cam_rot_z = 45 + ($i / $frameCount) * 360
        $cameraVal = "0,0,30,55,0,$cam_rot_z,280"
        
        $frameArgs = @(
            "-o", $pngFile,
            "-D", $partArg,
            "-D", $animateArg,
            "-D", $tArg,
            "--imgsize", "640,360",
            "--camera", $cameraVal,
            "--colorscheme", "DeepOcean",
            "--enable", "manifold",
            "aeropress_cleaner.scad"
        )
        
        # Render single frame
        & $osPath $frameArgs | Out-Null
    }
    
    if (Test-Path "$tempFrameDir/frame_0000.png") {
        Write-Host "  Frames generated. Combining into GIF..." -ForegroundColor Yellow
        
        # Check if ffmpeg is available
        $ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
        if ($ffmpegPath) {
            # Combine using ffmpeg (generates a very clean optimized palette GIF)
            $ffmpegArgs = @(
                "-y",
                "-framerate", "10",
                "-i", "$tempFrameDir/frame_%04d.png",
                "-vf", "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
                $gifFile
            )
            & $ffmpegPath $ffmpegArgs | Out-Null
        } else {
            # Fallback to ImageMagick's convert
            $convertPath = Get-Command convert -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
            if ($convertPath) {
                $convertArgs = @(
                    "-delay", "10",
                    "-loop", "0",
                    "$tempFrameDir/frame_*.png",
                    $gifFile
                )
                & $convertPath $convertArgs | Out-Null
            } else {
                Write-Host "  ERROR: Neither ffmpeg nor convert (ImageMagick) found. Cannot assemble GIF." -ForegroundColor Red
            }
        }
        
        if ((Test-Path $gifFile) -and (Get-Item $gifFile).Length -gt 0) {
            Write-Host "  [GIF] Success" -ForegroundColor Green
        } else {
            Write-Host "  [GIF] Failed assembling" -ForegroundColor Red
        }
    } else {
        Write-Host "  [GIF] Failed to generate frames" -ForegroundColor Red
    }
    
    # Clean up temp frames
    if (Test-Path $tempFrameDir) { Remove-Item -Recurse -Force $tempFrameDir }
}

Write-Host "--- All Processes Complete ---" -ForegroundColor Cyan
