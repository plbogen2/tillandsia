// OpenSCAD Model for Aeropress Desk Cleaning Funnel (ADCF)
// Designed for support-free printing.

// --- PART SELECTOR ---
// Select which part to render for printing
part = "all"; // [all: Visual Assembly, funnel: Funnel Body (Rigid), plunger_insert: Plunger Squeegee (Flexible), filter_insert: Filter Squeegee Half (Flexible)]

// --- CUSTOMIZABLE PARAMETERS ---
// Outer diameter of the Aeropress plunger rubber seal (mm)
plunger_di = 57.2;
// Depth of the plunger face dome (mm). Use 0 for flat, positive for convex (domed out).
plunger_dome_h = 3.5;
// Diameter of the metal filter disc (mm)
filter_di = 62.0;
// Thickness of the metal filter disc (mm)
filter_thickness = 0.3;

// --- ADVANCED PARAMETERS (TOLERANCES & WALLS) ---
// Clearance between printed parts (mm)
clearance = 0.2;
// Wall thickness for the rigid funnel body (mm)
wall_thickness = 2.4;
// Wall thickness for the flexible inserts (mm)
flex_wall = 2.0;
// Thicker wall for the filter pocket housing to make it robust (mm)
pocket_wall = 3.6;

// --- DERIVED DIMENSIONS ---
plunger_scrape_di = plunger_di - 0.6; // slightly smaller for tight squeegee fit
plunger_insert_od = plunger_scrape_di + 2 * flex_wall;
plunger_flange_od = plunger_insert_od + 4.0;
plunger_insert_h = 15.0;
flange_h = 2.0;

chamber_id = plunger_insert_od + clearance * 2;
flange_id = plunger_flange_od + clearance * 2;
chamber_h = plunger_insert_h - flange_h;

block_w = filter_di + 12.0;
block_d = 12.0;
block_h = 10.0; // thicker block for robustness (was 7.5)
recess_w = filter_di + 1.0;
recess_d = 2.0; // deeper recess (was 1.5)

pocket_w = block_w + clearance * 2;
pocket_d = block_d + clearance * 2;
pocket_h = block_h * 2; // 20.0 mm height

// pocket position
pocket_x_center = (flange_id / 2) + wall_thickness + (pocket_d / 2) - 3.0; // overlap slightly for boolean union

// --- ANIMATION CONTROLS ($t based) ---
// Set to true in OpenSCAD to preview motion locally
animate = false;

// Default override parameter for command-line rendering
time_t = undef;
// Compute final time variable (prioritize command line override, fallback to built-in $t)
t_val = (time_t != undef) ? time_t : $t;

// Calculate plunger movements:
// t = 0.0 -> 0.2: inserts plunger down to chamber (z = 100 to z = 54.5)
// t = 0.2 -> 0.4: twists plunger 180 degrees
// t = 0.4 -> 0.6: pulls plunger back up to z = 100
plunger_z = 
    (t_val < 0.2) ? 100 - (t_val / 0.2) * 45.5 :
    (t_val < 0.4) ? 54.5 :
    (t_val < 0.6) ? 54.5 + ((t_val - 0.4) / 0.2) * 45.5 :
    100;

plunger_rot_z = 
    (t_val >= 0.2 && t_val < 0.4) ? ((t_val - 0.2) / 0.2) * 180 :
    (t_val >= 0.4) ? 180 :
    0;

// Calculate filter movements:
// t = 0.6 -> 0.75: slides filter from outside (x_center + 60) into slot (x_center - 30)
// t = 0.75 -> 0.9: slides filter back out (to x_center + 60)
filter_x = 
    (t_val < 0.6) ? pocket_x_center + 60 :
    (t_val < 0.75) ? (pocket_x_center + 60) - ((t_val - 0.6) / 0.15) * 90 :
    (t_val < 0.9) ? (pocket_x_center - 30) + ((t_val - 0.75) / 0.15) * 90 :
    pocket_x_center + 60;

// Run selected part
if (part == "all") {
    assembly();
} else if (part == "funnel") {
    funnel_body();
} else if (part == "plunger_insert") {
    plunger_insert();
} else if (part == "filter_insert") {
    filter_insert_half();
}

module assembly() {
    funnel_body();
    
    // Plunger insert (semi-transparent green)
    color([0.2, 0.8, 0.2, 0.8])
        translate([0, 0, 50.0])
            plunger_insert();
            
    // Filter insert bottom half (semi-transparent blue)
    color([0.2, 0.2, 0.8, 0.8])
        translate([pocket_x_center, 0, 37.5])
            filter_insert_half();
            
    // Filter insert top half (semi-transparent red)
    color([0.8, 0.2, 0.2, 0.8])
        translate([pocket_x_center, 0, 57.5])
            rotate([180, 0, 0])
                filter_insert_half();

    // Render animated components if animating
    if (animate || t_val > 0) {
        // Mock Plunger
        translate([0, 0, plunger_z])
            rotate([0, 0, plunger_rot_z])
                mock_plunger();
                
        // Mock Metal Filter
        translate([filter_x, 0, 47.5])
            mock_filter();
    }
}

module funnel_body() {
    difference() {
        union() {
            // 1. Spout
            cylinder(d = 35 + 2 * wall_thickness, h = 15, $fn = 100);
            
            // 2. Cone
            translate([0, 0, 15])
                cylinder(d1 = 35 + 2 * wall_thickness, d2 = 61 + 2 * wall_thickness, h = 35, $fn = 100);
                
            // 3. Outer transition to chamber
            translate([0, 0, 50])
                cylinder(d1 = 61 + 2 * wall_thickness, d2 = 65 + 2 * wall_thickness, h = 2, $fn = 100);
                
            // 4. Chamber Outer Cylinder
            translate([0, 0, 52])
                cylinder(d = 65 + 2 * wall_thickness, h = 13, $fn = 100);
                
            // 5. Ergonomic Rounded Handle (Support-free)
            ergonomic_handle();
            
            // 6. Filter Pocket Outer Body (Drawer design, open at +y)
            translate([pocket_x_center, -pocket_wall/2, 37.5 + pocket_h/2])
                cube([pocket_d + 2 * pocket_wall, pocket_w + pocket_wall, pocket_h], center = true);
                
            // 7. Pocket Support Gusset
            pocket_gusset();
        }

        // Inner Cutouts
        union() {
            // Spout bore
            translate([0, 0, -1])
                cylinder(d = 35, h = 15 + 1.1, $fn = 100);
                
            // Cone bore
            translate([0, 0, 15 - 0.1])
                cylinder(d1 = 35, d2 = 61, h = 35 + 0.2, $fn = 100);
                
            // Lower Chamber bore (fits insert body)
            translate([0, 0, 50 - 0.1])
                cylinder(d = 61, h = 11 + 0.2, $fn = 100);
                
            // Shoulder taper (self-supporting)
            translate([0, 0, 61 - 0.1])
                cylinder(d1 = 61, d2 = 65, h = 2 + 0.2, $fn = 100);
                
            // Flange socket bore (fits insert flange)
            translate([0, 0, 63 - 0.1])
                cylinder(d = 65, h = 2.2, $fn = 100);
                
            // Keyways at the rim (aligned to Y axis to avoid weakening pocket/handle mounts)
            translate([0, 0, 64])
                cube([4.4, 72.0, 2.5], center = true);
                
            // Pocket Cavity (Drawer slot open at +y)
            translate([pocket_x_center, 2.0, 37.5 + pocket_h/2])
                cube([pocket_d, pocket_w + 4.0, pocket_h + 0.1], center = true);
                
            // Filter Inner Slot (passes into funnel)
            translate([pocket_x_center - pocket_d/2 - 2.0, 0, 47.5])
                cube([pocket_d + 4.0, recess_w, 3.0], center = true);
                
            // Filter Outer Slot (entry from outside)
            translate([pocket_x_center + pocket_d/2, 0, 47.5])
                cube([pocket_wall * 3, filter_di + 2.0, 5.0], center = true);
                
            // Support slot on opposite wall (prevents filter bending)
            translate([-31.0, 0, 47.5])
                cube([3.0, recess_w, 3.0], center = true);
        }
    }
}

module ergonomic_handle() {
    // Rounded comfortable handle loop (support-free)
    color("gray") {
        // 1. Vertical grip cylinder
        translate([-48, 0, 34])
            cylinder(d = 16, h = 24, $fn = 50);
            
        // 2. Top horizontal bracket
        hull() {
            translate([-48, 0, 53])
                cylinder(d = 16, h = 6, $fn = 50);
            translate([-33, 0, 53])
                cylinder(d = 16, h = 6, $fn = 50);
        }
        
        // 3. Bottom sloped bracket (45 degrees, self-supporting)
        hull() {
            translate([-19.9, 0, 5])
                cylinder(d = 16, h = 4, $fn = 50);
            translate([-48, 0, 34])
                cylinder(d = 16, h = 4, $fn = 50);
        }
    }
}

module pocket_gusset() {
    // Solid sloped support under the pocket (support-free)
    polyhedron(
        points = [
            [pocket_x_center - pocket_d/2 - pocket_wall, -pocket_w/2 - pocket_wall, 22.0], // 0
            [pocket_x_center + pocket_d/2 + pocket_wall, -pocket_w/2 - pocket_wall, 37.5], // 1
            [pocket_x_center - pocket_d/2 - pocket_wall, -pocket_w/2 - pocket_wall, 37.5], // 2
            [pocket_x_center - pocket_d/2 - pocket_wall,  pocket_w/2, 22.0], // 3
            [pocket_x_center + pocket_d/2 + pocket_wall,  pocket_w/2, 37.5], // 4
            [pocket_x_center - pocket_d/2 - pocket_wall,  pocket_w/2, 37.5]  // 5
        ],
        faces = [
            [0, 2, 1],       // Side 1
            [3, 4, 5],       // Side 2
            [0, 1, 4, 3],    // Sloped face
            [1, 2, 5, 4],    // Top face
            [0, 3, 5, 2]     // Back face
        ]
    );
}

module plunger_insert() {
    // 1. Ring Body
    difference() {
        union() {
            cylinder(d = plunger_insert_od, h = plunger_insert_h, $fn = 100);
            translate([0, 0, plunger_insert_h - flange_h])
                cylinder(d = plunger_flange_od, h = flange_h, $fn = 100);
            translate([0, 0, plunger_insert_h - flange_h/2])
                cube([4.0, plunger_flange_od + 3.8, flange_h], center = true); // key aligned to Y
        }
        translate([0, 0, -1])
            cylinder(d = plunger_scrape_di, h = plunger_insert_h + 2, $fn = 100);
            
        // Top guide chamfer
        translate([0, 0, plunger_insert_h - 2.0])
            cylinder(d1 = plunger_scrape_di, d2 = plunger_scrape_di + 2.0, h = 2.1, $fn = 100);
    }
    
    // 2. Scraper Blade
    difference() {
        translate([-plunger_scrape_di/2, -1.5, 0])
            cube([plunger_scrape_di, 3.0, 8.0]);
            
        if (plunger_dome_h > 0) {
            r_scrape = plunger_scrape_di / 2;
            R_cyl = (r_scrape * r_scrape + plunger_dome_h * plunger_dome_h) / (2 * plunger_dome_h);
            translate([0, 0, 8.0 + R_cyl - plunger_dome_h])
                rotate([0, 90, 0])
                    cylinder(r = R_cyl, h = r_scrape * 3, center = true, $fn = 100);
        }
    }
}

module filter_insert_half() {
    difference() {
        // Body block
        translate([-block_w/2, 0, 0])
            cube([block_w, block_d, block_h]);
            
        // Filter channel recess
        translate([-recess_w/2, -1, block_h - recess_d])
            cube([recess_w, block_d + 2, recess_d + 0.1]);
    }
    
    // Scraper Lip (thickened and robust)
    hull() {
        translate([-recess_w/2, 2.0, block_h - recess_d])
            cube([recess_w, 2.2, 0.1]);
        translate([-recess_w/2, 3.5, block_h + 0.1])
            cube([recess_w, 1.0, 0.1]);
    }
}

module mock_plunger() {
    // Semi-transparent grey plunger
    color([0.4, 0.4, 0.4, 0.6]) {
        // Main body (hollow cylinder look)
        difference() {
            cylinder(d = plunger_di, h = 50.0, $fn=100);
            translate([0, 0, -1])
                cylinder(d = plunger_di - 4.0, h = 48.0, $fn=100);
        }
        // Plunger face dome (approximated by sphere segment or flat base)
        if (plunger_dome_h > 0) {
            r_val = plunger_di / 2;
            R_sph = (r_val * r_val + plunger_dome_h * plunger_dome_h) / (2 * plunger_dome_h);
            difference() {
                translate([0, 0, plunger_dome_h - R_sph])
                    sphere(r = R_sph, $fn=100);
                translate([0, 0, -R_sph])
                    cube([R_sph*2 + 10, R_sph*2 + 10, R_sph*2], center=true);
            }
        } else {
            cylinder(d = plunger_di, h = 2.0, $fn=100);
        }
        // Top lip/handle connector
        translate([0, 0, 50.0])
            cylinder(d = plunger_di - 8.0, h = 20.0, $fn=50);
        translate([0, 0, 70.0])
            cylinder(d = plunger_di + 4.0, h = 4.0, $fn=50);
    }
}

module mock_filter() {
    // Metal disc representation
    color([0.7, 0.7, 0.7, 0.9]) {
        cylinder(d = filter_di, h = filter_thickness, center = true, $fn=100);
    }
}
