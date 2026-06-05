// OpenSCAD Model for Aeropress Desk Cleaning System
// Designed for support-free printing.
// This is a 2-Part System:
// 1. Funnel Part (Rigid): A simple waste director with handle.
// 2. Scraper Part (Flexible): A handheld dual-purpose tool (plunger squeegee cup + metal filter squeegee clamp).

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
// Wall thickness for the flexible cup (mm)
flex_wall = 2.0;

// --- ANIMATION CONTROLS ($t based) ---
// Animation mode: 0 = all (loops both), 1 = plunger (plunger only), 2 = filter (filter only)
anim_mode = 0; // [0, 1, 2]
// Set to true in OpenSCAD to preview motion locally
animate = false;

// Default override parameter for command-line rendering
time_t = undef;
// Compute final time variable (prioritize command line override, fallback to built-in $t)
t_val = (time_t != undef) ? time_t : $t;

// --- ANIMATION PATH MATH ---
// Set up visibility based on mode
plunger_visible = (anim_mode == 0 && t_val < 0.5) || (anim_mode == 1);
filter_visible = (anim_mode == 0 && t_val >= 0.5) || (anim_mode == 2);

// Plunger Position (static above funnel)
plunger_pos = [0, 0, 75];

// Filter Position (slides along Y through the scraper jaws in filter mode)
filter_pos = 
    (anim_mode == 2) ? (
        (t_val < 0.2) ? [0, -15, 45] :
        (t_val < 0.7) ? [0, -15 + ((t_val - 0.2)/0.5) * 40, 45] :
        [0, 25 - ((t_val - 0.7)/0.3) * 40, 45]
    ) : [0, 0, 45]; // default static

// Scraper Tool Position & Rotation during animation
// Note: plunger cup center is at local y = -56.6. filter jaw center is at local y = 35.0.
scraper_pos = 
    (anim_mode == 1) ? (
        // Plunger mode: align cup (y = -56.6) with plunger (y = 0)
        (t_val < 0.2) ? [0, 56.6 - 60 + (t_val/0.2)*60, 73] : // approach plunger
        (t_val < 0.7) ? [0, 56.6, 73] : // press and wipe
        [0, 56.6 - 60 * ((t_val-0.7)/0.3), 73] // retract
    ) :
    (anim_mode == 2) ? (
        // Filter mode: tool is rotated 180 around Z, so local y = 35 becomes y = -35.
        // Align folded jaw (y = -35) with filter (y = 0)
        (t_val < 0.2) ? [0, 35 - 50 + (t_val/0.2)*50, 45] : // approach filter
        [0, 35, 45] // stay clamped while filter slides
    ) :
    // Fallback "all" mode (loops both phases)
    (t_val < 0.1) ? [0, 56.6 - 60 + (t_val/0.1)*60, 73] :
    (t_val < 0.3) ? [0, 56.6, 73] :
    (t_val < 0.4) ? [0, 56.6 - 60 * ((t_val-0.3)/0.1)*60, 73] :
    (t_val < 0.5) ? [0, 0, 73] :
    (t_val < 0.6) ? [0, 35 - 50 + ((t_val-0.5)/0.1)*50, 45] :
    (t_val < 0.8) ? [0, 35, 45] :
    [0, 35 - 50, 45];

scraper_rot = 
    (anim_mode == 1) ? [0, 0, 0] :
    (anim_mode == 2) ? [0, 0, 180] : // rotate 180 around Z to swap ends
    (t_val < 0.5) ? [0, 0, 0] : [0, 0, 180];

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
            
        // 2. Plunger Squeegee Cup (attached at y = -25, centered at y = -56.6)
        translate([0, -25 - (plunger_di/2 + flex_wall), 0])
            plunger_scraper_cup();
            
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
            
        // 2. Plunger Squeegee Cup
        translate([0, -25 - (plunger_di/2 + flex_wall), 0])
            plunger_scraper_cup();
                
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

module plunger_scraper_cup() {
    // Shallow flexible cup that scrapes both the circular dome face and outer edge of plunger seal
    difference() {
        // Outer cylinder of cup (flat bottom prints cleanly on bed)
        cylinder(d = plunger_di + 2 * flex_wall, h = 8.0, $fn = 100);
        
        // Inner cavity (fits snugly over plunger seal to scrape sides)
        translate([0, 0, 2.0])
            cylinder(d = plunger_di + 0.4, h = 7.0, $fn = 100);
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
