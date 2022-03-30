use <RoundedCube.scad>;

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
EXPANSION = RENAISSANCE;
// Which tray to print (1-4).
TRAY = 1;
// Only models the front half of the tray. Model the back with `false`.
ONLY_FRONT = true;
// Only models a single bucket corresponding to an item index (starting with 0).
// `false` to print the tray as per normal
ONLY_BUCKET = false;
// Overall quality. Use 36 or higher when rendering before exporting the STL.
$fn = 36;


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

// Overall tray height to the top of the side walls.
TOTAL_H = 40;
// Inner tray height to the flat surface (for mats + token buckets).
INNER_H = 25;
// Rounded edges around inner radius.
INNER_R = 3;
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

// Mat holder rounded edge size.
MH_SMOOTH_R = 5;
// Mat holder padding inside the slot.
MH_PAD = 1;

// Token bucket extra padding inside the token bucket slot.
TB_PAD = 1;
// How much the token bucket will overflow over the top.
TB_TOP_OVERFLOW = 5;

CARD_ANGLED_D = CARD_D / cos(ANGLE);
SPILL_Z = CARD_D * MIN_CARDS * sin(ANGLE);
INNER_W = TOTAL_W - WALL_D * 2;
// Does not take into account front wall depth.
INNER_D = TOTAL_D - WALL_D * 2;
HOLE_W = INNER_W * HOLE_SCALE;

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
  concat(item[P_I_TYPE], true, [for (i = [2 : len(item)]) item[i]]);

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

// Mats are stored on their side with the mat height being the overall depth of
// the holder.
I_MAT_HOLDER = 2;
P_MH_MAT_W = 2; // The middlest dimension of the mat
P_MH_MAT_D = 3; // The smallest dimension of the mat
P_MH_MAT_H = 4; // The largest dimension of the mat
P_MH_NUM_MATS = 5;
function iMH(matW, matD, matH, numMats) = [I_MAT_HOLDER, false, matW, matD, matH, numMats];

// Item Token Bucket
I_TOKEN_BUCKET = 3;
P_TB_W = 2;
P_TB_D = 3;
P_TB_H = 4;
function iTB(width, depth, height) = [I_TOKEN_BUCKET, false, width, depth, height];

// Gets the depth of an item.
function itemDepth(i) =
  let (item = ITEMS[i]) (
    item[P_I_TYPE] == I_CARD_HOLDER ?
      let (numCards = item[P_CH_NUM_CARDS],
           clipFront = shouldClipCardHolderFront(i)) (
        (clipFront ? -cardHolderSpillFrontD(i) : 0) + numCards * CARD_ANGLED_D + DIV_D
      )
      :
    item[P_I_TYPE] == I_MAT_HOLDER ?
      MH_PAD * 2 + item[P_MH_MAT_H]
      :
    item[P_I_TYPE] == I_TOKEN_BUCKET ?
      TB_PAD * 2 + item[P_TB_D]
      :
      0
  );

function getSplitIndex(i = 0) =
  i >= len(ITEMS) ? undef : ITEMS[i][P_I_SPLIT_AFTER] ? i : getSplitIndex(i + 1);

function getDepthToIndex(i) =
  itemDepth(i) + (i >= 0 ? getDepthToIndex(i - 1) : 0);

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
  undef, // BASE_2E tray 1
  undef, // BASE_2E tray 2
  undef, // BASE_2E tray 3
  undef, // BASE_2E tray 4
  undef, // INTRIGUE_2E tray 1
  undef, // INTRIGUE_2E tray 2
  undef, // INTRIGUE_2E tray 3
  undef, // INTRIGUE_2E tray 4
  undef, // SEASIDE_1E tray 1
  undef, // SEASIDE_1E tray 2
  undef, // SEASIDE_1E tray 3
  undef, // SEASIDE_1E tray 4
  undef, // PROSPERITY tray 1
  undef, // PROSPERITY tray 2
  undef, // PROSPERITY tray 3
  undef, // PROSPERITY tray 4
  undef, // HINTERLANDS tray 1
  undef, // HINTERLANDS tray 2
  undef, // HINTERLANDS tray 3
  undef, // HINTERLANDS tray 4
  // DARK_AGES tray 1
  [iCH(12), iCH(10), iCH(11), iCH(10), iCH(10), iCH(10), splitAfter(iCH(10)), iCH(10), iCH(10), iCH(10), iCH(10)],
  // DARK_AGES tray 2
  [iCH(10), iCH(10), iCH(11), iCH(10), iCH(10), splitAfter(iCH(10)), iCH(20), iCH(10), iCH(10), iCH(10)],
  undef, // DARK_AGES tray 3
  undef, // DARK_AGES tray 4
  undef, // GLDS_AND_CRNCP tray 1
  undef, // GLDS_AND_CRNCP tray 2
  undef, // GLDS_AND_CRNCP tray 3
  undef, // GLDS_AND_CRNCP tray 4
  undef, // ADVENTURES tray 1
  undef, // ADVENTURES tray 2
  undef, // ADVENTURES tray 3
  undef, // ADVENTURES tray 4
  undef, // EMPIRES tray 1
  undef, // EMPIRES tray 2
  undef, // EMPIRES tray 3
  undef, // EMPIRES tray 4
  undef, // NOCTURNE tray 1
  undef, // NOCTURNE tray 2
  undef, // NOCTURNE tray 3
  undef, // NOCTURNE tray 4
  // RENAISSANCE tray 1
  [iCH(10), iCH(10), iCH(10), iCH(10), iCH(11), splitAfter(iCH(10)), iCH(10), iCH(10), iCH(12), iCH(10)],
  // RENAISSANCE tray 2
  [iCH(10), iCH(10), iCH(10), iCH(10), iCH(10), splitAfter(iCH(10)), iCH(10), iCH(10), iCH(10), iCH(10)],
  undef, // RENAISSANCE tray 3
  // RENAISSANCE tray 4
  [splitAfter(iMH(84, 7/6, 127, 6)), iTB(60, 40, 25), iTB(60, 40, 25)],
  undef, // MENAGERIE tray 1
  undef, // MENAGERIE tray 2
  undef, // MENAGERIE tray 3
  undef, // MENAGERIE tray 4
  undef, // ALLIES tray 1
  undef, // ALLIES tray 2
  undef, // ALLIES tray 3
  undef, // ALLIES tray 4
  undef, // SEASIDE_2E tray 1
  undef, // SEASIDE_2E tray 2
  undef, // SEASIDE_2E tray 3
  undef, // SEASIDE_2E tray 4
][EXPANSION * 4 + TRAY - 1];
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

// At this time, only all-cards or all other stuff are supported
ALL_CARDS = ITEMS[0][P_I_TYPE] == I_CARD_HOLDER;

// Only use for the calculate of E!
function recursiveItemDepth(i) =
  i == len(ITEMS) ? 0 : itemDepth(i) + recursiveItemDepth(i + 1);

// Extra mm per item section so we evenly get to MIN_BACK_GAP.
E =
  ALL_CARDS ?
    (TOTAL_D - FIRST_WALL_D - recursiveItemDepth(0) - MIN_BACK_GAP) / len(ITEMS) :
    (TOTAL_D - WALL_D * 2 - INNER_R * 2 - recursiveItemDepth(0)) / len(ITEMS);
assert(E >= 0, str(
  "Too many/deep items defined for EXPANSION = ", EXPANSION, ", TRAY = ", TRAY));

if (false && ONLY_BUCKET == false) {
  difference() {
    union() {
      difference() {
        // Full wall.
        sideRoundedCube(TOTAL_W, TOTAL_D, TOTAL_H, ROUNDED_CORNER);

        // Cut out inner section.
        translate([WALL_D, ALL_CARDS ? FIRST_WALL_D : WALL_D, BOTTOM_H])
        cube([
          TOTAL_W - WALL_D * 2,
          TOTAL_D - WALL_D - (ALL_CARDS ? FIRST_WALL_D : WALL_D),
          // The .1 sticks out the top.
          TOTAL_H - BOTTOM_H + .1]);
      };

      // Optional divider before first card holder.
      if (ALL_CARDS) {
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
              cube([INNER_W, WALL_D, TOTAL_H - BOTTOM_H]);

              // Cuts out the bottom of the first wall under the divider.
              translate([
                0,
                FIRST_WALL_D + CARD_ANGLED_D * firstNumCards - firstExtra,
                0])
              rotate([-ANGLE, 0, 0])
              translate([0, -CARD_D * firstNumCards, -TOTAL_H])
              cube([INNER_W, CARD_D * firstNumCards, TOTAL_H * 2]);
            };
          };

          // Cuts out the divider in front of the tray.
          translate([-INNER_W, -INNER_W, -.1])
          cube([INNER_W * 4, INNER_W, TOTAL_H + .2]);
        };

        // All the items.
        translate([WALL_D, FIRST_WALL_D, BOTTOM_H])
        recusiveModelItem(0);

        // Rounded cap at end after last card holder.
        CAP_R = 10;
        translate([0, TOTAL_D - WALL_D - CAP_R, CAP_R + BOTTOM_H])
        rotate([0, 90, 0])
        cylCap(TOTAL_W, CAP_R, 180);
      } else {
        // For mat holders + trays, add a rounded edge on the top.
        translate([WALL_D, WALL_D, BOTTOM_H])
        difference() {
          // This should just be connected to the front and back wall with depth INNER_R.
          cube([INNER_W, INNER_D, TOTAL_H - BOTTOM_H]);

          union() {
            translate([0, 0, INNER_H])
            bowlCube(INNER_W, INNER_D, TOTAL_H, INNER_R);

            // All the items.
            recusiveModelItem(0);
          }
        };
      }
    };

    // Splits the thing in half.
    if (ONLY_FRONT == true || ONLY_FRONT == false) {
      splitIndex = getSplitIndex();
      splitY = FIRST_WALL_D + getDepthToIndex(splitIndex) + (splitIndex + 1) * E;

      maybe_invert()
      translate([0, splitY, 0]) {
        if (ITEMS[splitIndex][P_I_TYPE] == I_CARD_HOLDER) {
          holderMask();
        } else {
          translate([0, WALL_D - FIRST_WALL_D - TOTAL_D, 0])
          cube([TOTAL_D, TOTAL_D, TOTAL_D]);
        }
      };
    }
  };
} else if (false) {
  item = ITEMS[ONLY_BUCKET];
  grippy_bowl(item[P_TB_W], item[P_TB_D], item[P_TB_H]);
} else {
  card_divider();
}

// Iterative calculation of the necessary mat angle starting with a guess.
function calcMatHolderAngle(item, angleGuess = 45) =
  let (angle = acos(
                 (INNER_W - 2 * MH_PAD - item[P_MH_NUM_MATS] * item[P_MH_MAT_D] / sin(angleGuess)) /
                 item[P_MH_MAT_W]))
    abs(angle - angleGuess) <= 0.1 ? angle : calcMatHolderAngle(item, angle);

module recusiveModelItem(i) {
  if (i < len(ITEMS)) {
    item = ITEMS[i];

    if (item[P_I_TYPE] == I_CARD_HOLDER) {
      holder(i);
    } else {
      translate([0, E / 2, 0]) {
        if (item[P_I_TYPE] == I_MAT_HOLDER) {
          mhAngle = calcMatHolderAngle(item);
          roundedSlot(
            item[P_MH_MAT_D] * item[P_MH_NUM_MATS] + 2 * MH_PAD,
            item[P_MH_MAT_H] + 2 * MH_PAD,
            INNER_H + .05,
            mhAngle,
            MH_SMOOTH_R);
        } else if (item[P_I_TYPE] == I_TOKEN_BUCKET) {
          w = item[P_TB_W] + TB_PAD * 2;
          d = item[P_TB_D] + TB_PAD * 2;
          h = item[P_TB_H];
          translate([(INNER_W - w) / 2, 0, INNER_H - h + TB_TOP_OVERFLOW])
          grippyBowlHolder(w, d, h);
        }
      };
    }

    translate([0, itemDepth(i) + E])
    recusiveModelItem(i + 1);
  }
}

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

module holderMask() {
  topCardsZ = 6.5 * CARD_D * sin(ANGLE);
  topCardsY = TOTAL_H * tan(ANGLE) - topCardsZ / tan(90 - ANGLE);

  difference() {
    union() {
      translate([0, -DIV_D / 2, BOTTOM_H])
      rotate([-ANGLE, 0 ,0])
      translate([0, -TOTAL_D * 4, -TOTAL_H * 16])
      cube([TOTAL_W, TOTAL_D * 4, TOTAL_H * 62]);

      translate([0, -DIV_D / 2-1, 0])
      cube([TOTAL_W, 6, 5]);
    };

    translate([0, -DIV_D / 2 + topCardsY, 0])
    cube([TOTAL_W, 10, TOTAL_H]);
  };
};

module holder(i) {
  numCards = ITEMS[i][P_CH_NUM_CARDS];
  clipFront = shouldClipCardHolderFront(i);

  difference() {
    translate([0, clipFront ? -cardHolderSpillFrontD(i): 0, 0]) {
      difference() {
        // A big cube for the spill-top.
        translate([0, numCards * CARD_ANGLED_D + E, 0])
        rotate([180 - ANGLE, 0, 0])
        cube([INNER_W, CARD_D * (numCards * CARD_ANGLED_D + E) / CARD_ANGLED_D, INNER_W]);

        union() {
          // Spill top
          if (numCards > MIN_CARDS) {
            translate([-INNER_W, -INNER_W, SPILL_Z])
            cube([INNER_W * 4, INNER_W * 4, INNER_W]);
          }

          // Under the spill
          translate([-INNER_W, -INNER_W, -INNER_W])
          cube([INNER_W * 4, INNER_W * 4, INNER_W]);
        }
      };

      translate([0, numCards * CARD_ANGLED_D + E, 0])
      card_divider();
    };

    if (clipFront) {
      translate([-INNER_W, -INNER_W, -INNER_W])
      cube([INNER_W * 4, INNER_W, INNER_W * 4]);
    }
  };
}

module card_divider() {
  // Card divider.
  translate([INNER_W, 0, 0])
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
          [INNER_W, 0, 0], // 4
          [INNER_W, -DIV_D , 0], // 5
          [INNER_W, -DIV_BACK_Y, DIV_BACK_BOT_Z], // 6
          [INNER_W, -DIV_BACK_Y, DIV_H], // 7
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
        cylinder(INNER_W, DIV_CAP_R, DIV_CAP_R);

        // What is this for?
        rotate([0, 90, 0])
        translate([-DIV_CAP_R*1.25, 0, -1])
        cube([DIV_CAP_R * 2.5, DIV_CAP_R * 1.5, INNER_W * 2]);
      };
    };

    // I want to move this up a bit...
    // Divider hole. 2.373
    translate([0, -DIV_D*2.3776, SPILL_Z])
    rotate([ANGLE - 90, 0, 0])
    difference() {
      union() {
        translate([(INNER_W - HOLE_W) / 2, -DIV_L, 0])
        cube([HOLE_W, DIV_L, DIV_D]);

        translate([INNER_W - (INNER_W - HOLE_W) / 2 -.0001, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 0);

        translate([(INNER_W - HOLE_W) / 2-TOP_R, -DIV_L, 0])
        cylCap(DIV_D, TOP_R, 90);
      };

      union() {
        translate([(INNER_W - HOLE_W) / 2, -HOLE_R, 0])
        cylCap(DIV_D, HOLE_R, 270);

        translate([INNER_W - (INNER_W - HOLE_W) / 2 - HOLE_R, -HOLE_R, 0])
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

/**
 * @param {number} w Width
 * @param {number} d Depth
 * @param {number} h Height
 * @param {=number} or Outside radius
 * @param {=number} wt Wall thickness
 * @param {=number} bt Bottom thickness
 * @param {=number} gs Grippy size
 */
module grippy_bowl(w, d, h, or = 7, wt = 2 * .8, bt = 4 * .24, gs = 8.5) {
  ir = or - wt; // Inside radius
  tr = wt / 2; // Top radius
 
  // Make the model easier to print by clipping the bottom.
  botClipH = sin(25) * or;

  // Outside shell
  translate([0, 0, -botClipH])
  difference() {
    difference() {
      bowlCube(w, d, botClipH + h - tr, or);

      translate([wt, wt, botClipH + bt])
      bowlCube(w - wt*2, d - wt*2, botClipH + h, ir);
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

  difference() {
    translate([w / 2, tr, h - tr])
    rotate([90, 0, 0]) {
      cylinder(wt, gs, gs, center = true);

      rotate_extrude(angle = 180)
      translate([gs, 0])
      circle(tr);
    };

    translate([-w, -wt, 0])
    cube([w * 4, wt * 4, h - tr]);
  };
}

module grippyBowlHolder(w, d, h, or = 7) {
  // Make the model easier to print by clipping the bottom.
  botClipH = sin(25) * or;

  // Outside shell
  translate([0, 0, -botClipH])
  difference() {
    bowlCube(w, d, h, or);

    cube([w, d, botClipH]);
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
