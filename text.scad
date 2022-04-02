A = -20;

shearAlongZ(A)
linear_extrude(10)
text("HELLO");

rotate([0, -A, 0])
color("pink")
translate([0, 0, -5])
cube([50, 10, 5]);


module shearAlongZ(ang) {
  multmatrix([
    [1,        0, 0, 0],
    [0,        1, 0, 0],
    [tan(ang), 0, 1, 0]
  ])
  children();
}