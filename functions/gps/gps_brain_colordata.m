function cdata = gps_brain_colordata(data, thresh, coloring)
% Converts data into a coloring
%
% Author: Conrad Nied
%
% Changelog
% 2012.06.16 - Created as GPS1.6(-)/rois_draw_color.m
% 2012.09.04 - Added coloring by string names ie 'r' so this could be used
% with other programs
% 2012.10.10 - Adapted to GPS1.7

%% Evaluate Thresholding

c1 = data;
c2 = data;
c3 = data;

c1(c1>thresh(4)) = thresh(4);
c1 = c1 - thresh(3);
c1(c1<0) = 0;
if(thresh(4)-thresh(3) == 0)
    c1(:) = 0;
else
    c1 = c1 /(thresh(4)-thresh(3));
end

c2(c2>thresh(3)) = thresh(3);
c2 = c2 - thresh(2);
c2(c2<0) = 0;
if(thresh(3)-thresh(2) == 0)
    c2(:) = 0;
else
    c2 = c2 /(thresh(3)-thresh(2));
end

c3(c3>thresh(2)) = thresh(2);
c3 = c3 - thresh(1);
c3(c3<0) = 0;
if(thresh(2)-thresh(1) == 0)
    c3(:) = 0;
else
    c3 = c3 /(thresh(2)-thresh(1));
end

%% Find Red Green and Blue

if(~exist('coloring', 'var')); coloring = 1; end
if(isnumeric(coloring)); coloring = num2str(coloring); end

switch lower(coloring)
    case {'1', 'hot', 'h'}
        red = c3;
        green = c2;
        blue = c1;
    case {'2', 'cool'}
        red = c1;
        green = c2;
        blue = c3;
    case {'3', 'rgb'}
        red = min(c3, 1 - c2);
        green = min(c2, 1 - c1);
        blue = c1;
    case {'4', 'rbg'}
        red = min(c3, 1 - c2);
        green = c1;
        blue = min(c2, 1 - c1);
    case {'5', 'red', 'r'}
        red = c2 / 2 + c3 / 2;
        green = c1;
        blue = c1;
    case {'6', 'yellow', 'y'}
        red = c2 / 2 + c3 / 2;
        green = c2 / 2 + c3 / 2;
        blue = c1;
    case {'7', 'green', 'g'}
        red = c1;
        green = c2 / 2 + c3 / 2;
        blue = c1;
    case {'8', 'cyan', 'c'}
        red = c1;
        green = c2 / 2 + c3 / 2;
        blue = c2 / 2 + c3 / 2;
    case {'9', 'blue', 'b'}
        red = c1;
        green = c1;
        blue = c2 / 2 + c3 / 2;
    case {'10', 'magenta', 'm'}
        red = c2 / 2 + c3 / 2;
        green = c1;
        blue = c2 / 2 + c3 / 2;
    case {'11', 'bright', 'w'}
        red = c1 / 3 + c2 / 3 + c3 / 3;
        green = c1 / 3 + c2 / 3 + c3 / 3;
        blue = c1 / 3 + c2 / 3 + c3 / 3;
end

% Save
cdata = [red green blue];

end % function