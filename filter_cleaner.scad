// OpenSCAD Model for Aeropress Metal Filter Cleaner (AMFC)
// Clamped 3-Piece Design using standard M3 Screws:
// 1. Front Half (Rigid): Holds front TPU blade, contains M3 clearance holes.
// 2. Back Half (Rigid): Holds back TPU blade, contains M3 tap holes.
// 3. Wiper Blades (Flexible, x2): Simple flat TPU sheets (55mm x 15mm x 1.5mm).

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, front: Front Half (Rigid), back: Back Half (Rigid), blade: Flex PLA Insert (Flexible)]

// --- PARAMETERS ---
filter_di = 62.0;       // Standard metal filter diameter
filter_thickness = 0.3; // Metal filter thickness
wall_thickness = 3.0;   // Outer wall shell thickness

// Frame & Flex dimensions
frame_w = filter_di + 2 * wall_thickness + 10.0; // 78mm total width
frame_h = 30.0;                                  // 30mm vertical height
frame_t = 5.0;                                   // 5mm thick rigid backing plates
flex_t = 2.0;                                    // 2mm thick flex PLA inserts

// Dado (Filter Channel) dimensions
dado_w = filter_di + 0.5; // 62.5mm width (0.5mm clearance)
dado_d = 0.15;            // 0.15mm depth per side (0.3mm total channel gap)

// Scraping Ridge dimensions
ridge_w = 62.0; // 62mm wide (covers filter mesh area)
ridge_h = 0.15; // 0.15mm height above dado bottom (reaches split plane)
ridge_t = 2.0;  // 2.0mm vertical width of the ridge

// M3 Screw spacing
screw_x_offset = frame_w / 2 - 5.0; // 34mm from center (screws at x = -34 and +34)
screw_z_offset = 10.0;              // screws at z = -10 and +10

// M3 Square Nut dimensions (DIN 562)
nut_pocket_w = 6.0; // 6.0mm flat-to-flat pocket width (5.5mm nut + 0.5mm tolerance)
nut_pocket_d = 2.2; // 2.2mm pocket depth (1.8mm nut + 0.4mm tolerance)

// --- ANIMATION CONTROLS ---
animate = false;
time_t = undef;
t_val = (time_t != undef) ? time_t : $t;

// Filter position animation (passes through from top to bottom)
// t = 0.2 -> 0.8: filter slides from z = 45 (above) to z = -45 (below)
filter_z = 
    (t_val < 0.2) ? 45.0 :
    (t_val < 0.8) ? 45.0 - ((t_val - 0.2) / 0.6) * 90.0 :
    -45.0;

if (part == "all") {
    assembly();
} else if (part == "front") {
    front_half();
} else if (part == "back") {
    back_half();
} else if (part == "blade") {
    flex_plate();
}

module assembly() {
    // 1. Front Half (Rigid, transparent in assembly to see inside)
    color([0.7, 0.7, 0.7, 0.5])
        translate([0, -flex_t, 0])
            front_half();
            
    // 2. Front Flex Plate (Flex PLA, transparent blue, grooved)
    color([0.0, 0.0, 1.0, 0.6])
        translate([0, 0, 0])
            flex_plate();
            
    // 3. Back Flex Plate (Flex PLA, transparent blue, mirrored to face front)
    color([0.0, 0.0, 1.0, 0.6])
        mirror([0, 1, 0])
            flex_plate();
            
    // 4. Back Half (Rigid, solid)
    color("gray")
        translate([0, flex_t, 0])
            back_half();
                
    // 5. Mock M3 Screws (x4)
    // Shaft heads are on the front surface (y = -flex_t - frame_t)
    for (x = [-screw_x_offset, screw_x_offset]) {
        for (z = [-screw_z_offset, screw_z_offset]) {
            translate([x, -flex_t - frame_t, z])
                rotate([-90, 0, 0])
                    mock_m3_screw(len = 14.0);
        }
    }
    
    // 6. Mock Metal Filter (Animated)
    if (animate || t_val > 0) {
        translate([0, -filter_thickness/2, filter_z])
            rotate([90, 0, 0])
                color("silver")
                    cylinder(d = filter_di, h = filter_thickness, center = true, $fn = 100);
    }
}

module front_half() {
    // Simple flat front clamp plate.
    // Local coordinate origin [0,0,0] is on the mating plane.
    // Plate extends in the -Y direction from y = 0 to -frame_t.
    difference() {
        // Main block
        translate([-frame_w/2, -frame_t, -frame_h/2])
            cube([frame_w, frame_t, frame_h]);
            
        // M3 Screw Clearance Holes with Counterbores
        for (x = [-screw_x_offset, screw_x_offset]) {
            for (z = [-screw_z_offset, screw_z_offset]) {
                // Shaft clearance (D=3.3)
                translate([x, 1.0, z])
                    rotate([90, 0, 0])
                        cylinder(d = 3.3, h = frame_t + 2.0, $fn = 20);
                // Counterbore recess (D=6.0, depth 3.0)
                translate([x, -frame_t + 3.0, z])
                    rotate([90, 0, 0])
                        cylinder(d = 6.0, h = 4.1, $fn = 20);
            }
        }
    }
}

module back_half() {
    // Simple flat back clamp plate.
    // Local coordinate origin [0,0,0] is on the mating plane.
    // Plate extends in the +Y direction from y = 0 to frame_t.
    difference() {
        // Main block
        translate([-frame_w/2, 0.0, -frame_h/2])
            cube([frame_w, frame_t, frame_h]);
            
        // M3 Screw Clearance Holes (D=3.3) and Square Nut Pockets
        for (x = [-screw_x_offset, screw_x_offset]) {
            for (z = [-screw_z_offset, screw_z_offset]) {
                // Clearance shaft
                translate([x, frame_t + 1.0, z])
                    rotate([90, 0, 0])
                        cylinder(d = 3.3, h = frame_t + 2.0, $fn = 20);
                // Square nut pocket on the rear face (y = frame_t)
                translate([x - nut_pocket_w/2, frame_t - nut_pocket_d, z - nut_pocket_w/2])
                    cube([nut_pocket_w, nut_pocket_d + 0.1, nut_pocket_w]);
            }
        }
    }
}

module flex_plate() {
    // Symmetric flexible clamping plate with dado (channel) and scraping ridge.
    // Local coordinate origin [0,0,0] is on the mating plane.
    // Base plate extends in the -Y direction from y = 0 to -flex_t.
    difference() {
        union() {
            // 1. Base plate with vertical channel and funnel cut out
            difference() {
                // Base block
                translate([-frame_w/2, -flex_t, -frame_h/2])
                    cube([frame_w, flex_t, frame_h]);
                // Vertical Dado (channel of depth dado_d = 0.15)
                translate([-dado_w/2, -dado_d - 0.05, -frame_h/2 - 1.0])
                    cube([dado_w, dado_d + 0.1, frame_h + 2.0]);
                // Entry Funnel (slants the channel back to the plate rear face)
                translate([-dado_w/2, 0, 0])
                    rotate([0, 90, 0])
                        linear_extrude(height = dado_w)
                            polygon([
                                [-dado_d, frame_h/2 - 3.0],
                                [-flex_t - 0.1, frame_h/2 + 0.1],
                                [-dado_d, frame_h/2 + 0.1]
                            ]);
            }
            // 2. Scraping Ridge (added back on top of the channel surface)
            // Starts at y = -dado_d (-0.15), extends by ridge_h (0.15) to y = 0.0 (mating plane)
            translate([-ridge_w/2, -dado_d, -ridge_t/2])
                cube([ridge_w, ridge_h, ridge_t]);
        }
        // 3. M3 Screw Clearance Holes (D=3.3)
        for (x = [-screw_x_offset, screw_x_offset]) {
            for (z = [-screw_z_offset, screw_z_offset]) {
                translate([x, 1.0, z])
                    rotate([90, 0, 0])
                        cylinder(d = 3.3, h = flex_t + 2.0, $fn = 20);
            }
        }
    }
}

module mock_m3_screw(len = 12.0) {
    color("silver") {
        // Cap Head (D=5.5, H=3.0)
        cylinder(d = 5.5, h = 3.0, $fn = 20);
        // Shaft (D=3.0, H=len)
        translate([0, 0, 3.0])
            cylinder(d = 3.0, h = len, $fn = 20);
    }
}
