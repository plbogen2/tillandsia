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
trigger_pivot_x = -80.0;
trigger_pivot_y = 0.0;

screw_tap_d = 2.8;     // M3 threads tap directly into plastic
screw_clearance_d = 3.3; // loose fit for smooth pivot rotation
screw_head_d = 6.0;    // recess for M3 socket head cap screw
screw_head_h = 2.5;

// Handle and Spring peg positions
stationary_handle_x = -135.0;
stationary_handle_y = 0.0;
spring_peg_d = 6.0; // fits inside 8mm ID spring

// --- ANIMATION CONTROLS ---
animate = false;
time_t = undef;
t_val = (time_t != undef) ? time_t : $t;

// Wiper Angle Animation:
// t = 0.0 -> 0.2: Wiper parks at +90 degrees (idle, top)
// t = 0.2 -> 0.5: Wiper sweeps clockwise to -90 degrees (compressing spring)
// t = 0.5 -> 0.8: Wiper returns counter-clockwise to +90 degrees
wiper_angle = 
    (t_val < 0.2) ? 90 :
    (t_val < 0.5) ? 90 - ((t_val - 0.2) / 0.3) * 180 :
    (t_val < 0.8) ? -90 + ((t_val - 0.5) / 0.3) * 180 :
    90;

// Trigger Angle Animation: Squeezes counter-clockwise from -90 -> -45 linked to wiper (ratio 4:1)
trigger_angle = -90.0 - (wiper_angle - 90.0) / 4.0;


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
    
    stationary_peg_x = -65.0;
    stationary_peg_y = 10.0;
    
    dx = trigger_peg_x - stationary_peg_x;
    dy = trigger_peg_y - stationary_peg_y;
    dist = sqrt(dx*dx + dy*dy);
    angle = atan2(dy, dx);
    
    color("red")
        translate([stationary_peg_x, stationary_peg_y, -2.0])
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
                                [0.0, 0.0],
                                [75.0 * cos(15.0), 75.0 * sin(15.0)],
                                [75.0 * cos(90.0), 75.0 * sin(90.0)],
                                [75.0 * cos(180.0), 75.0 * sin(180.0)],
                                [75.0 * cos(270.0), 75.0 * sin(270.0)],
                                [75.0 * cos(345.0), 75.0 * sin(345.0)]
                            ]);
                        }
                    }
                }
            }
            
            // 2. Dual-Pivot Integrated Handle Casing (z = -12.0 -> 12.0)
            // Solid casing block including the flat horizontal handle
            hull() {
                translate([pivot_x, pivot_y, 0.0])
                    cylinder(d = 12.0, h = 24.0, center = true, $fn = 50);
                translate([trigger_pivot_x, trigger_pivot_y, 0.0])
                    cylinder(d = 16.0, h = 24.0, center = true, $fn = 50);
                translate([-160.0, 0.0, 0.0])
                    cylinder(d = 20.0, h = 24.0, center = true, $fn = 60);
            }
            
            // 3. Stationary Spring Post (starts at bottom plate floor z = -4.0, height 6.0)
            // Placed at [-65.0, 10.0] inside the gear cavity slot
            translate([-65.0, 10.0, -4.0])
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
            // Head recess at bottom:
            translate([pivot_x, pivot_y, -12.1])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
            // Clearance hole through bottom floor & knuckle:
            translate([pivot_x, pivot_y, -12.1])
                cylinder(d = screw_clearance_d, h = 16.2, $fn = 30);
            // Tap hole in top plate (z = 4.0 -> 12.0):
            translate([pivot_x, pivot_y, 4.0])
                cylinder(d = screw_tap_d, h = 8.1, $fn = 30);
                
            // M3 Screw Pivot holes (Pivot B - Trigger):
            // Head recess at bottom:
            translate([trigger_pivot_x, trigger_pivot_y, -12.1])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
            // Clearance hole through bottom floor & knuckle:
            translate([trigger_pivot_x, trigger_pivot_y, -12.1])
                cylinder(d = screw_clearance_d, h = 16.2, $fn = 30);
            // Tap hole in top plate (z = 4.0 -> 12.0):
            translate([trigger_pivot_x, trigger_pivot_y, 4.0])
                cylinder(d = screw_tap_d, h = 8.1, $fn = 30);
                
            // 4. Internal Gear Pocket Cavity Cutout (z = -4.1 -> 4.1, height 8.2)
            // Houses both gear knuckles and the trigger lever swept path
            translate([0, 0, -4.1]) {
                linear_extrude(height = 8.2) {
                    hull() {
                        translate([pivot_x, pivot_y])
                            circle(r = 11.0, $fn = 50);
                        translate([trigger_pivot_x, trigger_pivot_y])
                            circle(r = 29.0, $fn = 50);
                    }
                    // Extend pocket left to clear the trigger tab base and spring
                    translate([-120.0, -15.0])
                        square([60.0, 30.0]);
                }
            }
        }
    }
}

module wiper_arm() {
    // Geared wiper arm (local origin [0,0,0] is Pivot A)
    // Squeegee arm points along +X, gear sector faces along -X (180 degrees)
    difference() {
        union() {
            // Knuckle (middle pivot block: z = -3.6 -> 3.6, height 7.2)
            cylinder(d = 11.6, h = 7.2, center = true, $fn = 50);
                
            // Wiper Arm pointing along +X locally (length 63.0mm, thickness 3.6mm, z = -1.8 -> 1.8)
            translate([0, -2.5, -1.8])
                cube([63.0, 5.0, 3.6]);
                
            // 9.0mm Pinion Gear Sector centered at Z=0 (thickness 3.6mm, z = -1.8 -> 1.8)
            // Teeth at local -90, -30, 30, 90 degrees relative to 180 (spans 180 degrees total)
            rotate([0, 0, 180])
                gear_sector(pitch_r = 9.0, num_teeth = 4, tooth_angle_span = 60.0, thickness = 3.6);
        }

        // Pin Hole (Clearance fit for M3 screw)
        cylinder(d = screw_clearance_d, h = 10.0, center = true, $fn = 30);
            
        // Wiper Blade slot (width 1.5mm, depth 5.0mm, z = -1.8 -> 3.2)
        translate([8.0, -0.75, -1.8])
            cube([55.0, 1.5, 5.0]);
    }
}

module trigger_lever() {
    // Geared moving thumb trigger lever (local origin [0,0,0] is Pivot B)
    // Gear sector faces along 0 degrees (straight right), thumb tab extends along 180 degrees (straight left)
    difference() {
        union() {
            // Knuckle (middle pivot block: z = -3.6 -> 3.6, height 7.2)
            cylinder(d = 14.0, h = 7.2, center = true, $fn = 50);
            
            // Vertical Gooseneck Riser (hulls from knuckle at z=0 to top deck at z=12)
            hull() {
                cylinder(d = 14.0, h = 1.0, center = true, $fn = 50);
                translate([-15.0, 0.0, 13.5])
                    cylinder(d = 10.0, h = 1.0, center = true, $fn = 50);
            }
            
            // Thumb Tab horizontal plate (sitting at z = 13.5, thickness 3.6mm, 1.5mm clearance gap)
            translate([-15.0, 0.0, 13.5]) {
                hull() {
                    cylinder(d = 10.0, h = 3.6, center = true, $fn = 50);
                    translate([-15.0, 0.0, 0.0])
                        cylinder(d = 10.0, h = 3.6, center = true, $fn = 50);
                }
            }
                
            // 27.0mm Gear Sector centered at Z=0 (thickness 3.6mm, z = -1.8 -> 1.8)
            // Teeth at local 37.5, 52.5, 67.5, 82.5, 97.5 degrees (pitch spacing 15 degrees)
            rotate([0, 0, 67.5])
                gear_sector(pitch_r = 27.0, num_teeth = 5, tooth_angle_span = 15.0, thickness = 3.6);
                
            // Vertical Spring Peg pointing down from knuckle center (z = 0.0 -> -3.0)
            // Placed at distance 15mm along the thumb tab axis (180 degrees)
            translate([-15.0, 0.0, 0.0])
                mirror([0, 0, 1])
                    cylinder(d = spring_peg_d, h = 3.0, $fn = 25);
        }

        // Pin Hole (Clearance fit for M3 screw)
        cylinder(d = screw_clearance_d, h = 10.0, center = true, $fn = 30);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade
    // Fits into the wiper arm slot and extends upwards to scrape the plunger face.
    // Shifted to start at local x = 8.0 to clear pivot knuckle.
    // Total length is 55.0mm.
    // Total height is 8.0mm (5.0mm in slot, 3.0mm sticking out).
    translate([8.0, -0.75, -1.8]) {
        // Base slot block
        cube([55.0, 1.5, 5.0]);
        // Squeegee flap (3.0mm sticks out, total height 8.0mm, z = 3.2 -> 6.2)
        translate([0, 0, 5.0])
            cube([55.0, 1.0, 3.0]);
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

module sector_cylinder(r, angle, h) {
    // Generates a cylinder sector of radius r, height h, centered at origin
    // Spans 'angle' degrees symmetrically around the +X axis (from -angle/2 to +angle/2)
    linear_extrude(height = h, center = true)
        polygon([
            [0.0, 0.0],
            [r * cos(-angle/2), r * sin(-angle/2)],
            [r * cos(-angle/4), r * sin(-angle/4)],
            [r, 0.0],
            [r * cos(angle/4), r * sin(angle/4)],
            [r * cos(angle/2), r * sin(angle/2)]
        ]);
}

module gear_sector(pitch_r, num_teeth, tooth_angle_span, thickness) {
    // Generates a wedge-shaped sector of gear teeth centered at the origin
    union() {
        // Wedge backing sector
        sector_angle = (num_teeth - 1) * tooth_angle_span + 30.0;
        sector_cylinder(r = pitch_r - 1.0, angle = sector_angle, h = thickness);
        
        // Spaced teeth
        for (i = [0 : num_teeth-1]) {
            angle = (i - (num_teeth-1)/2) * tooth_angle_span;
            rotate([0, 0, angle])
                gear_tooth(pitch_r, thickness);
        }
    }
}

