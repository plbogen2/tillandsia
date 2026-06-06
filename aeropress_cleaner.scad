// OpenSCAD Model for Aeropress Plunger Wiper Ring (ADCR)
// Simplified 2-Part Mechanical System with Shroud and Slot:
// 1. Ring Body (Rigid): 30mm tall collar with slot and bracket for spring post.
// 2. Wiper Arm (Rigid): Pivoted lever with spring peg and slot for blade.
// 3. Wiper Blade (Flexible): Curved TPU blade pointing upwards.
// 4. Pivot Pin (Rigid): Secures wiper arm to ring.

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, ring: Ring Body (Rigid), wiper: Wiper Arm (Rigid), blade: Wiper Blade (Flexible), pin: Pivot Pin (Rigid)]

// --- CUSTOMIZABLE PARAMETERS ---
plunger_di = 57.2;
plunger_dome_h = 3.5;

// --- ADVANCED PARAMETERS ---
wall_thickness = 3.0; // thick walls for robust ring
clearance = 0.2;

// Hinge/Pivot geometry
pivot_x = -35.0;
pivot_y = 0.0;
pivot_d = 5.0; // 5mm pivot pin

// Spring peg positions
ring_post_x = -55.0;
ring_post_y = 12.0;
spring_peg_d = 6.0; // fits inside 8mm ID spring

// --- ANIMATION CONTROLS ---
animate = false;
time_t = undef;
t_val = (time_t != undef) ? time_t : $t;

// Wiper Angle Animation:
// t = 0.0 -> 0.2: Wiper parks at -90 degrees (idle)
// t = 0.2 -> 0.5: Wiper sweeps to 0 degrees (compressing spring)
// t = 0.5 -> 0.8: Wiper returns to -90 degrees (spring release)
wiper_angle = 
    (t_val < 0.2) ? -90 :
    (t_val < 0.5) ? -90 + ((t_val - 0.2) / 0.3) * 90 :
    (t_val < 0.8) ? 0 - ((t_val - 0.5) / 0.3) * 90 :
    -90;

// Plunger insertion animation
plunger_z = 
    (t_val < 0.1) ? 60 - (t_val/0.1)*60 :
    (t_val < 0.8) ? 0.0 :
    ((t_val - 0.8)/0.2)*60;

if (part == "all") {
    assembly();
} else if (part == "ring") {
    ring_body();
} else if (part == "wiper") {
    wiper_arm();
} else if (part == "blade") {
    wiper_blade();
} else if (part == "pin") {
    pivot_pin();
}

module assembly() {
    // 1. Ring Body (Rigid)
    ring_body();
    
    // 2. Wiper Arm & Blade (Animated rotation around Z at pivot_x, pivot_y)
    // Wiper arm sits at z = -8.0 -> -4.0 (inside clevis joint)
    translate([pivot_x, pivot_y, -8.0]) {
        rotate([0, 0, wiper_angle]) {
            color("green") wiper_arm();
            color("blue") wiper_blade();
        }
    }
    
    // 3. Pivot Pin (Rigid)
    // Pin head at bottom (z = -14.0)
    color("gray")
        translate([pivot_x, pivot_y, -14.0])
            pivot_pin();
            
    // 4. Mock Plunger (Animated)
    if (animate || t_val > 0) {
        translate([0, 0, plunger_z])
            mock_plunger();
            
        // Mock Spring (Animated compression between Ring Post and Lever Peg)
        // Ring Post is at [-55, 12, -6]
        // Lever Peg is at [pivot_x + 15*cos(wiper_angle+180), pivot_y + 15*sin(wiper_angle+180), -6]
        lever_peg_x = pivot_x + 15 * cos(wiper_angle + 180);
        lever_peg_y = pivot_y + 15 * sin(wiper_angle + 180);
        
        dx = lever_peg_x - ring_post_x;
        dy = lever_peg_y - ring_post_y;
        dist = sqrt(dx*dx + dy*dy);
        angle = atan2(dy, dx);
        
        color("silver")
            translate([ring_post_x, ring_post_y, -6.0])
                rotate([0, 0, angle])
                    rotate([0, 90, 0])
                        cylinder(d = 9.0, h = dist, $fn=20);
    }
}

module ring_body() {
    difference() {
        union() {
            // Main ring cylinder (height 30mm, from z = -15 to +15)
            translate([0, 0, -15.0])
                cylinder(d = plunger_di + 2 * wall_thickness, h = 30.0, $fn = 100);
            
            // Knuckles (Double shear clevis joint)
            // Lower knuckle: z = -12 -> -8
            // Upper knuckle: z = -4 -> 0
            translate([pivot_x, pivot_y, -12.0])
                cylinder(d = 12.0, h = 4.0, $fn = 50);
            translate([pivot_x, pivot_y, -4.0])
                cylinder(d = 12.0, h = 4.0, $fn = 50);
                
            // Bracket for stationary Spring Post (above arm sweep)
            // Z span: z = 0 -> 4
            translate([0, 0, 0.0]) {
                hull() {
                    translate([pivot_x, pivot_y, 0]) cylinder(d = 12.0, h = 4.0, $fn = 50);
                    translate([ring_post_x, ring_post_y, 0]) cylinder(d = 12.0, h = 4.0, $fn = 50);
                }
            }
            
            // Stationary Spring Post extending down from the bracket
            // Z span: z = -8 -> 0
            translate([ring_post_x, ring_post_y, -8.0]) {
                cylinder(d = 12.0, h = 8.0, $fn = 50);
                // Vertical spring peg pointing up (z = -8 -> -2)
                translate([0, 0, 2.0])
                    cylinder(d = spring_peg_d, h = 6.0, $fn = 25);
            }
            
            // Grip Tab
            translate([plunger_di/2 + wall_thickness - 2.0, -10.0, -10.0])
                cube([8.0, 20.0, 20.0]);
        }

        // Cutouts
        union() {
            // Upper Chamber (plunger bore, fits plunger seal, ID 57.5, z = 0 -> 15)
            translate([0, 0, -0.1])
                cylinder(d = plunger_di + 0.3, h = 15.1, $fn = 100);
                
            // Lower Chamber (shroud, ID 57.5, z = -15 -> 0)
            translate([0, 0, -15.1])
                cylinder(d = plunger_di + 0.3, h = 15.2, $fn = 100);
                
            // Stop Ledge (internal flange, ID 53.0, z = 15 -> 17)
            translate([0, 0, 14.9])
                cylinder(d1 = plunger_di + 0.3, d2 = 53.0, h = 2.1, $fn = 100);
            translate([0, 0, 17.0])
                cylinder(d = 53.0, h = 4.1, $fn = 100);
                
            // Hinge Pin Bore (Z span: z = -13 -> 1)
            translate([pivot_x, pivot_y, -13.0])
                cylinder(d = pivot_d + clearance * 2, h = 14.0, $fn = 50);
                
            // Horizontal Slot in ring wall for arm to sweep (Z span: z = -8 -> -4)
            // Sector: -95 to +10 degrees
            translate([0, 0, -8.0]) {
                intersection() {
                    difference() {
                        cylinder(d = plunger_di + 2*wall_thickness + 5.0, h = 4.0, $fn=100);
                        cylinder(d = plunger_di - 2.0, h = 6.0, center=true, $fn=100);
                    }
                    linear_extrude(height = 4.0) {
                        polygon([
                            [0, 0],
                            [50*cos(-95), 50*sin(-95)],
                            [50*cos(-45), 50*sin(-45)],
                            [50*cos(0), 50*sin(0)],
                            [50*cos(10), 50*sin(10)]
                        ]);
                    }
                }
            }
        }
    }
}

module wiper_arm() {
    // Rigid wiper lever arm (printed flat)
    // Local origin [0,0,0] is the pivot point.
    // Z span: z = 0 -> 3.6 (actual z in assembly will be z_assembly + z_local)
    difference() {
        union() {
            // Knuckle (middle pivot block: z = 0.2 -> 3.8)
            translate([0, 0, 0.2])
                cylinder(d = 11.6, h = 3.6, $fn = 50);
                
            // Wiper Arm pointing along +X locally (length 58.0mm)
            translate([0, -2.5, 0.2])
                cube([58.0, 5.0, 3.6]);
                
            // Lever Extension pointing along -X locally (opposite to wiper arm)
            translate([-20.0, -4.0, 0.2])
                cube([20.0, 8.0, 3.6]);
                
            // Lever Spring Peg (vertical peg pointing up, Z = 0.2 -> 6.2)
            translate([-15.0, 0.0, 0.2])
                cylinder(d = spring_peg_d, h = 6.0, $fn = 25);
        }

        // Pin Hole
        translate([0, 0, -1])
            cylinder(d = pivot_d + clearance * 2, h = 6, $fn = 50);
            
        // Wiper Blade slot (width 1.5mm, depth 2.2mm, z = 1.8 -> 4.0)
        translate([10.0, -0.75, 1.8])
            cube([47.0, 1.5, 2.2]);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade
    // Fits into the wiper arm slot and extends upwards to scrape the plunger face.
    // Total height is 8.0mm (2.2mm in slot, 5.8mm sticking out).
    // The top edge should have a convex curve matching the plunger dome,
    // but a flat blade that flexes is also very effective. Let's make it flat for printability.
    translate([10.0, -0.75, 1.8]) {
        // Base slot block (2.2mm fits the slot depth)
        cube([47.0, 1.5, 2.2]);
        // Squeegee flap (5.8mm sticks out, total height 8.0mm)
        translate([0, 0, 2.2])
            cube([47.0, 1.0, 5.8]);
    }
}

module pivot_pin() {
    // Rigid pin to secure the hinge (head thickness 2.0, shaft length 12.0)
    cylinder(d = 10.0, h = 2.0, $fn = 50);
    translate([0, 0, 2.0])
        cylinder(d = pivot_d - clearance, h = 12.0, $fn = 50);
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
