// =================================================================
// UNIFIED FANTASY FOOTBALL TROPHY & MODULAR SYSTEM
// Creator: Tim Riley - (c)2026
//
// Viewer / Editor: https://ochafik.com/openscad2/
//
// Units: Millimeters (1 inch = 25.4 mm)
//
// =================================================================

// =================================================================
// --- GLOBAL SYSTEM PARAMETERS ---
// Resolution setting for smooth curves
$fn = 100;
ROD_DIAMETER  = 16;       // Central threaded rod clearance diameter

// =================================================================
// Chalice Parameters
wall          = 3;        // shell thickness of the bowl, mm
foot_r        = 49.2;     // radius of the foot (3.875" dia / 2)
foot_lip_r    = 51;       // slight outward flare of the foot's edge
stem_r        = 13;       // radius of the narrow waist/stem
bowl_bot_r    = 22;       // radius where the bowl starts widening (at the stem)
bowl_top_r    = 63.5;     // radius of the bowl at the rim (5" dia / 2)
total_height  = 111.125;  // overall height (4.375")
foot_height   = 34.925;   // 1.375"
stem_height   = 15.875;   // 0.625"
bowl_height   = 60.325;   // 2.375"
flute_depth   = 1.4;      // how deep each flute groove cuts
bowl_steps    = 28;       // resolution of the curved bowl profile
z_foot_bottom = 0;
z_foot_top    = foot_height;                 // 34.925
z_stem_bottom = foot_height + 3;             // 37.925
z_stem_waist  = foot_height + stem_height*0.6; // ~44.45
z_bowl_bottom = foot_height + stem_height;   // 50.8
z_rim         = total_height;                // 111.125

// =================================================================
// Pedestal Shell & Alignment Parameters
pedestal_h = 60;   // Height of body
outer_r    = 125;  // Radius spanning footprint (vertex distance)
shell_wall = 12;   // Thicker shell wall thickness for pins & slots


// =================================================================
// Half-business-card dimensions & parameters
// Standard business card = 3.5" x 2.0" (88.9mm x 50.8mm)
// Half card = 1.75" x 2.0" (44.45mm W x 50.8mm H)
card_w      = 44.45;
card_h      = 50.8;
slot_w      = card_w + 1.0;      // Clearance width for sliding in (45.45mm)
card_thick  = 1.2;               // Internal channel thickness
lip_overlap = 1.5;               // Frame lip overlap retaining the card inside
apothem     = outer_r * cos(18); // center-to-face-midpoint distance

// =================================================================
// Centering / Alignment Pin & Socket Parameters
pin_r             = 3;                             // Radius of alignment pins (6mm diameter)
socket_h          = 5;                             // Cylindrical depth of socket hole
pin_clearance_gap = 0.5;                           // Gap between top of pin and bottom of socket
pin_h             = socket_h - pin_clearance_gap;  // 4.5 mm height
pin_dist          = outer_r - (shell_wall / 2);    // Radial distance to place pins
pin_tol           = 0.25;                          // Socket clearance tolerance


// =================================================================
// Top Cap Parameters
// 3.875" Inner Diameter for Chalice Opening
top_opening_r = (3.925 * 25.4) / 2; // ~49.8475 mm inner radius

// 0.25" Chalice support ledge thickness & 0.33" inset depth
land_width    = 0.25 * 25.4;        // 6.35 mm horizontal land width
land_depth    = 0.33 * 25.4;        // 8.382 mm inset depth from top rim
top_cap_h     = 80;                 // Overall height

// =================================================================
// Bottom Cap Parameters
bottom_cap_h  = 80;         // Adjust overall height of the base as preferred
base_r = outer_r + 30; // Flare radius for the expanded circular base (default: 150mm)
interior_angle_deg   = 52;           // Overhang angle relative to horizontal (>50 deg)
bottom_floor_thick   = 6;            // Solid bottom floor thickness (mm)

// =================================================================
// HELPER MODULES (SUPPORTLESS GEOMETRY)
// =================================================================

// Self-Supporting Conical Pin Socket (45-degree angled top cone)
module conical_socket_hole(r, h, tol) {
    eff_r = r + tol;
    union() {
        cylinder(r=eff_r, h=h, $fn=32);
        translate([0, 0, h])
            cylinder(r1=eff_r, r2=0, h=eff_r, $fn=32);
    }
}

// =================================================================
// HOLLOW DECAGONAL PEDESTAL w/ CONICAL SUPPORTLESS SOCKETS
// =================================================================
module decade_pedestal_nesting() {
    difference() {
        union() {
            // 1. Thickened Hollow Decagonal Shell
            difference() {
                cylinder(r=outer_r, h=pedestal_h, $fn=10);
               
                // Hollow Inner Cavity
                translate([0, 0, -1])
                    cylinder(r=outer_r - shell_wall, h=pedestal_h + 2, $fn=10);
            }


            // 2. Centering Pins on TOP Face (10 Pins)
            for (i = [0:9]) {
                rotate([0, 0, i * 36])
                    translate([pin_dist, 0, pedestal_h])
                        cylinder(r=pin_r, h=pin_h, $fn=32);
            }
        }



        // Supportless Conical Pin Sockets on BOTTOM Face (10 Sockets, 5mm depth)
        for (i = [0:9]) {
            rotate([0, 0, i * 36])
                translate([pin_dist, 0, -0.1])
                    conical_socket_hole(pin_r, socket_h, pin_tol);
        }

        // Retaining Card Slots (10 faces, Open-Top)
        for (i = [0:9]) {
            rotate([0, 0, i * 36 + 18]) {
                
                // Internal Card Track
                translate([
                    apothem - 2.0 - card_thick,
                    -slot_w / 2,
                    pedestal_h - card_h - 1
                ])
                    cube([card_thick, slot_w, card_h + 10]);

                // Open-Top Front Window
                translate([
                    apothem - 2.5,
                    -(slot_w - 2 * lip_overlap) / 2,
                    pedestal_h - card_h - 1
                ])
                    cube([5, slot_w - 2 * lip_overlap, card_h + 10]);
            }
        }
    }
}

// =================================================================
// PEDESTAL TOP CAP - FULLY BLIND CONICAL SOCKETS & SUPPORTLESS FUNNEL
// =================================================================
module pedestal_cap() {
    // Outer radius at top including wall thickness
    top_outer_r = top_opening_r + wall;

    difference() {
        // Outer Body: Solid base ring to encapsulate sockets, then funnels up to top rim
        union() {
            // Base ring matching decagonal footprint, tall enough to seal sockets
            cylinder(r=outer_r, h=socket_h + 3, $fn=10);
            
            // Funnel body transitioning to outer rim at top
            hull() {
                cylinder(r=outer_r, h=socket_h + 3, $fn=10);
                
                translate([0, 0, top_cap_h])
                    cylinder(r=top_outer_r, h=0.1, $fn=100);
            }
        }

        // Central Threaded Rod Pass-Through (Bottom Section)
        translate([0, 0, -1])
            cylinder(r=ROD_DIAMETER / 2, h=top_cap_h + 2, $fn=64);

        // 1. Top Opening Bore (3.875" ID down to 0.33" depth)
        translate([0, 0, top_cap_h - land_depth])
            cylinder(r=top_opening_r, h=land_depth + 0.1, $fn=100);

        // 2. Interior Funnel Cutout
        // Funnels from ROD_DIAMETER at base up to the inner edge of the flat land (top_opening_r - 0.25")
        hull() {
            translate([0, 0, socket_h + 3])
                cylinder(r=ROD_DIAMETER / 2, h=0.1, $fn=64);
            
            translate([0, 0, top_cap_h - land_depth])
                cylinder(r=top_opening_r - land_width, h=0.1, $fn=100);
        }

        // 10 Blind Supportless Conical Pin Sockets on Bottom Face
        for (i = [0:9]) {
            rotate([0, 0, i * 36])
                translate([pin_dist, 0, -0.1])
                    conical_socket_hole(pin_r, socket_h, pin_tol);
        }
    }
}

// =================================================================
// PEDESTAL BOTTOM CAP - OUTWARD FLARED FUNNEL BASE
// =================================================================
module pedestal_bottom_cap() {
    // Top cavity lands precisely at central rod clearance radius
    top_cavity_r = ROD_DIAMETER / 2;

    // Calculate maximum bottom opening radius permitted by the >50° angle constraint
    // run = rise / tan(angle)
    max_radial_run = bottom_cap_h / tan(interior_angle_deg);
    bot_cavity_r   = min(base_r - shell_wall, top_cavity_r + max_radial_run);

    difference() {
        union() {
            // 1. Outer Flared Body (Flares out from top decagon to bottom circle)
            hull() {
                translate([0, 0, bottom_cap_h - 0.1])
                    cylinder(r=outer_r, h=0.1, $fn=10);
                
                cylinder(r=base_r, h=0.1, $fn=100);
            }

            // 2. Centering Pins on Top Face
            for (i = [0:9]) {
                rotate([0, 0, i * 36])
                    translate([pin_dist, 0, bottom_cap_h])
                        cylinder(r=pin_r, h=pin_h, $fn=32);
            }
        }

        // Central Threaded Rod Pass-Through (clears top land + pins)
        translate([0, 0, -1])
            cylinder(r=ROD_DIAMETER / 2, h=bottom_cap_h + pin_h + 2, $fn=64);

        // 3. Bottom-Up Interior Funnel (>50° angle relative to horizontal)
        // Wide at bottom (bot_cavity_r), narrowing as it ascends to top_cavity_r
        translate([0, 0, -0.1])
            cylinder(
                r1  = bot_cavity_r, 
                r2  = top_cavity_r, 
                h   = bottom_cap_h + 0.1, 
                $fn = 100
            );
    }
}

// =================================================================
// CHALICE
// =================================================================
function bowl_curve(r0, r1, z0, h, steps) =
    [for (i = [1 : steps])
        let (phi = i / steps * 90)
        [r0 + (r1 - r0) * sin(phi), z0 + h * (1 - cos(phi))]
    ];


module chalice_outer() {
    rotate_extrude(convexity = 10)
    polygon(points = concat(
        [
            [0,            z_foot_bottom],
            [foot_r,       z_foot_bottom],
            [foot_lip_r,   0],
            [foot_r - 4,   z_foot_top],
            [stem_r + 4,   z_stem_bottom],
            [stem_r,       z_stem_waist],
            [bowl_bot_r,   z_bowl_bottom]
        ],
        bowl_curve(bowl_bot_r, bowl_top_r, z_bowl_bottom, bowl_height, bowl_steps),
        [
            [bowl_top_r - wall*0.6, z_rim],
            [0,            z_rim]
        ]
    ));
}


bowl_bot_r_in = max(bowl_bot_r - wall, 6);
bowl_top_r_in = bowl_top_r - wall;
z_cavity_bot  = z_bowl_bottom + 6;


module chalice_cavity() {
    rotate_extrude(convexity = 10)
    polygon(points = concat(
        [
            [0,             z_cavity_bot],
            [bowl_bot_r_in, z_cavity_bot]
        ],
        bowl_curve(bowl_bot_r_in, bowl_top_r_in, z_cavity_bot, z_rim - z_cavity_bot, bowl_steps),
        [
            [bowl_top_r_in + 5, z_rim + 5],
            [0,                 z_rim + 5]
        ]
    ));
}


module rod_clearance_hole() {
    translate([0, 0, -1])
    cylinder(h = z_cavity_bot + 2, r = (ROD_DIAMETER/2), $fn = 64);
}


module chalice() {
    difference() {
        chalice_outer();
        chalice_cavity();
        rod_clearance_hole();
    }
}




// =================================================================
// RENDER & EXPORT PREVIEW
// =================================================================
translate([0, 0, 0])   pedestal_bottom_cap();
translate([0, 0, 90])  decade_pedestal_nesting();
translate([0, 0, 160]) decade_pedestal_nesting();
translate([0, 0, 230]) decade_pedestal_nesting();
translate([0, 0, 300]) pedestal_cap();
translate([0, 0, 390]) chalice();