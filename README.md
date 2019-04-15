# RRT-star
RRT star motion planning

this is a matlab implementation of RRT* algorithm which is an "enhanced" version of RRT.

in addition to RRT, for each random point x_rand, the algorithm finds all the others points x_near in the tree that are within a circle of radius r
from the random point and removes redundant edges. (look in code for more detail)

example run:

the lines in the color magneta represent obstacles.
the black lines represent the created rapidly exploring tree.
the red line is the final path from start point to end point.


![alt text](https://raw.githubusercontent.com/TamerMograbi/RRT-star/master/RRTstartExample.png)

