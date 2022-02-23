W = 65;  // Width
D = 55;  // Depth
H = 20;  // Height
OR = 7;  // Outside radius
WT = 5;  // Wall thickness
BT = 2;  // Bottom thickness

// Computed values
IR = OR - WT;
TR = WT / 2;
GS = D / 5; // Grippy size

$fn = 36;

//translate([0, D + 15, 0])
//color("blue", 0.25)
//cube([W, 5, H]);
//translate([W + 15, 0, 0])
//color("blue", 0.25)
//cube([5, D, H]);

// non-centered sphere.
module ball (r) {
  translate([r, r, r])
  sphere(r);
}

module square_ring (w, d, r) {
  // Corners
  translate([0, 0, 0]) ball(r);
  translate([w-r*2, 0, 0]) ball(r);
  translate([0, d-r*2, 0]) ball(r);
  translate([w-r*2, d-r*2, 0]) ball(r);

  // Edges
  ew = w-r*2;
  ed = d-r*2;
  translate([0, 0, r]) {
    translate([r, r, 0])
    rotate([-90, 0, 0])
    cylinder(ed, r, r);
    translate([w-r, r, 0])
    rotate([-90, 0, 0])
    cylinder(ed, r, r);
    translate([r, r, 0])
    rotate([0, 90, 0])
    cylinder(ew, r, r);
    translate([r, d-r, 0])
    rotate([0, 90, 0])
    cylinder(ew, r, r);
  };
}

module bowl_thing (w, d, h, r) {
  // Blocky inner parts
  translate([0, r, r])
  cube([w, d - r*2, h - r]);

  translate([r, 0, r])
  cube([w - r*2, d, h - r]);

  translate([r, r, 0])
  cube([w - r*2, d - r*2, h]);

  // Rottom ring
  square_ring(w, d, r);

  // Edge upright cylinders
  translate([r, r, r])
  rotate([0, 0, 90])
  cylinder(h - r, r, r);

  translate([w - r, r, r])
  rotate([0, 0, 90])
  cylinder(h - r, r, r);

  translate([r, d-r, r])
  rotate([0, 0, 90])
  cylinder(h - r, r, r);

  translate([w - r, d - r, r])
  rotate([0, 0, 90])
  cylinder(h - r, r, r);
}

// Outside shell
color("green", 0.4) {
  difference() {
    bowl_thing(W, D, H - TR, OR);

    translate([WT, WT, BT])
    bowl_thing(W - WT*2, D - WT*2, H, IR);
  }
};

translate([0, 0, H-TR])
color("yellow", 0.5) {
  translate([OR, OR, 0])
  rotate([0, 0, 180])
  rotate_extrude(angle=90)
    translate([OR-TR, 0]) circle(TR);
  
  translate([W-OR, D-OR, 0])
  rotate_extrude(angle=90)
    translate([OR-TR, 0]) circle(TR);
  
  translate([OR, D-OR, 0])
  rotate([0, 0, 90])
  rotate_extrude(angle=90)
    translate([OR-TR, 0]) circle(TR);

  translate([W-OR, OR, 0])
  rotate([0, 0, 270])
  rotate_extrude(angle=90)
    translate([OR-TR, 0]) circle(TR);


  translate([OR, TR, 0])
  rotate([0, 90, 0])
  cylinder(W - OR*2, TR, TR);

  translate([OR, D-TR, 0])
  rotate([0, 90, 0])
  cylinder(W - OR*2, TR, TR);
  
  translate([TR, OR, 0])
  rotate([-90, 0, 0])
  cylinder(D - OR*2, TR, TR);
  
  translate([W-TR, OR, 0])
  rotate([-90, 0, 0])
  cylinder(D - OR*2, TR, TR);
};


translate([TR, D/2, H-TR])
rotate([90, 0, 90]) {
cylinder(WT, GS, GS, center=true);
rotate_extrude(angle=180)
  translate([GS, 0]) circle(TR);
};

//eps = 0.01;
//translate([eps, 60, 0])
//scale([1, 1, .25])
//   rotate_extrude(angle=180, convexity=10)
//       translate([40, 0]) circle(10);
//rotate_extrude(angle=90, convexity=10)
//   translate([20, 0]) circle(10);
//translate([20, eps, 0])
//   rotate([90, 0, 0]) cylinder(r=10, h=80+eps);

