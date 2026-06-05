# Design Handoff: Aeropress Desk Cleaning Funnel (ADCF)

This document records the design rationale, parameters, alternatives, and technical specifications for the Aeropress Desk Cleaning Funnel (ADCF) created for the `tillandsia` repository.

## 1. Problem Statement
The user has an Aeropress with a flow control cap, a metal filter, and a paper filter. In an office setting equipped only with a kettle and a trash can (no immediate access to a sink or running water), the user needs to clean coffee grounds off:
1. **The Plunger Seal**: The convex face and cylindrical outer walls of the rubber seal.
2. **The Metal Filter**: The flat faces of the stainless steel filter disc.

The goal is to design a 3D-printable tool that cleans both components using dry scraping, funneling all coffee grounds directly into a trash can without water or mess.

---

## 2. Alternatives Considered

### Alternative A: Dual-Ended Scraper Wand
*   **Description**: A compact handheld wand with a curved scraper on one end and a split-jaw squeegee clamp on the other.
*   **Pros**: Very fast print, low material usage, small footprint.
*   **Cons**: Requiring manual handling near coffee grounds; leaves the wand itself covered in wet grounds which would then require wiping/washing.

### Alternative B: Desk-Side Rinse & Scrape Station
*   **Description**: A small container holding a splash of hot water from the kettle to dip/loosen grounds, alongside squeegee slots.
*   **Pros**: Dissolves oils and removes fine particles better than dry scraping.
*   **Cons**: Introduces liquid waste disposal problems in an office desk setting (requires emptying a cup of muddy coffee water).

### Alternative C: Unified Cleaning Funnel (Selected)
*   **Description**: A handheld funnel with a handle and a side-mounting slot. Pushing the plunger down cleans it; sliding the metal filter through the slot cleans both sides. Grounds fall directly down into the trash.
*   **Pros**: Complete containment of waste, hands-free scraping directly into the trash, modular and easy to print without supports.

---

## 3. Selected Design: Aeropress Desk Cleaning Funnel (ADCF)

The design is modular to allow printing on single-extruder 3D printers using two different materials:
1.  **Funnel Body (Rigid - PETG/PLA)**: Holds the components and handles the waste.
2.  **Plunger Squeegee Insert (Flexible PLA)**: Snaps into the top of the funnel to scrape the plunger.
3.  **Filter Squeegee halves (Flexible PLA - print 2)**: Stack inside the side pocket to scrape the metal filter.

### Key Design Highlights:
*   **Support-Free Printing**: The funnel wall angles, the vertical handle loop, the pocket support gusset, and the internal shoulders are all designed at or under 45 degrees relative to the vertical axis when printed bottom-up. No support material is required.
*   **Unified Path**: The plunger moves downwards through a circular squeegee lip that pushes grounds down off the seal. At the bottom, a curved blade matching the dome of the plunger seal wipes the face clean when twisted.
*   **Filter Stability**: A slot in the opposite inner wall of the funnel guides and stabilizes the far edge of the metal filter as it is pushed through the scraper block, preventing the thin metal disc from bending.
*   **No-Bridge Slot**: The filter scraper block is split horizontally into two identical halves, enabling flat printing on the bed to prevent slot sag and ensure pristine scraping lips.

---

## 4. File Structure & CAD Model
The CAD model has been saved to the repository at:
*   `[aeropress_cleaner.scad](file:///usr/local/google/home/plbogen/github/tillandsia/aeropress_cleaner.scad)`

The file contains customizer parameters allowing adjustment of:
*   `plunger_di` (default 57.2mm)
*   `plunger_dome_h` (default 3.5mm)
*   `filter_di` (default 62.0mm)
*   `filter_thickness` (default 0.3mm)
*   `clearance` (default 0.2mm)
*   `wall_thickness` (default 2.4mm)
*   `flex_wall` (default 2.0mm)

You can select which part to export (`all`, `funnel`, `plunger_insert`, or `filter_insert`) using the `part` variable.

---

## 5. Next Steps
1.  Open `aeropress_cleaner.scad` in OpenSCAD.
2.  Render and export the STL for `part = "funnel"` in PETG or PLA.
3.  Render and export the STL for `part = "plunger_insert"` in Flexible PLA.
4.  Render and export the STL for `part = "filter_insert"` in Flexible PLA (print two copies).
5.  Assemble by dropping the plunger insert into the top of the funnel (lining up the keys) and sliding the two filter insert halves into the side pocket.
