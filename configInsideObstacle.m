%a is a columnn vector [x;y]
%take random ray from a, if it intersects with an odd number of obstacle
%segments then it's inside the obstacle, else it is outside
function isInside = configInsideObstacle(a,obstacle)
    %a and b forms a horizental vector
    b = [a(1)+30;a(2)];
    [rows,cols] = size(obstacle);
    count = 0;
    for i = 1:1:cols-1
        c = [obstacle(1,i) ; obstacle(2,i)];
        d = [obstacle(1,i+1) ; obstacle(2,i+1)];
        if collisionBetweenLines(a,b,c,d) == 1
            count = count + 1;
        end
    end
    
    if mod(count,2) == 1
        isInside = 1;
    else
        isInside = 0;
    end