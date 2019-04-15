figure(1);
axis([0 10 0 10]);



obs = [2,5,3,2;3,4,5,3];

for i=1:1:3
    line([obs(1,i);obs(1,i+1)], [obs(2,i);obs(2,i+1)], 'Color', 'k', 'LineWidth', 2);
    drawnow
    hold on
end

[x,y] = ginput(2);
line(x, y, 'Color', 'k', 'LineWidth', 2);
drawnow
hold on

a = [x(1);y(1)];
b = [x(2);y(2)];
if collisionWithObstacle(a,b,obs) == 1
    disp('collision found');
else
    disp('no collision');
end

% obs = zeroes(2,4);
% a = [];
% b = [];
% for i=1:1:3
%     [x,y] = ginput(2);
%     line(x, y, 'Color', 'k', 'LineWidth', 2);
%     drawnow
%     hold on
%     a = [x(1) ; y(1)];
%     b = [x(2) ; y(2)];
%     obs(:,i) = 1
% end
% 
% obs_start = [obs(1,1); obs(1,2)];
% obs = [ obs obs_start];

