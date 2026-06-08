#!/bin/bash
# Bash script to export STLs and compile animations for Aeropress Cleaners on Linux

RENDER_PNG=false
RENDER_GIF=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -RenderPng|--png) RENDER_PNG=true ;;
        -RenderGif|--gif) RENDER_GIF=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Setup directories
STL_DIR="./STLs"
PNG_DIR="./PNGs"
GIF_DIR="./Animation"
TEMP_DIR="./temp_frames"

mkdir -p "$STL_DIR"
if [ "$RENDER_PNG" = true ]; then mkdir -p "$PNG_DIR"; fi
if [ "$RENDER_GIF" = true ]; then mkdir -p "$GIF_DIR"; fi

echo "--- Starting Render Loop ---"

# Check if openscad is available
if ! command -v openscad &> /dev/null; then
    echo "ERROR: openscad command not found. Please install it using: sudo apt install openscad"
    exit 1
fi

# Check if ffmpeg is available if rendering GIF
if [ "$RENDER_GIF" = true ] && ! command -v ffmpeg &> /dev/null; then
    echo "ERROR: ffmpeg command not found. Please install it using: sudo apt install ffmpeg"
    exit 1
fi

# Plunger Cleaner Project
scad_plunger="aeropress_cleaner.scad"
parts_plunger=("ring" "wiper" "trigger" "blade")
png_plunger="preview_v2"
cam_png_plunger="0,0,30,55,0,45,300"
gif_plunger="plunger_scrape_v2"
pitch_plunger=55
dist_plunger=280

# Filter Cleaner Project
scad_filter="filter_cleaner.scad"
parts_filter=("front" "back" "blade")
filter_output_names=("filter_front" "filter_back" "filter_blade")
png_filter="filter_preview"
cam_png_filter="0,0,0,55,0,45,280"
gif_filter="filter_clean_anim"
pitch_filter=55
dist_filter=280

# 1. RENDER PLUNGER PARTS
echo "Processing Project: $scad_plunger"
for part in "${parts_plunger[@]}"; do
    echo "  Rendering part $part -> $STL_DIR/$part.stl"
    rm -f "$STL_DIR/$part.stl"
    openscad -o "$STL_DIR/$part.stl" -D "part=\"$part\"" "$scad_plunger"
done

# 2. RENDER PLUNGER PNG
if [ "$RENDER_PNG" = true ]; then
    echo "  Rendering Preview PNG -> $PNG_DIR/$png_plunger.png"
    rm -f "$PNG_DIR/$png_plunger.png"
    openscad -o "$PNG_DIR/$png_plunger.png" -D "part=\"all\"" --imgsize 1280,720 --camera "$cam_png_plunger" --colorscheme DeepOcean "$scad_plunger"
fi

# 3. RENDER PLUNGER GIF
if [ "$RENDER_GIF" = true ]; then
    echo "  Rendering Animation GIF -> $GIF_DIR/$gif_plunger.gif"
    rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR"
    
    for i in {0..39}; do
        t_val=$(awk "BEGIN {print $i / 40}")
        frame_name=$(printf "frame_%04d.png" "$i")
        cam_rot_z=$(awk "BEGIN {print 45 + ($i / 40) * 90}")
        camera_val="0,0,30,$pitch_plunger,0,$cam_rot_z,$dist_plunger"
        
        openscad -o "$TEMP_DIR/$frame_name" -D "part=\"all\"" -D "animate=true" -D "time_t=$t_val" --imgsize 640,360 --camera "$camera_val" --colorscheme DeepOcean "$scad_plunger" > /dev/null 2>&1
    done
    
    ffmpeg -y -framerate 5 -i "$TEMP_DIR/frame_%04d.png" -vf "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$GIF_DIR/$gif_plunger.gif" > /dev/null 2>&1
    rm -rf "$TEMP_DIR"
fi

# 4. RENDER FILTER PARTS
echo "Processing Project: $scad_filter"
for i in "${!parts_filter[@]}"; do
    part="${parts_filter[$i]}"
    out_name="${filter_output_names[$i]}"
    echo "  Rendering part $part -> $STL_DIR/$out_name.stl"
    rm -f "$STL_DIR/$out_name.stl"
    openscad -o "$STL_DIR/$out_name.stl" -D "part=\"$part\"" "$scad_filter"
done

# 5. RENDER FILTER PNG
if [ "$RENDER_PNG" = true ]; then
    echo "  Rendering Preview PNG -> $PNG_DIR/$png_filter.png"
    rm -f "$PNG_DIR/$png_filter.png"
    openscad -o "$PNG_DIR/$png_filter.png" -D "part=\"all\"" --imgsize 1280,720 --camera "$cam_png_filter" --colorscheme DeepOcean "$scad_filter"
fi

# 6. RENDER FILTER GIF
if [ "$RENDER_GIF" = true ]; then
    echo "  Rendering Animation GIF -> $GIF_DIR/$gif_filter.gif"
    rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR"
    
    for i in {0..39}; do
        t_val=$(awk "BEGIN {print $i / 40}")
        frame_name=$(printf "frame_%04d.png" "$i")
        cam_rot_z=$(awk "BEGIN {print 45 + ($i / 40) * 90}")
        camera_val="0,0,0,$pitch_filter,0,$cam_rot_z,$dist_filter"
        
        openscad -o "$TEMP_DIR/$frame_name" -D "part=\"all\"" -D "animate=true" -D "time_t=$t_val" --imgsize 640,360 --camera "$camera_val" --colorscheme DeepOcean "$scad_filter" > /dev/null 2>&1
    done
    
    ffmpeg -y -framerate 5 -i "$TEMP_DIR/frame_%04d.png" -vf "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$GIF_DIR/$gif_filter.gif" > /dev/null 2>&1
    rm -rf "$TEMP_DIR"
fi

echo "--- All Processes Complete ---"
