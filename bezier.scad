function bezCoord(t, n0, n1, n2, n3) = 
  n0 * pow((1 - t), 3) + 3 * n1 * t * pow((1 - t), 2) + 
  3 * n2 * pow(t, 2) * (1 - t) + n3 * pow(t, 3);

function bezPoint(t, p0, p1, p2, p3) = 
    [bezCoord(t, p0[0], p1[0], p2[0], p3[0]),
     bezCoord(t, p0[1], p1[1], p2[1], p3[1])];

function bezPoints(p0, p1, p2, p3, t_step = 0.05) = 
    [for(t = [0: t_step: 1]) bezPoint(t, p0, p1, p2, p3)];
