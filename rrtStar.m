%there are more details on how to run code in the PDF

clear; %without this, you will get weird results in consecutive runs as
%previous worksapce variables will be used

warning off;


x_max = 500;
y_max = 500;

maxStep = 50;
maxNodes = 300;
r = 70;

figure(1)
axis([0 x_max 0 y_max])

obs = [2+3,5+3,3+3,2+3;3+3,4+3,5+3,3+3]; % just a random obstacle
obs = 50*obs; % scale obstacle for 1000 by 1000 axis (would be too small otherwise

obs2 = [1,2,4,3,2,1;2,1,2,4,1.5,2]; %another obstacle.
obs2 = 60*obs2;

%the above 2 obstacles will always show up

allObs{1} = obs;
allObs{2} = obs2;
%draw obstacles
for i=1:1:3
    line([obs(1,i);obs(1,i+1)], [obs(2,i);obs(2,i+1)], 'Color', 'm', 'LineWidth', 2);
    drawnow
    hold on
end

for i=1:1:length(obs2)-1
    line([obs2(1,i);obs2(1,i+1)], [obs2(2,i);obs2(2,i+1)], 'Color', 'm', 'LineWidth', 2);
    drawnow
    hold on
end

disp(['press Y if you want to add an obstacle' newline]);
%in case user wants to add obstacles using mouse
[~,~,buttonYN] = ginput(1); % we don't used first 2 variables so we replace with ~
%user will press Y if they want to add a new obstacle
yAscii = 121; %ascii number of character y
newObs = [];

while buttonYN == yAscii
    disp('keep using the left mouse click to create the obstacle');
    disp(['when done, click anything else and the last point will be connected with the first point in order to form obstacle' newline]);
    [x,y,~] = ginput(2);%we draw first line using x and y
    line(x, y, 'Color', 'm', 'LineWidth', 2);
    newObs = [x(1) x(2); y(1) y(2)];
    prevPoint = [x(2) , y(2)]; % this will be the start point of next line
    
    [x1,y1,button] = ginput(1);
    while button == 1 % 1 is for left mouse click
        newObs = [ newObs [x1;y1]];
        line([prevPoint(1), x1],[prevPoint(2);y1], 'Color', 'm', 'LineWidth', 2);
        prevPoint = [x1 , y1];
        [x1,y1,button] = ginput(1);%get next point
    end
    newObs = [ newObs [x(1);y(1)]]; % connect first and last points
    line([prevPoint(1), x(1)],[prevPoint(2);y(1)], 'Color', 'm', 'LineWidth', 2);
    allObs{length(allObs)+1} = newObs;%add newObs to the list of obstacles
    disp(['press Y if you want to start creating another obstacle' newline]);
    [~,~,buttonYN] = ginput(1); %if user presses y again then we add another obstacle
end

disp(['choose start and end points' newline]);
%only for xbox capture
%[d,f] = ginput(1);

%get start and end points
[x,y] = ginput(2);

%nodes is a struct that will hold each node
nodes(1).coord = [x(1);y(1)];
nodes(1).cost = 0; %cost will hold the distance from root to node
nodes(1).parent = 0; % parent will hold the parent of the current node
nodes(1).idx = 1; %the index of the node in the list. (so i don't have to send it to function separetly.

%show start and end points in red
plot(x(1),y(1),'r*')
plot(x(2),y(2),'r*')

%end point coordinates
x_end.coord = [x(2);y(2)];
x_end.cost = 0; %will bot be used but needed so we can put x_end in nodes

%disp('nodes(1).coord = ' + nodes(1).coord);

%this will hold the list of edges
edges = [];

%starts from 2 because we already filled nodes(1)
i = 2;

while i < maxNodes
    x_rand = [floor(rand(1)*x_max) ; floor(rand(1)*y_max)];
    
    nearest_idx = nearest(nodes, x_rand);
    x_new = steer(x_rand, nodes(nearest_idx).coord, maxStep);
    if collisionWithAllObs(nodes(nearest_idx).coord,x_new,allObs) == 0
        r_near_nodes = r_near(nodes, x_new, r);
        plot(x_new(1),x_new(2),'k*')
        
        x_min = nodes(nearest_idx);
        %current minimum cost
        cost_min = nodes(nearest_idx).cost + distance(nodes(nearest_idx).coord,x_new);
        
        %we search for an alternative path with less cost from one of the near nodes (in radius r
        %if we find such a path then we will choose an edge between the
        %approriate node in x_near and x_new instead of edge
        %(x_nearest,x_new)
        for i_near = 1:1:length(r_near_nodes)
            if collisionWithAllObs(r_near_nodes(i_near).coord,x_new,allObs) == 0 && (r_near_nodes(i_near).cost + distance(r_near_nodes(i_near).coord,x_new)) < cost_min
                x_min = r_near_nodes(i_near);
                cost_min = r_near_nodes(i_near).cost + distance(r_near_nodes(i_near).coord,x_new);
            end
        end
        % here i need to add the edge x_min,x_new to the list of edges
        edges = [edges [x_min.idx; i]];
        %now we know everything about the current node
        nodes(i).idx = i;
        nodes(i).coord = x_new;
        nodes(i).cost = cost_min;
        nodes(i).parent = x_min.idx;
        %add new_node to list of nodes
        %nodes = [nodes node_new];
        
        %we check if there is an alternative path to x_near (within radius
        %r from x_new) from x_new. if there is, then remove edge
        %(x_near.parent,x_near) and add edge (x_new,x_near) as this new
        %path to x_near has less cost
        for j_near = 1:1:length(r_near_nodes)
            if collisionWithAllObs(x_new,r_near_nodes(j_near).coord,allObs) == 0 && (nodes(i).cost +distance(x_new,r_near_nodes(j_near).coord) < r_near_nodes(j_near).cost)
                x_parent = r_near_nodes(j_near).parent;
                %update cost of node within radius r appropriately
                r_near_nodes(j_near).cost = nodes(i).cost +distance(x_new,r_near_nodes(j_near).coord);
                %now we want to delete edge x_parent, i_near
                [rows,cols] = size(edges);
                for col = 1:1:cols
                    if edges(1,col) == x_parent &&  edges(2,col) == r_near_nodes(j_near).idx
                        %replace edge (x_near.parent,x_near) with (x_new,x_near)
                        edges(1,col) = i;
                        edges(2,col) = r_near_nodes(j_near).idx;
                        break;
                    end
                end
            end
        end
        i = i + 1; % we only add 1 if x_rand was obstacle free
    end
    
end


%draw all edges in the tree in black
[~,cols] = size(edges);
for col = 1:1:cols
    %in row 1, edge has u, in row 2 of the same column it has v
    % (there is an edge from u to v)
    u_x = nodes(edges(1,col)).coord(1);
    u_y = nodes(edges(1,col)).coord(2);
    v_x = nodes(edges(2,col)).coord(1);
    v_y = nodes(edges(2,col)).coord(2);
    line([u_x;v_x], [u_y;v_y], 'Color', 'k', 'LineWidth', 2);
    drawnow
    hold on
end

% we look for closeset point to x_end and see if we can connect it to tree
nearest_idx = nearest(nodes, x_end.coord);
%if there was no path between start and goal, then this if will always fail
%and we won't visualize path.

if collisionWithAllObs(nodes(nearest_idx).coord,x_end.coord,allObs) == 0
    x_end.parent = nearest_idx;
    x_end.idx = length(nodes)+1;
    nodes(length(nodes)+1) = x_end;
    current_idx = x_end.idx;
    parent_idx = x_end.parent;
    %start from end point and traverse tree by parent pointer until root is
    %reached (root has parent equal 0)
    %code will reach this point only if we were able to form connection
    %between end point and tree (and the tree always contains the root so
    %we will never get stuck here
    while parent_idx ~= 0
        line([nodes(current_idx).coord(1);nodes(parent_idx).coord(1)], [nodes(current_idx).coord(2);nodes(parent_idx).coord(2)], 'Color', 'r', 'LineWidth', 2);
        current_idx = parent_idx;
        parent_idx = nodes(current_idx).parent;
    end
else
    %if we weren't able to connect tree to end point then there is no path
    %(of course this doesn't mean that there is no path 100%
    disp('NO PATH FOUND');
end


% functions

%euclidean distance between 2 points 
function d = distance(a,b)
    d = sqrt( (a(1)-b(1))^2 + (a(2)-b(2))^2 );
end

%returns nearest point from tree to x_rand
function nearest_idx = nearest(nodes, x_rand)
    distList = [];
    for i = 1:1:length(nodes)
        distList = [distList , distance(nodes(i).coord,x_rand)];
    end
    [~,idx] = min(distList);
    nearest_idx = idx;
end

%returns x_rand or a if it's too far away then returns a point maxStep
%distance away from x_near in the direction of the vector x_rand-x_near
function x_new = steer(x_rand, x_near,maxStep)
    dist = distance(x_rand,x_near);
    if dist > maxStep
        x_new = x_near + (x_rand - x_near)*maxStep/dist;
    else
        x_new = x_rand;
    end
end

%returns list of nodes that are within radius r from x_new
function r_near_nodes = r_near(nodes, x_new, r)
    r_near_nodes = [];
    for i = 1:1:length(nodes)
        if distance(nodes(i).coord,x_new) <= r
            r_near_nodes = [r_near_nodes nodes(i)];
        end
    end
end

%returns 1 if line a b collides with any of the obstacles.
%else returns 0
function colFound = collisionWithAllObs(a,b,obstacles)
    for i = 1:1:length(obstacles)
        if collisionWithObstacle(a,b,obstacles{i}) == 1 || configInsideObstacle(b,obstacles{i}) == 1
            colFound = 1;
            return;
        end
        colFound = 0;
    end
end
    
    
         
    
    
    
   