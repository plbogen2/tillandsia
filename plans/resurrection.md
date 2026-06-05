# Jetski Project Resurrection State: Aeropress Desk Cleaning System (ADCF)

Use this file to instantly restore context, design knowledge, and execution progress when starting a new session or switching development machines.

---

## 1. Project Goal
Design and print a support-free, office-desk-friendly cleaning system for the **AeroPress** coffee maker that cleans:
1.  **The Rubber Plunger Seal face & sides** (standard diameter: **57.2mm**, dome: **3.5mm**).
2.  **The Stainless Steel Metal Filter disc** (standard diameter: **62.0mm**, thickness: **0.3mm**).

---

## 2. Selected Architecture: 2-Part Separate Tools (Option B)
After iterating on an integrated single-tool design, we separated the system into two distinct components. This resolved physical collisions, avoided print overhang/sag issues, and simplified daily usage.

### Part 1: Funnel Body (Rigid - PETG/PLA)
*   **Role**: Simple, open waste-directing funnel with a comfortable handle. Directs grounds and rinses straight into the trash can.
*   **Features**:
    *   No slots, notches, or inner channels (extremely easy to rinse clean).
    *   Ergonomic, thick, rounded D-loop handle.
    *   100% support-free slopes (cone angles $\le 45^\circ$, brackets print vertically).

### Part 2: Dual-Purpose Handheld Scraper (Flexible - TPU/Flexible PLA)
*   **Role**: A single handheld squeegee tool used manually over the funnel.
*   **Plunger Scraper End**: A U-shaped hook with a concave curve matching the 57.2mm plunger face and sides. Wipes the dome clean in one rotational swipe.
*   **Filter Scraper End**: A split-jaw squeegee clamp built with a **living hinge**.
    *   **Flat Print Layout**: Prints completely open and flat on the bed to guarantee the scraping lips print perfectly without sagging or fusing.
    *   **Snap Pins**: Fold the upper jaw $180^\circ$ over the lower jaw and press-fit the pegs into the holes. This aligns the two squeegee lips face-to-face with a 1mm slot gap.
    *   **Use**: Push the metal filter disc through the jaws vertically. Wipes both sides clean; grounds fall straight down.

---

## 3. Parametric Design Values (in `aeropress_cleaner.scad`)
If you need to customize the sizes:
*   `plunger_di = 57.2;` (AeroPress plunger seal diameter)
*   `plunger_dome_h = 3.5;` (dome height)
*   `filter_di = 62.0;` (metal filter disc diameter)
*   `filter_thickness = 0.3;` (metal filter thickness)
*   `wall_thickness = 2.4;` (funnel rigid shell)

---

## 4. Repository File Index
*   [`aeropress_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad): Parametric OpenSCAD CAD model. Customizer selects `part="all"`, `part="funnel"`, or `part="scraper"`.
*   [`export.ps1`](file:///usr/local/google/home/plbogen/github/tillandsia/export.ps1): PowerShell script that exports the STLs and builds the rendering animations.
*   [`.github/workflows/export-stls.yml`](file:///usr/local/google/home/plbogen/github/tillandsia/.github/workflows/export-stls.yml): GitHub Actions CI workflow that automates exporting STLs and rendering preview animations on every push.
*   [`README.md`](file:///usr/local/google/home/plbogen/github/tillandsia/README.md): Landing page documentation with standard side-by-side animation tables.
*   [`plans/handoff_transcript.md`](file:///usr/local/google/home/plbogen/github/tillandsia/plans/handoff_transcript.md): Detailed narrative of the engineering decisions during layout changes.

---

## 5. Next Steps for the Developer
1.  **Monitor the CI Build**: Check that the latest GitHub actions run completes successfully and updates the repository's preview GIFs:
    *   https://github.com/plbogen2/tillandsia/actions
2.  **Slicing and Printing**:
    *   Load `STLs/funnel.stl` into your slicer. Print in PETG or PLA. No supports.
    *   Load `STLs/scraper.stl` into your slicer. Print in Flexible PLA or TPU. No supports.
3.  **Assembly**:
    *   Fold the scraper tool's filter end and press the snap pegs into the holes.
    *   Test squeegeeing actions over the funnel!
