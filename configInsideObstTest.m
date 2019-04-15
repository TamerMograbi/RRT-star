obs = [2,5,3,2;3,4,5,3];

figure(1);
axis([0 10 0 10]);

for i=1:1:3
    line([obs(1,i);obs(1,i+1)], [obs(2,i);obs(2,i+1)], 'Color', 'k', 'LineWidth', 2);
    drawnow
    hold on
end

[x,y] = ginput(1);

a = [x(1);y(1)];
if configInsideObstacle(a,obs) == 1
    disp('config is inside')
else
    disp('config is outside')
end
