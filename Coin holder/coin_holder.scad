/* CONSTRUCTIVE PARAMETERS */
 
// Note: All dimensions are in mm.

VM = 2; // Vertical margin around each coin section
HM = 4; // Horizontal margin for each coin section
H = 2; // The horizontal distance between coins
SE = 1; // Width of the ditches around coin sections

D = 0.6; // The depth to which a coin's surface will sink below the sheet's
         // surface
T = 0.4; // The minimum thickness of the coin's supports
SW = 2; // The width of a coin's supports
HT = 0.1; // Tolerance for the coin holes
CH = 0.4; // Chamfer for the coin holes

R = 8; // Radius for the rounded corners of a sheet
CS = 0.7; // Chamfer for the sheets

CHR = 6; // Radius for the corner hole
CHM = 4; // Margin for the corner hole
CHT = 0.1; // Tolerance for the corner hole

TBH = 8; // Height for the tabs
TBR = 4; // Radius for the rounded corners of the tabs
TTH = 5; // Tab text height
TTD = 1; // Tab text depth
TTM = 3; // Tab text horizontal margin

BH = 4; // Base height
TH = 3; // Top height

XW = 2; // Cross width
XM = 2; // Cross margin vs pylon
XD = 20; // Cross depth
XT = 0.1; // Cross tolerance

GM = 1; // "Glue margin". Adjancent components will be embedded by this
        // amount so that there are no artefacts at the interface. It is
        // also used when cutting holes near the boundary of an object.

/* Enter non-zero dimensions here if you already have a printed holder and
   wish to ensure that any modifications to coin sizes, etc. still produce
   sheets of a compatible size. */
COMPAT_SHEET_SIZE = [0, 0];

FULL_QUALITY = false; // Whether to render in full quality (slow)

PART = "SPLAYED"; // Which component to render (TOP, BASE, 0-9)


$fa = FULL_QUALITY ? 2 : 12;
$fs = FULL_QUALITY ? 0.2 : 2;

use <../lib/dcm_math.scad>;
use <../lib/dcm_utils.scad>;
use <../lib/dcm_shapes.scad>;
include <coin_defs.scad>;
include <sheet_defs.scad>;


/**
 * BUILD FUNCTIONS
 */

function coins_in_row(row) =
  concat_all(row);

function coins_in_sheet(sheet) =
  concat(coins_in_row(sheet[0]), coins_in_row(sheet[1]));

function section_width(section) =
    2*HM + sum([for (c=section) c[0] + 2*HT + H]) - H;

function min_section_height(section) =
    2*VM + max([for (c=section) c[0] + 2*HT]);

function min_row_width(row) =
    sum([for (section=row) section_width(section)]);

function min_row_height(row) =
    max([for (section=row) min_section_height(section)]);

function ideal_sheet_size(sheet) = [
  max(
    min_row_width(sheet[0]) + 2*(CHR + CHM),
    min_row_width(sheet[1])
  ),
  min_row_height(sheet[0]) + min_row_height(sheet[1])
];

function ideal_sheet_depth(sheet) =
    D + T + max([for (c=coins_in_sheet(sheet)) c[1]]);

std_sheet_size = [
    max(max([for (s=SHEETS) ideal_sheet_size(s)[0]]), COMPAT_SHEET_SIZE[0]),
    max(max([for (s=SHEETS) ideal_sheet_size(s)[1]]), COMPAT_SHEET_SIZE[1])
];

module coin_hole(coin, depth) {
    r = (coin[0] / 2) + HT;
    d = D + coin[1];
    tc = CH;
    bc = max(0, min(CH, depth - d - T));
    
    rotate_extrude()
        polygon([
            [0, depth/2 + GM],
            [r + tc, depth/2 + GM],
            [r + tc, depth/2],
            [r, depth/2 - tc],
            [r, depth/2 - d],
            [r - SW, depth/2 - d],
            [r - SW, -depth/2 + bc],
            [r - SW + bc, -depth/2],
            [r - SW + bc, -depth/2 - GM],
            [0, -depth/2 - GM],
        ]);
}

module corner_hole(depth) {
    c = CH;
    r = CHR + CHT;
        
    rotate_extrude()
        polygon([
            [0, depth/2 + GM],
            [r + c, depth/2 + GM],
            [r + c, depth/2],
            [r, depth/2 - c],
            [r, -depth/2 + c],
            [r + c, -depth/2],
            [r + c, -depth/2 - GM],
            [0, -depth/2 - GM],
        ]);
}

module ditch(width, depth) {
    s = SE * sqrt(2) / 2;
    
    translate([0, 0, depth/2])
        rotate([45, 0, 0])
            cube([width, s, s], center=true);
}

module coin_section(section, row_height, depth) {
    w = section_width(section);
    
    sums = cumsum([for (c=section) c[0] + 2*HT]);
    base_x = (section[0][0] - sums[len(section)] - (len(section) - 1)*H)/2;

    for (i = [0 : len(section) - 1]) {
        translate([
            base_x + sums[i] + H*i + (section[i][0] - section[0][0])/2,
            0, 0])
            coin_hole(section[i], depth);
    }

    translate([-w/2, 0, 0]) rotate([0, 0, 90]) ditch(row_height, depth);
    translate([w/2, 0, 0]) rotate([0, 0, 90]) ditch(row_height, depth);
}

module coin_row(width, row_height, depth, row) {
    sums = cumsum([for (section=row) section_width(section)]);
    
    base_x = (section_width(row[0]) - sums[len(row)])/2;
    
    for (i=[0 : len(row) - 1]) {
        translate([
            base_x + sums[i] +
                (section_width(row[i]) - section_width(row[0]))/2,
            0, 0])
            coin_section(row[i], row_height, depth);
    }
}

module tab(title, width, depth, tab_pos) {
    tab_w = TTH * len(title) + 2 * TTM;
    
    x = width/2 - R - tab_w/2;
    
    translate([-x + x*2*tab_pos, 0, 0])
        difference() {
            side_rounded_chamfered_ppd([tab_w, TBH*2, depth], TBR, CS);
            ditch(tab_w, depth);
        
            translate([0, -TBH/2, depth/2 - TTD])
                linear_extrude(TTD + GM)
                    text(
                        text=title, size=TTH,
                        valign="center", halign="center"
                    );
       }
}

module sheet(s) {
    w = std_sheet_size[0];
    h = std_sheet_size[1];
    d = ideal_sheet_depth(s);
    
    row1 = s[0];
    row2 = s[1];
    
    dh = (h - min_row_height(row1) - min_row_height(row2))/2;
    h0 = min_row_height(row1) + dh;
    h1 = min_row_height(row2) + dh;
    
    difference() {
        union() {
            side_rounded_chamfered_ppd([w, h, d], R, CS);
            
            translate([0, -h/2, 0]) tab(s[2], w, d, s[3]);
        }
        
        translate([CHR + CHM, h1/2, 0])
            coin_row(w - 2*(CHR + CHM), h0, d, row1);
        
        translate([0, (h1-h0)/2, 0]) ditch(w, d);

        translate([0, -h0/2, 0])
            coin_row(w, h1, d, row2);
       
        translate([
            -w/2 + CHR + CHM,
            h/2 - CHR - CHM,
            0])
            corner_hole(d);
    }
}

pylon_height = sum([for (s=SHEETS) ideal_sheet_depth(s)]);

module pylon() {
    c = CH;
    
    xw = XW + 2*XT;
    xr = 2 * (CHR - XM + XT);
    
    difference() {
        rotate_extrude()
            polygon([
                [0, pylon_height],
                [CHR, pylon_height],
                [CHR, c],
                [CHR + c + GM, -GM],
                [0, -GM],
            ]);
        
        translate([-xw/2, -xr/2, pylon_height-XD])
            cube([xw, xr, XD + GM]);
        translate([-xr/2, -xw/2, pylon_height-XD])
            cube([xr, xw, XD + GM]);
    }
}

module pylon_cross() {
    xw = XW;
    xr = 2 * (CHR - XM);
    
    translate([-xw/2, -xr/2, -GM])
        cube([xw, xr, XD + GM]);
    translate([-xr/2, -xw/2, -GM])
        cube([xr, xw, XD + GM]);
}

module base() {
    w = std_sheet_size[0];
    h = std_sheet_size[1];
    d = BH;
    
    translate([0, 0, d/2])
        side_rounded_chamfered_ppd([w, h, d], R, CS);
    
    translate([
        -w/2 + CHR + CHM,
        h/2 - CHR - CHM,
        d])
        pylon();
}

module top() {
    w = std_sheet_size[0];
    h = std_sheet_size[1];
    d = TH;
    
    translate([0, 0, d/2])
        side_rounded_chamfered_ppd([w, h, d], R, CS);
    
    translate([
        -w/2 + CHR + CHM,
        -h/2 + CHR + CHM,
        d])
        pylon_cross();
}

module do_render() {
    if (PART == "SPLAYED") {
        translate([-160, 90, 0]) sheet(SHEETS[0]);
        translate([-160, 0, 0]) sheet(SHEETS[1]);
        translate([-160, -90, 0]) sheet(SHEETS[2]);
        translate([-160, -180, 0]) base();
        translate([0, 90, 0]) sheet(SHEETS[3]);
        translate([0, 0, 0]) sheet(SHEETS[4]);
        translate([0, -90, 0]) sheet(SHEETS[5]);
        translate([0, -180, 0]) sheet(SHEETS[6]);
        translate([160, 90, 0]) sheet(SHEETS[7]);
        translate([160, 0, 0]) sheet(SHEETS[8]);
        translate([160, -90, 0]) sheet(SHEETS[9]);
        translate([160, -180, 0]) top();
    } else if (PART == "BASE") {
        base();
    } else if (PART == "TOP") {
        top();
    } else {
        translate([0, 0, ideal_sheet_depth(SHEETS[PART]/2)])
            sheet(SHEETS[PART]);
    }
}

if (
    (COMPAT_SHEET_SIZE != [0,0]) && (
        (std_sheet_size[0] > COMPAT_SHEET_SIZE[0]) ||
        (std_sheet_size[1] > COMPAT_SHEET_SIZE[1])
    )
) {
    echo("ERROR: sheet size exceeds compatibility sheet dimensions");
    echo("Sheet size:", std_sheet_size);
    echo("Compat size:", COMPAT_SHEET_SIZE);
} else {
    do_render();
}
