// TODO
// 3. Split vertically for trays with tokens (no point in the angled split)
// 4. Consider reducing filament along the back of the walls
// 5. Convert HOLDERS to a list of items and use functions to create different ones.
I_CARD_HOLDER = 1;
P_CH_NUM_CARDS = 1;
// Item Card Holder
function iCH(numCards) = [I_CARD_HOLDER, numCards];

I_MAT_HOLDER = 2;
P_MH_NUM_MATS = 1;
P_MH_HOLDER_DEPTH = 2;
function iMH(numMats, holderDepth) = [I_MAT_HOLDER, numMats, holderDepth];

I_TOKEN_BUCKET = 3;


ANGLE = 51; // 51 Was 52 in origional design
CARD_D = .66; // depth

TOTAL_H = 40;
BOTTOM_H = .24 * 3;
TOTAL_W = 72;
TOTAL_D = 288;
WALL_D = 4;
ROUNDED_CORNER = 2;

DIV_GAP_H = 1.8;
DIV_D = 6;

// Divider hole stuff
HOLE_R = 12;
HOLE_SCALE = .66;
TOP_R = 3;

SPLIT = true;
ONLY_FRONT = false; // false being "only back"

$fn = 18; // 36 or higher for print...

// NON-CARD SPECIAL CONFIGURATION
// SPECIAL = false;

// EXPANSIONS

// Renaissance Globals
MIN_BACK_GAP = 80; // Ensures finger access for cards in back.
FIRST_WALL_D = WALL_D; // Plenty of space in this expansion.

// Renaissance col 1 + 2
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 4.51576; // Extra
//HOLDERS = [10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Renaissance col 3
//SPLIT_AFTER = 4; // Split the thing in half after this many.
//E = 4.51576; // Extra
//HOLDERS = [20 + E, 25 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Renaissance col 4
SPECIAL = "renaissance";
SPLIT_AFTER = 1; // Split the thing in half after this many.
E = 0; // Extra
HOLDERS = [140, 10];

// Dark Ages Globals
//FIRST_WALL_D = .4 * 3;
//MIN_BACK_GAP = 75.5; // Ensures finger access for cards in back. DON'T GO SMALLER!

// Dark ages col 1
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 3.036114; // Extra
//HOLDERS = [12 + E, 10 + E, 11 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Dark ages col 2
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 4.11183; // Extra
//HOLDERS = [10 + E, 10 + E, 11 + E, 10 + E, 10 + E, 10 + E, 20 + E, 10 + E, 10 + E, 10 + E];

// Dark ages col 3
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 2.36487; // Extra
//HOLDERS = [10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 20 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Dark ages col 4
//SPLIT_AFTER = 4; // Split the thing in half after this many.
//E = 1.61166; // Extra
//HOLDERS = [50 + E, 18 + E, 15 + E, 35 + E, 10 + E, 10 + E, 20 + E];

// Mainly configures the height of the spill-over area...
MIN_CARDS = 13; // per holder

// CALCULATED CONSTANTS
CARD_ANGLED_D = CARD_D / cos (ANGLE);
SPILL_Z = (CARD_D * MIN_CARDS) * sin(ANGLE);
WIDTH = TOTAL_W - WALL_D * 2;
HOLE_W = WIDTH * HOLE_SCALE;

DIV_H = TOTAL_H - BOTTOM_H - DIV_GAP_H;
DIV_BACK_Y = DIV_H * tan(ANGLE);
DIV_BACK_BOT_Z = DIV_H - DIV_D / tan(ANGLE); // Points 2 + 6
DIV_CAP_R = (DIV_H - DIV_BACK_BOT_Z) / 2;
DIV_L = 1.13282*(DIV_H - SPILL_Z)/ sin(ANGLE);

FIRST_EXTRA = min(
  (CARD_D * HOLDERS[0] * sin(ANGLE)) / tan(90 - ANGLE),
  SPILL_Z * tan(ANGLE)
);

// Visual of inside of the box
//color("green", 0.125)
//translate([TOTAL_W, 0, 0])
//cube([2, TOTAL_D, 70]);
//
//color("green", 0.125)
//translate([0, 0, 70])
//cube([TOTAL_W, TOTAL_D, 2]);

difference() {
  union() {
    difference() {
      // Full wall.
      sideRoundedCube(TOTAL_W, TOTAL_D, TOTAL_H, ROUNDED_CORNER);

      // Cut out inner section.
      translate([WALL_D, FIRST_WALL_D, BOTTOM_H])
      cube([TOTAL_W - WALL_D * 2, TOTAL_D - WALL_D - FIRST_WALL_D, TOTAL_H - BOTTOM_H + .1]);
    };

    if (SPECIAL == false) {
      // Back cap rear
      CAP_R = 10;
      translate([0, TOTAL_D - WALL_D - CAP_R, CAP_R + BOTTOM_H])
      rotate([0, 90, 0])
      cylCap(TOTAL_W, CAP_R, 180);

      // Divider before first holder...
      translate([WALL_D, 0, BOTTOM_H])
      difference() {
        union() {
          translate([0, FIRST_WALL_D - DIV_D - FIRST_EXTRA, 0])
          cardDivider();

          difference() {
            translate([0, 0, 0])
            cube([WIDTH, WALL_D, TOTAL_H -  BOTTOM_H]);
            
            translate([0, FIRST_WALL_D + CARD_ANGLED_D * HOLDERS[0] - FIRST_EXTRA, 0])
            rotate([-ANGLE, 0, 0])
            translate([0, -CARD_D * HOLDERS[0], -TOTAL_H])
            cube([WIDTH, CARD_D * HOLDERS[0], TOTAL_H * 2]);
          };
        }

        translate([-WIDTH, -WIDTH, 0])
        cube([WIDTH*4, WIDTH, TOTAL_H]);
      };

      // Card holders.
      difference() {
        translate([WALL_D, 0, BOTTOM_H])
        card_holder(0, FIRST_WALL_D - FIRST_EXTRA);

        // Cut off the front.
        translate([0, FIRST_WALL_D - TOTAL_W, 0])
        cube([TOTAL_W, TOTAL_W, TOTAL_H]);
      };
    } else if (SPECIAL == "renaissance") {
      INNER_H = 25 - BOTTOM_H;
      INNER_D = TOTAL_D - 2 * WALL_D;
      CAP_R = 6.5;

      MAT_D = 1.16666666667;
      MAT_ANGLE = 41;
      MAT_ANGLED_D = MAT_D / cos(MAT_ANGLE);
      MAT_CNT = 7; // 6 + some wiggle room
      MAT_W = 128 + 4;
      MAT_H = 84;
      MAT_X_PAD = 0;
      MAT_Y_PAD = 12;
      MAT_CLIP_SIZE = MAT_D * 3;
      MAT_CLIP_DROP_Z = 5; // Trig fails me...

      translate([WALL_D, WALL_D, BOTTOM_H])
      difference() {
        // Middle bottom
        color("red", 0.25)
        cube([WIDTH, INNER_D, TOTAL_H - BOTTOM_H]);

        color("blue", 0.25)
        union() {
          // Major bowl indentation
          translate([0, 0, INNER_H])
          bowl_thing(WIDTH, INNER_D, INNER_H, CAP_R);

          TRAY_BOWL_R = 5;

          // Coins bowl
          COIN_B_W = 45;
          COIN_B_D = 45;
          COIN_B_H = 20;
          COIN_B_Y = MAT_Y_PAD + MAT_W + 32;
          translate([(WIDTH - COIN_B_W) / 2, COIN_B_Y, INNER_H - COIN_B_H])
          bowl_thing(COIN_B_W, COIN_B_D, INNER_H, TRAY_BOWL_R);

          // Cubes bowl
          CUBES_B_W = 45;
          CUBES_B_D = 35;
          CUBES_B_H = 20;
          CUBES_B_Y = COIN_B_Y + COIN_B_D + 14;
          translate([(WIDTH - CUBES_B_W) / 2, CUBES_B_Y, INNER_H - CUBES_B_H])
          bowl_thing(CUBES_B_W, CUBES_B_D, INNER_H, TRAY_BOWL_R);

          matTotalD = MAT_D * MAT_CNT;
          matAngledTotalD = MAT_ANGLED_D * MAT_CNT;

          translate([MAT_X_PAD, MAT_Y_PAD, 0])
          union() {
            // Holder slot.
            translate([matAngledTotalD, 0, 0])
            difference() {
              // Slot inside
              rotate([0, MAT_ANGLE, 0])
              translate([-matTotalD, 0, -MAT_H])
              cube([matTotalD, MAT_W, MAT_H * 2]);

              // Cut off the bottom so it's flat.
              translate([-MAT_H * 5, -MAT_H * 5, -MAT_H * 10])
              cube([MAT_H * 10, MAT_H * 10, MAT_H * 10]);
            };

            // Clip: Flat part on top for ease of storage.
            translate([INNER_H / tan(90 - MAT_ANGLE) - MAT_CLIP_SIZE, 0, INNER_H - MAT_CLIP_DROP_Z])
            cube([MAT_CLIP_SIZE * 2, MAT_W, MAT_H]);
          };
        };
      };
    }
  };

  // Splits the thing in half.
  if (SPLIT) {
    maybe_invert()
    holder_mask(0, FIRST_WALL_D - FIRST_EXTRA);
  }
};

module maybe_invert() {
  if (ONLY_FRONT) {
    difference() {
      cube([TOTAL_W, TOTAL_D, TOTAL_H]);
      children();
    };
  } else {
    children();
  }
}

module holder_mask(i, cur_d) {
  if (i < len(HOLDERS)) {
    numCards = HOLDERS[i];
    depth = holderDepth(numCards);

    translate([0, cur_d, 0]) {
      if (i == SPLIT_AFTER - 1) {
        nextCardsZ = min(MIN_CARDS, HOLDERS[i + 1]) * CARD_D * sin(ANGLE);
        nextCardsY = nextCardsZ / tan(90 - ANGLE);

        topCardsZ = 6.5 * CARD_D * sin(ANGLE);
        topCardsY = TOTAL_H * tan(ANGLE) - topCardsZ / tan(90 - ANGLE);

        difference() {
          union() {
            translate([0, depth - DIV_D / 2 - 50, 0])
            cube([TOTAL_W, nextCardsY + 50, nextCardsZ + BOTTOM_H]);

            translate([0, depth - DIV_D / 2, BOTTOM_H])
            rotate([-ANGLE, 0 ,0])
            translate([0, -TOTAL_D, -TOTAL_H * 4])
            cube([TOTAL_W, TOTAL_D, TOTAL_H * 8]);
          };

          translate([0, depth - DIV_D / 2 + topCardsY, TOTAL_H - topCardsZ + BOTTOM_H])
          cube([TOTAL_W, 10, topCardsZ - BOTTOM_H]);
        };
      }
    }

    holder_mask(i + 1, cur_d + depth);
  }
};

module card_holder(i, cur_d) {
  spaceLeft = TOTAL_D - cur_d;
  echo(i = i + 1, MIN_BACK_GAP = MIN_BACK_GAP, spaceLeft = spaceLeft);
  if (i < len(HOLDERS)) {
    numCards = HOLDERS[i];

    translate([0, cur_d])
    holder(numCards);

    card_holder(i + 1, cur_d + holderDepth(numCards));
  } else {
    assert(spaceLeft >= MIN_BACK_GAP, "Too tight! Fingers will have a hard time picking up the back stack of cards...");
  }
};

function holderDepth(numCards) =
    numCards * CARD_ANGLED_D + DIV_D;

module holder(numCards, isFront) {
  difference() {
    translate([0, numCards * CARD_ANGLED_D, 0])
    rotate([180-ANGLE, 0, 0])
    cube([WIDTH, CARD_D * numCards, WIDTH]);

    union() {
      // Spill top
      if (numCards - E > MIN_CARDS) {
        translate([-WIDTH, -WIDTH, SPILL_Z])
        cube([WIDTH * 4, WIDTH * 4, WIDTH]);
      }

      // Under the spill
      translate([-WIDTH, -WIDTH, -WIDTH])
      cube([WIDTH * 4, WIDTH * 4, WIDTH]);
    }
  };

  translate([0, numCards * CARD_ANGLED_D, 0])
  cardDivider();
}

module cardDivider() {
  // Card divider.
  translate([WIDTH, 0, 0])
  rotate([0, 0, 180])
  difference() {
    union() {
      // Point image: https://photos.app.goo.gl/Lu6kYR7UExFjoFv78
      polyhedron(
        points = [
          [0, 0, 0], // 0
          [0, -DIV_BACK_Y, DIV_H], // 1
          [0, -DIV_BACK_Y, DIV_BACK_BOT_Z], // 2
          [0, -DIV_D , 0], // 3
          [WIDTH, 0, 0], // 4
          [WIDTH, -DIV_D , 0], // 5
          [WIDTH, -DIV_BACK_Y, DIV_BACK_BOT_Z], // 6
          [WIDTH, -DIV_BACK_Y, DIV_H], // 7
        ],
        faces = [
          [0, 1, 2, 3],
          [4, 5, 6, 7],
          [0, 4, 7, 1],
          [1, 7, 6, 2],
          [6, 5, 3, 2],
          [0, 3, 5, 4],
        ]);

         // Card divider end cap.
        translate([0, -DIV_BACK_Y, DIV_BACK_BOT_Z + DIV_CAP_R])
        scale([1, .53, 1.04757])
        difference() {
          shearAlongZ([0, -.3, 1])
          rotate([0, 90, 0])
          cylinder(WIDTH, DIV_CAP_R, DIV_CAP_R);

          rotate([0, 90, 0])
          translate([-DIV_CAP_R*1.25, 0, -1])
          cube([DIV_CAP_R * 2.5, DIV_CAP_R * 1.5, WIDTH * 2]);
        };
      };

    // Divider hole. 2.373
    translate([0, -DIV_D*2.3776, SPILL_Z])
    rotate([ANGLE - 90, 0, 0])
    difference() {
      //translate([WIDTH - HOLE_W / 2, -SPILL_Y*4, SPILL_Z])
      union() {
        translate([(WIDTH - HOLE_W) / 2, -DIV_L, 0])
        cube([HOLE_W, DIV_L, DIV_D]);

        translate([WIDTH - (WIDTH - HOLE_W) / 2 -.0001, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 0);
        
        translate([(WIDTH - HOLE_W) / 2-TOP_R, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 90);
      };

      union() {
        translate([(WIDTH - HOLE_W) / 2, -HOLE_R, 0])
        cylCap(DIV_D, HOLE_R, 270);

        translate([WIDTH - (WIDTH - HOLE_W) / 2 - HOLE_R, -HOLE_R, 0])
        cylCap(DIV_D, HOLE_R, 180);
      };
    };
  };
}

module cylCap(h, r, a) {
  translate([r / 2, r / 2, 0])
  rotate([0, 0, a + 180])
  translate([-r / 2, -r / 2, 0])
  difference() {
    cube([r+.001, r+.001, h]);

    translate([0, 0, - h * .5])
    cylinder(h * 2, r, r);
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

module bowl_thing (w, d, h, r) {
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

module shearAlongZ(p) {
  multmatrix([
    [1, 0, p.x / p.z, 0],
    [0, 1, p.y / p.z, 0],
    [0, 0, 1,         0]
  ])
  children();
}