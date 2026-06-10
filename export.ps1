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

$dq = [char]34

# 3. DEFINE PROJECTS AND PARTS
$projects = @(
    @{
        ScadFile = "aeropress_cleaner.scad"
        Parts = @(
            @{ Name = "ring"; StlName = "ring" },
            @{ Name = "wiper"; StlName = "wiper" },
            @{ Name = "trigger"; StlName = "trigger" },
            @{ Name = "blade"; StlName = "blade" }
        )
        PngName = "preview_v2"
        PngCamera = "0,0,30,55,0,45,300"
        GifName = "plunger_scrape_v2"
        GifPitch = 55
        GifCamDist = 280
    },
    @{
        ScadFile = "filter_cleaner.scad"
        Parts = @(
            @{ Name = "front"; StlName = "filter_front" },
            @{ Name = "back"; StlName = "filter_back" },
            @{ Name = "blade"; StlName = "filter_blade" }
        )
        PngName = "filter_preview"
        PngCamera = "0,0,0,55,0,45,280"
        GifName = "filter_clean_anim"
        GifPitch = 55
        GifCamDist = 280
    }
)

# 4. RENDER LOOP
foreach ($proj in $projects) {
    Write-Host "Processing Project: $($proj.ScadFile)" -ForegroundColor Green
    
    # A. Render STL Parts
    foreach ($part in $proj.Parts) {
        $stlFile = "$stlDir/$($part.StlName).stl"
        Write-Host "  Rendering part $($part.Name) -> $stlFile" -ForegroundColor Yellow
        
        if (Test-Path $stlFile) { Remove-Item $stlFile }
        
        $partArg = "part=${dq}$($part.Name)${dq}"
        $stlArgs = @(
            "-o", $stlFile,
            "-D", $partArg,
            $proj.ScadFile
        )
        
        & $osPath $stlArgs | Out-Null
        
        if ((Test-Path $stlFile) -and (Get-Item $stlFile).Length -gt 0) {
            Write-Host "    [STL] Success" -ForegroundColor Green
        } else {
            Write-Host "    [STL] Failed" -ForegroundColor Red
        }
    }
    
    # B. Render PNG Preview
    if ($RenderPng) {
        $pngFile = "$pngDir/$($proj.PngName).png"
        Write-Host "  Rendering Preview PNG -> $pngFile" -ForegroundColor Yellow
        
        if (Test-Path $pngFile) { Remove-Item $pngFile }
        
        $partArg = "part=${dq}all${dq}"
        $pngArgs = @(
            "-o", $pngFile,
            "-D", $partArg,
            "--imgsize", "1280,720",
            "--camera", $proj.PngCamera,
            "--colorscheme", "DeepOcean",
            $proj.ScadFile
        )
        
        & $osPath $pngArgs | Out-Null
        
        if (Test-Path $pngFile) {
            Write-Host "    [PNG] Success" -ForegroundColor Green
        } else {
            Write-Host "    [PNG] Failed" -ForegroundColor Red
        }
    }
    
    # C. Render GIF Animation
    if ($RenderGif) {
        $gifFile = "$gifDir/$($proj.GifName).gif"
        Write-Host "  Rendering Animation GIF -> $gifFile" -ForegroundColor Yellow
        
        if (Test-Path $tempFrameDir) { Remove-Item -Recurse -Force $tempFrameDir }
        New-Item -ItemType Directory -Path $tempFrameDir | Out-Null
        
        $frameCount = 40
        Write-Host "    Rendering $frameCount frames..." -ForegroundColor Yellow
        
        for ($i = 0; $i -lt $frameCount; $i++) {
            $t_val = $i / $frameCount
            $frameName = "frame_$(($i).ToString('0000')).png"
            $pngFile = "$tempFrameDir/$frameName"
            
            $partArg = "part=${dq}all${dq}"
            $animateArg = "animate=true"
            $tArg = "time_t=$t_val"
            
            # Slow 720-degree camera sweep (2 full rotations)
            $cam_rot_z = 45 + ($i / $frameCount) * 720
            $cameraVal = "0,0,0,$($proj.GifPitch),0,$cam_rot_z,$($proj.GifCamDist)"
            if ($proj.ScadFile -eq "aeropress_cleaner.scad") {
                # Center camera slightly higher for plunger
                $cameraVal = "0,0,30,$($proj.GifPitch),0,$cam_rot_z,$($proj.GifCamDist)"
            }
            
            $frameArgs = @(
                "-o", $pngFile,
                "-D", $partArg,
                "-D", $animateArg,
                "-D", $tArg,
                "--imgsize", "640,360",
                "--camera", $cameraVal,
                "--colorscheme", "DeepOcean",
                $proj.ScadFile
            )
            
            & $osPath $frameArgs | Out-Null
        }
        
        if (Test-Path "$tempFrameDir/frame_0000.png") {
            Write-Host "    Combining frames into GIF..." -ForegroundColor Yellow
            
            $ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
            if ($ffmpegPath) {
                $ffmpegArgs = @(
                    "-y",
                    "-framerate", "5",
                    "-i", "$tempFrameDir/frame_%04d.png",
                    "-vf", "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
                    $gifFile
                )
                & $ffmpegPath $ffmpegArgs | Out-Null
            } else {
                $convertPath = Get-Command convert -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
                if ($convertPath) {
                    $convertArgs = @(
                        "-delay", "20",
                        "-loop", "0",
                        "$tempFrameDir/frame_*.png",
                        $gifFile
                    )
                    & $convertPath $convertArgs | Out-Null
                } else {
                    Write-Host "    ERROR: Neither ffmpeg nor convert found." -ForegroundColor Red
                }
            }
            
            if ((Test-Path $gifFile) -and (Get-Item $gifFile).Length -gt 0) {
                Write-Host "    [GIF] Success: $gifFile" -ForegroundColor Green
            } else {
                Write-Host "    [GIF] Failed assembling: $gifFile" -ForegroundColor Red
            }
        } else {
            Write-Host "    [GIF] Failed to generate frames" -ForegroundColor Red
        }
        
        if (Test-Path $tempFrameDir) { Remove-Item -Recurse -Force $tempFrameDir }
    }
}

Write-Host "--- All Processes Complete ---" -ForegroundColor Cyan
