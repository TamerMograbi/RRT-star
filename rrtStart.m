clear; %without this, you will get weird  in consecutive runs results as
%previous worksapce variables will be used


x_max = 500;
y_max = 500;

maxStep = 50;
maxNodes = 300;
r = 70;

figure(1)
axis([0 x_max 0 y_max])

obs = [2+3,5+3,3+3,2+3;3+3,4+3,5+3,3+3];
obs = 50*obs; % scale obstacle for 1000 by 1000 axis

obs2 = [1,2,4,3,2,1;2,1,2,4,1.5,2];
obs2 = 60*obs2;


%draw obstacle
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

%only for xbox capture
%[d,f] = ginput(1);

[x,y] = ginput(2);

nodes(1).coord = [x(1);y(1)];
nodes(1).cost = 0;
nodes(1).parent = 0;
nodes(1).idx = 1;
plot(x(1),y(1),'r*')
plot(x(2),y(2),'r*')

x_end.coord = [x(2);y(2)];
x_end.cost = 0;

%disp('nodes(1).coord = ' + nodes(1).coord);

edges = [];

i = 2;
%for i = 2:1:maxNodes
while i < maxNodes
    x_rand = [floor(rand(1)*x_max) ; floor(rand(1)*y_max)];
    
    nearest_idx = nearest(nodes, x_rand);
    x_new = steer(x_rand, nodes(nearest_idx).coord, maxStep);
    if collisionWithAllObs(nodes(nearest_idx).coord,x_new,obs,obs2) == 0
        r_near_nodes = r_near(nodes, x_new, r);
        plot(x_new(1),x_new(2),'k*')
        
        x_min = nodes(nearest_idx);
        cost_min = nodes(nearest_idx).cost + distance(nodes(nearest_idx).coord,x_new);
        
        for i_near = 1:1:length(r_near_nodes)
            if collisionWithAllObs(r_near_nodes(i_near).coord,x_new,obs,obs2) == 0 && (r_near_nodes(i_near).cost + distance(r_near_nodes(i_near).coord,x_new)) < cost_min
                x_min = r_near_nodes(i_near);
                cost_min = r_near_nodes(i_near).cost + distance(r_near_nodes(i_near).coord,x_new);
            end
        end
        % here i need to add the edge x_min,x_new to the list of edges
        edges = [edges [x_min.idx; i]];
        %line([x_min.coord(1);nodes(i).coord(1)], [x_min.coord(2);nodes(i).coord(2)], 'Color', 'k', 'LineWidth', 2);
        nodes(i).idx = i;
        nodes(i).coord = x_new;
        nodes(i).cost = cost_min;
        nodes(i).parent = x_min.idx;
        %add new_node to list of nodes
        %nodes = [nodes node_new];
        
        for j_near = 1:1:length(r_near_nodes)
            if collisionWithAllObs(x_new,r_near_nodes(j_near).coord,obs,obs2) == 0 && (nodes(i).cost +distance(x_new,r_near_nodes(j_near).coord) < r_near_nodes(j_near).cost)
                x_parent = r_near_nodes(j_near).parent;
                %now we want to delete edge x_parent, i_near
                [rows,cols] = size(edges);
                for col = 1:1:cols
                    if edges(1,col) == x_parent &&  edges(2,col) == r_near_nodes(j_near).idx
                        %edges(:,col) = [];
                        %replace edges instead of deleting and then adding
                        edges(1,col) = i;
                        edges(2,col) = r_near_nodes(j_near).idx;
                        break;
                    end
                end
                % and add an edge from x_new to r_near
               % edges = [ edges [nodes(i).idx; r_near_nodes(j_near).idx]];
            end
        end
        i = i + 1; % we only add 1 if it was obstacle free
    end
    
end


[rows,cols] = size(edges);
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

% we look for closeset point to x_end and see if we can connect
nearest_idx = nearest(nodes, x_end.coord);
%might need to check maxStep here too.
%if there was no path between start and goal, then this if will always fail
%and we won't visualize path.
if collisionWithAllObs(nodes(nearest_idx).coord,x_end.coord,obs,obs2) == 0
    x_end.parent = nearest_idx;
    x_end.idx = length(nodes)+1;
    nodes(length(nodes)+1) = x_end;
    current_idx = x_end.idx;
    parent_idx = x_end.parent;
    while parent_idx ~= 0
        line([nodes(current_idx).coord(1);nodes(parent_idx).coord(1)], [nodes(current_idx).coord(2);nodes(parent_idx).coord(2)], 'Color', 'r', 'LineWidth', 2);
        current_idx = parent_idx;
        parent_idx = nodes(current_idx).parent;
    end
else
    disp('NO PATH FOUND');
end


% functions

function d = distance(a,b)
    d = sqrt( (a(1)-b(1))^2 + (a(2)-b(2))^2 );
end

function nearest_idx = nearest(nodes, x_rand)
    distList = [];
    for i = 1:1:length(nodes)
        distList = [distList , distance(nodes(i).coord,x_rand)];
    end
    [val,idx] = min(distList);
    nearest_idx = idx;
end

function x_new = steer(x_rand, x_near,maxStep)
    dist = distance(x_rand,x_near);
    if dist > maxStep
        x_new = x_near + (x_rand - x_near)*maxStep/dist;
    else
        x_new = x_rand;
    end
end

function r_near_nodes = r_near(nodes, x_new, r)
    r_near_nodes = [];
    for i = 1:1:length(nodes)
        if distance(nodes(i).coord,x_new) <= r
            r_near_nodes = [r_near_nodes nodes(i)];
        end
    end
end

function colFound = collisionWithAllObs(a,b,obs1,obs2)
    if collisionWithObstacle(a,b,obs1) == 1 || collisionWithObstacle(a,b,obs2) == 1
        colFound = 1;
        return;
    end
    colFound = 0;
end
    
    
         
    
    
    
   