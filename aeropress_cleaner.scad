// OpenSCAD Model for Aeropress Desk Cleaning Ring (ADCR)
// Simplified 2-Part Mechanical System (No Funnel):
// 1. Ring Body (Rigid): Fits over plunger, holds pivot knuckles and spring pocket.
// 2. Wiper Arm (Rigid): Pivoted lever with flexible TPU blade.
// 3. Wiper Blade (Flexible): Slides into wiper arm.
// 4. Pivot Pin (Rigid): Secures wiper arm to ring.

// --- PART SELECTOR ---
part = "all"; // [all: Visual Assembly, ring: Ring Body (Rigid), wiper: Wiper Arm (Rigid), blade: Wiper Blade (Flexible), pin: Pivot Pin (Rigid)]

// --- CUSTOMIZABLE PARAMETERS ---
plunger_di = 57.2;
plunger_dome_h = 3.5;

// --- ADVANCED PARAMETERS ---
wall_thickness = 3.0; // thicker walls for robust ring
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
wiper_angle = 
    (t_val < 0.2) ? -45 :
    (t_val < 0.5) ? -45 + ((t_val - 0.2) / 0.3) * 90 :
    (t_val < 0.8) ? 45 - ((t_val - 0.5) / 0.3) * 90 :
    -45;

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
    translate([pivot_x, pivot_y, -2.0]) {
        rotate([0, 0, wiper_angle]) {
            color("green") wiper_arm();
            color("blue") wiper_blade();
        }
    }
    
    // 3. Pivot Pin (Rigid)
    color("gray")
        translate([pivot_x, pivot_y, -7.0])
            pivot_pin();
            
    // 4. Mock Plunger (Animated)
    if (animate || t_val > 0) {
        translate([0, 0, plunger_z])
            mock_plunger();
            
        // Mock Spring (Animated compression)
        color("silver")
            translate([pivot_x - 12.0, 10.0, -2.0])
                rotate([90, 0, 0])
                    cylinder(d = spring_od, h = 25.0 - (wiper_angle + 45)/90 * 15.0, $fn=20);
    }
}

module ring_body() {
    difference() {
        union() {
            // Main ring cylinder (height 20mm)
            cylinder(d = plunger_di + 2 * wall_thickness, h = 20.0, $fn = 100);
            
            // Knuckles (Double shear)
            // Lower knuckle: z = -8 -> -4
            // Upper knuckle: z = 0 -> 4
            translate([pivot_x, pivot_y, -8.0])
                cylinder(d = 12.0, h = 4.0, $fn = 50);
            translate([pivot_x, pivot_y, 0.0])
                cylinder(d = 12.0, h = 4.0, $fn = 50);
                
            // Spring Housing (horizontal cylinder running along Y on the side)
            translate([pivot_x - 12.0, -15.0, -2.0])
                rotate([-90, 0, 0])
                    cylinder(d = spring_pocket_d + 2 * wall_thickness, h = 30.0, $fn = 50);
                    
            // Small handle tab for grip
            translate([plunger_di/2 + wall_thickness - 2.0, -10.0, 0.0])
                cube([8.0, 20.0, 20.0]);
        }

        // Cutouts
        union() {
            // Plunger bore (fits plunger seal, ID 57.5)
            translate([0, 0, -1])
                cylinder(d = plunger_di + 0.3, h = 15.0 + 1.1, $fn = 100);
                
            // Stop Ledge (internal flange, ID 53.0, z = 15 -> 17)
            // Has 45-degree chamfers on both sides for printability and smooth fit
            translate([0, 0, 14.9])
                cylinder(d1 = plunger_di + 0.3, d2 = 53.0, h = 2.1, $fn = 100);
            translate([0, 0, 17.0])
                cylinder(d = 53.0, h = 4.1, $fn = 100);
                
            // Hinge Pin Bore
            translate([pivot_x, pivot_y, -9.0])
                cylinder(d = pivot_d + clearance * 2, h = 15.0, $fn = 50);
                
            // Spring Pocket Bore
            translate([pivot_x - 12.0, -16.0, -2.0])
                rotate([-90, 0, 0])
                    cylinder(d = spring_pocket_d, h = 28.0, $fn = 50);
        }
    }
}

module wiper_arm() {
    // Rigid wiper lever arm (printed flat)
    // Local origin [0,0,0] is the pivot point.
    difference() {
        union() {
            // Knuckle (middle pivot block: z = 0.2 -> 3.8)
            translate([0, 0, 0.2])
                cylinder(d = 11.6, h = 3.6, $fn = 50);
                
            // Wiper Arm (reaches inside the ring bottom, length 58.0mm)
            rotate([0, 0, 90])
                translate([-2.5, 0, 0.2])
                    cube([5.0, 58.0, 3.6]);
                    
            // Lever Handle / Spring Bracket
            rotate([0, 0, 225]) {
                translate([-4.0, 0, 0.2])
                    cube([8.0, 22.0, 3.6]);
                // Spring retainer peg
                translate([0, 20.0, 0.2])
                    cylinder(d = spring_od - 1.5, h = 6.0, $fn = 20);
            }
        }

        // Pin Hole
        translate([0, 0, -1])
            cylinder(d = pivot_d + clearance * 2, h = 6, $fn = 50);
            
        // Wiper Blade slot (width 1.5mm, depth 2.0mm, z = 1.8 -> 3.8)
        rotate([0, 0, 90])
            translate([-0.75, 10.0, 1.8])
                cube([1.5, 47.0, 2.2]);
    }
}

module wiper_blade() {
    // Flexible TPU squeegee blade
    // Fits into the wiper arm slot and extends upwards to scrape the plunger face.
    rotate([0, 0, 90])
        translate([-0.75, 10.0, 1.8]) {
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
    // Rigid pin to secure the hinge
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
