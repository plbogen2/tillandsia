// OpenSCAD Model for Aeropress Plunger Wiper Ring (ADCR)
// Simplified 2-Part Mechanical System with Shroud and M3 Metal Pivot Screw:
// 1. Ring Body (Rigid): 35mm tall collar with 330-degree slot and internal stop ledge.
// 2. Wiper Arm (Rigid): Long pivoted lever (65mm) that completely crosses the plunger.
// 3. Wiper Blade (Flexible): 57mm TPU blade pointing upwards, starts 8mm from pivot.

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, ring: Ring Body (Rigid), wiper: Wiper Arm (Rigid), trigger: Trigger Lever (Rigid), blade: Wiper Blade (Flexible)]

// --- CUSTOMIZABLE PARAMETERS ---
plunger_di = 57.2;
plunger_dome_h = 3.5;
right_handed = false; // Set to true for right-handed version, false for left-handed

// --- ADVANCED PARAMETERS ---
wall_thickness = 3.0; // thick walls for robust ring
clearance = 0.2;

// Hinge/Pivot geometry (M3 Metal Screw Pivot)
pivot_x = -35.0;
pivot_y = 0.0;
trigger_pivot_x = -71.0;
trigger_pivot_y = 0.0;

screw_tap_d = 2.8;     // M3 threads tap directly into plastic
screw_clearance_d = 3.3; // loose fit for smooth pivot rotation
screw_head_d = 6.0;    // recess for M3 socket head cap screw
screw_head_h = 2.5;

// Handle and Spring peg positions
stationary_handle_x = -115.0;
stationary_handle_y = 0.0;
spring_peg_d = 6.0; // fits inside 8mm ID spring

// --- ANIMATION CONTROLS ---
animate = false;
time_t = undef;
t_val = (time_t != undef) ? time_t : $t;

// Wiper Angle Animation:
// t = 0.0 -> 0.2: Wiper parks at -90 degrees (idle)
// t = 0.2 -> 0.5: Wiper sweeps to +45 degrees (compressing spring, crossing plunger)
// t = 0.5 -> 0.8: Wiper returns to -90 degrees (spring release)
wiper_angle = 
    (t_val < 0.2) ? -90 :
    (t_val < 0.5) ? -90 + ((t_val - 0.2) / 0.3) * 135 :
    (t_val < 0.8) ? 45 - ((t_val - 0.5) / 0.3) * 135 :
    -90;

// Trigger Angle Animation: Squeezes clockwise from -90 -> -135 linked to wiper (ratio 3:1)
trigger_angle = -90.0 - (wiper_angle + 90.0) / 3.0;


// Plunger insertion animation
plunger_z = 
    (t_val < 0.1) ? 60 - (t_val/0.1)*60 :
    (t_val < 0.8) ? 0.0 :
    ((t_val - 0.8)/0.2)*60;

module directional_layout() {
    if (right_handed) {
        mirror([1, 0, 0]) children();
    } else {
        children();
    }
}

if (part == "all") {
    directional_layout() assembly();
} else if (part == "ring") {
    directional_layout() ring_body();
} else if (part == "wiper") {
    directional_layout() wiper_arm();
} else if (part == "trigger") {
    directional_layout() trigger_lever();
} else if (part == "blade") {
    directional_layout() wiper_blade();
}

module assembly() {
    // 1. Ring Body (Rigid)
    ring_body();
    
    // 2. Wiper Arm & Blade (Pivot A)
    translate([pivot_x, pivot_y, -8.0]) {
        rotate([0, 0, wiper_angle]) {
            color("green") wiper_arm();
            color("blue") wiper_blade();
        }
    }
    
    // 3. Trigger Lever (Pivot B)
    translate([trigger_pivot_x, trigger_pivot_y, -8.0]) {
        rotate([0, 0, trigger_angle]) {
            color("green") trigger_lever();
        }
    }
    
    // 4. M3 Metal Pivot Screws (Pivot A & B)
    translate([pivot_x, pivot_y, -12.0])
        mock_m3_screw(len = 12.0);
    translate([trigger_pivot_x, trigger_pivot_y, -12.0])
        mock_m3_screw(len = 12.0);
            
    // 5. Mock Plunger (Animated)
    if (animate || t_val > 0) {
        translate([0, 0, plunger_z])
            mock_plunger();
    }
    
    // 6. Mock Spring (Animated compression between pegs, global z = -4.2)
    trigger_peg_x = trigger_pivot_x + 15.0 * cos(trigger_angle + 180.0);
    trigger_peg_y = trigger_pivot_y + 15.0 * sin(trigger_angle + 180.0);
    
    stationary_peg_x = -95.0;
    stationary_peg_y = 20.0;
    
    dx = trigger_peg_x - stationary_peg_x;
    dy = trigger_peg_y - stationary_peg_y;
    dist = sqrt(dx*dx + dy*dy);
    angle = atan2(dy, dx);
    
    color("silver")
        translate([stationary_peg_x, stationary_peg_y, -4.2])
            rotate([0, 0, angle])
                rotate([0, 90, 0])
                    cylinder(d = 8.0, h = dist, $fn=20);
}

module ring_body() {
    difference() {
        // UNION of all positive geometry
        union() {
            // 1. Ring Wall (with Slot cut out of it)
            difference() {
                // Main ring cylinder (height 35mm, from z = -15 to +20)
                translate([0, 0, -15.0])
                    cylinder(d = plunger_di + 2 * wall_thickness, h = 35.0, $fn = 100);
                
                // Horizontal Slot in ring wall for arm/blade to sweep (Z span: z = -8.0 -> +2.0, height 10.0mm)
                translate([0, 0, -8.0]) {
                    intersection() {
                        difference() {
                            cylinder(d = plunger_di + 2*wall_thickness + 5.0, h = 10.0, $fn=100);
                            cylinder(d = plunger_di - 2.0, h = 12.0, center=true, $fn=100);
                        }
                        linear_extrude(height = 10.0) {
                            polygon([
                                [-10.0, -10.0],
                                [75*cos(-225), 75*sin(-225)],
                                [75*cos(-180), 75*sin(-180)],
                                [75*cos(-135), 75*sin(-135)],
                                [75*cos(-90), 75*sin(-90)],
                                [75*cos(-45), 75*sin(-45)],
                                [75*cos(0), 75*sin(0)],
                                [75*cos(45), 75*sin(45)],
                                [75*cos(105), 75*sin(105)],
                                [-10.0, 10.0]
                            ]);
                        }
                    }
                }
            }
            
            // 2. Dual-Pivot Gearbox Casing (Upper Deck: z = 0 -> 20, Lower Deck: z = -12 -> -8)
            // Upper Deck casing (z = 0 -> 20)
            hull() {
                translate([pivot_x, pivot_y, 0.0])
                    cylinder(d = 12.0, h = 20.0, $fn = 50);
                translate([trigger_pivot_x, trigger_pivot_y, 0.0])
                    cylinder(d = 16.0, h = 20.0, $fn = 50);
                translate([-(plunger_di/2 + wall_thickness - 1.0), 0.0, 0.0])
                    cylinder(d = 8.0, h = 20.0, $fn = 50);
            }
            // Lower Deck casing (z = -12 -> -8)
            hull() {
                translate([pivot_x, pivot_y, -12.0])
                    cylinder(d = 12.0, h = 4.0, $fn = 50);
                translate([trigger_pivot_x, trigger_pivot_y, -12.0])
                    cylinder(d = 16.0, h = 4.0, $fn = 50);
                translate([-(plunger_di/2 + wall_thickness - 1.0), 0.0, -12.0])
                    cylinder(d = 8.0, h = 4.0, $fn = 50);
            }
                
            // 3. Stationary Handle Post (Inline cylindrical grip, z = -60 -> 20)
            // Hull of two cylinders to make a long comfortable horizontal bar
            hull() {
                translate([-85.0, 0.0, -60.0])
                    cylinder(d = 22.0, h = 80.0, $fn = 60);
                translate([-145.0, 0.0, -60.0])
                    cylinder(d = 22.0, h = 80.0, $fn = 60);
            }
            
            // 4. Stationary Spring Post Bracket (at clevis level z = -8 -> -4.4, thickness 3.6mm)
            // Extends from the side of the handle body to [-95.0, 20.0]
            translate([0, 0, -8.0]) {
                hull() {
                    translate([-95.0, 0.0, 0.0])
                        cylinder(d = 22.0, h = 3.6, $fn = 50);
                    translate([-95.0, 20.0, 0.0])
                        cylinder(d = 10.0, h = 3.6, $fn = 50);
                }
            }
            // Vertical spring peg pointing up (starts at top of bracket z = -4.4, height 6.0)
            translate([-95.0, 20.0, -4.4])
                cylinder(d = spring_peg_d, h = 6.0, $fn = 25);
        }

        // SUBTRACT internal bores and holes from the entire assembly
        union() {
            // Upper Chamber (plunger bore, ID 57.5, z = 0 -> 15)
            translate([0, 0, -0.1])
                cylinder(d = plunger_di + 0.3, h = 15.1, $fn = 100);
                
            // Lower Chamber (shroud, ID 57.5, z = -15 -> 0)
            translate([0, 0, -15.1])
                cylinder(d = plunger_di + 0.3, h = 15.2, $fn = 100);
                
            // Stop Ledge (internal flange, ID 53.0, z = 15 -> 18)
            rotate_extrude($fn = 100) {
                polygon([
                    [0, 14.9],
                    [(plunger_di + 0.3)/2, 14.9],
                    [53.0/2, 17.0],
                    [53.0/2, 18.0],
                    [(plunger_di + 0.3)/2, 20.1],
                    [0, 20.1]
                ]);
            }
                
            // M3 Screw Pivot holes (Pivot A):
            translate([pivot_x, pivot_y, -4.1])
                cylinder(d = screw_tap_d, h = 4.2, $fn = 30);
            translate([pivot_x, pivot_y, -12.1])
                cylinder(d = screw_clearance_d, h = 4.2, $fn = 30);
            translate([pivot_x, pivot_y, -12.1])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
                
            // M3 Screw Pivot holes (Pivot B - Trigger):
            translate([trigger_pivot_x, trigger_pivot_y, -4.1])
                cylinder(d = screw_tap_d, h = 4.2, $fn = 30);
            translate([trigger_pivot_x, trigger_pivot_y, -12.1])
                cylinder(d = screw_clearance_d, h = 4.2, $fn = 30);
            translate([trigger_pivot_x, trigger_pivot_y, -12.1])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
                
            // 4. Clevis knuckle slot cutout for Pivot B trigger (z = -8.1 -> 0.1)
            // Cuts straight back along X-axis to clear knuckle rotation
            translate([trigger_pivot_x, trigger_pivot_y, -8.1])
                translate([-20.0, -8.0, 0.0])
                    cube([40.0, 16.0, 8.2]);
        }
    }
}

module wiper_arm() {
    // Geared wiper arm (local origin [0,0,0] is Pivot A)
    // Squeegee arm points along +X, gear sector faces along -X (180 degrees)
    difference() {
        union() {
            // Knuckle (middle pivot block: z = 0.2 -> 3.8)
            translate([0, 0, 2.0])
                cylinder(d = 11.6, h = 3.6, center = true, $fn = 50);
                
            // Wiper Arm pointing along +X locally (length 65.0mm)
            translate([0, -2.5, 0.2])
                cube([65.0, 5.0, 3.6]);
                
            // 9.0mm Pinion Gear Sector pointing along -X (180 degrees)
            // Teeth at local 120, 180, 240 degrees (pitch spacing 60 degrees)
            translate([0, 0, 2.0]) rotate([0, 0, 180])
                gear_sector(pitch_r = 9.0, num_teeth = 3, tooth_angle_span = 60.0, thickness = 3.6);
        }

        // Pin Hole (Clearance fit for M3 screw)
        translate([0, 0, -1])
            cylinder(d = screw_clearance_d, h = 6, $fn = 30);
            
        // Wiper Blade slot (width 1.5mm, depth 2.2mm, z = 1.8 -> 4.0)
        translate([8.0, -0.75, 1.8])
            cube([57.0, 1.5, 2.2]);
    }
}

module trigger_lever() {
    // Geared moving thumb trigger lever (local origin [0,0,0] is Pivot B)
    // Gear sector faces along 0 degrees (straight right), thumb tab extends along 180 degrees (straight left)
    difference() {
        union() {
            // Knuckle & Thumb Tab base
            hull() {
                translate([0, 0, 2.0])
                    cylinder(d = 14.0, h = 3.6, center = true, $fn = 50);
                translate([-25.0, 0.0, 2.0])
                    cylinder(d = 10.0, h = 3.6, center = true, $fn = 50);
            }
                
            // 27.0mm Gear Sector pointing along 0 degrees (towards Pivot A)
            // Teeth at local -40, -20, 0, 20, 40 degrees (pitch spacing 20 degrees, centered at 0)
            translate([0, 0, 2.0]) rotate([0, 0, 0])
                gear_sector(pitch_r = 27.0, num_teeth = 5, tooth_angle_span = 20.0, thickness = 3.6);
                
            // Vertical Spring Peg pointing up from top surface (z = 3.8)
            // Placed at distance 15mm along the thumb tab axis (180 degrees)
            translate([-15.0, 0.0, 3.8])
                cylinder(d = spring_peg_d, h = 6.0, $fn = 25);
        }

        // Pin Hole (Clearance fit for M3 screw)
        translate([0, 0, -1])
            cylinder(d = screw_clearance_d, h = 6, $fn = 30);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade
    // Fits into the wiper arm slot and extends upwards to scrape the plunger face.
    // Shifted to start at local x = 8.0 to clear pivot knuckle.
    // Total length is 57.0mm.
    // Total height is 8.0mm (2.2mm in slot, 5.8mm sticking out).
    translate([8.0, -0.75, 1.8]) {
        // Base slot block
        cube([57.0, 1.5, 2.2]);
        // Squeegee flap (5.8mm sticks out, total height 8.0mm)
        translate([0, 0, 2.2])
            cube([57.0, 1.0, 5.8]);
    }
}

module mock_m3_screw(len = 12.0) {
    color("silver") {
        // Head recess sits at z = -12 -> -9.5, so screw head sits here pointing down.
        // Rendering socket head cap screw head (D=5.5, H=3.0) sticking out 0.5mm below knuckle
        translate([0, 0, -2.5])
            cylinder(d = 5.5, h = 3.0, $fn = 20);
        // Screw shaft going up into the upper knuckle
        cylinder(d = 3.0, h = len, $fn = 20);
    }
}

// --- MOCK PLUNGER ---
module mock_plunger() {
    color([0.5, 0.5, 0.5, 0.6]) {
        difference() {
            cylinder(d = plunger_di, h = 50.0, $fn=100);
            translate([0, 0, -1])
                cylinder(d = plunger_di - 4.0, h = 48.0, $fn=100);
        }
        if (plunger_dome_h > 0) {
            r_val = plunger_di / 2;
            R_sph = (r_val * r_val + plunger_dome_h * plunger_dome_h) / (2 * plunger_dome_h);
            difference() {
                translate([0, 0, plunger_dome_h - R_sph])
                    sphere(r = R_sph, $fn=100);
                translate([0, 0, -R_sph])
                    cube([R_sph*2 + 10, R_sph*2 + 10, R_sph*2], center=true);
            }
        }
    }
}

// --- GEAR HELPER MODULES ---
module gear_tooth(pitch_r, thickness) {
    // Generates a single robust trapezoidal tooth along +X
    // Extruded height matches the knuckle slots
    linear_extrude(height = thickness, center = true)
        polygon([
            [pitch_r - 1.5, 2.0],
            [pitch_r + 1.5, 1.0],
            [pitch_r + 1.5, -1.0],
            [pitch_r - 1.5, -2.0]
        ]);
}

module gear_sector(pitch_r, num_teeth, tooth_angle_span, thickness) {
    // Generates a sector of gear teeth centered at the origin
    union() {
        // Base backing sector cylinder
        cylinder(r = pitch_r - 1.0, h = thickness, center = true, $fn = 50);
        // Spaced teeth
        for (i = [0 : num_teeth-1]) {
            angle = (i - (num_teeth-1)/2) * tooth_angle_span;
            rotate([0, 0, angle])
                gear_tooth(pitch_r, thickness);
        }
    }
}

