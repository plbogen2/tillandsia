# Jetski Project Resurrection State: Aeropress Cleaners (ADCR & AMFC)

Use this file to instantly restore context, design knowledge, and execution progress when starting a new session or switching development machines.

---

## 1. Project Goals
Design and print support-free, office-desk-friendly cleaning tools for the **AeroPress** coffee maker:
1.  **Plunger Wiper Ring (ADCR)**: Cleans the rubber plunger seal face (diameter **57.2mm**, dome: **3.5mm**) using a spring-returned pivoted squeegee. Uses a harvested Mounjaro pen spring and a single M3x12mm screw.
2.  **Metal Filter Cleaner (AMFC)**: Wipes grounds off both sides of a circular metal mesh filter (diameter **62.0mm**, thickness **0.3mm**) using a clamped double-sided squeegee envelope. Uses four M3x12mm screws.

---

## 2. Selected Architectures

### Plunger Wiper Ring (ADCR)
*   **Ring Body (Rigid)**: A 35mm tall collar (ID 57.5mm) with an internal stop ledge (ID 53.0mm) at $z = 15.0 \to 18.0\text{ mm}$ and a $10.0\text{ mm}$ tall wall slot ($z = -8.0 \to +2.0\text{ mm}$) covering $330^\circ$.
*   **Clevis Hinge**: Double shear knuckles at $z = -12.0 \to -8.0\text{ mm}$ (lower) and $z = -4.0 \to 0.0\text{ mm}$ (upper). Secures via an M3x12mm screw.
*   **Wiper Arm & Blade**: A $65\text{mm}$ lever with a $57\text{mm}$ TPU blade starting at local $x = 8.0\text{ mm}$ to clear the hinge.
*   **Spring Return**: Mounjaro pen spring captured vertically on $6\text{mm}$ pegs on the ring post and lever post.

### Metal Filter Cleaner (AMFC)
*   **Front Half (Rigid)**: Contains a recessed track (depth $0.5\text{mm}$, width $62.5\text{mm}$) for the filter path, a pocket ($55.2\text{mm} \times 15.2\text{mm} \times 1.5\text{mm}$) for one TPU blade, and four M3 screw clearance holes (diameter $3.3\text{mm}$) with countersunk recesses.
*   **Back Half (Rigid)**: Mirrored copy of the front half, but with M3 tap holes (diameter $2.8\text{mm}$) to screw the clamp halves together.
*   **Wiper Blades (Flexible TPU, x2)**: Flat rectangular sheets ($55.0\text{mm} \times 15.0\text{mm} \times 1.5\text{mm}$) clamped between the halves, with tips extending into the channel to scrape both sides of the filter mesh.

---

## 3. Parametric Design Values

### Plunger Ring (`aeropress_cleaner.scad`)
*   `plunger_di = 57.2;` (AeroPress plunger seal diameter)
*   `wall_thickness = 3.0;` (Ring shell thickness)
*   `pivot_x = -35.0; pivot_y = 0.0;` (Pivot position)
*   `screw_tap_d = 2.8;` (Upper knuckle tap bore for M3 screw)
*   `screw_clearance_d = 3.3;` (Lower/arm knuckle clearance bore)
*   `ring_post_x = -55.0; ring_post_y = -12.0;` (Stationary spring post position)
*   `spring_peg_d = 6.0;` (Peg diameter for spring mounting)

### Filter Cleaner (`filter_cleaner.scad`)
*   `filter_di = 62.0;` (Metal filter mesh diameter)
*   `filter_thickness = 0.3;` (Filter thickness)
*   `blade_w = 55.0; blade_h = 15.0; blade_t = 1.5;` (TPU sheet dimensions)
*   `frame_w = 78.0; frame_h = 30.0; frame_t = 7.0;` (Half-clamp block dimensions)
*   `screw_x_offset = 34.0; screw_z_offset = 10.0;` (M3 clamping screw grid positions)

---

## 4. Repository File Index
*   [`aeropress_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad): Plunger cleaner CAD model.
*   [`filter_cleaner.scad`](file:///usr/local/google/home/plbogen/github/tillandsia/filter_cleaner.scad): Metal filter cleaner CAD model.
*   [`export.ps1`](file:///usr/local/google/home/plbogen/github/tillandsia/export.ps1): PowerShell script that exports all STLs and renders the plunger and filter animations (for Windows and CI).
*   [`export.sh`](file:///usr/local/google/home/plbogen/github/tillandsia/export.sh): Bash shell script that does the same (for native gLinux/Linux execution).
*   [`README.md`](file:///usr/local/google/home/plbogen/github/tillandsia/README.md): Landing page documentation detailing assembly and print guidelines.

---

## 5. Printing & Slicing
*   **Plunger Cleaner**:
    *   `STLs/ring.stl` -> PETG/PLA, print **upside-down (top rim on bed)**. Support-free.
    *   `STLs/wiper.stl` -> PETG/PLA, print flat.
    *   `STLs/blade.stl` -> TPU, print flat.
*   **Filter Cleaner**:
    *   `STLs/filter_front.stl` -> PETG/PLA, print flat, mating face on bed.
    *   `STLs/filter_back.stl` -> PETG/PLA, print flat, mating face on bed.
    *   `STLs/filter_blade.stl` (x2) -> TPU, print flat.

---

## 6. Assembly Steps

### Plunger Ring:
1.  Insert the flexible `blade` into the `wiper` arm's slot.
2.  Press-fit the Mounjaro pen spring onto the stationary **Ring Post peg** and the moving **Lever Post peg**.
3.  Align the wiper arm knuckle inside the slot between the ring's upper and lower knuckles.
4.  Insert an **M3x12mm screw** from the bottom and screw it tight into the upper knuckle.

### Filter Cleaner:
1.  Place the two TPU **filter_blade** sheets into the recesses of the **filter_front** and **filter_back** halves.
2.  Press the front and back halves together.
3.  Insert **four M3x12mm screws** from the front and screw them securely into the back tap holes to clamp the blades flat.
