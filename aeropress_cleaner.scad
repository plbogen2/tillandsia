// OpenSCAD Model for Aeropress Desk Cleaning Funnel (ADCF)
// Mechanical Spring-Loaded Wiper Version.
// Consists of:
// 1. Funnel Body (Rigid): Simple funnel with handle, hinge knuckle, and spring housing.
// 2. Wiper Arm (Rigid): Pivoted lever that sweeps across the plunger face.
// 3. Wiper Blade (Flexible): Slides into the wiper arm to squeegee the plunger face.
// 4. Pivot Pin (Rigid): Secures the wiper arm to the funnel.

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, funnel: Funnel Body (Rigid), wiper: Wiper Arm (Rigid), blade: Wiper Blade (Flexible), pin: Pivot Pin (Rigid)]

// --- CUSTOMIZABLE PARAMETERS ---
plunger_di = 57.2;
plunger_dome_h = 3.5;
filter_di = 62.0;

// --- ADVANCED PARAMETERS ---
wall_thickness = 2.4;
clearance = 0.2;

// Hinge/Pivot geometry
pivot_x = -35.0;
pivot_y = 0.0;
pivot_d = 5.0; // 5mm pivot pin

// Spring Geometry (Mounjaro Pen Spring: OD ~10mm, length ~40mm)
spring_od = 10.0;
spring_len = 40.0;
spring_pocket_d = spring_od + 1.0;

// --- ANIMATION CONTROLS ---
animate = false;
time_t = undef;
t_val = (time_t != undef) ? time_t : $t;

// Wiper Angle Animation:
// t = 0.0 -> 0.2: Wiper parks at -45 degrees (idle)
// t = 0.2 -> 0.5: Wiper sweeps to +45 degrees (compressing spring)
// t = 0.5 -> 0.8: Wiper returns to -45 degrees (spring release)
// t = 0.8 -> 1.0: Idle
wiper_angle = 
    (t_val < 0.2) ? -45 :
    (t_val < 0.5) ? -45 + ((t_val - 0.2) / 0.3) * 90 :
    (t_val < 0.8) ? 45 - ((t_val - 0.5) / 0.3) * 90 :
    -45;

// Plunger insertion animation (enters funnel before sweep, retracts after)
plunger_z = 
    (t_val < 0.1) ? 100 - (t_val/0.1)*48 :
    (t_val < 0.8) ? 52 :
    52 + ((t_val - 0.8)/0.2)*48;

if (part == "all") {
    assembly();
} else if (part == "funnel") {
    funnel_body();
} else if (part == "wiper") {
    wiper_arm();
} else if (part == "blade") {
    wiper_blade();
} else if (part == "pin") {
    pivot_pin();
}

module assembly() {
    // 1. Funnel (Rigid)
    funnel_body();
    
    // 2. Wiper Arm & Blade (Animated rotation around Z at pivot_x, pivot_y)
    translate([pivot_x, pivot_y, 45.0]) {
        rotate([0, 0, wiper_angle]) {
            color("green") wiper_arm();
            color("blue") wiper_blade();
        }
    }
    
    // 3. Pivot Pin (Rigid)
    color("gray")
        translate([pivot_x, pivot_y, 41.0])
            pivot_pin();
            
    // 4. Mock Plunger (Animated)
    if (animate || t_val > 0) {
        translate([0, 0, plunger_z])
            mock_plunger();
            
        // Mock Spring (Animated compression)
        // Spring sits in the pocket on the side. We can render a simple helical line or blocks.
        color("silver")
            translate([pivot_x - 12.0, 10.0, 45.0])
                rotate([90, 0, 0])
                    cylinder(d = spring_od, h = 25.0 - (wiper_angle + 45)/90 * 15.0, $fn=20);
    }
}

module funnel_body() {
    difference() {
        union() {
            // Spout
            cylinder(d = 35 + 2 * wall_thickness, h = 15, $fn = 100);
            
            // Cone
            translate([0, 0, 15])
                cylinder(d1 = 35 + 2 * wall_thickness, d2 = 61 + 2 * wall_thickness, h = 35, $fn = 100);
                
            // Chamber Outer Cylinder
            translate([0, 0, 50])
                cylinder(d = 65 + 2 * wall_thickness, h = 15, $fn = 100);
                
            // Ergonomic Rounded Handle
            ergonomic_handle();
            
            // Hinge Knuckles (Clevis joint on outside of the cone at pivot_x, pivot_y)
            // Lower knuckle: z = 41 -> 44
            // Upper knuckle: z = 48 -> 51
            translate([pivot_x, pivot_y, 41.0])
                cylinder(d = 12.0, h = 3.0, $fn = 50);
            translate([pivot_x, pivot_y, 48.0])
                cylinder(d = 12.0, h = 3.0, $fn = 50);
                
            // Spring Housing (horizontal cylinder running along Y on the side of the hinge)
            translate([pivot_x - 12.0, -15.0, 45.0])
                rotate([-90, 0, 0])
                    cylinder(d = spring_pocket_d + 2 * wall_thickness, h = 35.0, $fn = 50);
        }

        // Cutouts
        union() {
            // Spout bore
            translate([0, 0, -1])
                cylinder(d = 35, h = 15 + 1.1, $fn = 100);
                
            // Cone bore
            translate([0, 0, 15 - 0.1])
                cylinder(d1 = 35, d2 = 61, h = 35 + 0.2, $fn = 100);
                
            // Chamber bore
            translate([0, 0, 50 - 0.1])
                cylinder(d = 61, h = 15 + 0.2, $fn = 100);
                
            // Shoulder taper (self-supporting)
            translate([0, 0, 61 - 0.1])
                cylinder(d1 = 61, d2 = 65, h = 2 + 0.2, $fn = 100);
                
            // Flange socket bore
            translate([0, 0, 63 - 0.1])
                cylinder(d = 65, h = 2.2, $fn = 100);
                
            // Hinge Pin Bore (through both knuckles)
            translate([pivot_x, pivot_y, 40.0])
                cylinder(d = pivot_d + clearance * 2, h = 12.0, $fn = 50);
                
            // Wiper Arm Entry Slot (90-degree horizontal cut in the cone wall at z = 44 -> 48)
            // Allows the wiper arm to sweep inside the cone.
            // Spans from y = -22 to y = 22 inside the chamber.
            translate([0, 0, 44.0])
                linear_extrude(height = 4.0)
                    projection()
                        intersection() {
                            cylinder(d = 65, h = 10, center = true);
                            rotate([0, 0, -45])
                                translate([-100, 0, -5])
                                    cube([200, 200, 10]);
                        }
            // Better simpler representation of the slot:
            // A cylinder shell sector cut.
            translate([0, 0, 44.0])
                difference() {
                    cylinder(d = 68.0, h = 4.0, $fn = 100);
                    cylinder(d = 56.0, h = 4.2, $fn = 100);
                    // Mask everything outside -45 to +45 deg
                    rotate([0, 0, 45]) translate([0, -100, -1]) cube([200, 200, 6]);
                    rotate([0, 0, -135]) translate([0, -100, -1]) cube([200, 200, 6]);
                }

            // Spring Pocket Bore
            translate([pivot_x - 12.0, -16.0, 45.0])
                rotate([-90, 0, 0])
                    cylinder(d = spring_pocket_d, h = 32.0, $fn = 50); // closed end at y = 16
        }
    }
}

module ergonomic_handle() {
    color("gray") {
        // Vertical grip cylinder
        translate([-48, 0, 25])
            cylinder(d = 16, h = 24, $fn = 50);
        // Top horizontal bracket
        hull() {
            translate([-48, 0, 44])
                cylinder(d = 16, h = 6, $fn = 50);
            translate([-33, 0, 44])
                cylinder(d = 16, h = 6, $fn = 50);
        }
        // Bottom sloped bracket (45 degrees, self-supporting)
        hull() {
            translate([-19.9, 0, 5])
                cylinder(d = 16, h = 4, $fn = 50);
            translate([-48, 0, 25])
                cylinder(d = 16, h = 4, $fn = 50);
        }
    }
}

module wiper_arm() {
    // Rigid wiper lever arm (printed flat)
    // Local origin [0,0,0] is the pivot point.
    difference() {
        union() {
            // Knuckle (middle pivot block: z = 3.2 -> 6.8)
            translate([0, 0, 3.2])
                cylinder(d = 11.6, h = 3.6, $fn = 50);
                
            // Wiper Arm (reaches inside the funnel, length 58.0mm)
            // It sweeps flat in Z = 3.2 -> 6.8.
            // Directed along the local Y axis (sweeps from -45 to +45)
            // Actually, let's align the arm along local Y so when rotated it sweeps.
            rotate([0, 0, 90])
                translate([-2.5, 0, 3.2])
                    cube([5.0, 58.0, 3.6]);
                    
            // Lever Handle / Spring Bracket (extends outside the hinge)
            // Lever points at 135 degrees relative to wiper arm (which is along Y).
            // So lever is at angle 225 degrees (along -X / -Y).
            rotate([0, 0, 225]) {
                translate([-4.0, 0, 3.2])
                    cube([8.0, 22.0, 3.6]);
                // Spring retainer peg at the end of the lever
                translate([0, 20.0, 3.2])
                    cylinder(d = spring_od - 1.5, h = 6.0, $fn = 20);
            }
        }

        // Pin Hole (fits the 5mm pivot pin)
        translate([0, 0, -1])
            cylinder(d = pivot_d + clearance * 2, h = 10, $fn = 50);
            
        // Wiper Blade slot (runs along the arm, width 1.5mm, depth 2.0mm)
        // Located on the upper face of the arm (z = 4.8 -> 6.8)
        rotate([0, 0, 90])
            translate([-0.75, 10.0, 4.8])
                cube([1.5, 47.0, 2.2]);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade that slides into the wiper arm slot.
    // Local coordinates matching the wiper arm slot.
    // Blade is 1.5mm thick, height 4.5mm (so it sticks out 2.5mm above the arm).
    // This allows it to compress against the plunger face.
    rotate([0, 0, 90])
        translate([-0.75, 10.0, 4.8]) {
            // Base slot block
            cube([1.5, 47.0, 4.5]);
            // Tapered wiper tip
            hull() {
                translate([0, 0, 4.5]) cube([1.5, 47.0, 0.1]);
                translate([0.5, 0, 5.5]) cube([0.5, 47.0, 0.1]);
            }
        }
}

module pivot_pin() {
    // Rigid pin to secure the hinge (printed flat for layer strength)
    // Head: d = 10.0, h = 2.0. Shaft: d = 5.0, h = 10.0.
    cylinder(d = 10.0, h = 2.0, $fn = 50);
    translate([0, 0, 2.0])
        cylinder(d = pivot_d - clearance, h = 9.0, $fn = 50);
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
