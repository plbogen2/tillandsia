// OpenSCAD Model for Aeropress Desk Cleaning System
// Designed for support-free printing.
// This is a 2-Part System:
// 1. Funnel Part (Rigid): A simple waste director with handle.
// 2. Scraper Part (Flexible): A handheld dual-purpose tool (plunger face scraper + metal filter squeegee clamp).

// --- PART SELECTOR ---
// Select which part to render for printing
part = "all"; // [all: Visual Assembly, funnel: Funnel Body (Rigid), scraper: Scraper Tool Open (Flexible)]

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
// Wall thickness for the rigid funnel body (mm)
wall_thickness = 2.4;

// --- ANIMATION CONTROLS ($t based) ---
// Set to true in OpenSCAD to preview motion locally
animate = false;

// Default override parameter for command-line rendering
time_t = undef;
// Compute final time variable (prioritize command line override, fallback to built-in $t)
t_val = (time_t != undef) ? time_t : $t;

// --- ANIMATION PATH MATH ---
// Plunger phase: t = 0.0 -> 0.5
// Filter phase:  t = 0.5 -> 1.0

// Mock Plunger Position
plunger_visible = (t_val < 0.5);
plunger_pos = [0, 0, 75];

// Mock Filter Position
filter_visible = (t_val >= 0.5);
filter_pos = [0, 0, 45];

// Scraper Tool Position & Rotation during animation
scraper_pos = 
    (t_val < 0.1) ? [-60 + (t_val/0.1)*60, -40, 73] : // approach plunger
    (t_val < 0.3) ? [0, -40 + ((t_val-0.1)/0.2)*10, 73] : // scrape plunger face (sweep)
    (t_val < 0.4) ? [0, -30 - ((t_val-0.3)/0.1)*30, 73] : // retract plunger end
    (t_val < 0.5) ? [0, -60, 73] : // transition pause
    (t_val < 0.6) ? [60 - ((t_val-0.5)/0.1)*60, 10, 45] : // approach filter
    (t_val < 0.8) ? [0, 10 + ((t_val-0.6)/0.2)*25, 45] : // slide filter through jaws
    (t_val < 0.9) ? [0, 35 - ((t_val-0.8)/0.1)*50, 45] : // retract filter end
    [60, -15, 45]; // return to start

scraper_rot = 
    (t_val < 0.5) ? [0, 0, 0] : // Plunger scraper end pointing towards plunger (needs 0 rotation since model is aligned)
    [0, 180, 0]; // Filter scraper end pointing towards filter (flipped 180)

// Run selected part
if (part == "all") {
    assembly();
} else if (part == "funnel") {
    funnel_body();
} else if (part == "scraper") {
    scraper_tool_open();
}

module assembly() {
    // 1. Funnel (Rigid)
    funnel_body();
    
    // 2. Animated Mock Plunger
    if ((animate || t_val > 0) && plunger_visible) {
        translate(plunger_pos)
            mock_plunger();
    }
    
    // 3. Animated Mock Filter
    if ((animate || t_val > 0) && filter_visible) {
        translate(filter_pos)
            mock_filter();
    }
    
    // 4. Animated Scraper Tool (Folded assembly)
    if (animate || t_val > 0) {
        translate(scraper_pos)
            rotate(scraper_rot)
                scraper_tool_folded();
    } else {
        // Default static view: show the folded scraper floating next to the funnel
        translate([50, 0, 40])
            scraper_tool_folded();
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
        }

        // Inner Cutouts (Open clear funnel)
        union() {
            // Spout bore
            translate([0, 0, -1])
                cylinder(d = 35, h = 15 + 1.1, $fn = 100);
                
            // Cone bore
            translate([0, 0, 15 - 0.1])
                cylinder(d1 = 35, d2 = 61, h = 35 + 0.2, $fn = 100);
                
            // Lower Chamber bore
            translate([0, 0, 50 - 0.1])
                cylinder(d = 61, h = 11 + 0.2, $fn = 100);
                
            // Shoulder taper (self-supporting)
            translate([0, 0, 61 - 0.1])
                cylinder(d1 = 61, d2 = 65, h = 2 + 0.2, $fn = 100);
                
            // Flange socket bore
            translate([0, 0, 63 - 0.1])
                cylinder(d = 65, h = 2.2, $fn = 100);
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

// --- FLEXIBLE DUAL-PURPOSE SCRAPER TOOL ---

module scraper_tool_open() {
    // Renders the tool flat and open for 3D printing (requires zero support)
    color("green") {
        // 1. Central Handle
        translate([-7.5, -25, 0])
            cube([15, 50, 4]);
            
        // 2. Plunger Scraper End (attached at y = -25, sweeps downwards)
        translate([0, -25, 0])
            rotate([0, 0, 180])
                plunger_scraper_end();
                
        // 3. Filter Scraper End (attached at y = 25, printed open for living hinge)
        translate([0, 25, 0])
            filter_scraper_end_open();
    }
}

module scraper_tool_folded() {
    // Renders the tool in its folded assembly state for visualization
    color("green") {
        // 1. Central Handle
        translate([-7.5, -25, 0])
            cube([15, 50, 4]);
            
        // 2. Plunger Scraper End
        translate([0, -25, 0])
            rotate([0, 0, 180])
                plunger_scraper_end();
                
        // 3. Lower Jaw
        translate([0, 25, 0])
            difference() {
                translate([-37, 0, 0])
                    cube([74, 20, 3]);
                // Snap holes
                translate([-34.0, 10.0, -0.5]) cylinder(d = 4.0, h = 4.0, $fn=30);
                translate([ 34.0, 10.0, -0.5]) cylinder(d = 4.0, h = 4.0, $fn=30);
            }
        // Lower Scraper Lip
        translate([0, 25, 0])
            hull() {
                translate([-31.5, 9.0, 3]) cube([63, 2.0, 0.1]);
                translate([-31.5, 9.5, 4.5]) cube([63, 1.0, 0.1]);
            }
        
        // 4. Folded Hinge Loop Representation
        translate([-20, 45, 0])
            cube([40, 1, 6]);
            
        // 5. Upper Jaw (Folded over in Z, thickness is z=3.0 -> 6.0)
        translate([0, 25, 3.0]) {
            translate([-37, 0, 0])
                cube([74, 20, 3]);
            // Upper Scraper Lip (pointing downwards now!)
            hull() {
                translate([-31.5, 9.0, 0]) cube([63, 2.0, 0.1]);
                translate([-31.5, 9.5, -1.5]) cube([63, 1.0, 0.1]);
            }
        }
    }
}

module plunger_scraper_end() {
    difference() {
        // Base block
        translate([-31, 0, 0])
            cube([62, 15, 4]);
        
        // Subtract plunger seal curve (diameter 57.2, dome height 3.5)
        r_val = plunger_di / 2;
        h_dome = plunger_dome_h;
        R_cyl = (r_val*r_val + h_dome*h_dome) / (2 * h_dome);
        translate([0, 15 + R_cyl - h_dome, -1])
            cylinder(r = R_cyl, h = 6, $fn=100);
    }
}

module filter_scraper_end_open() {
    // 1. Lower Jaw
    difference() {
        translate([-37, 0, 0])
            cube([74, 20, 3]);
        // Snap holes
        translate([-34.0, 10.0, -0.5]) cylinder(d = 4.0, h = 4.0, $fn=30);
        translate([ 34.0, 10.0, -0.5]) cylinder(d = 4.0, h = 4.0, $fn=30);
    }
    // Lower Scraper Lip (angled upwards)
    hull() {
        translate([-31.5, 9.0, 3]) cube([63, 2.0, 0.1]);
        translate([-31.5, 9.5, 4.5]) cube([63, 1.0, 0.1]);
    }
    
    // 2. Living Hinge (thin 1mm flex strip)
    translate([-20, 20, 0])
        cube([40, 6, 1.0]);
        
    // 3. Upper Jaw
    translate([-37, 26, 0])
        cube([74, 20, 3]);
    // Upper Scraper Lip
    hull() {
        translate([-31.5, 35.0, 3]) cube([63, 2.0, 0.1]);
        translate([-31.5, 35.5, 4.5]) cube([63, 1.0, 0.1]);
    }
    // Snap pegs (press-fit into holes)
    translate([-34.0, 36.0, 3]) cylinder(d = 3.8, h = 4.5, $fn=30);
    translate([ 34.0, 36.0, 3]) cylinder(d = 3.8, h = 4.5, $fn=30);
}

// --- MOCK MODELS FOR ANIMATION PREVIEW ---

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
        translate([0, 0, 50.0])
            cylinder(d = plunger_di - 8.0, h = 20.0, $fn=50);
        translate([0, 0, 70.0])
            cylinder(d = plunger_di + 4.0, h = 4.0, $fn=50);
    }
}

module mock_filter() {
    color([0.7, 0.7, 0.7, 0.9]) {
        cylinder(d = filter_di, h = filter_thickness, center = true, $fn=100);
    }
}
