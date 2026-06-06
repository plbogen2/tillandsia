# Jetski Project Resurrection State: Aeropress Plunger Wiper Ring (ADCR) - Mechanical Spring-Loaded

Use this file to instantly restore context, design knowledge, and execution progress when starting a new session or switching development machines.

---

## 1. Project Goal
Design and print a support-free, office-desk-friendly cleaning ring for the **AeroPress** coffee maker plunger face:
*   Cleans the flat/domed circular plunger seal face (diameter **57.2mm**, dome: **3.5mm**).
*   Uses a **pivoted squeegee wiper** (65mm arm) that sweeps completely across the plunger face.
*   Uses a **harvested Mounjaro injection pen spring** (OD ~8mm, free length ~40mm) mounted vertically on pegs to automatically return the wiper arm.
*   **M3 Screw Pivot**: Uses a standard Prusa-style M3x12mm metal screw (SHCS or BHCS) as the pivot pin to ensure high strength and low friction.

---

## 2. Selected Architecture: Spring-Returned Pivoted Wiper Ring (ADCR)
*   **Ring Body (Rigid)**: A 35mm tall collar (ID 57.5mm) that spans $z = -15.0 \to +20.0\text{ mm}$.
    *   **Stop Ledge**: An internal chamfered stop flange (ID 53.0mm) located at $z = 15.0 \to 18.0\text{ mm}$ to prevent the plunger from falling through.
    *   **Horizontal Wall Slot**: A $10.0\text{ mm}$ tall slot ($z = -8.0 \to +2.0\text{ mm}$) covering a $330^\circ$ sector (from $-225^\circ \to +105^\circ$) to let the wiper arm and squeegee blade pass through.
    *   **Clevis Knuckles**: Double shear hinge tabs at $z = -12.0 \to -8.0\text{ mm}$ (lower) and $z = -4.0 \to 0.0\text{ mm}$ (upper). The lower knuckle has a $6.0\text{mm}$ recess to flush-mount the M3 screw head.
*   **Wiper Arm (Rigid)**: A $65\text{mm}$ long pivoted lever. Contains a $3.3\text{mm}$ clearance hole at the pivot. Includes a lever extension ($20\text{mm}$) extending back for the spring peg.
*   **Wiper Blade (Flexible)**: A $57\text{mm}$ long TPU squeegee insert that slots into the arm. Starts at local $x = 8.0\text{ mm}$ to clear the 12mm pivot knuckle. Wipes the plunger face at $z = 0.0$ (has $1.0\text{mm}$ compression overlap).
*   **Linear Compression Spring peg assembly**:
    *   **Ring Post**: Located at `[-55.0, -12.0]`, spans $z = -8.0 \to 0.0\text{ mm}$.
    *   **Lever Post**: Located on the arm extension.
    *   Both posts have vertical $6\text{mm}$ diameter pegs pointing upwards at $z = -6.0\text{ mm}$ to capture the spring. The positions keep the spring compressed from $33.6\text{mm}$ down to $9.5\text{mm}$ over the $135^\circ$ travel sweep without over-center locking.

---

## 3. Parametric Design Values (in `aeropress_cleaner.scad`)
*   `plunger_di = 57.2;` (AeroPress plunger seal diameter)
*   `plunger_dome_h = 3.5;` (plunger face dome height)
*   `wall_thickness = 3.0;` (Rigid ring shell thickness)
*   `pivot_x = -35.0; pivot_y = 0.0;` (Pivot position)
*   `screw_tap_d = 2.8;` (Upper knuckle tap bore for M3 screw)
*   `screw_clearance_d = 3.3;` (Lower/arm knuckle clearance bore)
*   `screw_head_d = 6.0; screw_head_h = 2.5;` (recess dimensions for M3 cap head)
*   `ring_post_x = -55.0; ring_post_y = -12.0;` (Stationary spring post position)
*   `spring_peg_d = 6.0;` (Vertical peg diameter for spring mounting)

---

## 4. Repository File Index
*   [`aeropress_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad): Parametric OpenSCAD CAD model. Select `part="ring"`, `part="wiper"`, or `part="blade"`.
*   [`export.ps1`](file:///usr/local/google/home/plbogen/github/tillandsia/export.ps1): PowerShell script that exports the 3 STL parts (ring, wiper, blade) and renders the plunger scraping animation GIF.
*   [`.github/workflows/export-stls.yml`](file:///usr/local/google/home/plbogen/github/tillandsia/.github/workflows/export-stls.yml): GitHub Actions CI workflow that automates exporting STLs and rendering preview animations on every push.
*   [`README.md`](file:///usr/local/google/home/plbogen/github/tillandsia/README.md): Landing page documentation detailing usage, 3D printing parameters, and assembly.

---

## 5. Slicing and Printing (No support required)
*   Print `STLs/ring.stl` in PETG or PLA. **Upside-down (Top rim on bed)**. The internal stop ledge features 45-degree chamfers on both sides to print completely support-free!
*   Print `STLs/wiper.stl` in PETG or PLA. Flat on bed.
*   Print `STLs/blade.stl` in Flexible TPU or Flex-PLA. Flat on bed.

---

## 6. Assembly Steps
1.  Insert the flexible `blade` into the `wiper` arm's slot (starts 8mm from pivot).
2.  Press-fit the Mounjaro pen spring onto the stationary **Ring Post peg** and the moving **Lever Post peg**.
3.  Align the wiper arm's knuckle inside the slot between the ring's upper and lower knuckles.
4.  Insert a standard **M3x12mm screw** from the bottom through the lower knuckle, through the wiper arm, and screw it tight into the upper knuckle. The screw head will sit recessed in the bottom.
5.  Verify the smooth spring-return movement and test it over a trash can!
