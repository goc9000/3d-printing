module chamfered_cylinder(r, h, chamfer) {
    c = min(chamfer, r, h/2);
    
    rotate_extrude()
        polygon([
            [0, h], [r - c, h], [r, h - c],
            [r, c], [r - c, 0], [0, 0]
        ]);
}

module chamfered_ppd(sizes, chamfer) {
    w = sizes[0];
    d = sizes[1];
    h = sizes[2];
    c = min(chamfer, w/2, d/2, h/2);
    
    polyhedron(
        points=[
            [-w/2 + c, -d/2 + c, -h/2],
            [ w/2 - c, -d/2 + c, -h/2],
            [ w/2 - c,  d/2 - c, -h/2],
            [-w/2 + c,  d/2 - c, -h/2],
            [-w/2, -d/2, -h/2 + c],
            [ w/2, -d/2, -h/2 + c],
            [ w/2,  d/2, -h/2 + c],
            [-w/2,  d/2, -h/2 + c],
            [-w/2, -d/2, h/2 - c],
            [ w/2, -d/2, h/2 - c],
            [ w/2,  d/2, h/2 - c],
            [-w/2,  d/2, h/2 - c],
            [-w/2 + c, -d/2 + c, h/2],
            [ w/2 - c, -d/2 + c, h/2],
            [ w/2 - c,  d/2 - c, h/2],
            [-w/2 + c,  d/2 - c, h/2]
        ],
        faces=[
            [ 1, 2, 3, 0 ],
            [ 1, 5, 6, 2 ],
            [ 0, 4, 5, 1 ],
            [ 3, 7, 4, 0 ],
            [ 2, 6, 7, 3 ],
            [ 5, 9, 10, 6 ],
            [ 4, 8, 9, 5 ],
            [ 7, 11, 8, 4 ],
            [ 6, 10, 11, 7 ],
            [ 9, 13, 14, 10 ],
            [ 8, 12, 13, 9 ],
            [ 11, 15, 12, 8 ],
            [ 10, 14, 15, 11 ],
            [ 15, 14, 13, 12 ],
        ]
    );
}

/* A parallelipiped with rounded sides (but not a rounded top or
   bottom). Always centered at (0,0,0) */
module side_rounded_ppd(sizes, radius) {
    w = sizes[0];
    d = sizes[1];
    h = sizes[2];
    
    r = min(radius, w/2, d/2);
    
    cube([w - 2*r, d, h], center=true);
    cube([w, d - 2*r, h], center=true);
    translate([-w/2 + r, -d/2 + r, -h/2]) cylinder(r=r, h=h);
    translate([-w/2 + r, d/2 - r, -h/2]) cylinder(r=r, h=h);
    translate([w/2 - r, -d/2 + r, -h/2]) cylinder(r=r, h=h);
    translate([w/2 - r, d/2 - r, -h/2]) cylinder(r=r, h=h);
}

module side_rounded_chamfered_ppd(sizes, radius, chamfer) {
    w = sizes[0];
    d = sizes[1];
    h = sizes[2];
    
    r = min(radius, w/2, d/2);
    c = min(chamfer, r, w/2, d/2, h/2);
    
    minkowski() {
        side_rounded_ppd([w - 2*c, d - 2*c, h - 2*c], r - c);
        rotate_extrude() polygon([[0, -c], [0, c], [c, 0]]);
    }
}
