function cdata = rois_draw_coloring(data, thresh, coloring)
% Converts data into a coloring
%
% Author: Conrad Nied
%
% Input: The vector of the data to be colored, value thresholds along the
% data, and an integer specifying which coloring you are doing.
% Output: the colored data
%
% Date Created: 2012.06.16
% Last Modified: 2012.09.04
%
% 2012.09.04: Added coloring by string names ie 'r' so this could be used
% with other programs

if(~exist('coloring', 'var'))
    coloring = 1;
end

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
if(isnumeric(coloring))
    coloring = num2str(coloring);
end

switch coloring
    case {'1', 'Hot', 'h'}
        red = c3;
        green = c2;
        blue = c1;
    case {'2', 'Cool'}
        red = c1;
        green = c2;
        blue = c3;
    case {'3', 'RGB'}
        red = min(c3, 1-c2);
        green = min(c2, 1-c1);
        blue = c1;
    case {'4', 'RBG'}
        red = min(c3, 1-c2);
        green = c1;
        blue = min(c2, 1-c1);
    case {'5', 'Red', 'r'}
        red = c2 / 2 + c3 / 2;
        green = c1;
        blue = c1;
    case {'6', 'Yellow', 'y'}
        red = c2 / 2 + c3 / 2;
        green = c2 / 2 + c3 / 2;
        blue = c1;
    case {'7', 'Green', 'g'}
        red = c1;
        green = c2 / 2 + c3 / 2;
        blue = c1;
    case {'8', 'Cyan', 'c'}
        red = c1;
        green = c2 / 2 + c3 / 2;
        blue = c2 / 2 + c3 / 2;
    case {'9', 'Blue', 'b'}
        red = c1;
        green = c1;
        blue = c2 / 2 + c3 / 2;
    case {'10', 'Magenta', 'm'}
        red = c2 / 2 + c3 / 2;
        green = c1;
        blue = c2 / 2 + c3 / 2;
    case {'11', 'Bright', 'w'}
        red = c1 / 3 + c2 / 3 + c3 / 3;
        green = c1 / 3 + c2 / 3 + c3 / 3;
        blue = c1 / 3 + c2 / 3 + c3 / 3;
end

% Save
cdata = [red green blue];

end % function