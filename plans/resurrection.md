# Jetski Project Resurrection State: Aeropress Plunger Wiper Ring (ADCR) - Mechanical Spring-Loaded

Use this file to instantly restore context, design knowledge, and execution progress when starting a new session or switching development machines.

---

## 1. Project Goal
Design and print a support-free, office-desk-friendly cleaning ring for the **AeroPress** coffee maker plunger face:
*   Cleans the flat/domed circular plunger seal face (diameter **57.2mm**, dome: **3.5mm**).
*   Uses a **pivoted squeegee wiper** that sweeps the plunger face mechanically.
*   Uses a **harvested Mounjaro injection pen spring** (OD ~10mm, free length ~40mm) to automatically return the wiper arm to its parked/home position.
*   **No Funnel**: Reduced to a simple, compact ring to minimize print time and material usage.

---

## 2. Selected Architecture: Spring-Returned Pivoted Wiper Ring (ADCR)
Instead of a full funnel, the squeegee is integrated into a compact ring:
*   **Ring Body (Rigid)**: A 20mm tall collar (ID 57.5mm) that slides over the plunger seal. Contains an internal stop ledge (ID 53.0mm) to seat the plunger face exactly at $z = 0$.
*   **No Wall Slots**: Because the plunger face sits flush with the bottom face of the ring ($z = 0$), the wiper arm sits directly *below* the ring, sweeping the open bottom without requiring any wall slot cuts.
*   **Wiper Arm (Rigid)**: Pivots outside the ring wall. Holds a flexible blade and a lever arm for thumb pressure.
*   **Wiper Blade (Flexible)**: A TPU squeegee insert slotted into the wiper arm. Wipes the plunger face at $z = 0$.
*   **Mounjaro Spring Pocket**: A horizontal housing cylinder on the side of the ring. Compresses a single pen spring when you push the lever, providing automatic snap-back.
*   **Pivot Pin (Rigid)**: Locks the wiper arm into the double-shear knuckles of the ring.

---

## 3. Parametric Design Values (in `aeropress_cleaner.scad`)
If you need to customize the sizes:
*   `plunger_di = 57.2;` (AeroPress plunger seal diameter)
*   `plunger_dome_h = 3.5;` (plunger face dome height)
*   `spring_od = 10.0;` (Mounjaro pen spring outer diameter)
*   `spring_len = 40.0;` (Mounjaro pen spring free length)
*   `pivot_d = 5.0;` (Pivot shaft hinge diameter)
*   `wall_thickness = 3.0;` (Rigid ring shell thickness)

---

## 4. Repository File Index
*   [`aeropress_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad): Parametric OpenSCAD CAD model. Select `part="ring"`, `part="wiper"`, `part="blade"`, or `part="pin"`.
*   [`export.ps1`](file:///usr/local/google/home/plbogen/github/tillandsia/export.ps1): PowerShell script that exports the 4 STL parts and renders the plunger scraping animation GIF.
*   [`.github/workflows/export-stls.yml`](file:///usr/local/google/home/plbogen/github/tillandsia/.github/workflows/export-stls.yml): GitHub Actions CI workflow that automates exporting STLs and rendering preview animations on every push.
*   [`README.md`](file:///usr/local/google/home/plbogen/github/tillandsia/README.md): Landing page documentation detailing usage, 3D printing parameters, and assembly.

---

## 5. Next Steps for the Developer
1.  **Monitor the CI Build**: Check that the latest GitHub Actions run completes successfully and updates the `Animation/plunger_scrape.gif` on the home page:
    *   https://github.com/plbogen2/tillandsia/actions
2.  **Slicing and Printing (No support required)**:
    *   Print `STLs/ring.stl` in PETG or PLA. **Upside-down (Top rim on bed)**.
    *   Print `STLs/wiper.stl` in PETG or PLA. Flat on bed.
    *   Print `STLs/pin.stl` in PETG or PLA. Flat on bed (horizontal).
    *   Print `STLs/blade.stl` in Flexible TPU or PLA. Flat on bed.
3.  **Assembly**:
    *   Insert the flexible `blade` into the `wiper` arm's slot.
    *   Insert the Mounjaro pen spring into the side pocket of the `ring`.
    *   Align the wiper knuckle with the ring knuckles and insert the `pin` from the bottom.
    *   Verify the smooth spring-return movement and test it over a trash can!
