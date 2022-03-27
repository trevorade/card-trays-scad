use <RoundedCube.scad>;

// TODO
// 3. Split vertically for trays with tokens (no point in the angled split)
// 4. Consider reducing filament along the back of the walls
// 5. Convert HOLDERS to a list of items and use functions to create different ones.

// Expansion tray presets.
// Note, many presets are missing at this moment (see the large ITEMS list below).
// Small expansions are also not included.
BASE_2E = 0;
INTRIGUE_2E = 1;
SEASIDE_1E = 2;
PROSPERITY = 3;
HINTERLANDS = 4;
DARK_AGES = 5;
GLDS_AND_CRNCP = 6;
ADVENTURES = 7;
EMPIRES = 8;
NOCTURNE = 9;
RENAISSANCE = 10;
MENAGERIE = 11;
ALLIES = 12;
SEASIDE_2E = 13;


// Export STL settings.

// Which expansion to export.
EXPANSION = DARK_AGES;
// Which tray to print (0, 1, 2 or 3).
TRAY = 0;
// Only models the front half of the tray. Model the back with `false`.
ONLY_FRONT = true;
// Only models a single bucket corresponding to an item index (starting with 0).
// `false` to print the tray as per normal
ONLY_BUCKET = false;
// Overall quality. Use 36 or higher when rendering before exporting the STL.
$fn = 18;


// Global object settings.

// Total sleeved card depth in mm.
CARD_D = .66;
// First-layer-height.
BOTTOM_H = .24 * 3;
// Outside wall rounded corner
ROUNDED_CORNER = 2;
// Wall dimension. May want to be smaller for larger sleeves.
WALL_D = 4;


// You probably don't want to change these constants below.

// Overall tray height.
TOTAL_H = 40;
// Card-holder angle. A bit wonky as it starts with the object at 90 deg then
// rotates from there. Excuse the weird math because of this.
ANGLE = 51;
// Total tray width. 72 is used for Dominion trays.
TOTAL_W = 72;
// Total tray depth. 288 is used for Dominion trays.
TOTAL_D = 288;

// Vertical gap between top of wall and top of card divider.
DIV_GAP_H = 1.8;
// Divider wall depth.
DIV_D = 6;
// Divider hole radius.
HOLE_R = 12;
// The divider hole width in relation to the total divider width
HOLE_SCALE = .66;
// The divider hole rounded corner radius at the top.
TOP_R = 3;
// Minimum number of cards per holder. Impacts the spill-over height for cards.
// Makes sure big stacks of cards don't get too vertically high.
MIN_CARDS = 13;

CARD_ANGLED_D = CARD_D / cos(ANGLE);
SPILL_Z = CARD_D * MIN_CARDS * sin(ANGLE);
INNER_WIDTH = TOTAL_W - WALL_D * 2;
HOLE_W = INNER_WIDTH * HOLE_SCALE;

DIV_H = TOTAL_H - BOTTOM_H - DIV_GAP_H;
DIV_BACK_Y = DIV_H * tan(ANGLE);
DIV_BACK_BOT_Z = DIV_H - DIV_D / tan(ANGLE); // Points 2 + 6
DIV_CAP_R = (DIV_H - DIV_BACK_BOT_Z) / 2;
// I do not remember what this dark magic is...
DIV_L = 1.13282*(DIV_H - SPILL_Z)/ sin(ANGLE);


// "Classes" for various types of tray items.

// Just lists with some magic numbers/indices referenced by index constants.
// P_ is a parameter index constant.
// I_ identifies the "class" of item.

// All item lists start with the item type parameter.
P_I_TYPE = 0;
P_I_SPLIT_AFTER = 1;

// Makes an item trigger a split after it.
function splitAfter(item) =
  false;
  //concat(item[P_I_TYPE], true, [for (i = [2 : len(item)]) item[i]]);

// Item Card Holder
I_CARD_HOLDER = 1;
P_CH_NUM_CARDS = 2;
function iCH(numCards) = [I_CARD_HOLDER, false, numCards];

function shouldClipCardHolderFront(i) =
  i == 0 || ITEMS[i - 1][P_I_TYPE] != I_CARD_HOLDER;

function cardHolderSpillH(i) =
  let (numCards = ITEMS[i][P_CH_NUM_CARDS])
    numCards > MIN_CARDS ? SPILL_Z : CARD_D * numCards * sin(ANGLE);

function cardHolderSpillFrontD(i) =
  cardHolderSpillH(i) / tan(90 - ANGLE);


// Item Mat Holder
I_MAT_HOLDER = 2;
P_MH_NUM_MATS = 2;
P_MH_MAT_DEPTH = 3;
P_MH_HOLDER_DEPTH = 4;
function iMH(numMats, matDepth, holderDepth) = [I_MAT_HOLDER, false, numMats, matDepth, holderDepth];

// Item Token Bucket
I_TOKEN_BUCKET = 3;
P_TB_W = 2;
P_TB_D = 3;
P_TB_H = 4;
function iTB(width, depth, height) = [I_TOKEN_BUCKET, false, depth, height];


// Gets the depth of an item.
function itemDepth(i) =
  let (item = ITEMS[i]) (
    item[P_I_TYPE] == I_CARD_HOLDER ?
      let (numCards = item[P_CH_NUM_CARDS],
           clipFront = shouldClipCardHolderFront(i)) (
        (clipFront ? -cardHolderSpillFrontD(i) : 0) + numCards * CARD_ANGLED_D + DIV_D
      )
      :
      0
  );


// Expansions

// Ensures finger access for cards in back. DON'T GO SMALLER than 75.5!
MIN_BACK_GAP = [
  80, // BASE_2E
  80, // INTRIGUE_2E
  80, // SEASIDE_1E
  80, // PROSPERITY
  80, // HINTERLANDS
  75.5, // DARK_AGES
  80, // GLDS_AND_CRNCP
  80, // ADVENTURES
  80, // EMPIRES
  80, // NOCTURNE
  80, // RENAISSANCE
  80, // MENAGERIE
  80, // ALLIES
  80, // SEASIDE_2E
][EXPANSION];

// Enables an optional thinner first wall where the first card holder will
// cut into the wall by this amount.
FIRST_WALL_D = [
  true, // BASE_2E
  true, // INTRIGUE_2E
  false, // SEASIDE_1E
  false, // PROSPERITY
  false, // HINTERLANDS
  true, // DARK_AGES
  false, // GLDS_AND_CRNCP
  false, // ADVENTURES
  false, // EMPIRES
  false, // NOCTURNE
  false, // RENAISSANCE
  false, // MENAGERIE
  false, // ALLIES
  false, // SEASIDE_2E
][EXPANSION] ? .4 * 3 : WALL_D;

// Items that will be included in the model tray.
// Items are front to back which is typically the reverse of how you'll want
// to organize cards so keep that in mind.
ITEMS = [
  undef, // BASE_2E tray 0
  undef, // BASE_2E tray 1
  undef, // BASE_2E tray 2
  undef, // BASE_2E tray 3
  undef, // INTRIGUE_2E tray 0
  undef, // INTRIGUE_2E tray 1
  undef, // INTRIGUE_2E tray 2
  undef, // INTRIGUE_2E tray 3
  undef, // SEASIDE_1E tray 0
  undef, // SEASIDE_1E tray 1
  undef, // SEASIDE_1E tray 2
  undef, // SEASIDE_1E tray 3
  undef, // PROSPERITY tray 0
  undef, // PROSPERITY tray 1
  undef, // PROSPERITY tray 2
  undef, // PROSPERITY tray 3
  undef, // HINTERLANDS tray 0
  undef, // HINTERLANDS tray 1
  undef, // HINTERLANDS tray 2
  undef, // HINTERLANDS tray 3
  // DARK_AGES tray 0
  // [iCH(12), iCH(10), iCH(11), iCH(10), iCH(10), splitAfter(iCH(10)), iCH(10), iCH(10), iCH(10), iCH(10), iCH(10)],
  // DARK_AGES tray 1
  [iCH(10), iCH(10), iCH(11), iCH(10), iCH(10), splitAfter(iCH(10)), iCH(20), iCH(10), iCH(10), iCH(10)],
  undef, // DARK_AGES tray 2
  undef, // DARK_AGES tray 3
  undef, // GLDS_AND_CRNCP tray 0
  undef, // GLDS_AND_CRNCP tray 1
  undef, // GLDS_AND_CRNCP tray 2
  undef, // GLDS_AND_CRNCP tray 3
  undef, // ADVENTURES tray 0
  undef, // ADVENTURES tray 1
  undef, // ADVENTURES tray 2
  undef, // ADVENTURES tray 3
  undef, // EMPIRES tray 0
  undef, // EMPIRES tray 1
  undef, // EMPIRES tray 2
  undef, // EMPIRES tray 3
  undef, // NOCTURNE tray 0
  undef, // NOCTURNE tray 1
  undef, // NOCTURNE tray 2
  undef, // NOCTURNE tray 3
  undef, // RENAISSANCE tray 0
  undef, // RENAISSANCE tray 1
  undef, // RENAISSANCE tray 2
  undef, // RENAISSANCE tray 3
  undef, // MENAGERIE tray 0
  undef, // MENAGERIE tray 1
  undef, // MENAGERIE tray 2
  undef, // MENAGERIE tray 3
  undef, // ALLIES tray 0
  undef, // ALLIES tray 1
  undef, // ALLIES tray 2
  undef, // ALLIES tray 3
  undef, // SEASIDE_2E tray 0
  undef, // SEASIDE_2E tray 1
  undef, // SEASIDE_2E tray 2
  undef, // SEASIDE_2E tray 3
][EXPANSION * 4 + TRAY];
assert(ITEMS != undef, str(
  "Sorry. No presets for EXPANSION = ", EXPANSION,
  ", TRAY = ", TRAY,
  ". Consider defining a preset."));


// Renaissance Globals
//MIN_BACK_GAP = 80; // Ensures finger access for cards in back.
//FIRST_WALL_D = WALL_D; // Plenty of space in this expansion.

// Renaissance col 1 + 2
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 4.51576; // Extra
//HOLDERS = [10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Renaissance col 3
//SPLIT_AFTER = 4; // Split the thing in half after this many.
//E = 4.51576; // Extra
//HOLDERS = [20 + E, 25 + E, 10 + E, 10 + E, 10 + E, 10 + E, 10 + E];

// Renaissance col 4
//SPECIAL = "renaissance";
//SPLIT_AFTER = 1; // Split the thing in half after this many.
//E = 0; // Extra
//HOLDERS = [140, 10];

// Dark Ages Globals
//FIRST_WALL_D = .4 * 3;
//MIN_BACK_GAP = 75.5; // Ensures finger access for cards in back. DON'T GO SMALLER than 75.5!

// Dark ages col 1
//SPLIT_AFTER = 6; // Split the thing in half after this many.
//E = 3.036114; // Extra
//ITEMS = [
//  iCH(12), iCH(10), iCH(11), iCH(10), iCH(10), splitAfter(iCH(10)),
//  iCH(10), iCH(10), iCH(10), iCH(10), iCH(10)];
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


// Only use for the calculate of E!
function recursiveItemDepth(i) =
  i == len(ITEMS) ? 0 : itemDepth(i) + recursiveItemDepth(i + 1);

// Extra mm per item section so we evenly get to MIN_BACK_GAP.
E = (TOTAL_D - FIRST_WALL_D - recursiveItemDepth(0) - MIN_BACK_GAP) / len(ITEMS);
assert(E >= 0, str(
  "Too many/deep items defined for EXPANSION = ", EXPANSION, ", TRAY = ", TRAY));

difference() {
  union() {
    difference() {
      // Full wall.
      sideRoundedCube(TOTAL_W, TOTAL_D, TOTAL_H, ROUNDED_CORNER);

      // Cut out inner section.
      translate([WALL_D, FIRST_WALL_D, BOTTOM_H])
      cube([
        TOTAL_W - WALL_D * 2,
        TOTAL_D - WALL_D - FIRST_WALL_D,
        // The .1 sticks out the top.
        TOTAL_H - BOTTOM_H + .1]);
    };

    // Optional divider before first card holder.
    if (ITEMS[0][P_I_TYPE] == I_CARD_HOLDER) {
      firstNumCards = ITEMS[0][P_CH_NUM_CARDS];
      firstExtra = min(
        (CARD_D * firstNumCards * sin(ANGLE)) / tan(90 - ANGLE),
        SPILL_Z * tan(ANGLE)
      );

      translate([WALL_D, 0, BOTTOM_H])
      difference() {
        union() {
          // The divider itself.
          translate([0, FIRST_WALL_D - DIV_D - firstExtra, 0])
          card_divider();

          difference() {
            // The first wall at its full thickness.
            translate([0, 0, 0])
            cube([INNER_WIDTH, WALL_D, TOTAL_H - BOTTOM_H]);

            // Cuts out the bottom of the first wall under the divider.
            translate([
              0,
              FIRST_WALL_D + CARD_ANGLED_D * firstNumCards - firstExtra,
              0])
            rotate([-ANGLE, 0, 0])
            translate([0, -CARD_D * firstNumCards, -TOTAL_H])
            cube([INNER_WIDTH, CARD_D * firstNumCards, TOTAL_H * 2]);
          };
        };

        // Cuts out the divider in front of the tray.
        translate([-INNER_WIDTH, -INNER_WIDTH, -.1])
        cube([INNER_WIDTH * 4, INNER_WIDTH, TOTAL_H + .2]);
      };
    }

    // All the items.
    translate([WALL_D, FIRST_WALL_D, BOTTOM_H])
    recusiveModelItem(0);

//    if (SPECIAL == false) {
//      // Back cap rear
//      CAP_R = 10;
//      translate([0, TOTAL_D - WALL_D - CAP_R, CAP_R + BOTTOM_H])
//      rotate([0, 90, 0])
//      cylCap(TOTAL_W, CAP_R, 180);
//
//
//      // Card holders.
//      difference() {
//        translate([WALL_D, 0, BOTTOM_H])
//        card_holder(0, FIRST_WALL_D - FIRST_EXTRA);
//
//        // Cut off the front.
//        translate([0, FIRST_WALL_D - TOTAL_W, 0])
//        cube([TOTAL_W, TOTAL_W, TOTAL_H]);
//      };
//    } else if (SPECIAL == "renaissance") {
//      INNER_H = 25 - BOTTOM_H;
//      INNER_D = TOTAL_D - 2 * WALL_D;
//      CAP_R = 6.5;
//
//      MAT_D = 1.16666666667;
//      MAT_ANGLE = 49;
//      MAT_ANGLED_D = MAT_D / cos(MAT_ANGLE);
//      MAT_CNT = 7; // 6 + some wiggle room
//      MAT_W = 128 + 4;
//      MAT_H = 84;
//      MAT_X_PAD = 0;
//      MAT_Y_PAD = 12;
//
//      translate([WALL_D, WALL_D, BOTTOM_H])
//      difference() {
//        // Middle bottom
//        color("red", 0.25)
//        cube([INNER_WIDTH, INNER_D, TOTAL_H - BOTTOM_H]);
//
//        color("blue", 0.25)
//        union() {
//          // Major bowl indentation
//          translate([0, 0, INNER_H])
//          bowlCube(INNER_WIDTH, INNER_D, INNER_H, CAP_R);
//
//          TRAY_BOWL_R = 5;
//
//          // Coins bowl
//          COIN_B_W = 45;
//          COIN_B_D = 45;
//          COIN_B_H = 20;
//          COIN_B_Y = MAT_Y_PAD + MAT_W + 32;
//          translate([(INNER_WIDTH - COIN_B_W) / 2, COIN_B_Y, INNER_H - COIN_B_H])
//          bowlCube(COIN_B_W, COIN_B_D, INNER_H, TRAY_BOWL_R);
//
//          // Cubes bowl
//          CUBES_B_W = 45;
//          CUBES_B_D = 35;
//          CUBES_B_H = 20;
//          CUBES_B_Y = COIN_B_Y + COIN_B_D + 14;
//          translate([(INNER_WIDTH - CUBES_B_W) / 2, CUBES_B_Y, INNER_H - CUBES_B_H])
//          bowlCube(CUBES_B_W, CUBES_B_D, INNER_H, TRAY_BOWL_R);
//
//          matTotalD = MAT_D * MAT_CNT;
//          matAngledTotalD = MAT_ANGLED_D * MAT_CNT;
//
//          translate([MAT_X_PAD, MAT_Y_PAD, .05])
//          roundedSlot(MAT_D * MAT_CNT, MAT_W, INNER_H, MAT_ANGLE, /* smoothR= */ 5);
//        };
//      };
//    }
  };

  // Splits the thing in half.
//  if (SPLIT) {
//    maybe_invert()
//    holder_mask(0, FIRST_WALL_D - FIRST_EXTRA);
//  }
};

module recusiveModelItem(i) {
  if (i < len(ITEMS)) {
    item = ITEMS[i];
    if (item[P_I_TYPE] == I_CARD_HOLDER) {
      holder(i);
    }

    translate([0, itemDepth(i) + E])
    recusiveModelItem(i + 1);
  }
}

//module maybe_invert() {
//  if (ONLY_FRONT) {
//    difference() {
//      cube([TOTAL_W, TOTAL_D, TOTAL_H]);
//      children();
//    };
//  } else {
//    children();
//  }
//}

//module holder_mask(i, cur_d) {
//  if (i < len(HOLDERS)) {
//    numCards = HOLDERS[i];
//    depth = holderDepth(numCards);
//
//    translate([0, cur_d, 0]) {
//      if (i == SPLIT_AFTER - 1) {
//        nextCardsZ = min(MIN_CARDS, HOLDERS[i + 1]) * CARD_D * sin(ANGLE);
//        nextCardsY = nextCardsZ / tan(90 - ANGLE);
//
//        topCardsZ = 6.5 * CARD_D * sin(ANGLE);
//        topCardsY = TOTAL_H * tan(ANGLE) - topCardsZ / tan(90 - ANGLE);
//
//        difference() {
//          union() {
//            translate([0, depth - DIV_D / 2 - 50, 0])
//            cube([TOTAL_W, nextCardsY + 50, nextCardsZ + BOTTOM_H]);
//
//            translate([0, depth - DIV_D / 2, BOTTOM_H])
//            rotate([-ANGLE, 0 ,0])
//            translate([0, -TOTAL_D, -TOTAL_H * 4])
//            cube([TOTAL_W, TOTAL_D, TOTAL_H * 8]);
//          };
//
//          translate([0, depth - DIV_D / 2 + topCardsY, TOTAL_H - topCardsZ + BOTTOM_H])
//          cube([TOTAL_W, 10, topCardsZ - BOTTOM_H]);
//        };
//      }
//    }
//
//    holder_mask(i + 1, cur_d + depth);
//  }
//};

module holder(i) {
  numCards = ITEMS[i][P_CH_NUM_CARDS];
  clipFront = shouldClipCardHolderFront(i);

  //extraSpillD

  difference() {
    translate([0, clipFront ? -cardHolderSpillFrontD(i): 0, 0]) {
      //color("#F008")
      difference() {
        // A big cube for the spill-top.
        translate([0, numCards * CARD_ANGLED_D + E, 0])
        rotate([180 - ANGLE, 0, 0])
        cube([INNER_WIDTH, CARD_D * (numCards * CARD_ANGLED_D + E) / CARD_ANGLED_D, INNER_WIDTH]);

        union() {
          // Spill top
          if (numCards > MIN_CARDS) {
            translate([-INNER_WIDTH, -INNER_WIDTH, SPILL_Z])
            cube([INNER_WIDTH * 4, INNER_WIDTH * 4, INNER_WIDTH]);
          }

          // Under the spill
          translate([-INNER_WIDTH, -INNER_WIDTH, -INNER_WIDTH])
          cube([INNER_WIDTH * 4, INNER_WIDTH * 4, INNER_WIDTH]);
        }
      };

      //color("#0F08")
      translate([0, numCards * CARD_ANGLED_D + E, 0])
      card_divider();
    };

    if (clipFront) {
      translate([-INNER_WIDTH, -INNER_WIDTH, -INNER_WIDTH])
      cube([INNER_WIDTH * 4, INNER_WIDTH, INNER_WIDTH * 4]);
    }
  };
}

module card_divider() {
  // Card divider.
  translate([INNER_WIDTH, 0, 0])
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
          [INNER_WIDTH, 0, 0], // 4
          [INNER_WIDTH, -DIV_D , 0], // 5
          [INNER_WIDTH, -DIV_BACK_Y, DIV_BACK_BOT_Z], // 6
          [INNER_WIDTH, -DIV_BACK_Y, DIV_H], // 7
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
          cylinder(INNER_WIDTH, DIV_CAP_R, DIV_CAP_R);

          rotate([0, 90, 0])
          translate([-DIV_CAP_R*1.25, 0, -1])
          cube([DIV_CAP_R * 2.5, DIV_CAP_R * 1.5, INNER_WIDTH * 2]);
        };
      };

    // Divider hole. 2.373
    translate([0, -DIV_D*2.3776, SPILL_Z])
    rotate([ANGLE - 90, 0, 0])
    difference() {
      //translate([INNER_WIDTH - HOLE_W / 2, -SPILL_Y*4, SPILL_Z])
      union() {
        translate([(INNER_WIDTH - HOLE_W) / 2, -DIV_L, 0])
        cube([HOLE_W, DIV_L, DIV_D]);

        translate([INNER_WIDTH - (INNER_WIDTH - HOLE_W) / 2 -.0001, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 0);
        
        translate([(INNER_WIDTH - HOLE_W) / 2-TOP_R, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 90);
      };

      union() {
        translate([(INNER_WIDTH - HOLE_W) / 2, -HOLE_R, 0])
        cylCap(DIV_D, HOLE_R, 270);

        translate([INNER_WIDTH - (INNER_WIDTH - HOLE_W) / 2 - HOLE_R, -HOLE_R, 0])
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

///**
// * @param {number} w Width
// * @param {number} d Depth
// * @param {number} h Height
// * @param {=number} or Outside radius
// * @param {=number} wt Wall thickness
// * @param {=number} bt Bottom thickness
// */
//module grippy_bowl(w, d, h, or = 10, wt = 5, bt = 2) {
//  ir = or - wt; // Inside radius
//  tr = wt / 2; // Top radius
//  gs = d / 5; // Grippy size
//
//  // Make the model easier to print by clipping the bottom.
//  botClipH = sin(25) * or;
//
//  // Outside shell
//  translate([0, 0, -botClipH])
//  difference() {
//    difference() {
//      bowlCube(w, d, botClipH + h - tr, or);
//
//      translate([wt, wt, botClipH + bt])
//      bowlCube(w - wt*2, d - wt*2, botClipH + h, ir);
//    };
//
//    cube([w, d, botClipH]);
//  };
//
//  translate([0, 0, h - tr]) {
//    translate([or, or, 0])
//    rotate([0, 0, 180])
//    rotate_extrude(angle = 90)
//    translate([or - tr, 0])
//    circle(tr);
//
//    translate([w - or, d - or, 0])
//    rotate_extrude(angle = 90)
//    translate([or - tr, 0])
//    circle(tr);
//
//    translate([or, d-or, 0])
//    rotate([0, 0, 90])
//    rotate_extrude(angle = 90)
//    translate([or - tr, 0])
//    circle(tr);
//
//    translate([w-or, or, 0])
//    rotate([0, 0, 270])
//    rotate_extrude(angle = 90)
//    translate([or - tr, 0])
//    circle(tr);
//
//
//    translate([or, tr, 0])
//    rotate([0, 90, 0])
//    cylinder(w - or * 2, tr, tr);
//
//    translate([or, d - tr, 0])
//    rotate([0, 90, 0])
//    cylinder(w - or * 2, tr, tr);
//
//    translate([tr, or, 0])
//    rotate([-90, 0, 0])
//    cylinder(d - or * 2, tr, tr);
//
//    translate([w - tr, or, 0])
//    rotate([-90, 0, 0])
//    cylinder(d - or * 2, tr, tr);
//  };
//
//  translate([tr, d / 2, h - tr])
//  rotate([90, 0, 90]) {
//    cylinder(wt, gs, gs, center = true);
//    rotate_extrude(angle = 180)
//    translate([gs, 0])
//    circle(tr);
//  };
//}

module shearAlongZ(p) {
  multmatrix([
    [1, 0, p.x / p.z, 0],
    [0, 1, p.y / p.z, 0],
    [0, 0, 1,         0]
  ])
  children();
}