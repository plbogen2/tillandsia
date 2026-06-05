# Aeropress Desk Cleaning Funnel (ADCF) - Mechanical Wiper Version

A 3D-printable, support-free, mechanical tool to clean your Aeropress plunger face directly at your office desk using a spring-returned pivoted squeegee wiper.

![Plunger Scraping Action](Animation/plunger_scrape.gif)

## How It Works
*   **Seating the Plunger**: Insert the Aeropress plunger into the top chamber of the funnel.
*   **Mechanical Sweep**: Push the external thumb lever. This compresses the internal spring and sweeps the flexible wiper blade across the entire plunger face, scraping the coffee grounds clean.
*   **Spring Return**: Release the lever. A harvested **Mounjaro pen spring** pushes the wiper arm back to its parked position, clear of the plunger.
*   **Clean Collection**: Scraped grounds fall straight down the funnel spout and into the trash.

---

## 3D Printing & Materials Guide

All 3D parts print completely **without supports**.

| Part | Material | Print Orientation | Qty | Notes |
| :--- | :--- | :--- | :---: | :--- |
| **Funnel Body** | PETG / PLA | Upright (Spout on bed) | 1 | Includes integrated hinge knuckles and spring housing. |
| **Wiper Arm** | PETG / PLA | Flat on bed | 1 | Heavy layer density for hinge strength. |
| **Wiper Blade** | Flexible TPU / PLA | Flat on bed | 1 | Snaps into the slot on the wiper arm. |
| **Pivot Pin** | PETG / PLA | Flat on bed | 1 | Printed horizontally for shear strength. |
| **Mounjaro Spring** | Stainless Steel | N/A | 1 | Harvested from a spent Mounjaro injection pen. |

### Settings:
*   **Rigid parts (Funnel, Arm, Pin)**: 0.2mm layer height, 3 walls, 20% infill.
*   **Flexible parts (Blade)**: 0.2mm layer height, 2 walls, 15% infill.

---

## Assembly
1.  Slide the flexible **Wiper Blade** into the slot on the **Wiper Arm** until it is centered.
2.  Harvest a spring from a spent **Mounjaro injection pen** (approx. 10mm OD, 40mm length).
3.  Insert the spring into the horizontal spring pocket on the side of the **Funnel Body**.
4.  Fit the **Wiper Arm** knuckle between the funnel knuckles, ensuring the lever's retainer peg fits inside the spring.
5.  Push the **Pivot Pin** up through the bottom of the knuckles to lock it all together.

---

## OpenSCAD Customization
The model is fully parametric in `aeropress_cleaner.scad`:
*   `plunger_di` (default `57.2` mm) — AeroPress plunger diameter.
*   `plunger_dome_h` (default `3.5` mm) — Plunger dome face depth.
*   `spring_od` (default `10.0` mm) — Diameter of the spring.
*   `spring_len` (default `40.0` mm) — Length of the spring.
