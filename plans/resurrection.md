# Jetski Project Resurrection State: Aeropress Desk Cleaning Funnel (ADCF) - Mechanical Wiper

Use this file to instantly restore context, design knowledge, and execution progress when starting a new session or switching development machines.

---

## 1. Project Goal
Design and print a support-free, office-desk-friendly cleaning funnel for the **AeroPress** coffee maker plunger face:
*   Cleans the flat/domed circular plunger seal face (diameter **57.2mm**, dome: **3.5mm**).
*   Uses a **pivoted squeegee wiper** that sweeps the plunger face mechanically.
*   Uses a **harvested Mounjaro injection pen spring** (OD ~10mm, free length ~40mm) to automatically return the wiper arm to its parked/home position.

---

## 2. Selected Architecture: Spring-Returned Pivoted Wiper Funnel
Instead of manual handheld scrapers or static inserts, the plunger cleaner is integrated mechanically into the funnel:
*   **Wiper Arm (Rigid)**: Pivots outside the cone wall on a horizontal axis. A long wiper blade extends through a $90^\circ$ horizontal slot in the cone wall to sweep inside the chamber.
*   **Wiper Blade (Flexible)**: A TPU squeegee insert slotted into the wiper arm. It stands slightly proud of the arm to press against the plunger face.
*   **Mounjaro Spring Pocket**: A horizontal housing cylinder on the side of the funnel knuckle. It compresses a single pen spring when you push the wiper lever, providing a clean automatic snap-return.
*   **Pivot Pin (Rigid)**: Prints horizontally for high shear strength. Locks the wiper arm into the funnel's clevis joints.

---

## 3. Parametric Design Values (in `aeropress_cleaner.scad`)
If you need to customize the sizes:
*   `plunger_di = 57.2;` (AeroPress plunger seal diameter)
*   `plunger_dome_h = 3.5;` (plunger face dome height)
*   `spring_od = 10.0;` (Mounjaro pen spring outer diameter)
*   `spring_len = 40.0;` (Mounjaro pen spring free length)
*   `pivot_d = 5.0;` (Pivot shaft hinge diameter)
*   `wall_thickness = 2.4;` (Rigid funnel shell thickness)

---

## 4. Repository File Index
*   [`aeropress_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad): Parametric OpenSCAD CAD model. Select `part="funnel"`, `part="wiper"`, `part="blade"`, or `part="pin"`.
*   [`export.ps1`](file:///usr/local/google/home/plbogen/github/tillandsia/export.ps1): PowerShell script that exports the 4 STL parts and renders the plunger scraping animation GIF.
*   [`.github/workflows/export-stls.yml`](file:///usr/local/google/home/plbogen/github/tillandsia/.github/workflows/export-stls.yml): GitHub Actions CI workflow that automates exporting STLs and rendering preview animations on every push.
*   [`README.md`](file:///usr/local/google/home/plbogen/github/tillandsia/README.md): Landing page documentation detailing usage, 3D printing parameters, and assembly.

---

## 5. Next Steps for the Developer
1.  **Monitor the CI Build**: Check that the latest GitHub Actions run completes successfully and updates the `Animation/plunger_scrape.gif` on the home page:
    *   https://github.com/plbogen2/tillandsia/actions
2.  **Slicing and Printing (No support required)**:
    *   Print `STLs/funnel.stl` in PETG or PLA. Upright (Spout down).
    *   Print `STLs/wiper.stl` in PETG or PLA. Flat on bed.
    *   Print `STLs/pin.stl` in PETG or PLA. Flat on bed (horizontal).
    *   Print `STLs/blade.stl` in Flexible TPU or PLA. Flat on bed.
3.  **Assembly**:
    *   Insert the flexible `blade` into the `wiper` arm's slot.
    *   Insert the Mounjaro pen spring into the side pocket of the `funnel`.
    *   Align the wiper knuckle with the funnel knuckles and insert the `pin` from the bottom.
    *   Verify the smooth spring-return movement and test it on the Aeropress!
