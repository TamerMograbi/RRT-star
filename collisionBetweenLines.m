%a and b are start and end coordinates of a line segment
%c and d are start and end coordinates of another line segment
%function returns 1 if line segments collide and 0 if not
% coordinates are represtened in a column [x;y]
function colFound = collisionBetweenLines(a,b,c,d)
    
    %lines are parallel => no collision
    if abs(b-a) == abs(d-a)
        colFound = 0;
    end
    
    a_x = a(1); b_x = b(1); c_x = c(1); d_x = d(1);
    a_y = a(2); b_y = b(2); c_y = c(2); d_y = d(2);
    
    % now we write the sys of linear equations in matrix form
    
    A = [b_x-a_x , c_x-d_x ; b_y-a_y , c_y-d_y];
    B = [c_x-a_x;c_y-a_y];
    % solves Ax=B
    X = linsolve(A,B);
%     syms u;
%     solU = solve( a_y+u*(b_y-a_y) == c_y + (d_y-c_y)*((a_x + u*(b_x-a_x)-c_x)/(d_x-c_x)),u);
%     solV = (a_x+solU*(b_x-a_x)-c_x)/(d_x-c_x);
    u = X(1);
    v = X(2);
    if u >= 0 && u<=1 && v >=0 && v <=1
        colFound = 1;
    else
        colFound = 0;
    end
    
    
    
    