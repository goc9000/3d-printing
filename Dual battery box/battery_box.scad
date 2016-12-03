/**
 * CONSTRUCTIVE PARAMETERS
 */
 
// Note: All dimensions are in mm.

NR1 = 2; // The number of rows and columns of batteries of the first and
NC1 = 4; // second kind respectively.
NR2 = 2;
NC2 = 4;

D1 = 14.5; // The diameters for the two kinds of batteries.
D2 = 10.5;

H1 = 50.5; // The heights for the two kinds of batteries. The height
H2 = 44.5; // includes the nub for the positive terminal.

HS = 1; // The horizontal spacing around a battery. This is the minimum
        // distance, in the horizontal plane, from the edge of a battery
        // to any other matter (box or battery). I'm being generous here,
        // as some batteries that age out while in storage tend to swell
        // or secrete random chemical goo. Ideally one should take out the
        // battery before that happens, but in case it does, one should at
        // least be confident that the battery will not get stuck in its
        // slot or damage the container.
VS = HS; // The vertical spacing for the battery. This is the distance
         // from the top and bottom edges of the battery, to the top and
         // bottom edges, respectively, of the cylindrical cavity in which
         // it is stored.

W1 = -1; // The width of the internal walls separating batteries of the same
W2 = 1;  // kind. If this is non-zero, two adjacent batteries will be
         // separated by a space of size HS, then an internal wall of
         // width at least Wx, then another space of size HS. Note that
         // this can be less than zero, in which case a battery may not be
         // fully surrounded by an internal wall -  the walls will be
         // reduced to a set of pillars that just "guide" the batteries
         // into the grid. The minimum value for this is -HS, which will
         // cause the batteries to be as close as physically possible
         // given the restriction defined by HS.

Wmin = 0.7; // The minimum printable width for the interior walls. Portions
            // of the interior walls that would be thinner than this are
            // automatically cut away.

CS = 2; // The width of the separating wall between the sections of
        // different kinds of batteries.

HX = 1.5; // The thickness of the external side wall. This wraps around the
          // core and represents the distance between the battery space and
          // the outside of the box at its thinnest point (i.e. where the
          // lid goes). Below that, the side wall is thicker so as to
          // include the thickness of the lid.
VX = 1.5; // The thickness of the top and bottom external walls of the box.

L = 1; // The thickness of the lid's side wall.
LH = 25; // The height of the lid.

LP = 10; // The height of the lip (the thin portion of the bottom where
         // the lid fits in

LT = 0.1; // The mating tolerance for the lid. The lid's hole will be made
          // larger than the lip by this amount.

BR = min(D1/2, D2/2) + HS + HX; // The radius for the box's rounded sides

IC = 1; // Internal chamfer (for the battery slots)
EC = 2; // External chamfer (for the box)


PART = "BOTH"; // Which part ("BODY", "LID", "BOTH")

FULL_QUALITY = false; // Whether to render in full quality (slow)


$fa = FULL_QUALITY ? 2 : 12;
$fs = FULL_QUALITY ? 0.2 : 2;

use <../lib/dcm_shapes.scad>;


/**
 * BUILD FUNCTIONS
 */

/* For a given battery type, the "subcore" is the parallelipiped
   that bounds all the cavities containing batteries of that
   particular type, without the external side and top/bottom
   walls. We call this the "ideal" size because in the finished
   product, the subcores may be padded so that their sizes are
   compatible such that they can be juxtaposed to form the box's
   core. */
function ideal_subcore_size(NR, NC, D, H, W) = [
    NC * (D + 2 * HS) + (NC - 1) * W,
    NR * (D + 2 * HS) + (NR - 1) * W,
    H + 2 * VS
];

subcore_sizes_1 = ideal_subcore_size(NR1,NC1,D1,H1,W1);
subcore_sizes_2 = ideal_subcore_size(NR2,NC2,D2,H2,W2);

/* The box's core is the paralellipiped that contains the subcores
   for both battery types. Again, this does not include any
   external walls. */

core_width = max(subcore_sizes_1[0], subcore_sizes_2[0]);
core_depth = subcore_sizes_1[1] + CS + subcore_sizes_2[1];
core_height = max(subcore_sizes_1[2], subcore_sizes_2[2]);

/* This produces the battery-containing cavities within a
   subcore. The ensemble will be horizontally centered at (0,0),
   but dug vertically beneath z=0. */
module subcore_cavities(NR, NC, D, H, W) {
    s = D + 2*HS + W;
    for (row=[0:NR-1], col=[0:NC-1])
        translate([
          s*(col - (NC - 1) / 2),
          s*(row - (NR - 1) / 2),
          -(H + 2*VS)
        ])
            chamfered_cylinder(D/2 + HS, H + 2*VS, IC);
    
    // Now add "wallbusters" that ensure interior walls thinner
    // than Wmin are removed
    
    delta_w = Wmin - W;
    if (delta_w > 0) {
        h = sqrt(delta_w * (4*(D/2 + HS) - delta_w));
        
        for (row=[0:NR-1])
            translate([
              0,
              s*(row - (NR - 1) / 2),
              -H/2 - VS
            ])
              chamfered_ppd([s*(NC - 1), h, H + 2*VS], IC);
        
        for (col=[0:NC-1])
            translate([
              s*(col - (NC - 1) / 2),
              0,
              -H/2 - VS
            ])
              chamfered_ppd([h, s*(NR - 1), H + 2*VS], IC);
    }
}

/* Produces cavities for the box core, assuming it is centered
   at (0,0,0) */
module core_cavities() {
    translate([
        0,
        (-core_depth + subcore_sizes_1[1]) / 2,
        core_height / 2
    ])
        subcore_cavities(NR1,NC1,D1,H1,W1);
    
    translate([
        0,
        (core_depth - subcore_sizes_2[1]) / 2,
        core_height / 2
    ])
        subcore_cavities(NR2,NC2,D2,H2,W2);
}

box_width = core_width + 2*(HX + L);
box_depth = core_depth + 2*(HX + L);
box_height = core_height + 2*VX;

/* Produces the complete box, with the lid part completely fused to
   the bottom part (they are separated later), centered at (0,0,0) */
module fused_box() {
    difference() {
        side_rounded_chamfered_ppd(
          [box_width, box_depth, box_height],
          BR, EC
        );
        core_cavities();
    }
}

module lid_selector(positive) {
    margin = 4;
    
    difference() {
        translate([
            -box_width/2 - margin,
            -box_depth/2 - margin,
            box_height/2 - LH
        ])
            cube([
                box_width + 2*margin,
                box_depth + 2*margin,
                LH + margin
            ]);
        
        translate([
            0,
            0,
            box_height/2 - LH - margin + (LP + margin) / 2
        ])
            side_rounded_ppd([
                box_width - 2*L + (positive ? LT : 0),
                box_depth - 2*L + (positive ? LT : 0),
                LP + margin
            ], BR);
    }
}

module box_bottom() {
    translate([0, 0, box_height / 2])
      difference() {
          fused_box();
          lid_selector(false);
      }
}

module box_lid() {
    translate([0, 0, box_height / 2])
        rotate([0, 180, 0])
          intersection() {
              fused_box();
              lid_selector(true);
          }
}


if (PART == "BODY") {
    box_bottom();
} else if (PART == "LID") {
    box_lid();
} else if (PART == "BOTH") {
    translate([-50, 0, 0]) box_bottom();
    translate([50, 0, 0]) box_lid();
}
