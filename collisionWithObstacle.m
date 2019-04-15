%checks if line segment with start point a and end point b , collides with
% obstacle
%obstacele will be represented as a list of line segments
% for example [d,c,e,f,d] (start and end coordinates are same)
function colFound = collisionWithObstacle(a,b,obstacle)
    [rows,col] = size(obstacle);
    for i = 1:1:col-1
        c = [obstacle(1,i) ; obstacle(2,i)];
        d = [obstacle(1,i+1) ; obstacle(2,i+1)];
        if(collisionBetweenLines(a,b,c,d) == 1)
            colFound = 1;
            return;
        end
    end
    colFound = 0;
