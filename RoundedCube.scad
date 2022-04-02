$fn = 36;

MAT_D = 1.16666666667;
// MAT_ANGLED_D = MAT_D / cos(MAT_ANGLE);
MAT_CNT = 15; // 7; 6 + some wiggle room

slotW = MAT_D * MAT_CNT; // Pre-rotation slot width
slotA = 49; // 49
slotD = 128 + 4;
slotH = 84;
slotClipW = 20;// MAT_D * 5;
smoothR = 10;

sideRoundedCube(20, 20, 20, 5);

translate([0, 25, 0])
oneSideRoundedCube(20, 20, 20, 5);

translate([25, 0, 0])
oneSideRoundedCube(20, 20, 20, 5);

//roundedSlot(slotW, slotD, slotH, slotA, smoothR, slotClipW);

function roundedSlotW(slotW, slotH, slotA) = slotH / tan(slotA) + slotW / cos(90 - slotA);

module roundedSlot(slotW, slotD, slotH, slotA, smoothR, slotClipW = 0) {
  totalW = roundedSlotW(slotW, slotH, slotA);
  angledExtra = smoothR / cos(90 - slotA);

  clipH = slotClipW * tan(slotA);
  clipZ = slotH - clipH;
  slotTopX = slotH / tan(slotA);
  clipX = slotTopX - slotClipW;

  Z = .0001; // A bit more than zero.

  difference() {
    translate([- Z, -smoothR - Z, 0])
    cube([Z + totalW + smoothR/2, slotD + smoothR * 2 + Z * 2, slotH]);

    union() {
      minkowski() {
        difference() {
          translate([-totalW / 2, -slotD / 2, -slotH - smoothR])
          cube([totalW * 2, slotD * 2, slotH * 2]);

          union() {
            color("green", 0.25)
            difference() {
              translate([-angledExtra, -smoothR, 0])
              rotate([0, 90 - slotA, 0])
              translate([0, 0, -slotH*250])
              cube([slotW + smoothR * 2, slotD + smoothR * 2, slotH * 1000]);

              union() {
                translate([-slotD * 2, -slotD * 2, -slotD * 2-smoothR])
                cube([slotD * 4, slotD * 4, slotD * 2]);
                translate([-slotD * 2, -slotD * 2, slotH])
                cube([slotD * 4, slotD * 4, slotD * 2]);
              };
            };

            color("red", 0.25)
            translate([clipX - smoothR, -smoothR, clipZ - smoothR])
            cube([slotClipW + Z + smoothR, slotD + smoothR * 2, clipH * 2 ]);
          };
        };

        sphere(smoothR);
      };

      // The top cut-off
      cutOffX = min(clipX - smoothR, slotTopX - (smoothR + smoothR / sin(90 - slotA)) / tan(slotA));
      translate([-1, -slotD, slotH - 1])
      cube([cutOffX + 1, slotD * 3, 8]);
    };
  };
}

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

// Top, bottom, and back are flat.
module oneSideRoundedCube(w, d, h, r) {
  minkowski() {
    translate([r, r, r / 2])
    cube([w - r * 2, d - r, h - r]);

    difference() {
      cylinder(h = r, r = r, center = true);

      translate([-r*2, 0, -r*2])
      cube([r*4, r*4, r*4]);
    }
  };
  
//  union() {
//    translate([0, r, 0])
//    cube([w, d - r, h]);
//
//    translate([r, 0, 0])
//    cube([w - r*2, r, h]);
//
//    translate([r, r, 0])
//    cylinder(h = h, r = r);
//
//    translate([w - r, r, 0])
//    cylinder(h = h, r = r);
//  };  
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