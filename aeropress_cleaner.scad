// OpenSCAD Model for Aeropress Plunger Wiper Ring (ADCR)
// Simplified 2-Part Mechanical System with Shroud and M3 Metal Pivot Screw:
// 1. Ring Body (Rigid): 35mm tall collar with 330-degree slot and internal stop ledge.
// 2. Wiper Arm (Rigid): Long pivoted lever (65mm) that completely crosses the plunger.
// 3. Wiper Blade (Flexible): 57mm TPU blade pointing upwards, starts 8mm from pivot.

use <MCAD/involute_gears.scad>

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, ring: Ring Body (Rigid), wiper: Wiper Arm (Rigid), trigger: Trigger Lever (Rigid), blade: Wiper Blade (Flexible)]

// --- CUSTOMIZABLE PARAMETERS ---
plunger_di = 58.0;
plunger_dome_h = 3.5;
right_handed = false; // Set to true for right-handed version, false for left-handed

// --- ADVANCED PARAMETERS ---
wall_thickness = 3.0; // thick walls for robust ring
clearance = 0.2;

// Hinge/Pivot geometry (M3 Metal Screw Pivot)
pivot_x = -35.0;
pivot_y = 0.0;
trigger_pivot_x = -60.0;
trigger_pivot_y = 0.0;

screw_tap_d = 2.8;     // M3 threads tap directly into plastic
screw_clearance_d = 3.3; // loose fit for smooth pivot rotation
screw_head_d = 6.0;    // recess for M3 socket head cap screw
screw_head_h = 2.5;

// Handle and Spring peg positions
stationary_handle_x = -145.0;
stationary_handle_y = 0.0;
spring_peg_d = 3.0; // fits inside 4mm ID spring
handle_roundover = 2.0; // radius of roundover on handle edges

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
    translate([pivot_x, pivot_y, 0.0]) {
        rotate([0, 0, wiper_angle]) {
            color("green") wiper_arm();
            color("blue") wiper_blade();
        }
    }
    
    // 3. Trigger Lever (Pivot B)
    translate([trigger_pivot_x, trigger_pivot_y, 0.0]) {
        rotate([0, 0, trigger_angle]) {
            color("green") trigger_lever();
            // Mock M3x20 screw for trigger spring peg (goes through riser)
            translate([-12.0, 0.0, 19.6])
                rotate([180, 0, 0])
                    mock_m3_screw(len = 20.0);
        }
    }
    
    // 4. M3 Metal Pivot Screws (Pivot A & B)
    translate([pivot_x, pivot_y, 15.0])
        rotate([180, 0, 0])
            mock_m3_screw(len = 30.0);
    translate([trigger_pivot_x, trigger_pivot_y, 15.0])
        rotate([180, 0, 0])
            mock_m3_screw(len = 30.0);
            
    // 4a. Mock M3x12 screw for casing spring peg
    translate([-85.0, 0.0, -15.0])
        mock_m3_screw(len = 12.0);
            
    // 5. Mock Plunger (Animated)
    if (animate || t_val > 0) {
        translate([0, 0, plunger_z])
            mock_plunger();
    }
    
    // 6. Mock Spring (Animated compression between pegs, global z = -4.2)
    trigger_peg_x = trigger_pivot_x + 12.0 * cos(trigger_angle + 180.0);
    trigger_peg_y = trigger_pivot_y + 12.0 * sin(trigger_angle + 180.0);
    
    stationary_peg_x = -85.0;
    stationary_peg_y = 0.0;
    
    dx = trigger_peg_x - stationary_peg_x;
    dy = trigger_peg_y - stationary_peg_y;
    dist = sqrt(dx*dx + dy*dy);
    angle = atan2(dy, dx);
    
    color("red")
        translate([stationary_peg_x, stationary_peg_y, -1.5])
            rotate([0, 0, angle])
                rotate([0, 90, 0])
                    cylinder(d = 5.0, h = dist, $fn=20);
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
                
                // Horizontal Slot in ring wall for arm/blade to sweep (Z span: z = -5.0 -> +7.0, height 12.0mm)
                translate([0, 0, -5.0]) {
                    intersection() {
                        difference() {
                            cylinder(d = plunger_di + 2*wall_thickness + 5.0, h = 12.0, $fn=100);
                            cylinder(d = plunger_di - 2.0, h = 14.0, center=true, $fn=100);
                        }
                        linear_extrude(height = 12.0) {
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
            
            // 2. Straight Tuning-Fork Handle Casing (z = -15.0 -> 15.0, H = 30mm)
            // A simple straight flat bar running from Pivot A to the grip end.
            hull() {
                translate([pivot_x, pivot_y, 0.0])
                    rounded_cylinder(d = 20.0, h = 30.0, r = handle_roundover, center = true);
                translate([trigger_pivot_x, trigger_pivot_y, 0.0])
                    rounded_cylinder(d = 20.0, h = 30.0, r = handle_roundover, center = true);
                translate([stationary_handle_x, 0.0, 0.0])
                    rounded_cylinder(d = 20.0, h = 30.0, r = handle_roundover, center = true);
            }
        }

        // SUBTRACT internal bores and holes from the entire assembly
        union() {
            // Upper Chamber (plunger bore, ID 58.3, z = 0 -> 20, extended to top)
            translate([0, 0, -0.1])
                cylinder(d = plunger_di + 0.3, h = 20.2, $fn = 100);
                
            // Lower Chamber (shroud, ID 58.3, z = -15 -> 0)
            translate([0, 0, -15.1])
                cylinder(d = plunger_di + 0.3, h = 15.2, $fn = 100);
                
            // M3 Screw Pivot holes (Pivot A):
            // Head recess at top of handle plate:
            translate([pivot_x, pivot_y, 15.0 - screw_head_h])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
            // Clearance hole through bottom plate, knuckle & top plate:
            translate([pivot_x, pivot_y, -15.1])
                cylinder(d = screw_clearance_d, h = 30.2, $fn = 30);
            // Hex nut recess at bottom of handle plate:
            translate([pivot_x, pivot_y, -15.1])
                cylinder(d = 6.2, h = 2.6, $fn = 6);
                
            // M3 Screw Pivot holes (Pivot B - Trigger):
            // Head recess at top of handle plate:
            translate([trigger_pivot_x, trigger_pivot_y, 15.0 - screw_head_h])
                cylinder(d = screw_head_d, h = screw_head_h + 0.1, $fn = 30);
            // Clearance hole through bottom plate, knuckle & top plate:
            translate([trigger_pivot_x, trigger_pivot_y, -15.1])
                cylinder(d = screw_clearance_d, h = 30.2, $fn = 30);
            // Hex nut recess at bottom of handle plate:
            translate([trigger_pivot_x, trigger_pivot_y, -15.1])
                cylinder(d = 6.2, h = 2.6, $fn = 6);
                
            // M3 Screw hole for stationary spring peg (Nut-secured)
            // Clearance hole d=3.4 through the bottom (Z=-15.1 to -7.1, height 8.0)
            translate([-85.0, 0.0, -15.1])
                cylinder(d = 3.4, h = 8.4, $fn = 20);
            // Counterbore for screw head (d=6.0, depth 3.0, Z=-15.1 to -11.9)
            translate([-85.0, 0.0, -15.1])
                cylinder(d = 6.0, h = 3.2, $fn = 30);
            // Hex Nut pocket in the pocket floor (d=5.8 flat-to-flat, depth 3.0, Z=-6.8 to -3.8)
            translate([-85.0, 0.0, -6.8])
                rotate([0, 0, 30])
                    cylinder(d = 5.8 / cos(30), h = 3.1, $fn = 6);
                
            // 4. Internal Gear Pocket Cavity Cutout (z = -3.8 -> 3.8, height 7.6)
            // Houses both gear knuckles and the trigger lever swept path (open 30mm wide slot)
            translate([0, 0, -3.8]) {
                linear_extrude(height = 7.6) {
                    hull() {
                        translate([pivot_x, pivot_y])
                            circle(r = 15.0, $fn = 50);
                        translate([trigger_pivot_x, trigger_pivot_y])
                            circle(r = 15.0, $fn = 50);
                    }
                    // Shortened pocket extension (Z = -3.8 -> 3.8, X = -95 -> -50)
                    translate([-95.0, -15.0])
                        square([45.0, 30.0]);
                }
            }
            
            // 5. Trigger lever riser slot cutout in top plate (z = 4.0 -> 15.1)
            // Arc of radius 12mm, width 11mm (0.5mm clearance), spanning 60 -> 180 degrees from Pivot B [-60, 0]
            translate([trigger_pivot_x, trigger_pivot_y, 3.5]) {
                linear_extrude(height = 11.6) {
                    intersection() {
                        difference() {
                            circle(r = 12.0 + 8.0, $fn = 60);
                            circle(r = 12.0 - 7.0, $fn = 60);
                        }
                        polygon([
                            [0.0, 0.0],
                            [25.0 * cos(60.0), 25.0 * sin(60.0)],
                            [0.0, 25.0],
                            [-25.0, 25.0],
                            [-25.0, 0.0]
                        ]);
                    }
                }
            }
            
        }
    }
    // 4. Plunger Guide Bumps (Z=8.0)
    plunger_guide_bumps();
}

module wiper_arm() {
    // Geared wiper arm (local origin [0,0,0] is Pivot A)
    // Squeegee arm points along +X, gear sector faces along -X (180 degrees)
    difference() {
        union() {
            // Knuckle (Split to avoid collision with trigger gear teeth)
            // Top half (standard size, Z = 0.0 -> 3.6)
            translate([0, 0, 0])
                cylinder(d = 11.6, h = 3.6, $fn = 50);
            // Bottom half (shrunk to gear root radius, Z = -3.6 -> 0.0)
            translate([0, 0, -3.6])
                cylinder(d = 6.26, h = 3.6, $fn = 50);
                
            // Stiffened Wiper Arm bar (length 63.0mm, thickness 6.6mm, z = -3.6 -> 3.0)
            translate([0, -2.5, -3.6])
                cube([63.0, 5.0, 6.6]);
                
            // 5.0mm Pinion Gear Sector centered at Z=-1.8 (thickness 3.6mm, z = -3.6 -> 0.0)
            // Uses MCAD involute gear library for smoother meshing.
            translate([0, 0, -1.8])
                rotate([0, 0, 180])
                    involute_gear_sector(
                        pitch_r = 5.0,
                        full_teeth = 6,
                        sector_angle = 240,
                        gear_rotation = 30,
                        thickness = 3.6
                    );
        }

        // Pin Hole (Clearance fit for M3 screw)
        cylinder(d = screw_clearance_d, h = 10.0, center = true, $fn = 30);
            
        // Wiper Blade slot (dovetail, 4.6mm deep, Z = -1.6 -> 3.0)
        translate([8.0, 0, 0.7])
            dovetail_solid(55.1);
    }
}

module trigger_lever() {
    // Geared moving thumb trigger lever (local origin [0,0,0] is Pivot B)
    // Gear sector faces along 0 degrees (straight right), thumb tab extends along 180 degrees (straight left)
    difference() {
        union() {
            // Knuckle (middle pivot block: z = -3.6 -> 3.6, height 7.2)
            cylinder(d = 14.0, h = 7.2, center = true, $fn = 50);
            
            // Offset trigger arm inside upper half of the slot (H = 3.6mm, z = 0.0 -> 3.6)
            hull() {
                translate([0, 0, 1.8])
                    cylinder(d = 14.0, h = 3.6, center = true, $fn = 50);
                translate([-12.0, 0.0, 1.8])
                    cylinder(d = 10.0, h = 3.6, center = true, $fn = 50);
            }
            
            // Riser (vertical cylinder, Z = -0.1 -> 16.1 for overlap)
            // Riser (vertical cylinder, Z = 3.5 -> 16.2 for overlap)
            translate([-12.0, 0.0, 3.5])
                cylinder(d = 10.0, h = 12.7, $fn = 50);
            
            // Thumb Tab horizontal plate (sitting at z = 16.0, thickness 3.6mm, 1.0mm clearance gap)
            // No center=true, so spans Z = 16.0 -> 19.6
            translate([-12.0, 0.0, 16.0]) {
                hull() {
                    cylinder(d = 10.0, h = 3.6, $fn = 50);
                    translate([-15.0, 0.0, 0.0])
                        cylinder(d = 10.0, h = 3.6, $fn = 50);
                }
            }
                
            // 20.0mm Gear Sector centered at Z=-1.8 (thickness 3.6mm, z = -3.6 -> 0.0)
            // Uses MCAD involute gear library for smoother meshing.
            translate([0, 0, -1.8])
                rotate([0, 0, 67.5])
                    involute_gear_sector(
                        pitch_r = 20.0,
                        full_teeth = 24,
                        sector_angle = 75,
                        gear_rotation = 0,
                        thickness = 3.6
                    );
        }

        // Pin Hole (Clearance fit for M3 screw)
        cylinder(d = screw_clearance_d, h = 10.0, center = true, $fn = 30);
        
        // M3 Screw hole for trigger spring peg (goes through riser, nut-secured)
        // Head counterbore at top of thumb tab (d=6.0, depth 3.0, Z=16.6 to 19.7)
        translate([-12.0, 0.0, 16.6])
            cylinder(d = 6.0, h = 3.2, $fn = 30);
        // Clearance hole through riser/arm (d=3.4, Z=3.0 to 16.6)
        translate([-12.0, 0.0, 2.9])
            cylinder(d = 3.4, h = 13.8, $fn = 20);
        // Hex nut pocket at bottom of arm (d=5.8 flat-to-flat, depth 3.0, Z=0.0 to 3.0)
        translate([-12.0, 0.0, -0.1])
            rotate([0, 0, 30])
                cylinder(d = 5.8 / cos(30), h = 3.2, $fn = 6);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade
    // Fits into the wiper arm slot and extends upwards to scrape the plunger face.
    // Shifted to start at local x = 8.0 to clear pivot knuckle.
    // Total length is 55.0mm.
    // Total height is 7.6mm (4.6mm in slot, 3.0mm sticking out).
    // Shifted to Z=0.7 to match the deeper wiper arm slot.
    translate([8.0, 0, 0.7]) {
        // Base slot block (dovetail with clearance)
        dovetail_blade_base(55.0, clearance);
        // Squeegee flap (3.0mm sticks out, total height 7.6mm, z = 2.9 -> 6.0 global)
        // Centered in Y, with 0.1mm overlap at base
        translate([0, -0.5, 2.2])
            cube([55.0, 1.0, 3.1]);
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

module involute_gear_sector(pitch_r, full_teeth, sector_angle, gear_rotation, thickness) {
    // Generates a gear sector using MCAD involute gear library
    // pitch_r: pitch radius of the gear
    // full_teeth: number of teeth in the full gear
    // sector_angle: angle of the sector to keep
    // gear_rotation: rotation of the gear before cutting (to align teeth)
    // thickness: gear thickness
    cp = pitch_r * 2 * PI / full_teeth;
    outer_r = pitch_r * (1 + 2.0 / full_teeth) + 1.0; // add 1mm safety margin
    
    intersection() {
        rotate([0, 0, gear_rotation])
            translate([0, 0, -thickness/2])
                gear(
                    number_of_teeth = full_teeth,
                    circular_pitch = cp,
                    pressure_angle = 20,
                    clearance = 0.2,
                    gear_thickness = thickness,
                    rim_thickness = thickness,
                    rim_width = 0,
                    hub_thickness = thickness,
                    hub_diameter = 0,
                    bore_diameter = 0,
                    circles = 0
                );
        sector_cylinder(r = outer_r, angle = sector_angle, h = thickness + 0.1);
    }
}

// --- DOVETAIL HELPER MODULES ---
module dovetail_solid(length) {
    rotate([0, 90, 0])
        linear_extrude(height = length)
            polygon([
                [2.3, -1.25],
                [2.3, 1.25],
                [-2.3, 0.75],
                [-2.3, -0.75]
            ]);
}

module dovetail_blade_base(length, clear = 0.0) {
    w_top = 1.5 - clear;
    w_bottom = 2.5 - clear;
    rotate([0, 90, 0])
        linear_extrude(height = length)
            polygon([
                [2.3, -w_bottom/2],
                [2.3, w_bottom/2],
                [-2.3, w_top/2],
                [-2.3, -w_top/2]
            ]);
}

module rounded_cylinder(d, h, r, center = true) {
    // Generates a cylinder with rounded top and bottom edges
    // d: diameter
    // h: height
    // r: roundover radius
    limit_r = min(r, d/2 - 0.1, h/2 - 0.1);
    
    z_shift = center ? 0 : h/2;
    
    translate([0, 0, z_shift]) {
        hull() {
            // Internal core cylinder
            cylinder(d = d - 2 * limit_r, h = h, center = true, $fn = 50);
            
            // Top rounding ring
            translate([0, 0, h/2 - limit_r])
                rotate_extrude($fn = 50)
                    translate([d/2 - limit_r, 0, 0])
                        circle(r = limit_r, $fn = 25);
                        
            // Bottom rounding ring
            translate([0, 0, -h/2 + limit_r])
                rotate_extrude($fn = 50)
                    translate([d/2 - limit_r, 0, 0])
                        circle(r = limit_r, $fn = 25);
        }
    }
}

module plunger_guide_bumps() {
    r_sphere = 1.5;
    protrusion = 0.8;
    rc = (plunger_di + 0.3)/2 + r_sphere - protrusion;
    color("gray") {
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([rc, 0, 8.0])
                    sphere(r = r_sphere, $fn = 20);
        }
    }
}

