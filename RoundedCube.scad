$fn = 18;

mR = 2;

// Adding rounded edges to cutting out a mat slot

translate([-45, 0, 0])
color("red", 0.25)
difference() {
  translate([mR, mR, mR])
  minkowski() {
    difference() {
      cube([40 -mR*2, 30-mR*2, 20 -mR*2]);
      
      translate([10+mR / cos(-45), 10 - mR*2, 1])
      rotate([0, -45, 0])
      cube([40+ mR * 2, 10+ mR * 2, 10+ mR * 2]);
    };

    sphere(mR);
  };

  // Cut out the bottom
  translate([10, 10, 1])
  rotate([0, -45, 0])
  cube([40, 10, 10]);
};

// All sides, edges, and corners are rounded.
module fullyRoundedCube(w, d, h, r) {
  minkowski() {
    translate([r, r, r])
    cube([w - r * 2, d - r * 2, h - r * 2]);

    sphere(r);
  };
}

// Top and bottom are flat.
module sideRoundedCube(w, d, h, r) {
  minkowski() {
    translate([r, r, r / 2])
    cube([w - r * 2, d - r * 2, h - r]);

    cylinder(h = r, r = r, center = true);
  };
}

// Top is flat.
module bowlCube(w, d, h, r) {
  minkowski() {
    translate([r, r, r])
    cube([w - r * 2, d - r * 2, h - r]);

    difference() {
      sphere(r);

      translate([-r*2, -r*2, 0])
      cube([r*4, r*4, r*2]);
    };
  };
}

// non-centered sphere.
module ball (r) {
  translate([r, r, r])
  sphere(r);
}

module square_ring (w, d, r) {
  Z = .0001; // ~zero

  translate([r, r, r])
  minkowski() {
    difference() {
      cube([w - r * 2, d - r * 2, Z]);
      translate([Z, Z, 0])
      cube([w - r * 2 - Z * 2, d - r * 2 - Z * 2, Z]);
    };

    sphere(r);
  };
}
