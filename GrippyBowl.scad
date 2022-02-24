$fn = 36;

grippy_bowl(65, 55, 20);

/**
 * @param {number} w Width
 * @param {number} d Depth
 * @param {number} h Height
 * @param {=number} or Outside radius
 * @param {=number} wt Wall thickness
 * @param {=number} bt Bottom thickness
 */
module grippy_bowl(w, d, h, or = 10, wt = 5, bt = 2) {
  ir = or - wt; // Inside radius
  tr = wt / 2; // Top radius
  gs = d / 5; // Grippy size

  // Make the model easier to print by clipping the bottom.
  botClipH = sin(25) * or;

  // Outside shell
  translate([0, 0, -botClipH])
  difference() {
    difference() {
      bowl_thing(w, d, botClipH + h - tr, or);

      translate([wt, wt, botClipH + bt])
      bowl_thing(w - wt*2, d - wt*2, botClipH + h, ir);
    };

    cube([w, d, botClipH]);
  };

  translate([0, 0, h - tr]) {
    translate([or, or, 0])
    rotate([0, 0, 180])
    rotate_extrude(angle = 90)
    translate([or - tr, 0])
    circle(tr);

    translate([w - or, d - or, 0])
    rotate_extrude(angle = 90)
    translate([or - tr, 0])
    circle(tr);

    translate([or, d-or, 0])
    rotate([0, 0, 90])
    rotate_extrude(angle = 90)
    translate([or - tr, 0])
    circle(tr);

    translate([w-or, or, 0])
    rotate([0, 0, 270])
    rotate_extrude(angle = 90)
    translate([or - tr, 0])
    circle(tr);


    translate([or, tr, 0])
    rotate([0, 90, 0])
    cylinder(w - or * 2, tr, tr);

    translate([or, d - tr, 0])
    rotate([0, 90, 0])
    cylinder(w - or * 2, tr, tr);

    translate([tr, or, 0])
    rotate([-90, 0, 0])
    cylinder(d - or * 2, tr, tr);

    translate([w - tr, or, 0])
    rotate([-90, 0, 0])
    cylinder(d - or * 2, tr, tr);
  };

  translate([tr, d / 2, h - tr])
  rotate([90, 0, 90]) {
    cylinder(wt, gs, gs, center = true);
    rotate_extrude(angle = 180)
    translate([gs, 0])
    circle(tr);
  };
}

module bowl_thing(w, d, h, r) {
  minkowski() {
    translate([r, r, r])
    cube([w - r * 2, d - r * 2, h - r]);

    difference() {
      sphere(r);

      translate([-r * 2, -r * 2, 0])
      cube([r * 4, r * 4, r * 2]);
    };
  };
}
