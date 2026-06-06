// OpenSCAD Model for Aeropress Metal Filter Cleaner (AMFC)
// Clamped 3-Piece Design using standard M3 Screws:
// 1. Front Half (Rigid): Holds front TPU blade, contains M3 clearance holes.
// 2. Back Half (Rigid): Holds back TPU blade, contains M3 tap holes.
// 3. Wiper Blades (Flexible, x2): Simple flat TPU sheets (55mm x 15mm x 1.5mm).

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, front: Front Half (Rigid), back: Back Half (Rigid), blade: TPU Wiper Blade (Flexible)]

// --- PARAMETERS ---
filter_di = 62.0;       // Standard metal filter diameter
filter_thickness = 0.3; // Metal filter thickness
wall_thickness = 3.0;   // Outer wall shell thickness

// Blade dimensions
blade_w = 55.0;
blade_h = 15.0;
blade_t = 1.5;

// Frame dimensions
frame_w = filter_di + 2 * wall_thickness + 10.0; // 78mm total width
frame_h = 30.0;                                  // 30mm vertical height
frame_t = 7.0;                                   // 7mm thickness per half (14mm total)

// M3 Screw spacing
screw_x_offset = frame_w / 2 - 5.0; // 34mm from center (screws at x = -34 and +34)
screw_z_offset = 10.0;              // screws at z = -10 and +10

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
    wiper_blade();
}

module assembly() {
    // 1. Front Half (Rigid, transparent in assembly to see inside)
    color([0.7, 0.7, 0.7, 0.5])
        translate([0, -frame_t, 0])
            front_half();
            
    // 2. Back Half (Rigid, solid)
    color("gray")
        translate([0, 0, 0])
            back_half();
            
    // 3. Front Wiper Blade (TPU, Blue)
    color("blue")
        translate([-blade_w/2, -blade_t, 0.0])
            wiper_blade();
            
    // 4. Back Wiper Blade (TPU, Blue, rotated to face front)
    color("blue")
        translate([blade_w/2, 0.0, 0.0])
            rotate([0, 0, 180])
                wiper_blade();
                
    // 5. Mock M3 Screws (x4)
    for (x = [-screw_x_offset, screw_x_offset]) {
        for (z = [-screw_z_offset, screw_z_offset]) {
            translate([x, -frame_t - 2.5, z])
                rotate([90, 0, 0])
                    mock_m3_screw(len = 12.0);
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
    // Front half of the clamp frame.
    // Local coordinate origin [0,0,0] is on the split plane (mating face).
    // The half extends in the -Y direction.
    difference() {
        // Main block
        translate([-frame_w/2, -frame_t, -frame_h/2])
            cube([frame_w, frame_t, frame_h]);
            
        // Cutouts
        union() {
            // 1. Filter Channel (recessed track, width 62.5, depth 0.5, full height)
            translate([-(filter_di + 0.5)/2, -0.5, -frame_h/2 - 1.0])
                cube([filter_di + 0.5, 0.6, frame_h + 2.0]);
                
            // 2. Wiper Pocket (holds the 55x15x1.5mm TPU sheet)
            // Pocket spans x = -27.5 -> +27.5, y = -1.4 -> 0.0, z = 0.0 -> 15.0
            translate([-blade_w/2 - 0.1, -1.4, 0.0])
                cube([blade_w + 0.2, 1.5, blade_h + 0.1]);
                
            // 3. Blade Flex Opening (lets the blade tip flex into the channel below z=0)
            // Opens from z = -5.0 to 0.0, width 51.0mm, depth 2.5mm
            translate([-48.0/2, -2.5, -5.0])
                cube([48.0, 3.0, 5.1]);
                
            // 4. M3 Screw Clearance Holes with Head Counterbores
            for (x = [-screw_x_offset, screw_x_offset]) {
                for (z = [-screw_z_offset, screw_z_offset]) {
                    // Clearance shaft (D=3.3)
                    translate([x, 1.0, z])
                        rotate([90, 0, 0])
                            cylinder(d = 3.3, h = frame_t + 2.0, $fn = 20);
                    // Cap head recess (D=6.0, depth 3.0)
                    translate([x, -frame_t - 0.1, z])
                        rotate([90, 0, 0])
                            cylinder(d = 6.0, h = 3.0, $fn = 20);
                }
            }
            
            // 5. Chamfered Entry Funnel (at the top, z = 12 -> 15) to guide filter in easily
            translate([-(filter_di + 0.5)/2, -0.5, frame_h/2 - 3.0])
                multmatrix([
                    [1, 0, 0, 0],
                    [0, 1, -1.0, 0], // sloped in Y
                    [0, 0, 1, 0],
                    [0, 0, 0, 1]
                ])
                cube([filter_di + 0.5, 3.0, 4.0]);
        }
    }
}

module back_half() {
    // Back half of the clamp frame.
    // Local coordinate origin [0,0,0] is on the split plane (mating face).
    // The half extends in the +Y direction (mirrored copy of front half, but with tap holes).
    difference() {
        // Main block
        translate([-frame_w/2, 0.0, -frame_h/2])
            cube([frame_w, frame_t, frame_h]);
            
        // Cutouts
        union() {
            // 1. Filter Channel (recessed track, width 62.5, depth 0.5, full height)
            translate([-(filter_di + 0.5)/2, -0.1, -frame_h/2 - 1.0])
                cube([filter_di + 0.5, 0.6, frame_h + 2.0]);
                
            // 2. Wiper Pocket (holds the 55x15x1.5mm TPU sheet)
            // Pocket spans x = -27.5 -> +27.5, y = 0.0 -> 1.4, z = 0.0 -> 15.0
            translate([-blade_w/2 - 0.1, -0.1, 0.0])
                cube([blade_w + 0.2, 1.5, blade_h + 0.1]);
                
            // 3. Blade Flex Opening
            translate([-48.0/2, -0.5, -5.0])
                cube([48.0, 3.0, 5.1]);
                
            // 4. M3 Screw Tap Holes (D=2.8, threads directly into plastic)
            for (x = [-screw_x_offset, screw_x_offset]) {
                for (z = [-screw_z_offset, screw_z_offset]) {
                    translate([x, -1.0, z])
                        rotate([90, 0, 0])
                            cylinder(d = 2.8, h = frame_t + 2.0, $fn = 20);
                }
            }
            
            // 5. Chamfered Entry Funnel (at the top, z = 12 -> 15)
            translate([-(filter_di + 0.5)/2, -2.5, frame_h/2 - 3.0])
                multmatrix([
                    [1, 0, 0, 0],
                    [0, 1, 1.0, 0], // sloped in +Y
                    [0, 0, 1, 0],
                    [0, 0, 0, 1]
                ])
                cube([filter_di + 0.5, 3.0, 4.0]);
        }
    }
}

module wiper_blade() {
    // Flat TPU sheet (55mm x 15mm x 1.5mm)
    // Sits in the pocket. Bottom tip can flex slightly.
    cube([blade_w, blade_t, blade_h]);
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
