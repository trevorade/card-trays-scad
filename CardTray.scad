use <RoundedCube.scad>;
use <bezier.scad>;

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
EXPANSION = BASE_2E;
// Which tray to print (1-4).
TRAY = 3;
// What part of the model to print.
PRINT = "all";  // "all", "front", "back"
// Only models a single bucket corresponding to an item index (starting with 1).
// `false` to print the tray as per normal
ONLY_BUCKET = false;
// Whether the card holders should engrave identifying text for card piles.
ENGRAVE_CARD_HOLDER_TEXT = true;
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
// Card-holder angle.
ANGLE = 39;
// Total tray width. 72 is used for Dominion trays.
TOTAL_W = 72 - 1/4;
// Total tray depth. 288 is used for Dominion trays.
TOTAL_D = 288 - 1/2;

// Vertical gap between top of wall and top of card divider.
DIV_GAP_H = 1.8;
// Divider wall depth. This is the literal depth of the angled piece.
DIV_D = 6;
// Divider hole radius.
HOLE_R = 12;
// The divider hole width in relation to the total divider width
HOLE_SCALE_W = .59;
// The divider hole height in relation to the angled divider height
HOLE_SCALE_H = .71;
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

CARD_ANGLED_D = CARD_D / sin(ANGLE);
SPILL_Z = CARD_D * MIN_CARDS * cos(ANGLE);
INNER_W = TOTAL_W - WALL_D * 2;
// Does not take into account front wall depth.
INNER_D = TOTAL_D - WALL_D * 2;
HOLE_W = INNER_W * HOLE_SCALE_W;
DIV_H = TOTAL_H - BOTTOM_H - DIV_GAP_H;

// "Classes" for various types of tray items.

// Just lists with some magic numbers/indices referenced by index constants.
// P_ is a parameter index constant.
// I_ identifies the "class" of item.

// All item lists start with the item type parameter.
P_I_TYPE = 0;
P_I_SPLIT_AFTER = 1;

// Makes an item trigger a split after it.
function splitBefore(item) =
  concat(item[P_I_TYPE], true, [for (i = [2 : len(item)]) item[i]]);

// Item Card Holder
I_CARD_HOLDER = 1;
P_CH_NUM_CARDS = 2;
P_CH_INITIALS = 3;
function iCH(numCards, initials = []) = [I_CARD_HOLDER, false, numCards, initials];

function shouldClipCardHolderFront(i) =
  i == 0 || ITEMS[i - 1][P_I_TYPE] != I_CARD_HOLDER;

function cardHolderSpillH(i) =
  let (numCards = ITEMS[i][P_CH_NUM_CARDS])
    numCards > MIN_CARDS ? SPILL_Z : CARD_D * numCards * cos(ANGLE);

function cardHolderSpillFrontD(i) =
  cardHolderSpillH(i) / tan(ANGLE);

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

// Items that will be included in the model tray. Back to front.
EXPANSION_TRAY_ITEMS = [
  // BASE_2E tray 1
  [
    iCH(10, ["A"]),
    iCH(10, ["Ba"]),
    iCH(10, ["Bu"]),
    iCH(10, ["Ce"]),
    splitBefore(iCH(10, ["Ch"])),
    iCH(10, ["CR"]),
    iCH(10, ["F"]),
    iCH(12, ["G"]),
    iCH(10, ["H"]),
    iCH(10, ["La"]),
  ],
  // BASE_2E tray 2
  [
    iCH(10, ["Li"]),
    iCH(10, ["Ma"]),
    iCH(10, ["Me"]),
    iCH(10, ["Mi"]),
    splitBefore(iCH(10, ["Mi"])),
    iCH(10, ["Mo"]),
    iCH(10, ["Mo"]),
    iCH(10, ["P"]),
    iCH(10, ["R"]),
    iCH(10, ["Se"]),
  ],
  // BASE_2E tray 3
  [
    iCH(10, ["Sm"]),
    iCH(10, ["TR"]),
    iCH(10, ["Va"]),
    iCH(10, ["Vi"]),
    iCH(10, ["Wi"]),
    iCH(10, ["Wo"]),
    splitBefore(iCH(12, ["P"])),
    iCH(12, ["D"]),
    iCH(24, ["E"]),
  ],
  // BASE_2E tray 4
  [
    iCH(24, ["Ra"]),
    iCH(30, ["Cu"]),
    splitBefore(iCH(30, ["G"])),
    iCH(40, ["S"]),
    iCH(60, ["C"]),
  ],
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
  [
    iCH(10, ["Al"]),
    iCH(10, ["Ar"]),
    iCH(10, ["BM"]),
    iCH(10, ["BC"]),
    iCH(10, ["Be"]),
    splitBefore(iCH(10, ["Ca"])),
    iCH(10, ["Co"]),
    iCH(10, ["Co"]),
    iCH(10, ["Cu"]),
    iCH(10, ["DC"]),
    iCH(12, ["Fe"]),
  ],
  // DARK_AGES tray 2
  [
    iCH(10, ["Fo"]),
    iCH(10, ["Fo"]),
    iCH(10, ["G"]),
    iCH(20, ["He", "M"]),
    splitBefore(iCH(10, ["HG"])),
    iCH(10, ["I"]),
    iCH(10, ["JD"]),
    iCH(10, ["K"]),
    iCH(10, ["Ma"]),
    iCH(10, ["MS"]),
  ],
  // DARK_AGES tray 3
  [
    iCH(10, ["My"]),
    iCH(10, ["Pi"]),
    iCH(10, ["PH"]),
    iCH(10, ["Pr"]),
    splitBefore(iCH(20, ["Ra"])),
    iCH(10, ["Re"]),
    iCH(10, ["Ro"]),
    iCH(10, ["Sa"]),
    iCH(10, ["Sc"]),
    iCH(10, ["Sq"]),
    iCH(10, ["St"]),
  ],
  // DARK_AGES tray 4
  [
    iCH(20, ["U", "M"]),
    iCH(10, ["V"]),
    iCH(10, ["WM"]),
    splitBefore(iCH(35, ["Ra"])),
    iCH(15, ["Sp"]),
    iCH(18, ["Sh"]),
    iCH(50, ["Ru"]),
  ],
  undef, // GLDS_AND_CRNCP tray 1
  undef, // GLDS_AND_CRNCP tray 2
  undef, // GLDS_AND_CRNCP tray 3
  undef, // GLDS_AND_CRNCP tray 4
  undef, // ADVENTURES tray 1
  undef, // ADVENTURES tray 2
  undef, // ADVENTURES tray 3
  undef, // ADVENTURES tray 4
  // EMPIRES tray 1
  [
    iCH(10, ["A"]),
    iCH(10, ["Ca"]),
    iCH(12, ["Ca"]),
    iCH(10, ["Ca", "R"]),
    splitBefore(iCH(10, ["CR"])),
    iCH(10, ["Ch"]),
    iCH(10, ["CQ"]),
    iCH(10, ["Cr"]),
    iCH(10, ["E", "P"]),
    iCH(10, ["En"]),
  ],
  // EMPIRES tray 2
  [
    iCH(10, ["En"]),
    iCH(10, ["FM"]),
    iCH(10, ["Fo"]),
    iCH(10, ["G", "F"]),
    splitBefore(iCH(10, ["G"])),
    iCH(10, ["L"]),
    iCH(10, ["O"]),
    iCH(10, ["P", "E"]),
    iCH(10, ["RB"]),
    iCH(10, ["S"]),
  ],
  // EMPIRES tray 3
  [
    iCH(10, ["S", "BV"]),
    iCH(10, ["T"]),
    iCH(10, ["V"]),
    iCH(10, ["WH"]),
    splitBefore(iCH(24)),
    iCH(24, ["R"]),
    iCH(21, ["L"]),
    iCH(13, ["E"]),
  ],
  // EMPIRES tray 4
  [
    iTB(45, 45, 23),
    iTB(45, 45, 23),
    splitBefore(iTB(45, 45, 23)),
    iTB(45, 45, 23),
  ],
  undef, // NOCTURNE tray 1
  undef, // NOCTURNE tray 2
  undef, // NOCTURNE tray 3
  undef, // NOCTURNE tray 4
  // RENAISSANCE tray 1
  [
    iCH(10, ["AT"]),
    iCH(12, ["BG", "H", "L"]),
    iCH(10, ["CS"]),
    iCH(10, ["D"]),
    splitBefore(iCH(10, ["E"])),
    iCH(11, ["FB", "F"]),
    iCH(10, ["H"]),
    iCH(10, ["Im"]),
    iCH(10, ["In"]),
    iCH(10, ["L"]),
  ],
  // RENAISSANCE tray 2
  [
    iCH(10, ["MV"]),
    iCH(10, ["OW"]),
    iCH(10, ["Pa"]),
    iCH(10, ["Pr"]),
    splitBefore(iCH(10, ["Re"])),
    iCH(10, ["Re"]),
    iCH(10, ["Sc"]),
    iCH(10, ["Sc"]),
    iCH(10, ["Sc"]),
    iCH(10, ["Se"]),
  ],
  // RENAISSANCE tray 3
  [
    iCH(10, ["SM"]),
    iCH(10, ["Sp"]),
    iCH(11, ["Sw", "TC"]),
    iCH(11, ["T", "K"]),
    iCH(10, ["V"]),
    splitBefore(iCH(25)), // Empty Gap
    iCH(25, ["R"]),
    iCH(20, ["P"]),
  ],
  // RENAISSANCE tray 4
  [
    iTB(50, 40, 20),  // Cubes
    iTB(60, 40, 23),  // Coins
    splitBefore(iMH(84, 7/6, 127, 6)), // Mats
  ],
  undef, // MENAGERIE tray 1
  undef, // MENAGERIE tray 2
  undef, // MENAGERIE tray 3
  undef, // MENAGERIE tray 4
  // ALLIES tray 1
  [
    iCH(10, ["Ba"]),
    iCH(10, ["Ba"]),
    iCH(10, ["Br"]),
    iCH(10, ["CC"]),
    splitBefore(iCH(10, ["Ca"])),
    iCH(10, ["Co"]),
    iCH(10, ["Co"]),
    iCH(10, ["E"]),
    iCH(10, ["Ga"]),
    iCH(10, ["Gu"]),
    iCH(10, ["Hi"]),
  ],
  // ALLIES tray 2
  [
    iCH(10, ["Hu"]),
    iCH(10, ["Im"]),
    iCH(10, ["In"]),
    iCH(10, ["Ma"]),
    splitBefore(iCH(10, ["MC"])),
    iCH(10, ["Mo"]),
    iCH(10, ["RG"]),
    iCH(10, ["Se"]),
    iCH(10, ["Sk"]),
    iCH(10, ["Sp"]),
    iCH(10, ["Sw"]),
  ],
  // ALLIES tray 3
  [
    iCH(10, ["Sy"]),
    iCH(10, ["T"]),
    iCH(10, ["U"]),
    splitBefore(iCH(16, ["A"])),
    iCH(16, ["C"]),
    iCH(16, ["F"]),
    iCH(16, ["O"]),
    iCH(16, ["T"]),
    iCH(16, ["W"]),
  ],
  // ALLIES tray 4
  [
    iCH(31, ["R"]),
    iCH(23, ["A"]),
  ],
  undef, // SEASIDE_2E tray 1
  undef, // SEASIDE_2E tray 2
  undef, // SEASIDE_2E tray 3
  undef, // SEASIDE_2E tray 4
][EXPANSION * 4 + TRAY - 1];
assert(EXPANSION_TRAY_ITEMS != undef, str(
  "Sorry. No presets for EXPANSION = ", EXPANSION,
  ", TRAY = ", TRAY,
  ". Consider defining a preset."));

// We use front to back when rendering...
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];
ITEMS = reverse(EXPANSION_TRAY_ITEMS);

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
  "Too many/deep items defined for EXPANSION = ", EXPANSION, ", TRAY = ", TRAY, ", E = ", E));

echo("Extra space for items: ", E);

if (ONLY_BUCKET == false) {
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
          (CARD_D * firstNumCards * cos(ANGLE)) / tan(ANGLE),
          SPILL_Z * tan(90 - ANGLE)
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
              rotate([ANGLE - 90, 0, 0])
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
    if (PRINT == "front" || PRINT == "back") {
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
} else {
  item = ITEMS[len(ITEMS) - ONLY_BUCKET];
  grippy_bowl(item[P_TB_W], item[P_TB_D], item[P_TB_H]);
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
  if (PRINT == "front") {
    difference() {
      cube([TOTAL_W, TOTAL_D, TOTAL_H]);
      children();
    };
  } else {
    children();
  }
}

module holderMask() {
  topCardsZ = 8.8 * CARD_D * sin(ANGLE);
  topCardsY = TOTAL_H * tan(90 - ANGLE) - topCardsZ / tan(ANGLE);

  difference() {
    union() {
      translate([0, -DIV_D / 2, BOTTOM_H])
      rotate([ANGLE - 90, 0 ,0])
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
        rotate([ANGLE + 90, 0, 0])
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
      card_divider(ITEMS[i][P_CH_INITIALS]);
    };

    if (clipFront) {
      translate([-INNER_W, -INNER_W, -INNER_W])
      cube([INNER_W * 4, INNER_W, INNER_W * 4]);
    }
  };
}

module card_divider(initials = []) {
  divBackY = DIV_H / tan(ANGLE);
  divBackH = DIV_D * tan(ANGLE);
  divLen = DIV_H / sin(ANGLE);

  xOff = DIV_D / 3;
  controlYOff = xOff * tan(ANGLE);
  smoothPoints = bezPoints([0, 0], [xOff, controlYOff], [xOff, divBackH + controlYOff], [0, divBackH]);

  // The smooth top additional length.
  smoothLen = max([for (p = smoothPoints) (p.y - divBackH) * sin(ANGLE) + p.x * cos(ANGLE)]);

  difference() {
    union() {
      // Simplest card divider.
      polyhedron(
        // Point image: https://photos.app.goo.gl/Lu6kYR7UExFjoFv78
        points = [
          [0, 0, 0], // 0
          [0, divBackY, DIV_H], // 1
          [0, divBackY, DIV_H - divBackH], // 2
          [0, DIV_D , 0], // 3
          [INNER_W, 0, 0], // 4
          [INNER_W, DIV_D , 0], // 5
          [INNER_W, divBackY, DIV_H - divBackH], // 6
          [INNER_W, divBackY, DIV_H], // 7
        ],
        faces = [
          [0, 1, 2, 3],
          [4, 5, 6, 7],
          [0, 4, 7, 1],
          [1, 7, 6, 2],
          [6, 5, 3, 2],
          [0, 3, 5, 4],
        ]);

      // Smooth top edge
      translate([0, divBackY, DIV_H - divBackH])
      rotate([90, 0, 90])
      linear_extrude(height = INNER_W)
      polygon(points = smoothPoints);
    };

    union() {
      if (ENGRAVE_CARD_HOLDER_TEXT && len(initials) > 0) {
        sideW = (INNER_W - HOLE_W) / 2;
        textSize = .76 * sideW;
        textGap = cos(ANGLE) * 1.3;
        textIndent = 1;

        translate([sideW / 2, divBackY, DIV_H - textIndent])
        shearText(ANGLE)
        scale([1, cos(ANGLE), 1])
        linear_extrude(10)
        translate([0, -textGap * 1.75])
        for(i = [0 : len(initials) - 1]) {
          scale([len(initials[i]) > 1 ? .73 : 1, 1])
          translate([0, -i * (textGap + textSize)])
          text(initials[i], size = textSize, halign = "center", valign = "top", font = "Lucida Sans Typewriter:style=Bold");
        }
      }

      divSmoothedLen = divLen + smoothLen + .01;
      holeH = divSmoothedLen * HOLE_SCALE_H;
      rotate([ANGLE, 0, 0])
      translate([(INNER_W - HOLE_W) / 2, divSmoothedLen - holeH, -HOLE_W / 2])
      union() {
        oneSideRoundedCube(HOLE_W, holeH, HOLE_W, HOLE_R);

        translate([HOLE_W, holeH - TOP_R, 0])
        cylCap(HOLE_W, TOP_R, 270);

        translate([-TOP_R, holeH - TOP_R, 0])
        cylCap(HOLE_W, TOP_R, 180);
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

module shearText(ang) {
  t = tan(ang);
  multmatrix([[1, 0, 0, 0],
              [0, 1, 0, 0],
              [0, t, 1, 0]])
  children();
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
