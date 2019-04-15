# RRT-star
RRT star motion planning

example run:

the lines in the color magneta represent obstacles.
the black lines represent the created rapidly exploring tree.
the red line is the final path from start point to end point.

![alt text](https://raw.githubusercontent.com/TamerMograbi/RRT-star/master/RRTstartExample.png)

using random uniform sampling, we choose a coordinates for a point and try to connect it to our current tree.
(which consists of only start point at first)
we try to connect this new point to the closest vertex in the tree. we are able to connect them only if the line
doesn't collide with any obstacles.
this is repeated until for example we reach a number of desired tree nodes.

finally we find the closest point to the end point and try to connect them and if we are able to then we have found a path.
(it's very unlikely that we don't get near the end point as we are sampling points uniformly)
this algorithm has a very high chance of finding a path if there is one.


this is a matlab implementation of RRT* algorithm which is an "enhanced" version of RRT.

in addition to RRT, for each random point x_rand, the algorithm finds all the others points x_near in the tree that are within a circle of radius r
from the random point and removes redundant edges. (look in code for more detail)






