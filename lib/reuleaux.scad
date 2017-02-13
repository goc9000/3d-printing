//  Produce a Reuleaux polygon

//  Reuleaux polygons are examples of curves of constant width.  The wheel is
//  the simplest such curve.  Reuleaux polygons are the next simplest, albeit
//  they suffer from tangent continuity.  Curves of constant width can be used,
//  for example, as wheels and hole covers (which cannot be oriented such that
//  they can fall through the opening they are covering).

//  Dan Newman, dan newman @ mtbaldy us
//  16 June 2012 
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License,
//  LGPL version 2.1, or (at your option) any later version of the GPL.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 

//  Produce a Reuleaux polygon of maximal width w and n sides
//  Note that n must be odd-valued.  Reason for that is that
//  the construction of a Reuleaux polygon requires each vertex V
//  to have two opposite vertices which are equidistant from V.

module reuleaux_polygon(n = 3, w = 10)
{
     // Angular separation between vertices of the regular n-gon
     angle = 360 / n;

     // If the n-gon's edge length is 1 then the distance from the
     // center to a vertex is
     r = 1 / (2 * sin(angle/2));

     // Place the first vertex, V0, at [0, r]
     V0 = [0, r];

     // We now wish to know the distance from V0 to either of the
     // two opposite vertices

     // Compute the angle from V0 to one of the opposite vertices  
     theta = angle * floor(n / 2);

     // Compute the coordinates of this opposite vertex
     Vopposite = [ V0 * [cos(theta), -sin(theta)],
                   V0 * [sin(theta),  cos(theta)] ];
 
     // What's the distance between these two vertices?
     d = sqrt( pow(V0[0] - Vopposite[0], 2) + pow(V0[1] - Vopposite[1], 2) );

     // Finally, the scaling to rescale d to be w
     s = w / d;
     intersection_for(i = [0 : n-1])
     {
          rotate([0, 0, i * angle])
              translate([0, s * r, 0])
                  circle(r = s * d, center=true);
     }
}

// $fn = 100;

// linear_extrude(height = 1) reuleaux_polygon(3, 5);
// for(i = [0 : 4])
// {
//      linear_extrude(height = 1)
//        rotate([0, 0, -i * 360/5])
//          translate([0, 5.5, 0]) reuleaux_polygon(5 + i*2, 5);
// }
